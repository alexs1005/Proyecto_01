/**
 * @description Controlador Apex para el componente LWC accountCrud.
 *              Implementa operaciones CRUD sobre el objeto Account con:
 *              - Validación de permisos CRUD/FLS (with sharing + stripInaccessible)
 *              - Paginación, búsqueda por texto y filtros
 *              - Ordenamiento dinámico con whitelist de campos
 */
public with sharing class AccountCrudController {

    // ─── Wrapper de respuesta paginada ────────────────────────────────────────
    public class AccountListWrapper {
        @AuraEnabled public List<Account> accounts;
        @AuraEnabled public Integer       totalRecords;
        @AuraEnabled public Boolean       canCreate;
        @AuraEnabled public Boolean       canUpdate;
        @AuraEnabled public Boolean       canDelete;
    }

    // ─── Whitelist de campos permitidos para ORDER BY ─────────────────────────
    private static final Set<String> ALLOWED_SORT_FIELDS = new Set<String>{
        'Name', 'Type', 'Industry', 'Phone', 'BillingCity',
        'Rating', 'AnnualRevenue', 'NumberOfEmployees', 'LastModifiedDate'
    };

    // =========================================================================
    // READ — Lista paginada con búsqueda, filtros y ordenamiento
    // =========================================================================
    @AuraEnabled
    public static AccountListWrapper getAccounts(
        String  searchTerm,
        String  typeFilter,
        String  ratingFilter,
        String  sortField,
        String  sortDirection,
        Integer pageSize,
        Integer pageNumber
    ) {
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para ver Accounts.');
        }

        Integer safeSize  = (pageSize   != null && pageSize   > 0) ? pageSize   : 10;
        Integer safePage  = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
        Integer offset    = (safePage - 1) * safeSize;

        // Patrón de búsqueda LIKE — escapado contra SOQL injection
        String searchPct = '%' + (String.isBlank(searchTerm)
            ? ''
            : String.escapeSingleQuotes(searchTerm.trim())) + '%';

        // Construcción de cláusulas WHERE
        List<String> conds = new List<String>();

        if (String.isNotBlank(searchTerm)) {
            conds.add('(Name LIKE :searchPct OR Phone LIKE :searchPct'
                    + ' OR Website LIKE :searchPct OR BillingCity LIKE :searchPct)');
        }
        if (String.isNotBlank(typeFilter) && typeFilter != 'All') {
            conds.add('Type = \'' + String.escapeSingleQuotes(typeFilter) + '\'');
        }
        if (String.isNotBlank(ratingFilter) && ratingFilter != 'All') {
            conds.add('Rating = \'' + String.escapeSingleQuotes(ratingFilter) + '\'');
        }

        String whereStr = conds.isEmpty() ? '' : ' WHERE ' + String.join(conds, ' AND ');

        // ORDER BY — campo validado contra whitelist para prevenir injection
        String safeField = (String.isNotBlank(sortField) && ALLOWED_SORT_FIELDS.contains(sortField))
            ? sortField : 'Name';
        String safeDir   = (sortDirection == 'desc') ? 'DESC' : 'ASC';

        String countQ = 'SELECT COUNT() FROM Account' + whereStr;
        String dataQ  = 'SELECT Id, Name, Type, Industry, Phone, Website,'
                      + ' BillingCity, BillingState, Rating,'
                      + ' AnnualRevenue, NumberOfEmployees, LastModifiedDate'
                      + ' FROM Account'
                      + whereStr
                      + ' ORDER BY ' + safeField + ' ' + safeDir + ' NULLS LAST'
                      + ' LIMIT :safeSize OFFSET :offset';

        AccountListWrapper wrap = new AccountListWrapper();
        wrap.totalRecords = Database.countQuery(countQ);

        // stripInaccessible aplica FLS sobre los resultados
        SObjectAccessDecision dec = Security.stripInaccessible(
            AccessType.READABLE,
            Database.query(dataQ)
        );
        wrap.accounts  = (List<Account>) dec.getRecords();
        wrap.canCreate = Schema.sObjectType.Account.isCreateable();
        wrap.canUpdate = Schema.sObjectType.Account.isUpdateable();
        wrap.canDelete = Schema.sObjectType.Account.isDeletable();

        return wrap;
    }

    // =========================================================================
    // READ — Detalle completo de un registro
    // =========================================================================
    @AuraEnabled
    public static Account getAccountDetail(Id accountId) {
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para ver este Account.');
        }

        SObjectAccessDecision dec = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Name, Type, Industry, Phone, Fax, Website,
                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                    ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                    Rating, AnnualRevenue, NumberOfEmployees, Description,
                    Owner.Name, CreatedDate, LastModifiedDate
             FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED LIMIT 1]
        );

        List<Account> recs = (List<Account>) dec.getRecords();
        if (recs.isEmpty()) {
            throw new AuraHandledException('Registro no encontrado o sin acceso.');
        }
        return recs[0];
    }

    // =========================================================================
    // CREATE
    // =========================================================================
    @AuraEnabled
    public static Id createAccount(Account account) {
        if (!Schema.sObjectType.Account.isCreateable()) {
            throw new AuraHandledException('No tienes permisos para crear Accounts.');
        }

        // stripInaccessible elimina campos que el usuario no puede crear
        SObjectAccessDecision dec = Security.stripInaccessible(
            AccessType.CREATABLE,
            new List<Account>{ account }
        );
        Account clean = (Account) dec.getRecords()[0];

        try {
            insert clean;
            return clean.Id;
        } catch (DmlException e) {
            throw new AuraHandledException(formatDmlError(e));
        }
    }

    // =========================================================================
    // UPDATE
    // =========================================================================
    @AuraEnabled
    public static void updateAccount(Account account) {
        if (!Schema.sObjectType.Account.isUpdateable()) {
            throw new AuraHandledException('No tienes permisos para editar Accounts.');
        }

        // Verificar que el registro existe y es accesible (record-level security)
        List<Account> existing = [
            SELECT Id FROM Account
            WHERE Id = :account.Id
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        if (existing.isEmpty()) {
            throw new AuraHandledException('Registro no encontrado o sin acceso para editarlo.');
        }

        // stripInaccessible elimina campos que el usuario no puede actualizar (FLS)
        SObjectAccessDecision dec = Security.stripInaccessible(
            AccessType.UPDATABLE,
            new List<Account>{ account }
        );

        try {
            update (Account) dec.getRecords()[0];
        } catch (DmlException e) {
            throw new AuraHandledException(formatDmlError(e));
        }
    }

    // =========================================================================
    // DELETE
    // =========================================================================
    @AuraEnabled
    public static void deleteAccount(Id accountId) {
        if (!Schema.sObjectType.Account.isDeletable()) {
            throw new AuraHandledException('No tienes permisos para eliminar Accounts.');
        }

        // WITH SECURITY_ENFORCED valida acceso al registro antes de borrar
        List<Account> recs = [
            SELECT Id FROM Account
            WHERE Id = :accountId
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        if (recs.isEmpty()) {
            throw new AuraHandledException('Registro no encontrado o sin acceso para eliminarlo.');
        }

        try {
            delete recs[0];
        } catch (DmlException e) {
            throw new AuraHandledException(formatDmlError(e));
        }
    }

    // ─── Utilidad: formatea errores DML con mensaje legible ──────────────────
    private static String formatDmlError(DmlException e) {
        String msg = e.getDmlMessage(0);
        return String.isNotBlank(msg) ? msg : e.getMessage();
    }
}
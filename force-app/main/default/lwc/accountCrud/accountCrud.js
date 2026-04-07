/**
 * @description LWC para CRUD completo del objeto Account.
 *
 * Funcionalidades:
 *  1. Listado con datatable: búsqueda, filtros tipo/rating, loading/empty/error,
 *     paginación, ordenamiento y edición inline de campos clave.
 *  2. Modal Crear con lightning-record-edit-form, validaciones y toast.
 *  3. Modal Detalle con lightning-record-view-form y todos los campos permitidos.
 *  4. Modal Editar (mismo formulario, mode edit), FLS/CRUD aplicado desde Apex.
 *  5. Modal Confirmación de Delete con validación de permisos y manejo de errores.
 */
import { LightningElement, track } from 'lwc';
import { ShowToastEvent }          from 'lightning/platformShowToastEvent';

import getAccountsApex   from '@salesforce/apex/AccountCrudController.getAccounts';
import updateAccountApex from '@salesforce/apex/AccountCrudController.updateAccount';
import deleteAccountApex from '@salesforce/apex/AccountCrudController.deleteAccount';

// ─── Constantes de columnas (se recalculan según permisos en getter) ──────────
const BASE_COLUMNS = [
    {
        label:          'Nombre',
        fieldName:      'accountUrl',
        type:           'url',
        sortable:       true,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_self' },
        cellAttributes: { class: { fieldName: 'nameClass' } }
    },
    { label: 'Tipo',      fieldName: 'Type',     type: 'text',  sortable: true },
    { label: 'Industria', fieldName: 'Industry', type: 'text',  sortable: true },
    { label: 'Rating',    fieldName: 'Rating',   type: 'text',  sortable: true },
    { label: 'Teléfono',  fieldName: 'Phone',    type: 'phone', sortable: true },
    { label: 'Ciudad',    fieldName: 'BillingCity', type: 'text', sortable: true },
    {
        label:          'Ingresos Anuales',
        fieldName:      'AnnualRevenue',
        type:           'currency',
        sortable:       true,
        typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 0 }
    }
];

// ─── Opciones estáticas de filtros ────────────────────────────────────────────
const TYPE_OPTIONS = [
    { label: '— Todos los tipos —',        value: 'All' },
    { label: 'Prospect',                   value: 'Prospect' },
    { label: 'Customer – Direct',          value: 'Customer - Direct' },
    { label: 'Customer – Channel',         value: 'Customer - Channel' },
    { label: 'Channel Partner / Reseller', value: 'Channel Partner / Reseller' },
    { label: 'Installation Partner',       value: 'Installation Partner' },
    { label: 'Technology Partner',         value: 'Technology Partner' },
    { label: 'Other',                      value: 'Other' }
];

const RATING_OPTIONS = [
    { label: '— Todos los ratings —', value: 'All'  },
    { label: 'Hot',                    value: 'Hot'  },
    { label: 'Warm',                   value: 'Warm' },
    { label: 'Cold',                   value: 'Cold' }
];

const PAGE_SIZE_OPTIONS = [
    { label: '5 por página',  value: '5'  },
    { label: '10 por página', value: '10' },
    { label: '25 por página', value: '25' },
    { label: '50 por página', value: '50' }
];

const DEBOUNCE_DELAY = 400; // ms — evita llamadas Apex en cada tecla

export default class AccountCrud extends LightningElement {

    // ── Opciones de UI ────────────────────────────────────────────────────────
    typeOptions     = TYPE_OPTIONS;
    ratingOptions   = RATING_OPTIONS;
    pageSizeOptions = PAGE_SIZE_OPTIONS;

    // ── Estado de filtros ─────────────────────────────────────────────────────
    searchTerm     = '';
    selectedType   = 'All';
    selectedRating = 'All';
    _searchTimer;

    // ── Estado de paginación ──────────────────────────────────────────────────
    currentPage  = 1;
    pageSize     = '10';
    totalRecords = 0;

    // ── Estado de ordenamiento ────────────────────────────────────────────────
    sortedBy        = 'Name';
    sortedDirection = 'asc';

    // ── Datos ─────────────────────────────────────────────────────────────────
    @track accounts    = [];
    @track draftValues = [];
    isLoading   = true;
    hasError    = false;
    errorMessage = '';

    // ── Permisos CRUD (retornados por Apex) ───────────────────────────────────
    canCreate = false;
    canUpdate = false;
    canDelete = false;

    // ── Estado de modales ─────────────────────────────────────────────────────
    showCreateEditModal = false;
    showDetailModal     = false;
    showDeleteModal     = false;
    isEditMode          = false;
    selectedAccountId   = null;
    selectedAccountName = '';
    isLoadingDetail     = false;
    isSaving            = false;
    isDeleting          = false;


    // =========================================================================
    // Ciclo de vida
    // =========================================================================
    connectedCallback() {
        this.loadAccounts();
    }

    // =========================================================================
    // Carga de datos
    // =========================================================================
    loadAccounts() {
        this.isLoading   = true;
        this.hasError    = false;
        this.errorMessage = '';

        getAccountsApex({
            searchTerm:    this.searchTerm || '',
            typeFilter:    this.selectedType   === 'All' ? '' : this.selectedType,
            ratingFilter:  this.selectedRating === 'All' ? '' : this.selectedRating,
            sortField:     this.sortedBy,
            sortDirection: this.sortedDirection,
            pageSize:      parseInt(this.pageSize, 10),
            pageNumber:    this.currentPage
        })
        .then(result => {
            this.totalRecords = result.totalRecords;
            this.canCreate    = result.canCreate;
            this.canUpdate    = result.canUpdate;
            this.canDelete    = result.canDelete;
            this.accounts     = (result.accounts || []).map(acc => ({
                ...acc,
                accountUrl: `/lightning/r/Account/${acc.Id}/view`
            }));
            this.draftValues  = [];
        })
        .catch(error => {
            this.hasError    = true;
            this.errorMessage = this.extractError(error);
            this.accounts    = [];
            this.totalRecords = 0;
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    // =========================================================================
    // Propiedades computadas
    // =========================================================================

    /** Columnas dinámicas — edición inline sólo si tiene permiso de update */
    get columns() {
        const editableColumns = new Set(['Type', 'Rating', 'Phone']);
        const cols = BASE_COLUMNS.map(col => ({
            ...col,
            editable: this.canUpdate && editableColumns.has(col.fieldName)
        }));

        // Acciones por fila: se muestra Edit y Delete sólo si hay permisos
        const rowActions = [
            { label: 'Ver Detalle', name: 'view',   iconName: 'utility:preview' }
        ];
        if (this.canUpdate) {
            rowActions.push({ label: 'Editar', name: 'edit', iconName: 'utility:edit' });
        }
        if (this.canDelete) {
            rowActions.push({ label: 'Eliminar', name: 'delete', iconName: 'utility:delete' });
        }

        cols.push({
            type:           'action',
            typeAttributes: { rowActions }
        });

        return cols;
    }

    get isEmpty()     { return !this.isLoading && !this.hasError && this.accounts.length === 0; }
    get showTable()   { return !this.isLoading && !this.hasError && this.accounts.length > 0;   }
    get isFirstPage() { return this.currentPage <= 1; }
    get isLastPage()  { return this.currentPage >= this.totalPages || this.totalRecords === 0; }
    get totalPages()  { return Math.max(1, Math.ceil(this.totalRecords / parseInt(this.pageSize, 10))); }
    get startRecord() { return this.totalRecords === 0 ? 0 : (this.currentPage - 1) * parseInt(this.pageSize, 10) + 1; }
    get endRecord()   { return Math.min(this.currentPage * parseInt(this.pageSize, 10), this.totalRecords); }

    get hasActiveFilters() {
        return this.searchTerm.trim() !== '' ||
               this.selectedType   !== 'All' ||
               this.selectedRating !== 'All';
    }
    get noActiveFilters() { return !this.hasActiveFilters; }

    get createEditTitle() {
        return this.isEditMode
            ? `Editar: ${this.selectedAccountName}`
            : 'Nuevo Account';
    }
    get saveButtonLabel() {
        return this.isEditMode ? 'Guardar Cambios' : 'Crear Account';
    }


    // =========================================================================
    // Handlers — Búsqueda y filtros
    // =========================================================================
    handleSearchChange(event) {
        // Debounce para no disparar Apex en cada tecla
        clearTimeout(this._searchTimer);
        const value = event.detail.value;
        this._searchTimer = setTimeout(() => {
            this.searchTerm  = value;
            this.currentPage = 1;
            this.loadAccounts();
        }, DEBOUNCE_DELAY);
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.currentPage  = 1;
        this.loadAccounts();
    }

    handleRatingChange(event) {
        this.selectedRating = event.detail.value;
        this.currentPage    = 1;
        this.loadAccounts();
    }

    handleClearFilters() {
        this.searchTerm    = '';
        this.selectedType  = 'All';
        this.selectedRating = 'All';
        this.currentPage   = 1;
        // Limpiar visualmente el campo de búsqueda
        const input = this.template.querySelector('lightning-input[type="search"]');
        if (input) input.value = '';
        this.loadAccounts();
    }

    handleRefresh() {
        this.loadAccounts();
    }


    // =========================================================================
    // Handlers — Ordenamiento
    // =========================================================================
    handleSort(event) {
        // La columna URL usa fieldName "accountUrl"; mapeamos a "Name" para Apex
        const rawField       = event.detail.fieldName;
        this.sortedBy        = rawField === 'accountUrl' ? 'Name' : rawField;
        this.sortedDirection = event.detail.sortDirection;
        this.currentPage     = 1;
        this.loadAccounts();
    }


    // =========================================================================
    // Handlers — Paginación
    // =========================================================================
    handlePrevPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
            this.loadAccounts();
        }
    }

    handleNextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
            this.loadAccounts();
        }
    }

    handlePageSizeChange(event) {
        this.pageSize    = event.detail.value;
        this.currentPage = 1;
        this.loadAccounts();
    }


    // =========================================================================
    // Handlers — Acciones de fila
    // =========================================================================
    handleRowAction(event) {
        const { name }    = event.detail.action;
        const row         = event.detail.row;
        this.selectedAccountId   = row.Id;
        this.selectedAccountName = row.Name;

        switch (name) {
            case 'view':   this._openDetailModal(); break;
            case 'edit':   this._openEditModal();   break;
            case 'delete': this._openDeleteModal(); break;
            default: break;
        }
    }


    // =========================================================================
    // Handlers — Edición inline en datatable
    // =========================================================================
    handleInlineSave(event) {
        const drafts = event.detail.draftValues;

        // Construir objetos Account sólo con los campos modificados + Id
        const promises = drafts.map(draft => {
            const account = { Id: draft.Id };
            if (draft.Type   !== undefined) account.Type   = draft.Type;
            if (draft.Rating !== undefined) account.Rating = draft.Rating;
            if (draft.Phone  !== undefined) account.Phone  = draft.Phone;
            return updateAccountApex({ account });
        });

        Promise.all(promises)
            .then(() => {
                this.showToast('success', 'Guardado', 'Cambios guardados correctamente.');
                this.draftValues = [];
                this.loadAccounts();
            })
            .catch(error => {
                this.showToast('error', 'Error al guardar inline', this.extractError(error));
            });
    }


    // =========================================================================
    // CREAR — Abrir / cerrar modal y manejar respuesta del formulario
    // =========================================================================
    handleNewAccount() {
        this.isEditMode          = false;
        this.selectedAccountId   = null;
        this.selectedAccountName = '';
        this.isSaving            = false;
        this.showCreateEditModal = true;
    }

    handleCloseCreateEdit() {
        this.showCreateEditModal = false;
        this.isSaving            = false;
    }

    /** Se dispara cuando lightning-record-edit-form termina de cargar los campos */
    handleFormLoad() {
        this.isSaving = false;
    }

    /** Éxito al guardar (crear o editar) */
    handleSaveSuccess(event) {
        const isNew  = !this.isEditMode;
        const msg    = isNew
            ? 'Account creado correctamente.'
            : 'Account actualizado correctamente.';

        this.showCreateEditModal = false;
        this.isSaving            = false;
        this.showToast('success', 'Éxito', msg);

        // Si se creó uno nuevo, ir a la primera página para verlo
        if (isNew) this.currentPage = 1;
        this.loadAccounts();
    }

    /** Error al guardar — lightning-record-edit-form puede mostrar errores
     *  inline, pero además mostramos un toast con mensaje claro. */
    handleSaveError(event) {
        this.isSaving = false;
        const msg = event.detail?.detail
            || event.detail?.message
            || 'Error al guardar. Verifica los campos requeridos.';
        this.showToast('error', 'Error al guardar', msg);
    }


    // =========================================================================
    // DETALLE — Abrir / cerrar modal
    // =========================================================================
    _openDetailModal() {
        this.isLoadingDetail = false;
        this.showDetailModal = true;
    }

    handleCloseDetail() {
        this.showDetailModal = false;
    }

    /** Botón "Editar" dentro del modal de detalle */
    handleEditFromDetail() {
        this.showDetailModal     = false;
        this._openEditModal();
    }


    // =========================================================================
    // EDITAR — Abrir modal de edición
    // =========================================================================
    _openEditModal() {
        this.isEditMode          = true;
        this.isSaving            = false;
        this.showCreateEditModal = true;
    }


    // =========================================================================
    // ELIMINAR — Modal de confirmación y ejecución
    // =========================================================================
    _openDeleteModal() {
        this.isDeleting      = false;
        this.showDeleteModal = true;
    }

    handleCloseDelete() {
        this.showDeleteModal = false;
        this.isDeleting      = false;
    }

    handleConfirmDelete() {
        if (!this.selectedAccountId) return;
        this.isDeleting = true;

        deleteAccountApex({ accountId: this.selectedAccountId })
            .then(() => {
                this.showDeleteModal = false;
                this.isDeleting      = false;
                this.showToast(
                    'success',
                    'Eliminado',
                    `"${this.selectedAccountName}" fue eliminado correctamente.`
                );

                // Si era el único registro de la página actual, retroceder página
                const remainingOnPage = this.accounts.filter(
                    a => a.Id !== this.selectedAccountId
                ).length;
                if (remainingOnPage === 0 && this.currentPage > 1) {
                    this.currentPage--;
                }

                this.loadAccounts();
            })
            .catch(error => {
                this.isDeleting = false;
                this.showToast('error', 'Error al eliminar', this.extractError(error));
            });
    }


    // =========================================================================
    // Utilidades privadas
    // =========================================================================

    /** Muestra un toast con variante, título y mensaje */
    showToast(variant, title, message) {
        this.dispatchEvent(new ShowToastEvent({ variant, title, message }));
    }

    /** Extrae un mensaje legible de diferentes estructuras de error de Apex/LWC */
    extractError(error) {
        if (typeof error === 'string')  return error;
        if (error?.body?.message)       return error.body.message;
        if (error?.body?.output?.errors?.length) {
            return error.body.output.errors.map(e => e.message).join(' | ');
        }
        if (error?.message)             return error.message;
        return 'Ha ocurrido un error inesperado. Inténtalo de nuevo.';
    }
}
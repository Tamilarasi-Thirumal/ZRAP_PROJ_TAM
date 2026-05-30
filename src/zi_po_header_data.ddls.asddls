@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for PO Header data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_PO_HEADER_DATA 
       as select from ztab_po_head
       composition [0..*] of  ZI_PO_ITEM_DATA as _PO_items 
{
    key po_num as PoNum,
    doc_cat as DocCat,
    type as Type,
    comp_code as CompCode,
    org as Org,
    status as Status,
    vendor as Vendor,
    plant as Plant,
    currency as Currency,
    @Semantics.amount.currencyCode: 'currency'
    po_tot_value as POValue,
    create_by as CreateBy,
    created_date_time as CreatedDateTime,
    changed_date_time as ChangedDateTime,
    local_last_changed_by as LocalLastChangedBy,
    _PO_items
}

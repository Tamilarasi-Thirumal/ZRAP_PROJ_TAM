@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for PO Item data'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZI_PO_ITEM_DATA 
       as select from ztab_po_item
       association to parent ZI_PO_HEADER_DATA as _po_hd on $projection.PoNum = _po_hd.PoNum 
       association [0..1] to ZC_SUPPLIER_DETAILS as _Supplierdetails on $projection.Supplier = _Supplierdetails.SupplierNum
       
{
    key po_num   as PoNum,
    key po_item  as PoItem,
    item_text    as ItemText,
    material     as Material,
    supplier     as Supplier,
    plant        as Plant,
    stor_loc     as StorLoc,
    @Semantics.quantity.unitOfMeasure: 'uom' 
    qty          as Qty,
    uom          as Uom,
    @Semantics.amount.currencyCode: 'currency'
    product_price as ProductPrice,
    currency      as Currency,
    @Semantics.amount.currencyCode: 'currency'
    total_price   as TotalPrice,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    _po_hd,
    _Supplierdetails
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for PO Item Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PO_ITEM_DATA as projection on ZI_PO_ITEM_DATA
{
    key PoNum,
    key PoItem,
    ItemText,
    Material,
    @Consumption.valueHelpDefinition: [{ 
                                          entity: { name: 'ZC_SUPPLIER_DETAILS', 
                                                    element: 'SupplierNum' }                                            
//                                          additionalBinding: [{ localElement: 'Supplier',
//                                                                 element: 'Supplier' }]                                            
                                       } ]
    Supplier,
    Plant,
    StorLoc,
    @Semantics.quantity.unitOfMeasure: 'uom'
    Qty,
    Uom,
    @Semantics.amount.currencyCode: 'Currency'
    ProductPrice,
    Currency,
    @Semantics.amount.currencyCode: 'Currency'
    TotalPrice,
    LocalLastChangedBy,
    LocalLastChangedAt,
    /* Associations */
    _Supplierdetails,
    _po_hd : redirected to parent ZC_PO_HEADER_DATA

}

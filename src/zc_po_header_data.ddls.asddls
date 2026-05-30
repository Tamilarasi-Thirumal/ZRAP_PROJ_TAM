@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for PO Header Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true 
@Search.searchable: true 
@ObjectModel.usageType:{ 
  serviceQuality: #X, 
  sizeCategory: #S, 
  dataClass: #MIXED } 
@UI:{ headerInfo: 
{ 
  typeName: 'Purchase Order', 
  typeNamePlural: 'Purchase Orders', 
  title: { 
  type: #STANDARD, 
  value: 'PoNum' } 
} 
} 
define root view entity ZC_PO_HEADER_DATA provider contract transactional_query  
as projection on ZI_PO_HEADER_DATA
{ 
    
    @Search.defaultSearchElement: true 
    key PoNum,
    DocCat,
    Type,
    CompCode,
    Org,
    Status,
    @Consumption.valueHelpDefinition: [{ 
                                          entity: { name: 'ZC_SUPPLIER_DETAILS', 
                                                    element: 'SupplierNum' }                                            
//                                          additionalBinding: [{ localElement: 'Supplier',
//                                                                 element: 'Supplier' }]                                            
                                       } ]
    
    Vendor,
    Plant,
    Currency,
    @Semantics.amount.currencyCode: 'Currency'
    POValue,
    CreateBy,
    CreatedDateTime,
    @Semantics.systemDateTime.lastChangedAt: true
    ChangedDateTime,
    LocalLastChangedBy,
    /* Associations */
    _PO_items : redirected to composition child ZC_PO_ITEM_DATA
}

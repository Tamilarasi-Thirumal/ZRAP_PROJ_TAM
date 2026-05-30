@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for supplier details'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true 
@ObjectModel.usageType:{ 
serviceQuality: #X, 
sizeCategory: #S, 
dataClass: #MIXED 
} 
define view entity ZC_SUPPLIER_DETAILS as select from ztab_supplier
{
    key supplier_num as SupplierNum,
    supplier_name as SupplierName,
    country as Country,
    contact_no as ContactNo,
    email as Email
}

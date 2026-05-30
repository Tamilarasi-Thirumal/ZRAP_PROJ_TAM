@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft table for Item Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PO_ITEM_DFT as select from zdft_po_item
   association to parent ZI_PO_HEADER_DFT as _POHeader_drft 
                          on $projection.Ponum  = _POHeader_drft.Ponum 
                          and $projection.Draftuuid = _POHeader_drft.Draftuuid
{
    key ponum                     as Ponum,
    key poitem                    as Poitem,
    key draftuuid                 as Draftuuid,
    parentdraftuuid               as Parentdraftuuid,
    itemtext                      as Itemtext,
    material                      as Material,
    supplier                      as Supplier,
    plant                         as Plant,
    storloc                       as Storloc,
    @Semantics.quantity.unitOfMeasure: 'uom'
    qty                           as Qty,
    uom                           as Uom,
    @Semantics.amount.currencyCode: 'currency'
    productprice                  as Productprice,
    currency                      as Currency,
     @Semantics.amount.currencyCode: 'currency'
    totalprice                    as Totalprice,
    locallastchangedby            as Locallastchangedby,
    locallastchangedat            as Locallastchangedat,
    draftentitycreationdatetime   as Draftentitycreationdatetime,
    draftentitylastchangedatetime as Draftentitylastchangedatetime,
    draftadministrativedatauuid   as Draftadministrativedatauuid,
    draftentityoperationcode      as Draftentityoperationcode,
    hasactiveentity               as Hasactiveentity,
    draftfieldchanges             as Draftfieldchanges,
    _POHeader_drft
}

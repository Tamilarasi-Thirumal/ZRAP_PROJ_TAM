@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft table for Header Data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PO_HEADER_DFT as select from zdft_po_head
composition [0..*] of ZI_PO_ITEM_DFT as _POItem_drft
{
    key ponum                     as Ponum,
    key draftuuid                 as Draftuuid,
    doccat                        as Doccat,
    type                          as Type,
    compcode                      as Compcode,
    org                           as Org,
    status                        as Status,
    vendor                        as Vendor,
    plant                         as Plant,
    currency                      as Currency,
    @Semantics.amount.currencyCode: 'currency'
    povalue                       as Povalue,
    createby                      as Createby,
    createddatetime               as Createddatetime,
    changeddatetime               as Changeddatetime,
    locallastchangedby            as Locallastchangedby,
    draftentitycreationdatetime   as Draftentitycreationdatetime,
    draftentitylastchangedatetime as Draftentitylastchangedatetime,
    draftadministrativedatauuid   as Draftadministrativedatauuid,
    draftentityoperationcode      as Draftentityoperationcode,
    hasactiveentity               as Hasactiveentity,
    draftfieldchanges             as Draftfieldchanges,
    _POItem_drft // Make association public
}

CLASS lhc_POHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    CLASS-DATA
     gv_success TYPE abap_boolean.

    TYPES: tt_failed_header   TYPE TABLE FOR FAILED EARLY zi_po_header_data,
           tt_reported_header TYPE TABLE FOR REPORTED EARLY zi_po_header_data,
           tt_failed_item     TYPE TABLE FOR FAILED EARLY zi_po_item_data,
           tt_reported_item   TYPE TABLE FOR REPORTED EARLY zi_po_item_data,
           ls_header_entity   TYPE TABLE FOR CREATE zi_po_header_data,
           ls_item_entity     TYPE TABLE FOR CREATE zi_po_item_data.

    METHODS map_messages_header
      IMPORTING
        iv_flag          TYPE abap_boolean
        iv_error         TYPE abap_boolean
        is_header_entity TYPE ls_header_entity
      EXPORTING
        failed_added     TYPE abap_boolean
      CHANGING
        failed           TYPE tt_failed_header
        reported         TYPE tt_reported_header.

    METHODS map_messages_item
      IMPORTING
        iv_flag        TYPE abap_boolean
        iv_error       TYPE abap_boolean
        is_item_entity TYPE ls_item_entity
      EXPORTING
        failed_added   TYPE abap_boolean
      CHANGING
        failed         TYPE tt_failed_item
        reported       TYPE tt_reported_item.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR POHeader RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR POHeader RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE POHeader.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE POHeader.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE POHeader.

    METHODS read FOR READ
      IMPORTING keys FOR READ POHeader RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK POHeader.

    METHODS rba_Po_items FOR READ
      IMPORTING keys_rba FOR READ POHeader\_Po_items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Po_items FOR MODIFY
      IMPORTING entities_cba FOR CREATE POHeader\_Po_items.

ENDCLASS.

CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.

    TYPES: ty_po_hd type STRUCTURE FOR CREATE zi_po_header_data\\poheader.
    TYPES: ty_po_itm type STRUCTURE FOR CREATE zi_po_header_data\\poitem.

    TYPES: BEGIN OF ty_header_buffer,
             flag           TYPE c LENGTH 1,        " 'C' = Create, 'U' = Update, 'D' = Delete
             lv_header_data TYPE ty_po_hd,          " The structure that holds PO Header data
           END OF ty_header_buffer.

    TYPES: BEGIN OF ty_item_buffer,
             flag         TYPE c LENGTH 1,
             lv_item_data TYPE ty_po_itm,
           END OF ty_item_buffer.

    CLASS-DATA mt_header_buffer TYPE STANDARD TABLE OF ty_header_buffer WITH EMPTY KEY.  " Table to store buffer entries
    CLASS-DATA mt_item_buffer TYPE STANDARD TABLE OF ty_item_buffer WITH EMPTY KEY.

    " Method to get an instance of the buffer class (Singleton pattern)
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer.

    " Method to add records to the buffer (Create, Update, or Delete)
    METHODS add_to_header_buffer
      IMPORTING
        iv_flag      TYPE c
        is_po_header TYPE ty_po_hd.

    METHODS add_to_item_buffer
      IMPORTING
        iv_flag    TYPE c
        is_po_item TYPE ty_po_itm.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_buffer.  " Holds the single instance of the class
ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.

  METHOD get_instance.

    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.

    ro_instance = go_instance.

  ENDMETHOD.

  METHOD add_to_header_buffer.

    APPEND VALUE #( flag = iv_flag
                    lv_header_data = is_po_header ) TO mt_header_buffer.

  ENDMETHOD.

  METHOD add_to_item_buffer.

    APPEND VALUE #( flag = iv_flag
                    lv_item_data = is_po_item ) TO mt_item_buffer.

  ENDMETHOD.

ENDCLASS.


CLASS lhc_POHeader IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    TYPES: ty_po_hd type STRUCTURE FOR CREATE zi_po_header_data\\poheader.

    DATA : ls_po_hd        TYPE ty_po_hd.

    DATA:  lv_failed_added TYPE abap_boolean,
           lv_error        TYPE abap_boolean.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_po_hd>).
      ls_po_hd = CORRESPONDING #( <lfs_po_hd> ).
      IF ls_po_hd IS NOT INITIAL.
        TRY.
            DATA(lv_pid) = cl_system_uuid=>create_uuid_x16_static( ).
            ls_po_hd-%cid = <lfs_po_hd>-%cid.
            lo_buffer->add_to_header_buffer( iv_flag = 'C' is_po_header = ls_po_hd ).

            APPEND VALUE #( %cid = <lfs_po_hd>-%cid
                          ) TO mapped-poheader.

          CATCH cx_uuid_error INTO DATA(lx_uuid).
        ENDTRY.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    TYPES: ty_po_hd type STRUCTURE FOR CREATE zi_po_header_data\\poheader.

    DATA : ls_po_hd        TYPE ty_po_hd.

    DATA : ls_po           TYPE zi_po_head,
           lv_failed_added TYPE abap_boolean,
           lv_error        TYPE abap_boolean.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_po_hd_update>).
      IF sy-subrc EQ 0.
        SELECT SINGLE * FROM ztab_po_head
                        WHERE po_num EQ @<lfs_po_hd_update>-PoNum
                        INTO @DATA(ls_po_hd_db).

        ls_po_hd = CORRESPONDING #( <lfs_po_hd_update> ).

        IF <lfs_po_hd_update>-PoNum IS NOT INITIAL.
          ls_po_hd-PoNum = <lfs_po_hd_update>-PoNum.
        ELSE.
          ls_po_hd-PoNum = ls_po_hd_db-po_num.
        ENDIF.

        IF <lfs_po_hd_update>-DocCat IS NOT INITIAL.
         ls_po_hd-DocCat = <lfs_po_hd_update>-DocCat.
        ELSE.
          ls_po_hd-DocCat = ls_po_hd_db-doc_cat.
        ENDIF.

        IF <lfs_po_hd_update>-Type IS NOT INITIAL.
          ls_po_hd-type = <lfs_po_hd_update>-Type.
        ELSE.
          ls_po_hd-type = ls_po_hd_db-type.
        ENDIF.

        IF <lfs_po_hd_update>-CompCode IS NOT INITIAL.
          ls_po_hd-CompCode = <lfs_po_hd_update>-CompCode.
        ELSE.
           ls_po_hd-CompCode = ls_po_hd_db-comp_code .
        ENDIF.

        IF <lfs_po_hd_update>-Org IS NOT INITIAL.
           ls_po_hd-org = <lfs_po_hd_update>-Org.
        ELSE.
          ls_po_hd-org = ls_po_hd_db-org.
        ENDIF.

        IF <lfs_po_hd_update>-Status IS NOT INITIAL.
          ls_po_hd-status = <lfs_po_hd_update>-Status.
        ELSE.
          ls_po_hd-status = ls_po_hd_db-status.
        ENDIF.

        IF <lfs_po_hd_update>-Vendor IS NOT INITIAL.
           ls_po_hd-vendor = <lfs_po_hd_update>-Vendor.
        ELSE.
          ls_po_hd-vendor = ls_po_hd_db-vendor.
        ENDIF.

        IF <lfs_po_hd_update>-Plant IS NOT INITIAL.
          ls_po_hd-plant = <lfs_po_hd_update>-Plant.
         ELSE.
          ls_po_hd-plant =  ls_po_hd_db-plant.
        ENDIF.

        IF <lfs_po_hd_update>-POValue IS NOT INITIAL.
          ls_po_hd-POValue = <lfs_po_hd_update>-POValue.
        ELSE.
          ls_po_hd-POValue = ls_po_hd_db-po_tot_value.
        ENDIF.

        " Add to buffer as update
        IF ls_po_hd IS NOT INITIAL.
          lo_buffer->add_to_header_buffer( iv_flag = 'U' is_po_header = ls_po_hd ).
        ENDIF.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD delete.

    TYPES: ty_po_hd type STRUCTURE FOR CREATE zi_po_header_data\\poheader.

    DATA : ls_po_hd        TYPE ty_po_hd.

    DATA: lv_failed_added TYPE abap_boolean,
          lv_error        TYPE abap_boolean.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<lfs_keys>) INDEX 1.
    IF sy-subrc EQ 0.

      ls_po_hd-PoNum = <lfs_keys>-PoNum.

      lo_buffer->add_to_header_buffer( iv_flag = 'D' is_po_header = ls_po_hd ).

    ENDIF.

  ENDMETHOD.

  METHOD read.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM ztab_po_head
      FOR ALL ENTRIES IN @keys
      WHERE po_num = @keys-PoNum
      INTO TABLE @DATA(lt_po_header_data).
    IF sy-subrc IS INITIAL.
      result = VALUE #( FOR ls_po_header_data IN lt_po_header_data
                        ( %tky   = VALUE #( PoNum = ls_po_header_data-po_num )
                          DocCat               = ls_po_header_data-doc_cat
                          Type                 = ls_po_header_data-type
                          CompCode             = ls_po_header_data-comp_code
                          Org                  = ls_po_header_data-org
                          Status               = ls_po_header_data-status
                          Vendor               = ls_po_header_data-vendor
                          Plant                = ls_po_header_data-plant
                          Currency             = ls_po_header_data-currency
                          POValue              = ls_po_header_data-po_tot_value
                          CreateBy             = ls_po_header_data-create_by
                          CreatedDateTime      = ls_po_header_data-created_date_time
                          ChangedDateTime      = ls_po_header_data-changed_date_time
                          LocalLastChangedBy   = ls_po_header_data-local_last_changed_by
                        )
                       ).
    ENDIF.

  ENDMETHOD.

  METHOD lock.



  ENDMETHOD.

  METHOD rba_Po_items.
  ENDMETHOD.

  METHOD cba_Po_items.

    TYPES: ty_po_items type STRUCTURE FOR CREATE zi_po_header_data\\poitem.

    DATA : ls_po_items        TYPE ty_po_items.

    DATA : lv_failed_added TYPE abap_boolean,
           lv_error        TYPE abap_boolean.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_po_items_cba>).

      DATA(lv_po) = <lfs_po_items_cba>-PoNum.

      LOOP AT <lfs_po_items_cba>-%target ASSIGNING FIELD-SYMBOL(<lfs_items_target>).
        ls_po_items = CORRESPONDING #( <lfs_items_target> ).
        IF ls_po_items IS NOT INITIAL.
          TRY.
              ls_po_items-%cid = <lfs_po_items_cba>-%cid_ref.
              lo_buffer->add_to_item_buffer( iv_flag = 'C' is_po_item = ls_po_items ).

              APPEND VALUE #( %cid   = <lfs_po_items_cba>-%cid_ref
                            ) TO mapped-poitem.

            CATCH cx_uuid_error INTO DATA(lx_uuid).
          ENDTRY.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD map_messages_header.

    IF iv_error IS NOT INITIAL.

      READ TABLE is_header_entity ASSIGNING FIELD-SYMBOL(<fs_po_header_entity>) INDEX 1.
      IF sy-subrc EQ 0.

        IF iv_flag EQ 'C'.

          APPEND VALUE #( %cid = <fs_po_header_entity>-%cid
                          PoNum = <fs_po_header_entity>-PoNum )
              TO failed.

          APPEND VALUE #( %msg = new_message( id = '00'
                                            number = '001'
                                            v1 = 'Creation Failed'
                                            severity = if_abap_behv_message=>severity-error )
                        %key-PoNum = <fs_po_header_entity>-PoNum
                        %cid = <fs_po_header_entity>-%cid )
                        TO reported.
        ENDIF.

        IF iv_flag EQ 'U'.

        ENDIF.

        IF iv_flag EQ 'D'.

        ENDIF.

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD map_messages_item.

    IF iv_error IS NOT INITIAL.

      LOOP AT is_item_entity ASSIGNING FIELD-SYMBOL(<fs_po_item_entity>).

        IF iv_flag = 'C'.

          APPEND VALUE #( %cid = <fs_po_item_entity>-%cid
                       PoNum = <fs_po_item_entity>-PoNum
                       PoItem = <fs_po_item_entity>-PoItem )
              TO failed.

          APPEND VALUE #( %msg = new_message( id = '00'
                                            number = '001'
                                            v1 = 'Invalid Details'
                                            severity = if_abap_behv_message=>severity-error )
                        %key-PoNum = <fs_po_item_entity>-PoNum
                        %key-POItem = <fs_po_item_entity>-PoItem
                        %cid = <fs_po_item_entity>-%cid )
                        TO reported.
        ENDIF.

        IF iv_flag = 'U'.

        ENDIF.

        IF iv_flag = 'D'.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_POHeader DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_POHeader IMPLEMENTATION.

  METHOD adjust_numbers.

   DATA: lv_max_item_id TYPE i.

   DATA(lo_buffer) = lcl_buffer=>get_instance( ).

   SELECT SINGLE
      MAX( po_num )
      FROM ztab_po_head
      INTO @DATA(lv_max_header_id).
   IF sy-subrc <> 0.

   ENDIF.

   LOOP AT lo_buffer->mt_header_buffer ASSIGNING FIELD-SYMBOL(<ls_header_buffer>).
    IF <ls_header_buffer>-lv_header_data-PoNum IS INITIAL.
        lv_max_header_id += 1.
        <ls_header_buffer>-lv_header_data-PoNum = lv_max_header_id.
        <ls_header_buffer>-lv_header_data-%key-PoNum = lv_max_header_id.

        APPEND VALUE #( ponum = lv_max_header_id
                   ) TO mapped-poheader.

     ENDIF.
    ENDLOOP.

    LOOP AT lo_buffer->mt_item_buffer ASSIGNING FIELD-SYMBOL(<ls_item_buffer>).

     IF <ls_item_buffer>-lv_item_data-PoNum IS INITIAL.
        lv_max_item_id += 1.
        <ls_item_buffer>-lv_item_data-PoItem = lv_max_item_id.
        <ls_item_buffer>-lv_item_data-PoNum = lv_max_header_id.

        APPEND VALUE #(  poitem = <ls_item_buffer>-lv_item_data-PoItem
                      ponum = <ls_item_buffer>-lv_item_data-PoNum ) to mapped-poitem.
     ELSEIF <ls_item_buffer>-lv_item_data-PoNum IS NOT INITIAL.

     ENDIF.

    ENDLOOP.

    CLEAR: lv_max_header_id, lv_max_item_id.

  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    DATA: ls_header_data_db TYPE ztab_po_head,
          ls_item_data_db   TYPE ztab_po_item.


    LOOP AT lo_buffer->mt_header_buffer ASSIGNING FIELD-SYMBOL(<ls_buf>).

      ls_header_data_db = CORRESPONDING ztab_po_head( <ls_buf>-lv_header_data MAPPING FROM ENTITY USING CONTROL ).

      ls_header_data_db-po_num             = <ls_buf>-lv_header_data-PoNum.
      ls_header_data_db-doc_cat            = <ls_buf>-lv_header_data-DocCat.
      ls_header_data_db-type               = <ls_buf>-lv_header_data-Type.
      ls_header_data_db-comp_code          = <ls_buf>-lv_header_data-CompCode.
      ls_header_data_db-org                = <ls_buf>-lv_header_data-Org.
      ls_header_data_db-status             = <ls_buf>-lv_header_data-Status.
      ls_header_data_db-vendor             = <ls_buf>-lv_header_data-Vendor.
      ls_header_data_db-plant              = <ls_buf>-lv_header_data-Plant.
      ls_header_data_db-currency           = <ls_buf>-lv_header_data-Currency.
      ls_header_data_db-po_tot_value       = <ls_buf>-lv_header_data-POValue.
      ls_header_data_db-create_by          = <ls_buf>-lv_header_data-CreateBy.
      ls_header_data_db-created_date_time  = <ls_buf>-lv_header_data-CreatedDateTime.
      ls_header_data_db-changed_date_time  = <ls_buf>-lv_header_data-ChangedDateTime.
      ls_header_data_db-local_last_changed_by = <ls_buf>-lv_header_data-LocalLastChangedBy.

      CASE <ls_buf>-flag.

        WHEN 'C'.
          INSERT ztab_po_head FROM @ls_header_data_db.
          IF sy-subrc <> 0.
*            lhc_POHeader->map_messages_header(
*            EXPORTING
*                iv_flag             = 'C'
*                iv_error            = 'X'
*                is_header_entity    = create-entities
*            IMPORTING
*                failed_added        = lv_failed_added
*            CHANGING
*                failed              = failed-POHeader
*                reported            = reported-POHeader ).
          ENDIF.
        WHEN 'U'.
          UPDATE ztab_po_head FROM @ls_header_data_db.
        WHEN 'D'.
          DELETE FROM ztab_po_head WHERE po_num = @ls_header_data_db-po_num.
      ENDCASE.

    ENDLOOP.

    LOOP AT lo_buffer->mt_item_buffer ASSIGNING FIELD-SYMBOL(<fs_itm_buf>).

      ls_item_data_db = CORRESPONDING #( <fs_itm_buf>-lv_item_data ).

      ls_item_data_db-po_num              = <fs_itm_buf>-lv_item_data-PoNum.
      ls_item_data_db-po_item             = <fs_itm_buf>-lv_item_data-PoItem.
      ls_item_data_db-item_text           = <fs_itm_buf>-lv_item_data-ItemText.
      ls_item_data_db-material            = <fs_itm_buf>-lv_item_data-Material.
      ls_item_data_db-supplier            = <fs_itm_buf>-lv_item_data-Supplier.
      ls_item_data_db-plant               = <fs_itm_buf>-lv_item_data-Plant.
      ls_item_data_db-stor_loc            = <fs_itm_buf>-lv_item_data-StorLoc.
      ls_item_data_db-qty                 = <fs_itm_buf>-lv_item_data-Qty.
      ls_item_data_db-uom                 = <fs_itm_buf>-lv_item_data-Uom.
      ls_item_data_db-product_price       = <fs_itm_buf>-lv_item_data-ProductPrice.
      ls_item_data_db-currency            = <fs_itm_buf>-lv_item_data-Currency.
      ls_item_data_db-total_price         = <fs_itm_buf>-lv_item_data-TotalPrice.
      ls_item_data_db-local_last_changed_by = <fs_itm_buf>-lv_item_data-LocalLastChangedBy.
      ls_item_data_db-local_last_changed_at = <fs_itm_buf>-lv_item_data-LocalLastChangedAt.


      CASE <fs_itm_buf>-flag.
        WHEN 'C'.
          INSERT ztab_po_item FROM @ls_item_data_db.
        WHEN 'U'.
          UPDATE ztab_po_item FROM @ls_item_data_db.
        WHEN 'D'.
          DELETE FROM ztab_po_item WHERE po_num = @ls_item_data_db-po_num
                                   AND po_item = @ls_item_data_db-po_item.
      ENDCASE.
    ENDLOOP.


    CLEAR: lo_buffer->mt_header_buffer, lo_buffer->mt_item_buffer .  " Clear the buffer after saving changes

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_POItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE POItem.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE POItem.

    METHODS read FOR READ
      IMPORTING keys FOR READ POItem RESULT result.

    METHODS rba_Po_hd FOR READ
      IMPORTING keys_rba FOR READ POItem\_Po_hd FULL result_requested RESULT result LINK association_links.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE POItem.

    METHODS Item_Total_Price FOR DETERMINE ON MODIFY
      IMPORTING keys FOR POItem~Item_Total_Price.

    METHODS Header_Total_Value FOR DETERMINE ON MODIFY
      IMPORTING keys FOR POItem~Header_Total_Value.


ENDCLASS.

CLASS lhc_POItem IMPLEMENTATION.

  METHOD update.

    TYPES: ty_po_items type STRUCTURE FOR CREATE zi_po_header_data\\poitem.

    DATA : ls_po_items        TYPE ty_po_items.

    DATA : lt_po_items_db     TYPE TABLE OF ztab_po_item.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).


    SELECT * FROM ztab_po_item
      FOR ALL ENTRIES IN @entities
      WHERE po_num = @entities-PoNum
      INTO TABLE @lt_po_items_db.
    IF sy-subrc EQ 0.

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_po_it>).
        READ TABLE lt_po_items_db ASSIGNING FIELD-SYMBOL(<lfs_po_item_db>)
                               WITH KEY po_num = <lfs_po_it>-PoNum
                                        po_item = <lfs_po_it>-PoItem BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_po_items-PoNum = <lfs_po_it>-PoNum.
          ls_po_items-PoItem = <lfs_po_it>-PoItem.

          IF <lfs_po_it>-ItemText IS NOT INITIAL.
            ls_po_items-ItemText = <lfs_po_it>-ItemText.
          ELSE.
            ls_po_items-ItemText = <lfs_po_item_db>-item_text.
          ENDIF.

          IF <lfs_po_it>-Material IS NOT INITIAL.
             ls_po_items-Material = <lfs_po_it>-Material.
          ELSE.
             ls_po_items-Material = <lfs_po_item_db>-material.
          ENDIF.

          IF <lfs_po_it>-Supplier IS NOT INITIAL.
            ls_po_items-supplier = <lfs_po_it>-supplier.
          ELSE.
            ls_po_items-supplier = <lfs_po_item_db>-supplier.
          ENDIF.

          IF <lfs_po_it>-Plant IS NOT INITIAL.
            ls_po_items-Plant = <lfs_po_it>-Plant.
          ELSE.
            ls_po_items-Plant = <lfs_po_item_db>-plant.
          ENDIF.

          IF <lfs_po_it>-StorLoc IS NOT INITIAL.
            ls_po_items-StorLoc = <lfs_po_it>-StorLoc.
          ELSE.
            ls_po_items-StorLoc = <lfs_po_item_db>-stor_loc.
          ENDIF.

          IF <lfs_po_it>-Qty IS NOT INITIAL.
            ls_po_items-Qty = <lfs_po_it>-Qty.
          ELSE.
            ls_po_items-Qty = <lfs_po_item_db>-qty.
          ENDIF.

          IF <lfs_po_it>-Uom IS NOT INITIAL.
            ls_po_items-uom = <lfs_po_it>-Uom.
          ELSE.
            ls_po_items-uom = <lfs_po_item_db>-uom.
          ENDIF.

          IF <lfs_po_it>-ProductPrice IS NOT INITIAL.
            ls_po_items-ProductPrice = <lfs_po_it>-ProductPrice.
          ELSE.
            ls_po_items-ProductPrice = <lfs_po_item_db>-product_price.
          ENDIF.

          IF <lfs_po_it>-currency IS NOT INITIAL.
            ls_po_items-Currency = <lfs_po_it>-currency.
          ELSE.
            ls_po_items-Currency = <lfs_po_item_db>-currency.
          ENDIF.

          IF <lfs_po_it>-TotalPrice IS NOT INITIAL.
            ls_po_items-TotalPrice = <lfs_po_it>-TotalPrice.
          ELSE.
            ls_po_items-TotalPrice = <lfs_po_item_db>-total_price.
          ENDIF.

          IF ls_po_items IS NOT INITIAL.
            lo_buffer->add_to_item_buffer( iv_flag = 'U' is_po_item = ls_po_items ).
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD delete.

    TYPES: ty_po_items type STRUCTURE FOR CREATE zi_po_header_data\\poitem.

    DATA : ls_po_items        TYPE ty_po_items.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<lfs_keys>) INDEX 1.
    IF sy-subrc EQ 0.

      ls_po_items-PoNum  = <lfs_keys>-PoNum.
      ls_po_items-PoItem = <lfs_keys>-PoItem.

      IF ls_po_items IS NOT INITIAL.
        lo_buffer->add_to_item_buffer( iv_flag = 'D' is_po_item = ls_po_items ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD read.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM ztab_po_item
      FOR ALL ENTRIES IN @keys
      WHERE po_num = @keys-PoNum AND po_item = @keys-PoItem
      INTO TABLE @DATA(lt_po_item_data).
    IF sy-subrc IS INITIAL.
      result = VALUE #( FOR ls_po_item_data IN lt_po_item_data
                        ( %tky   = VALUE #( PoNum = ls_po_item_data-po_num
                                            PoItem = ls_po_item_data-po_item )
*                            PoNum                = ls_po_item_data-po_num
*                            PoItem               = ls_po_item_data-po_item
                          ItemText             = ls_po_item_data-item_text
                          Material             = ls_po_item_data-material
                          Supplier             = ls_po_item_data-supplier
                          Plant                = ls_po_item_data-plant
                          StorLoc              = ls_po_item_data-stor_loc
                          Qty                  = ls_po_item_data-qty
                          Uom                  = ls_po_item_data-uom
                          ProductPrice         = ls_po_item_data-product_price
                          Currency             = ls_po_item_data-currency
                          TotalPrice           = ls_po_item_data-total_price
                          LocalLastChangedBy   = ls_po_item_data-local_last_changed_by
                          LocalLastChangedAt   = ls_po_item_data-local_last_changed_at
                        )
                       ).
    ENDIF.

  ENDMETHOD.

  METHOD rba_Po_hd.
  ENDMETHOD.

  METHOD create.

    TYPES: ty_po_items type STRUCTURE FOR CREATE zi_po_header_data\\poitem.

    DATA : ls_po_items        TYPE ty_po_items.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_item_create>) INDEX 1.
    IF sy-subrc EQ 0.
      ls_po_items = CORRESPONDING #( <lfs_po_item_create> ).
    ENDIF.

    " Add to buffer as create
    IF ls_po_items IS NOT INITIAL.
      lo_buffer->add_to_item_buffer( iv_flag = 'C' is_po_item = ls_po_items ).

      APPEND VALUE #( %cid = <lfs_po_item_create>-%cid
                    ) TO mapped-poitem.
    ENDIF.

    CLEAR: ls_po_items.

  ENDMETHOD.

  METHOD Item_Total_Price.

    READ ENTITIES OF zi_po_header_data IN LOCAL MODE
        ENTITY POHeader BY \_PO_items
        ALL FIELDS WITH
        CORRESPONDING #( keys )
        RESULT DATA(lt_result).

    DATA(ls_result) = VALUE #( lt_result[ 1 ] OPTIONAL ).

    IF ls_result-Qty IS NOT INITIAL.
      ls_result-TotalPrice = ls_result-Qty * ls_result-ProductPrice.

      MODIFY ENTITY IN LOCAL MODE zi_po_item_data
      UPDATE FIELDS ( TotalPrice )
      WITH VALUE #( ( %tky = ls_result-%tky
                      TotalPrice = ls_result-TotalPrice
                      %control-TotalPrice = if_abap_behv=>mk-on ) ).
    ENDIF.

  ENDMETHOD.

  METHOD Header_Total_Value.

    DATA(lv_total_po_val) = 0.

    READ ENTITIES OF zi_po_header_data IN LOCAL MODE
       ENTITY POHeader
        FIELDS ( PoNum )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header_data).

    DATA(lt_parent_keys) = lt_header_data.

    LOOP AT lt_parent_keys INTO DATA(ls_parent).

      READ ENTITIES OF zi_po_header_data IN LOCAL MODE
          ENTITY POHeader BY \_PO_items
          FIELDS ( Qty ProductPrice )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_itm_price).

      IF lt_itm_price[] IS NOT INITIAL.
        LOOP AT lt_itm_price INTO DATA(ls_itm_price).
          lv_total_po_val += ( ls_itm_price-Qty * ls_itm_price-ProductPrice ).
        ENDLOOP.

        IF lv_total_po_val IS NOT INITIAL.

          MODIFY ENTITY IN LOCAL MODE zi_po_header_data
          UPDATE FIELDS ( POValue )
              WITH VALUE #( ( %tky = ls_parent-%tky
                              POValue = lv_total_po_val
                              %control-POValue = if_abap_behv=>mk-on ) ).
        ENDIF.
      ENDIF.

      CLEAR: lv_total_po_val.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

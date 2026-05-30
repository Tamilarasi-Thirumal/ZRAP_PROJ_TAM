CLASS zcl_insert_table_entries DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INSERT_TABLE_ENTRIES IMPLEMENTATION.


    METHOD if_oo_adt_classrun~main.

    DATA: lt_po    TYPE STANDARD TABLE OF ztab_po_head,
          lt_items TYPE STANDARD TABLE OF ztab_po_item,
          lt_supplier TYPE STANDARD TABLE OF ztab_supplier.

*     lt_supplier = VALUE #(
*      ( supplier_num = '000100001'
*        supplier_name = 'Lucas'
*        country       = 'DE'
*        contact_no    = '4157083617'
*        email         = 'Lucas@gmail.com'
*      )
*
*      ( supplier_num = '000100002'
*        supplier_name = 'Jonas'
*        country       = 'US'
*        contact_no    = '1157043612'
*        email         = 'Jonas@gmail.com'
*      )
*
*      ( supplier_num = '000100003'
*        supplier_name = 'Sophie'
*        country       = 'DE'
*        contact_no    = '4167842931'
*        email         = 'Sophie@gmail.com'
*      )
*
*      ( supplier_num = '000100004'
*        supplier_name = 'Maximilian'
*        country       = 'FR'
*        contact_no    = '3612345678'
*        email         = 'Maximilian@gmail.com'
*      )
*
*      ( supplier_num = '000100005'
*        supplier_name = 'Felix Leon'
*        country       = 'DE'
*        contact_no    = '6745738922'
*        email         = 'Felix.leon@gmail.com'
*      )
*
*      ).
*
*      MODIFY ztab_supplier FROM TABLE @lt_supplier.

*    lt_po = VALUE #(
*
*      ( client = '100'
*        po_num = '1500000001'
*        doc_cat = 'F'
*        type = 'NB'
*        comp_code = '1000'
*        org = '1000'
*        status = 'A'
*        vendor = '0000100001'
*        plant = '1000'
*        create_by = sy-uname
*        created_date_time = '20260314090000'
*        changed_date_time = '20260314090000'
*        local_last_changed_by = sy-uname )
*
*      ( client = '100'
*        po_num = '1500000002'
*        doc_cat = 'F'
*        type = 'NB'
*        comp_code = '1100'
*        org = '1100'
*        status = 'A'
*        vendor = '0000100002'
*        plant = '1100'
*        create_by = sy-uname
*        created_date_time = '20260314090500'
*        changed_date_time = '20260314090500'
*        local_last_changed_by = sy-uname )
*
*      ( client = '100'
*        po_num = '1500000003'
*        doc_cat = 'F'
*        type = 'NB'
*        comp_code = '1200'
*        org = '1200'
*        status = 'O'
*        vendor = '0000100003'
*        plant = '1200'
*        create_by = sy-uname
*        created_date_time = '20260314091000'
*        changed_date_time = '20260314091000'
*        local_last_changed_by = sy-uname )
*
*      ( client = '100'
*        po_num = '1500000004'
*        doc_cat = 'F'
*        type = 'UB'
*        comp_code = '1300'
*        org = '1300'
*        status = 'A'
*        vendor = '0000100004'
*        plant = '1300'
*        create_by = sy-uname
*        created_date_time = '20260314091500'
*        changed_date_time = '20260314091500'
*        local_last_changed_by = sy-uname )
*
*      ( client = '100'
*        po_num = '1500000005'
*        doc_cat = 'F'
*        type = 'NB'
*        comp_code = '1400'
*        org = '1400'
*        status = 'C'
*        vendor = '0000100005'
*        plant = '1400'
*        create_by = sy-uname
*        created_date_time = '20260314092000'
*        changed_date_time = '20260314092000'
*        local_last_changed_by = sy-uname )
*
*      ( client = '100'
*        po_num = '1500000006'
*        doc_cat = 'F'
*        type = 'NB'
*        comp_code = '1500'
*        org = '1500'
*        status = 'O'
*        vendor = '0000100006'
*        plant = '1500'
*        create_by = sy-uname
*        created_date_time = '20260314092500'
*        changed_date_time = '20260314092500'
*        local_last_changed_by = sy-uname )
*
*    ).
*
*    INSERT ztab_po_head FROM TABLE @lt_po.
*
*
    lt_items = VALUE #(

    ( client = '100'
      po_num = '1500000001'
      po_item = '00010'
      item_text = 'Laptop'
      material = 'MAT1001'
      supplier = '000100001'
      plant = '1000'
      stor_loc = '0001'
      qty = '10'
      uom = 'EA'
      product_price = '50000'
      currency = 'INR'
      local_last_changed_by = sy-uname
      local_last_changed_at = '090000' )

    ( client = '100'
      po_num = '1500000001'
      po_item = '00020'
      item_text = 'Mouse'
      material = 'MAT1002'
      supplier = '000100002'
      plant = '1000'
      stor_loc = '0001'
      qty = '50'
      uom = 'EA'
      product_price = '500'
      currency = 'INR'
      local_last_changed_by = sy-uname
      local_last_changed_at = '090500' )

    ( client = '100'
      po_num = '1500000002'
      po_item = '00010'
      item_text = 'Monitor'
      material = 'MAT2001'
      supplier = '000100002'
      plant = '1100'
      stor_loc = '0002'
      qty = '20'
      uom = 'EA'
      product_price = '15000'
      currency = 'INR'
      local_last_changed_by = sy-uname
      local_last_changed_at = '091000' )

    ( client = '100'
      po_num = '1500000003'
      po_item = '00010'
      item_text = 'Keyboard'
      material = 'MAT3001'
      supplier = '000100003'
      plant = '1200'
      stor_loc = '0003'
      qty = '40'
      uom = 'EA'
      product_price = '1200'
      currency = 'INR'
      local_last_changed_by = sy-uname
      local_last_changed_at = '091500' )

    ( client = '100'
      po_num = '1500000004'
      po_item = '00010'
      item_text = 'Printer'
      material = 'MAT4001'
      supplier = '000100004'
      plant = '1300'
      stor_loc = '0004'
      qty = '5'
      uom = 'EA'
      product_price = '25000'
      currency = 'INR'
      local_last_changed_by = sy-uname
      local_last_changed_at = '092000' )

    ( client = '100'
      po_num = '1500000005'
      po_item = '00010'
      item_text = 'Scanner'
      material = 'MAT5001'
      supplier = '000100005'
      plant = '1400'
      stor_loc = '0005'
      qty = '8'
      uom = 'EA'
      product_price = '18000'
      currency = 'INR'
      local_last_changed_by = sy-uname
      local_last_changed_at = '092500' )

    ).

    MODIFY ztab_po_item FROM TABLE @lt_items.


  ENDMETHOD.
ENDCLASS.

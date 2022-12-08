class ZCL_TAGNO definition
  public
  final
  create public .

public section.
TYPES: BEGIN OF ty_display,
         vbeln      TYPE vbeln,
         posnr      TYPE posnr,
         quantity   TYPE kwmeng,
         tag_count  TYPE i,
         tag_number TYPE char30,
       END OF ty_display.
TYPES: BEGIN OF ty_conf_vbap,
         conf TYPE REF TO zcl_pdm_obj_conf_vbap,
       END OF ty_conf_vbap.
   CLASS-METHODS: create_display_line_from_data
    IMPORTING vbeln TYPE vbeln posnr TYPE posnr quantity TYPE kwmeng tag_count TYPE i char_value TYPE REF TO zcl_pdm_char_value
      RETURNING VALUE(display_line) TYPE ty_display.
protected section.
private section.
ENDCLASS.



CLASS ZCL_TAGNO IMPLEMENTATION.


  METHOD create_display_line_from_data.
    display_line = VALUE #( vbeln = vbeln posnr = posnr quantity = quantity tag_count = tag_count tag_number = char_value->get_value_as_text( ) ).
  ENDMETHOD.
ENDCLASS.

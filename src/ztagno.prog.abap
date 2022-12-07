*&---------------------------------------------------------------------*
*& Report  ZTAGNO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ztagno.

TABLES vbap.
SELECT-OPTIONS svbeln FOR vbap-vbeln.
SELECT-OPTIONS sposnr FOR vbap-posnr.

SELECT vbeln, posnr, kwmeng FROM vbap
  INTO TABLE @DATA(positions)
  WHERE vbeln IN @svbeln
  AND posnr IN @sposnr.

TYPES: BEGIN OF ty_conf_vbap,
         conf TYPE REF TO zcl_pdm_obj_conf_vbap,
       END OF ty_conf_vbap.
DATA t_conf_vbap TYPE STANDARD TABLE OF ty_conf_vbap WITH EMPTY KEY.
TYPES: BEGIN OF ty_display,
         vbeln      TYPE vbeln,
         posnr      TYPE posnr,
         quantity   TYPE kwmeng,
         tag_count  TYPE i,
         tag_number TYPE char30,
       END OF ty_display.
DATA t_display TYPE STANDARD TABLE OF ty_display.
DATA tag_numbers TYPE STANDARD TABLE OF atwrt.

t_conf_vbap = VALUE #( FOR <fs> IN positions ( conf = zcl_pdm_obj_conf_vbap=>create(
                                                                      i_sd_order           = <fs>-vbeln
                                                                      i_sd_order_pos       = <fs>-posnr
                                                                      if_ce_processing     = abap_false
                                                                      if_cbase             = abap_true
                                                                  ) ) ).
DATA count TYPE i.
LOOP AT positions REFERENCE INTO DATA(position).
  DATA(conf) = t_conf_vbap[ sy-tabix ]-conf.
  count = 1.
  IF conf IS BOUND.
    LOOP AT conf->get_char_list( ) INTO DATA(char).
      IF char IS BOUND.
        IF char->get_name( ) CP 'KENNZ_1_*'.
          LOOP AT char->get_value_list( ) INTO DATA(value).
            IF value IS BOUND.
              DATA d_line TYPE ty_display.
              d_line-vbeln = position->vbeln.
              d_line-posnr = position->posnr.
              d_line-quantity = position->kwmeng.
              d_line-tag_count = count.
              d_line-tag_number = value->get_value_as_text( ).
              APPEND d_line TO t_display.
              ADD 1 TO count.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CLEAR count.
ENDLOOP.

cl_salv_table=>factory(
  IMPORTING
    r_salv_table   = DATA(salv)    " Basis Class Simple ALV Tables
  CHANGING
    t_table        = t_display
).

salv->get_functions( )->set_all( ).
salv->get_columns( )->get_column( 'TAG_COUNT' )->set_short_text( 'Counter' ).
salv->get_columns( )->get_column( 'TAG_NUMBER' )->set_short_text( 'Tag_No' ).
salv->get_columns( )->get_column( 'TAG_NUMBER' )->set_medium_text( 'Tag Number ' ).
salv->get_sorts( )->add_sort( columnname = 'VBELN' ).
salv->get_sorts( )->add_sort( columnname = 'POSNR' ).
salv->get_sorts( )->add_sort( columnname = 'QUANTITY' ).

salv->display( ).

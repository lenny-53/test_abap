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

DATA t_conf_vbap TYPE STANDARD TABLE OF zcl_tagno=>ty_conf_vbap WITH EMPTY KEY.
DATA t_display TYPE STANDARD TABLE OF zcl_tagno=>ty_display.
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
              DATA(d_line) = zcl_tagno=>create_display_line_from_data(
                   vbeln        = position->vbeln
                   posnr        = position->posnr
                   quantity     = position->kwmeng
                   tag_count    = count
                   char_value   = value
               ).
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

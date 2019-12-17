*&---------------------------------------------------------------------*
*&  Include           XXXXXX_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'STATUS_9000'.
  SET TITLEBAR 'TIT_9000'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOSTRAR_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mostrar_alv_principal OUTPUT.
  PERFORM mostrar_alv_principal.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9001 OUTPUT.

  SET PF-STATUS 'STATUS_9001'.
  PERFORM agregar_titulo_alv_buttons.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  MOSTRAR_ALV_BOTONES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mostrar_alv OUTPUT.

  "Se lanza el ALV correspondiente según el flag.

  IF v_bonif EQ 'X'.

    IF t_DB2_alv_aux[] IS INITIAL.
      t_DB2_alv_aux[] = t_DB2_alv.
    ENDIF.
    PERFORM mostrar_alv_desc_bonif.

  ELSEIF v_ac_dan EQ 'X'.

    IF t_DB7_alv_aux[] IS INITIAL.
      t_DB7_alv_aux[] = t_DB7_alv.
    ENDIF.
    PERFORM mostrar_alv_ac_dan.

  ELSEIF v_plaz_topes EQ 'X'.

    IF t_DB3_alv_aux[] IS INITIAL.
      t_DB3_alv_aux[] = t_DB3_alv.
    ENDIF.
    PERFORM mostrar_alv_plaz_tope.

  ELSEIF v_desc_esp EQ 'X'.

    IF t_DB4_alv_aux[] IS INITIAL.
      t_DB4_alv_aux[] = t_DB4_alv.
    ENDIF.
    PERFORM mostrar_alv_desc_especiales.

  ELSEIF v_ap_precio EQ 'X'.

    IF t_DB6_alv_aux[] IS INITIAL.
      t_DB6_alv_aux[] = t_DB6_alv.
    ENDIF.
    PERFORM mostrar_alv_ap_precio.

  ELSEIF v_cond_serv EQ 'X'.

    IF t_DB5_alv_aux[] IS INITIAL.
      t_DB5_alv_aux[] = t_DB5_alv.
    ENDIF.
    PERFORM mostrar_alv_cond_serv.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'STATUS_9002'.
  SET TITLEBAR 'TIT_MOTIVO'.
ENDMODULE.

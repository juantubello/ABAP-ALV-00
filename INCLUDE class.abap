*&---------------------------------------------------------------------*
*&  Include           XXXXX_CLS
*&---------------------------------------------------------------------*
CLASS lcl_event_handler_autorizar DEFINITION.

  " Se define en que circusntancia se va a poder utilizar el método

  PUBLIC SECTION.
    METHODS:
      handle_toolbar  FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.

ENDCLASS.

CLASS lcl_event_handler_autorizar IMPLEMENTATION.

  METHOD handle_toolbar.

    DATA: wl_toolbar TYPE stb_button.

    " Se añade el pipe
    MOVE 3 TO wl_toolbar-butn_type.
    APPEND wl_toolbar TO e_object->mt_toolbar.
    CLEAR wl_toolbar.

    " Se añaden los botones
    wl_toolbar-function  = 'DESC_Y_BONIF'.
    wl_toolbar-text      = 'Desc y bonificaciones / Sustentable'.
    APPEND wl_toolbar TO e_object->mt_toolbar.
    CLEAR wl_toolbar.

    wl_toolbar-function  = 'PLAZ_Y_TOP_FIJ'.
    wl_toolbar-text      = 'Plazos y topes de fijación'.
    APPEND wl_toolbar TO e_object->mt_toolbar.
    CLEAR wl_toolbar.

    wl_toolbar-function  = 'DANIADOS'.
    wl_toolbar-text      = 'Act. Dañados'.
    APPEND wl_toolbar TO e_object->mt_toolbar.
    CLEAR wl_toolbar.

    wl_toolbar-function  = 'DESC_CALIDAD'.
    wl_toolbar-text      = 'Desc. especiales x calidad'.
    APPEND wl_toolbar TO e_object->mt_toolbar.
    CLEAR wl_toolbar.

    wl_toolbar-function  = 'AP_PRECIO'.
    wl_toolbar-text      = 'Apertura de Precio'.
    APPEND wl_toolbar TO e_object->mt_toolbar.
    CLEAR wl_toolbar.

    wl_toolbar-function  = 'SERV_CALIDAD'.
    wl_toolbar-text      = 'Cond. Servicios y Calidad'.
    APPEND wl_toolbar TO e_object->mt_toolbar.
    CLEAR wl_toolbar.

  ENDMETHOD.                    "handle_toolbar_autorizar

  METHOD handle_user_command.

    DATA: tl_rows TYPE lvc_t_row.

    CALL METHOD o_alv->get_selected_rows
      IMPORTING
        et_index_rows = tl_rows.

    CASE e_ucomm.  "Selección del usuario
      WHEN 'DESC_Y_BONIF'.

        IF t_zmpte3010_alv IS INITIAL.
          MESSAGE TEXT-001 TYPE 'I' DISPLAY LIKE 'E'.

        ELSE.
          "Limpiamos el flag que nos situa en el alv principal
          CLEAR v_alv_principal.
          "Indicamos el flag para situarnos en el boton
          v_bonif = 'X'.
          CALL SCREEN 9001 STARTING AT 05 05
                           ENDING AT 40 00.
        ENDIF.

      WHEN 'PLAZ_Y_TOP_FIJ'.

        IF t_zmpte3100_alv IS INITIAL.
          MESSAGE TEXT-001 TYPE 'I' DISPLAY LIKE 'E'.

        ELSE.
          "Limpiamos el flag que nos situa en el alv principal
          CLEAR v_alv_principal.
          "Indicamos el flag para situarnos en el boton
          v_plaz_topes = 'X'.
          CALL SCREEN 9001 STARTING AT 05 05
                           ENDING AT 40 00.
        ENDIF.

      WHEN 'DANIADOS'.

        IF t_zmpte3970_alv IS INITIAL.
          MESSAGE TEXT-001 TYPE 'I' DISPLAY LIKE 'E'.

        ELSE.
          "Limpiamos el flag que nos situa en el alv principal
          CLEAR v_alv_principal.
          v_ac_dan = 'X'.
          CALL SCREEN 9001 STARTING AT 05 05
                           ENDING AT 40 00.
        ENDIF.

      WHEN 'DESC_CALIDAD'.

        IF t_zmpte3060_alv IS INITIAL.
          MESSAGE TEXT-001 TYPE 'I' DISPLAY LIKE 'E'.

        ELSE.
          "Limpiamos el flag que nos situa en el alv principal
          CLEAR v_alv_principal.
          v_desc_esp = 'X'.
          CALL SCREEN 9001 STARTING AT 05 05
                           ENDING AT 40 00.
        ENDIF.

      WHEN 'AP_PRECIO'.

        IF t_zmpte7580_alv IS INITIAL.
          MESSAGE TEXT-001 TYPE 'I' DISPLAY LIKE 'E'.

        ELSE.
          "Limpiamos el flag que nos situa en el alv principal
          CLEAR v_alv_principal.
          v_ap_precio = 'X'.
          CALL SCREEN 9001 STARTING AT 05 05
                           ENDING AT 40 00.
        ENDIF.

      WHEN 'SERV_CALIDAD'.

        IF t_zmpte3070_alv IS INITIAL.
          MESSAGE TEXT-001 TYPE 'I' DISPLAY LIKE 'E'.

        ELSE.
          "Limpiamos el flag que nos situa en el alv principal
          CLEAR v_alv_principal.
          v_cond_serv = 'X'.
          CALL SCREEN 9001 STARTING AT 05 05
                           ENDING AT 40 00.
        ENDIF.

    ENDCASE.

  ENDMETHOD.
  METHOD handle_data_changed.

    IF v_alv_principal EQ 'X'.
      PERFORM log_zmpte3030 USING er_data_changed.

    ELSEIF v_bonif = 'X'.
      PERFORM guardo_DB1 USING er_data_changed.
      PERFORM mensaje_clave_duplicada USING v_duplicados.

    ELSEIF v_ac_dan = 'X'.
      PERFORM guardo_DB2 USING er_data_changed.
      PERFORM mensaje_clave_duplicada USING v_duplicados.

    ELSEIF v_desc_esp = 'X'.
      PERFORM guardo_DB3 USING er_data_changed.
      PERFORM mensaje_clave_duplicada USING v_duplicados.

    ELSEIF v_cond_serv = 'X'.
      PERFORM guardo_DB4 USING er_data_changed.
      PERFORM mensaje_clave_duplicada USING v_duplicados.

    ELSEIF v_plaz_topes = 'X'.
      PERFORM guardo_DB5 USING er_data_changed.
      PERFORM mensaje_clave_duplicada USING v_duplicados.

    ELSEIF v_ap_precio = 'X'.
      PERFORM guardo_DB6 USING er_data_changed.
      PERFORM mensaje_clave_duplicada USING v_duplicados.

    ENDIF.

  ENDMETHOD.                    "handle_data_changed

ENDCLASS.

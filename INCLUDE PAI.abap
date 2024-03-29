*&---------------------------------------------------------------------*
*&  Include           XXXXX_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE sy-ucomm.
    WHEN 'GUARDAR'.
      CLEAR v_motivo.
      PERFORM actualizar_TABLA_DB_1.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE sy-ucomm.

    WHEN 'GUARDAR'.

      DATA: vl_flag TYPE c.

      IF v_bonif EQ 'X'.

        PERFORM validar_campos_clave USING t_TABLA_DB_1_alv space CHANGING vl_flag.
        IF vl_flag IS INITIAL.
          PERFORM actualizo__TABLA_DB_2.
        ENDIF.

      ELSEIF v_ac_dan EQ 'X'.
        PERFORM validar_campos_clave USING t_TABLA_DB_2_alv 'PORC_DESDE' CHANGING vl_flag.
        IF vl_flag IS INITIAL.
          PERFORM actualizo_TABLA_DB_2.
        ENDIF.

      ELSEIF v_desc_esp EQ 'X'.
        PERFORM validar_campos_clave USING t_TABLA_DB_3_alv 'PORC_DESDE' CHANGING vl_flag.
        IF vl_flag IS INITIAL.
          PERFORM actualizo_TABLA_DB_3.
        ENDIF.

      ELSEIF v_cond_serv EQ 'X'.
        PERFORM validar_campos_clave USING t_TABLA_DB_4_alv 'PORC_DESDE' CHANGING vl_flag.
        IF vl_flag IS INITIAL.
          PERFORM actualizo_TABLA_DB_4.
        ENDIF.

      ELSEIF v_plaz_topes EQ 'X'.
        PERFORM validar_campos_clave USING t_TABLA_DB_5_alv space CHANGING vl_flag.
        IF vl_flag IS INITIAL.
          PERFORM actualizo_TABLA_DB_5.
        ENDIF.

      ELSEIF v_ap_precio EQ 'X'.
        PERFORM validar_campos_clave USING t_TABLA_DB_6alv space CHANGING vl_flag.
        IF vl_flag IS INITIAL.
          PERFORM actualizo_TABLA_DB_6.
        ENDIF.

      ENDIF.

      IF vl_flag IS INITIAL.

        IF v_duplicados IS INITIAL.
          CALL METHOD o_alv_botones->free. "Se limpia el ALV
          CALL METHOD o_alv_container_botones->free. "Se limpia el Container del ALV
          cl_gui_cfw=>flush( ).                      "Se libera memoria y refresca el front (gui)

          CLEAR:  v_cond_serv, v_ap_precio, v_desc_esp, v_plaz_topes, v_ac_dan,
                 v_bonif, o_alv_container_botones, o_alv_botones,vl_flag.

          REFRESH: t_TABLA_DB_1_mod, t_TABLA_DB_del, t_TABLA_DB_alv_aux,
                   t_TABLA_DB_2_mod, t_TABLA_DB_2_del, t_TABLA_DB_2_alv_aux,
                   t_TABLA_DB_3_mod, T_TABLA_DB_3_del, t_TABLA_DB_3_alv_aux,
                   t_TABLA_DB_4_mod, t_TABLA_DB_4_del, t_TABLA_DB_4__alv_aux,
                   t_TABLA_DB_5_mod, t_TABLA_DB_5_del, t_TABLA_DB_5_alv_aux,
                   t_TABLA_DB_6_mod, t_TABLA_DB_6_del, t_TABLA_DB_6_0_alv_aux,
                   t_log, t_fieldcat_aux.

          LEAVE TO SCREEN 0.

        ELSE.
          PERFORM mensaje_clave_duplicada USING v_duplicados.

        ENDIF.

      ELSE.

        MESSAGE TEXT-007 TYPE 'I' DISPLAY LIKE 'E'.
        CLEAR vl_flag.

      ENDIF.

    WHEN 'CANCELAR'.

      CALL METHOD o_alv_botones->free. "Se limpia el ALV
      CALL METHOD o_alv_container_botones->free. "Se limpia el Container del ALV
      cl_gui_cfw=>flush( ).                      "Se libera memoria y refresca el front (gui)

      IF v_bonif EQ 'X'.
        t_db1_alv[] = t_TABLA_DB_1_alv_aux[].

      ELSEIF v_ac_dan EQ 'X'.
        t_db2_alv[] = t_TABLA_DB_2_alv_aux[].

      ELSEIF v_desc_esp EQ 'X'.
        t_db3_alv[] = t_TABLA_DB_3_alv_aux[].

      ELSEIF v_cond_serv EQ 'X'.
        t_db4_alv[] = t_TABLA_DB_4_alv_aux[].

      ELSEIF v_plaz_topes EQ 'X'.
        t_db5_alv[] = t_TABLA_DB_5_alv_aux[].

      ELSEIF v_ap_precio EQ 'X'.
        t_db6_alv[] = t_TABLA_DB_6_alv_aux[].

      ENDIF.

      CLEAR: v_cond_serv, v_ap_precio, v_desc_esp, v_plaz_topes, v_ac_dan,
             v_bonif, o_alv_container_botones, o_alv_botones.

          REFRESH: t_TABLA_DB_1_mod, t_TABLA_DB_del, t_TABLA_DB_alv_aux,
                   t_TABLA_DB_2_mod, t_TABLA_DB_2_del, t_TABLA_DB_2_alv_aux,
                   t_TABLA_DB_3_mod, T_TABLA_DB_3_del, t_TABLA_DB_3_alv_aux,
                   t_TABLA_DB_4_mod, t_TABLA_DB_4_del, t_TABLA_DB_4__alv_aux,
                   t_TABLA_DB_5_mod, t_TABLA_DB_5_del, t_TABLA_DB_5_alv_aux,
                   t_TABLA_DB_6_mod, t_TABLA_DB_6_del, t_TABLA_DB_6_0_alv_aux,
                   t_log, t_fieldcat_aux.

      " Llenamos el flag que nos situa en el alv principal
      v_alv_principal = 'X'.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.

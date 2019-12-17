*&---------------------------------------------------------------------*
*&  Include           XXXXX_F01
*&---------------------------------------------------------------------*
FORM obtener_datos.

  " TABLA_DB_1 - Contratos
  SELECT *
  FROM TABLA_DB_1
  INTO CORRESPONDING FIELDS OF TABLE t_TABLA_DB_1_alv
  WHERE contrnum = p_cntrum.

  MOVE-CORRESPONDING t_TABLA_DB_1_alv TO t_TABLA_DB_1.

  IF t_TABLA_DB_1_alv IS INITIAL.
    MESSAGE TEXT-001 TYPE 'W' DISPLAY LIKE 'E'.

  ELSE.

    " TABLA_DB_2 - Descuentos y bonificaciones / Sustentable
    SELECT *
      FROM TABLA_DB_2
      INTO CORRESPONDING FIELDS OF TABLE t_TABLA_DB_2_alv
      WHERE contrnum = p_cntrum.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_TABLA_DB_2_alv TO t_TABLA_DB_2.
    ENDIF.

    " TABLA_DB_3 - Plazos y Topes de fijación
    SELECT *
      FROM TABLA_DB_3
      INTO CORRESPONDING FIELDS OF TABLE t_TABLA_DB_3_alv
      WHERE contrnum = p_cntrum.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_TABLA_DB_3_alv TO t_TABLA_DB_3.
    ENDIF.

    " TABLA_DB_7 - Act. dañados
    SELECT *
      FROM TABLA_DB_7
      INTO CORRESPONDING FIELDS OF TABLE t_TABLA_DB_7_alv
      WHERE contrnum = p_cntrum.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_TABLA_DB_7_alv TO t_TABLA_DB_7.
    ENDIF.

    " TABLA_DB_4 - Desc especiales x calidad
    SELECT *
       FROM TABLA_DB_4
       INTO CORRESPONDING FIELDS OF TABLE t_TABLA_DB_4_alv
       WHERE contrnum = p_cntrum.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_TABLA_DB_4_alv TO t_TABLA_DB_4.
    ENDIF.

    " TABLA_DB_6 - Apertura de precio
    SELECT *
    FROM TABLA_DB_6
    INTO CORRESPONDING FIELDS OF TABLE t_TABLA_DB_6_alv
    WHERE contrnum = p_cntrum.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_TABLA_DB_6_alv TO t_TABLA_DB_6.
    ENDIF.

    " TABLA_DB_4 - Cond. Servicios y Calidad
    SELECT *
    FROM TABLA_DB_4
    INTO CORRESPONDING FIELDS OF TABLE t_TABLA_DB_4_alv
    WHERE contrnum = p_cntrum.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_TABLA_DB_4_alv TO t_TABLA_DB_4.
    ENDIF.

  ENDIF.

ENDFORM.

FORM mostrar_alv_principal.

* Declaraciones locales *
*************************

  DATA: ol_alv_container TYPE REF TO cl_gui_custom_container.     "Contenedor

  DATA: tl_fieldcat      TYPE lvc_t_fcat,                         "Catalogo
        tl_exclude       TYPE ui_functions,                       "Exclusion de botones
        ol_event_handler TYPE REF TO lcl_event_handler_autorizar. "Instancia de clase

  DATA: wl_layout TYPE lvc_s_layo.                                "Diseño

* Lógica *
**********
  v_alv_principal = 'X'.
  "Si ya esta creado el ALV solamente refresco el mismo.
  IF o_alv IS BOUND.
    CALL METHOD o_alv->refresh_table_display
      EXCEPTIONS
        OTHERS = 0.
    EXIT.
  ENDIF.

  "Creo el objeto del container(Dynpro)
  CREATE OBJECT ol_alv_container
    EXPORTING
      container_name              = 'CC_ALV'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "Creo la relacion entre mi objeto alv y el container creado anteriormente
  CREATE OBJECT o_alv
    EXPORTING
      i_parent          = ol_alv_container
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  " Creo el catálogo
  PERFORM armar_fieldcat USING 'TABLA_DB_1'
                         CHANGING tl_fieldcat.

  LOOP AT tl_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
    " Campo clave no editable
    IF <fs_fieldcat>-fieldname <> 'CONTRNUM'.
      <fs_fieldcat>-edit = 'X'.
    ENDIF.
  ENDLOOP.
  UNASSIGN:<fs_fieldcat>.

  v_flag_add_delete_row = 'X'. "Eliminar botones de añadir y borrar registros del ALV

  " Se excluyen botones innecesarios
  PERFORM excluir_botones_ppal   USING v_flag_add_delete_row   CHANGING tl_exclude.

  CLEAR v_flag_add_delete_row.

  " Se añade la optimización de columnas al Diseño
  MOVE: 'X' TO wl_layout-col_opt.

  " Creación de objeto para manejar los eventos
  CREATE OBJECT ol_event_handler.
  SET HANDLER ol_event_handler->handle_toolbar FOR o_alv.
  SET HANDLER ol_event_handler->handle_user_command FOR o_alv.
  SET HANDLER ol_event_handler->handle_data_changed FOR o_alv.

  CALL METHOD o_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  " Se llama al método para mostrar el ALV
  CALL METHOD o_alv->set_table_for_first_display
    EXPORTING
*     i_structure_name              = 'TABLA_DB_1'
      is_layout                     = wl_layout
      it_toolbar_excluding          = tl_exclude
    CHANGING
      it_outtab                     = t_TABLA_DB_1_alv
      it_fieldcatalog               = tl_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
FORM armar_fieldcat  USING pe_estructura TYPE dd02l-tabname
                     CHANGING pt_fieldcat TYPE lvc_t_fcat.

  " Se crea el catálogo a partir de la estructura obtenida por parametro
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = pe_estructura
    CHANGING
      ct_fieldcat      = pt_fieldcat.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " ARMAR_FIELDCAT_AJUSTE
FORM excluir_botones_ppal USING pv_flag TYPE c
                          CHANGING pt_exclude TYPE ui_functions.
* Declaraciones locales *
*************************

  DATA wl_exclude TYPE ui_func.

* Lógica *
**********

  wl_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  IF pv_flag EQ 'X'.

    wl_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
    APPEND wl_exclude TO pt_exclude.
    CLEAR wl_exclude.

    wl_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
    APPEND wl_exclude TO pt_exclude.
    CLEAR wl_exclude.

  ENDIF.

  wl_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

  wl_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND wl_exclude TO pt_exclude.
  CLEAR wl_exclude.

ENDFORM.
FORM mostrar_alv_desc_bonif. "Tabla TABLA_DB_2

* Declaraciones locales *
*************************

  DATA: tl_fieldcat_desc_bonif      TYPE lvc_t_fcat,                         "Catalogo
        tl_exclude_desc_bonif       TYPE ui_functions,                       "Exclusion de botones
        ol_event_handler_desc_bonif TYPE REF TO lcl_event_handler_autorizar. "Instancia de clase

  DATA: wl_layout_desc_bonif TYPE lvc_s_layo.                                "Diseño

  DATA: vl_index   TYPE i,                                                   "Indice
        lt_celltab TYPE lvc_t_styl.                                          "Tabla de celdas (para setear campos clave como no editables)

  DATA: wl_TABLA_DB_2 TYPE ty_TABLA_DB_2.                                      "Work area de tabla ty_TABLA_DB_2
  DATA: tl_campos_clave TYPE STANDARD TABLE OF ty_campo_clave,               "Tabla para campos clave
        wl_campos_clave TYPE ty_campo_clave.                                 "Work area para campos clave

* Lógica *
**********

* "Si ya esta creado el ALV solamente refresco el mismo.
  IF o_alv_botones IS BOUND.
    CALL METHOD o_alv_botones->refresh_table_display
      EXCEPTIONS
        OTHERS = 0.
    EXIT.
  ENDIF.

  PERFORM crear_obj_alv_botones.

  " Creo el catálogo
  PERFORM armar_fieldcat USING 'TABLA_DB_2'
  CHANGING tl_fieldcat_desc_bonif.

  " Setiamos editables, ya que al agregar un nuevo registro, es necesario que sea completamente
  " editable, y la nueva fila insertada utiliza este catalogo(con los campos editables).
  LOOP AT tl_fieldcat_desc_bonif ASSIGNING FIELD-SYMBOL(<fs_fieldcat_desc_bonif>).

    IF <fs_fieldcat_desc_bonif>-fieldname EQ 'CONTRNUM'.
      <fs_fieldcat_desc_bonif>-auto_value = 'X'. "Al añadir un nuevo registro este toma el valor del contrato inmdediato superior.
    ELSE.
      <fs_fieldcat_desc_bonif>-edit = 'X'.
    ENDIF.

  ENDLOOP.

  UNASSIGN:<fs_fieldcat_desc_bonif>.

  " Se excluyen botones innecesarios
  PERFORM excluir_botones_ppal  USING v_flag_add_delete_row   CHANGING tl_exclude_desc_bonif.

  " Se añade la optimización de columnas al Diseño
  MOVE: 'X' TO wl_layout_desc_bonif-col_opt,
        'CELL' TO wl_layout_desc_bonif-stylefname. "Se utiliza para grisar los campos del ALV

  "Agregamos los campos que van a ser solo lectura (NO editables en la salida del ALV, pero si editables si se agrega un nuevo registro).
  wl_campos_clave-campo_clave = 'CONTRNUM'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'FEDESDE'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'FEHASTA'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'TIPO_PERIODO'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'TIPO_DB'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.

* Setea los campos claves del ALV como de SOLO LECTURA (grisados)
  LOOP AT t_TABLA_DB_2_alv INTO wl_TABLA_DB_2.
    vl_index = sy-tabix.
    REFRESH lt_celltab.
    PERFORM grisar_campo USING tl_campos_clave
                         CHANGING lt_celltab.
    IF wl_TABLA_DB_2-cell IS INITIAL.
      INSERT LINES OF lt_celltab INTO TABLE wl_TABLA_DB_2-cell.
    ENDIF.
    MODIFY t_TABLA_DB_2_alv FROM wl_TABLA_DB_2 INDEX vl_index.
  ENDLOOP.

  " Creación de objeto para manejar los eventos
  CREATE OBJECT ol_event_handler_desc_bonif.

  SET HANDLER ol_event_handler_desc_bonif->handle_user_command FOR o_alv_botones.
  SET HANDLER ol_event_handler_desc_bonif->handle_data_changed FOR o_alv_botones.

  "Activamos el enter para disparar eventos
  CALL METHOD o_alv_botones->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*  "Desactivo el log de errores al añadir un nuevo registro
*  o_alv_botones->activate_display_protocol( space ).

  " Se llama al método para mostrar el ALV
  CALL METHOD o_alv_botones->set_table_for_first_display
    EXPORTING
*     i_structure_name              = 'TABLA_DB_1'
      is_layout                     = wl_layout_desc_bonif
      it_toolbar_excluding          = tl_exclude_desc_bonif
    CHANGING
      it_outtab                     = t_TABLA_DB_2_alv
      it_fieldcatalog               = tl_fieldcat_desc_bonif
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
FORM mostrar_alv_plaz_tope. " Tabla TABLA_DB_3

* Declaraciones locales *
*************************

  DATA: tl_fieldcat_plaz_tope      TYPE lvc_t_fcat,                         "Catalogo
        tl_exclude_plaz_tope       TYPE ui_functions,                       "Exclusion de botones
        ol_event_handler_plaz_tope TYPE REF TO lcl_event_handler_autorizar. "Instancia de clase

  DATA: wl_layout_plaz_tope TYPE lvc_s_layo.                                "Diseño

  DATA: vl_index   TYPE i,                                                   "Indice
        lt_celltab TYPE lvc_t_styl.                                          "Tabla de celdas (para setear campos clave como no editables)

  DATA: wl_TABLA_DB_3 TYPE ty_TABLA_DB_3.                                      "Work area de tabla ty_TABLA_DB_3
  DATA: tl_campos_clave TYPE STANDARD TABLE OF ty_campo_clave,               "Tabla para campos clave
        wl_campos_clave TYPE ty_campo_clave.                                 "Work area para campos clave


* Lógica *
**********

*  "Si ya esta creado el ALV solamente refresco el mismo.
  IF o_alv_botones IS BOUND.
    CALL METHOD o_alv_botones->refresh_table_display
      EXCEPTIONS
        OTHERS = 0.
    EXIT.
  ENDIF.

  PERFORM crear_obj_alv_botones.

  " Creo el catálogo
  PERFORM armar_fieldcat USING 'TABLA_DB_3'
  CHANGING tl_fieldcat_plaz_tope.

  LOOP AT tl_fieldcat_plaz_tope ASSIGNING FIELD-SYMBOL(<fs_fieldcat_plaz_tope>).

    IF <fs_fieldcat_plaz_tope>-fieldname EQ 'CONTRNUM'.
      <fs_fieldcat_plaz_tope>-auto_value = 'X'. "Al añadir un nuevo registro este toma el valor del contrato inmdediato superior.
    ELSE.
      <fs_fieldcat_plaz_tope>-edit = 'X'.
    ENDIF.

  ENDLOOP.

  UNASSIGN:<fs_fieldcat_plaz_tope>.

  " Se excluyen botones innecesarios
  PERFORM excluir_botones_ppal   USING v_flag_add_delete_row  CHANGING tl_exclude_plaz_tope.

  " Se añade la optimización de columnas al Diseño
  MOVE: 'X' TO wl_layout_plaz_tope-col_opt,
  'CELL' TO wl_layout_plaz_tope-stylefname. "Se utiliza para grisar los campos del ALV

  "Agregamos los campos que van a ser solo lectura (NO editables en la salida del ALV, pero si editables si se agrega un nuevo registro).
  wl_campos_clave-campo_clave = 'CONTRNUM'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'FE_DESDE'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'FE_HASTA'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.

* Setea los campos claves del ALV como de SOLO LECTURA (grisados)
  LOOP AT t_TABLA_DB_3_alv INTO wl_TABLA_DB_3.
    vl_index = sy-tabix.
    REFRESH lt_celltab.
    PERFORM grisar_campo USING tl_campos_clave
                         CHANGING lt_celltab.

    IF wl_TABLA_DB_3-cell IS INITIAL.
      INSERT LINES OF lt_celltab INTO TABLE wl_TABLA_DB_3-cell.
    ENDIF.
    MODIFY t_TABLA_DB_3_alv FROM wl_TABLA_DB_3 INDEX vl_index.
  ENDLOOP.

  " Creación de objeto para manejar los eventos
  CREATE OBJECT ol_event_handler_plaz_tope.

  SET HANDLER ol_event_handler_plaz_tope->handle_user_command FOR o_alv_botones.
  SET HANDLER ol_event_handler_plaz_tope->handle_data_changed FOR o_alv_botones.

  "Activamos el enter para disparar eventos
  CALL METHOD o_alv_botones->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  "Desactivo el log de errores al añadir un nuevo registro
*  o_alv_botones->activate_display_protocol( space ).

  " Se llama al método para mostrar el ALV
  CALL METHOD o_alv_botones->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_layout_plaz_tope
      it_toolbar_excluding          = tl_exclude_plaz_tope
    CHANGING
      it_outtab                     = t_TABLA_DB_3_alv
      it_fieldcatalog               = tl_fieldcat_plaz_tope
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
FORM mostrar_alv_ac_dan. "Tabla TABLA_DB_7

* Declaraciones locales *
*************************

  DATA: tl_fieldcat_ac_dan      TYPE lvc_t_fcat,                         "Catalogo
        tl_exclude_ac_dan       TYPE ui_functions,                       "Exclusion de botones
        ol_event_handler_ac_dan TYPE REF TO lcl_event_handler_autorizar. "Instancia de clase

  DATA: wl_layout_ac_dan TYPE lvc_s_layo.                                "Diseño

  DATA: vl_index   TYPE i,                                               "Indice
        lt_celltab TYPE lvc_t_styl.                                      "Tabla de celdas (para setear campos clave como no editables)

  DATA: wl_TABLA_DB_7 TYPE ty_TABLA_DB_7.                                  "Work area de tabla ty_TABLA_DB_7
  DATA: tl_campos_clave TYPE STANDARD TABLE OF ty_campo_clave,           "Tabla para campos clave
        wl_campos_clave TYPE ty_campo_clave.                             "Work area para campos clave

* Lógica *
**********

*  "Si ya esta creado el ALV solamente refresco el mismo.
  IF o_alv_botones IS BOUND.
    CALL METHOD o_alv_botones->refresh_table_display
      EXCEPTIONS
        OTHERS = 0.
    EXIT.
  ENDIF.

  PERFORM crear_obj_alv_botones.

  " Creo el catálogo
  PERFORM armar_fieldcat USING 'TABLA_DB_7'
  CHANGING tl_fieldcat_ac_dan.

  LOOP AT tl_fieldcat_ac_dan ASSIGNING FIELD-SYMBOL(<fs_fieldcat_ac_dan>).

    IF <fs_fieldcat_ac_dan>-fieldname EQ 'CONTRNUM'.
      <fs_fieldcat_ac_dan>-auto_value = 'X'. "Al añadir un nuevo registro este toma el valor del contrato inmdediato superior.
    ELSE.
      <fs_fieldcat_ac_dan>-edit = 'X'.
    ENDIF.

  ENDLOOP.

  UNASSIGN:<fs_fieldcat_ac_dan>.

  " Se excluyen botones innecesarios
  PERFORM excluir_botones_ppal  USING v_flag_add_delete_row   CHANGING tl_exclude_ac_dan.

  " Se añade la optimización de columnas al Diseño
  MOVE: 'X' TO wl_layout_ac_dan-col_opt,
        'CELL' TO wl_layout_ac_dan-stylefname. "Se utiliza para grisar los campos del ALV

  "Agregamos los campos que van a ser solo lectura (NO editables en la salida del ALV, pero si editables si se agrega un nuevo registro).
  wl_campos_clave-campo_clave = 'CONTRNUM'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'CODIGO'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'PORC_DESDE'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'PORC_HASTA'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.

* Setea los campos claves del ALV como de SOLO LECTURA (grisados)
  LOOP AT t_TABLA_DB_7_alv INTO wl_TABLA_DB_7.
    vl_index = sy-tabix.
    REFRESH lt_celltab.
    PERFORM grisar_campo USING tl_campos_clave
                         CHANGING lt_celltab.

    IF wl_TABLA_DB_7-cell IS INITIAL.
      INSERT LINES OF lt_celltab INTO TABLE wl_TABLA_DB_7-cell.
    ENDIF.
    MODIFY t_TABLA_DB_7_alv FROM wl_TABLA_DB_7 INDEX vl_index.
  ENDLOOP.

  " Creación de objeto para manejar los eventos
  CREATE OBJECT ol_event_handler_ac_dan.

  SET HANDLER ol_event_handler_ac_dan->handle_user_command FOR o_alv_botones.
  SET HANDLER ol_event_handler_ac_dan->handle_data_changed FOR o_alv_botones.

  "Activamos el enter para disparar eventos
  CALL METHOD o_alv_botones->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  "Desactivo el log de errores al añadir un nuevo registro
*  o_alv_botones->activate_display_protocol( space ).

  " Se llama al método para mostrar el ALV
  CALL METHOD o_alv_botones->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_layout_ac_dan
      it_toolbar_excluding          = tl_exclude_ac_dan
    CHANGING
      it_outtab                     = t_TABLA_DB_7_alv
      it_fieldcatalog               = tl_fieldcat_ac_dan
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
FORM mostrar_alv_desc_especiales. "Tabla TABLA_DB_4

* Declaraciones locales *
*************************

  DATA: tl_fieldcat_desc_esp      TYPE lvc_t_fcat,                         "Catalogo
        tl_exclude_desc_esp       TYPE ui_functions,                       "Exclusion de botones
        ol_event_handler_desc_esp TYPE REF TO lcl_event_handler_autorizar. "Instancia de clase

  DATA: wl_layout_desc_esp TYPE lvc_s_layo.                                "Diseño

  DATA: vl_index   TYPE i,                                                 "Indice
        lt_celltab TYPE lvc_t_styl.                                        "Tabla de celdas (para setear campos clave como no editables)

  DATA: wl_TABLA_DB_4 TYPE ty_TABLA_DB_4.                                    "Work area de tabla ty_TABLA_DB_4
  DATA: tl_campos_clave TYPE STANDARD TABLE OF ty_campo_clave,             "Tabla para campos clave
        wl_campos_clave TYPE ty_campo_clave.                               "Work area para campos clave


* Lógica *
**********

*  "Si ya esta creado el ALV solamente refresco el mismo.
  IF o_alv_botones IS BOUND.
    CALL METHOD o_alv_botones->refresh_table_display
      EXCEPTIONS
        OTHERS = 0.
    EXIT.
  ENDIF.

  PERFORM crear_obj_alv_botones.

  " Creo el catálogo
  PERFORM armar_fieldcat USING 'TABLA_DB_4'
  CHANGING tl_fieldcat_desc_esp.

  LOOP AT tl_fieldcat_desc_esp ASSIGNING FIELD-SYMBOL(<fs_fieldcat_desc_esp>).

    IF <fs_fieldcat_desc_esp>-fieldname EQ 'CONTRNUM'.
      <fs_fieldcat_desc_esp>-auto_value = 'X'. "Al añadir un nuevo registro este toma el valor del contrato inmdediato superior.
    ELSE.
      <fs_fieldcat_desc_esp>-edit = 'X'.
    ENDIF.

  ENDLOOP.

  UNASSIGN:<fs_fieldcat_desc_esp>.

  " Se excluyen botones innecesarios
  PERFORM excluir_botones_ppal  USING v_flag_add_delete_row   CHANGING tl_exclude_desc_esp.

  " Se añade la optimización de columnas al Diseño
  MOVE: 'X' TO wl_layout_desc_esp-col_opt,
        'CELL' TO wl_layout_desc_esp-stylefname. "Se utiliza para grisar los campos del ALV

  "Agregamos los campos que van a ser solo lectura (NO editables en la salida del ALV, pero si editables si se agrega un nuevo registro).
  wl_campos_clave-campo_clave = 'CONTRNUM'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'CODIGO'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'PORC_DESDE'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'PORC_HASTA'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.

* Setea los campos claves del ALV como de SOLO LECTURA (grisados)
  LOOP AT t_TABLA_DB_4_alv INTO wl_TABLA_DB_4.
    vl_index = sy-tabix.
    REFRESH lt_celltab.
    PERFORM grisar_campo USING tl_campos_clave
                         CHANGING lt_celltab.
    IF wl_TABLA_DB_4-cell IS INITIAL.
      INSERT LINES OF lt_celltab INTO TABLE wl_TABLA_DB_4-cell.
    ENDIF.
    MODIFY t_TABLA_DB_4_alv FROM wl_TABLA_DB_4 INDEX vl_index.
  ENDLOOP.

  " Creación de objeto para manejar los eventos
  CREATE OBJECT ol_event_handler_desc_esp.

  SET HANDLER ol_event_handler_desc_esp->handle_user_command FOR o_alv_botones.
  SET HANDLER ol_event_handler_desc_esp->handle_data_changed FOR o_alv_botones.

  "Activamos el enter para disparar eventos
  CALL METHOD o_alv_botones->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  "Desactivo el log de errores al añadir un nuevo registro
*  o_alv_botones->activate_display_protocol( space ).

  " Se llama al método para mostrar el ALV
  CALL METHOD o_alv_botones->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_layout_desc_esp
      it_toolbar_excluding          = tl_exclude_desc_esp
    CHANGING
      it_outtab                     = t_TABLA_DB_4_alv
      it_fieldcatalog               = tl_fieldcat_desc_esp
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

FORM mostrar_alv_ap_precio. "Tabla TABLA_DB_6

* Declaraciones locales *
*************************

  DATA: tl_fieldcat_ap_precio      TYPE lvc_t_fcat,                         "Catalogo
        tl_exclude_ap_precio       TYPE ui_functions,                       "Exclusion de botones
        ol_event_handler_ap_precio TYPE REF TO lcl_event_handler_autorizar. "Instancia de clase

  DATA: wl_layout_ap_precio TYPE lvc_s_layo.                                "Diseño

  DATA: vl_index   TYPE i,                                                 "Indice
        lt_celltab TYPE lvc_t_styl.                                        "Tabla de celdas (para setear campos clave como no editables)

  DATA: wl_TABLA_DB_6 TYPE ty_TABLA_DB_6.                                    "Work area de tabla ty_TABLA_DB_4
  DATA: tl_campos_clave TYPE STANDARD TABLE OF ty_campo_clave,             "Tabla para campos clave
        wl_campos_clave TYPE ty_campo_clave.                               "Work area para campos clave

* Lógica *
**********

*  "Si ya esta creado el ALV solamente refresco el mismo.
  IF o_alv_botones IS BOUND.
    CALL METHOD o_alv_botones->refresh_table_display
      EXCEPTIONS
        OTHERS = 0.
    EXIT.
  ENDIF.

  PERFORM crear_obj_alv_botones.

  " Creo el catálogo
  PERFORM armar_fieldcat USING 'TABLA_DB_6'
  CHANGING tl_fieldcat_ap_precio.

  LOOP AT tl_fieldcat_ap_precio ASSIGNING FIELD-SYMBOL(<fs_fieldcat_ap_precio>).

    IF <fs_fieldcat_ap_precio>-fieldname EQ 'CONTRNUM'.
      <fs_fieldcat_ap_precio>-auto_value = 'X'. "Al añadir un nuevo registro este toma el valor del contrato inmdediato superior.
    ELSE.
      <fs_fieldcat_ap_precio>-edit = 'X'.
    ENDIF.

  ENDLOOP.

  UNASSIGN:<fs_fieldcat_ap_precio>.

  " Se excluyen botones innecesarios
  PERFORM excluir_botones_ppal   USING v_flag_add_delete_row  CHANGING tl_exclude_ap_precio.

  " Se añade la optimización de columnas al Diseño
  MOVE: 'X' TO wl_layout_ap_precio-col_opt,
        'CELL' TO wl_layout_ap_precio-stylefname. "Se utiliza para grisar los campos del ALV

  "Agregamos los campos que van a ser solo lectura (NO editables en la salida del ALV, pero si editables si se agrega un nuevo registro).
  wl_campos_clave-campo_clave = 'CONTRNUM'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'PEDIDO'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'CONCEPTO'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.

* Setea los campos claves del ALV como de SOLO LECTURA (grisados)
  LOOP AT t_TABLA_DB_6_alv INTO wl_TABLA_DB_6.
    vl_index = sy-tabix.
    REFRESH lt_celltab.
    PERFORM grisar_campo USING tl_campos_clave
                         CHANGING lt_celltab.

    IF wl_TABLA_DB_6-cell IS INITIAL.
      INSERT LINES OF lt_celltab INTO TABLE wl_TABLA_DB_6-cell.
    ENDIF.
    MODIFY t_TABLA_DB_6_alv  FROM wl_TABLA_DB_6  INDEX vl_index.
  ENDLOOP.

  " Creación de objeto para manejar los eventos
  CREATE OBJECT ol_event_handler_ap_precio.

  SET HANDLER ol_event_handler_ap_precio->handle_user_command FOR o_alv_botones.
  SET HANDLER ol_event_handler_ap_precio->handle_data_changed FOR o_alv_botones.

  "Activamos el enter para disparar eventos
  CALL METHOD o_alv_botones->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  "Desactivo el log de errores al añadir un nuevo registro
*  o_alv_botones->activate_display_protocol( space ).

  " Se llama al método para mostrar el ALV
  CALL METHOD o_alv_botones->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_layout_ap_precio
      it_toolbar_excluding          = tl_exclude_ap_precio
    CHANGING
      it_outtab                     = t_TABLA_DB_6_alv
      it_fieldcatalog               = tl_fieldcat_ap_precio
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

FORM mostrar_alv_cond_serv. "Tabla TABLA_DB_4

* Declaraciones locales *
*************************

  DATA: tl_fieldcat_cond_serv      TYPE lvc_t_fcat,                         "Catalogo
        tl_exclude_cond_serv       TYPE ui_functions,                       "Exclusion de botones
        ol_event_handler_cond_serv TYPE REF TO lcl_event_handler_autorizar. "Instancia de clase

  DATA: wl_layout_cond_serv TYPE lvc_s_layo.                                "Diseño

  DATA: vl_index   TYPE i,                                                 "Indice
        lt_celltab TYPE lvc_t_styl.                                        "Tabla de celdas (para setear campos clave como no editables)

  DATA: wl_TABLA_DB_4 TYPE ty_TABLA_DB_4.                                    "Work area de tabla ty_TABLA_DB_4
  DATA: tl_campos_clave TYPE STANDARD TABLE OF ty_campo_clave,             "Tabla para campos clave
        wl_campos_clave TYPE ty_campo_clave.                               "Work area para campos clave


* Lógica *
**********

*  "Si ya esta creado el ALV solamente refresco el mismo.
  IF o_alv_botones IS BOUND.
    CALL METHOD o_alv_botones->refresh_table_display
      EXCEPTIONS
        OTHERS = 0.
    EXIT.
  ENDIF.

  PERFORM crear_obj_alv_botones.

  " Creo el catálogo
  PERFORM armar_fieldcat USING 'TABLA_DB_4'
  CHANGING tl_fieldcat_cond_serv.

  LOOP AT tl_fieldcat_cond_serv ASSIGNING FIELD-SYMBOL(<fs_fieldcat_cond_serv>).

    IF <fs_fieldcat_cond_serv>-fieldname EQ 'CONTRNUM'.
      <fs_fieldcat_cond_serv>-auto_value = 'X'. "Al añadir un nuevo registro este toma el valor del contrato inmdediato superior.
    ELSE.
      <fs_fieldcat_cond_serv>-edit = 'X'.
    ENDIF.

  ENDLOOP.

  UNASSIGN:<fs_fieldcat_cond_serv>.

  " Se excluyen botones innecesarios
  PERFORM excluir_botones_ppal  USING v_flag_add_delete_row   CHANGING tl_exclude_cond_serv.

  " Se añade la optimización de columnas al Diseño
  MOVE: 'X' TO wl_layout_cond_serv-col_opt,
        'CELL' TO wl_layout_cond_serv-stylefname. "Se utiliza para grisar los campos del ALV

  "Agregamos los campos que van a ser solo lectura (NO editables en la salida del ALV, pero si editables si se agrega un nuevo registro).
  wl_campos_clave-campo_clave = 'CONTRNUM'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'CODIGO'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'PORC_DESDE'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.
  wl_campos_clave-campo_clave = 'PORC_HASTA'.
  APPEND wl_campos_clave TO tl_campos_clave.
  CLEAR wl_campos_clave.

* Setea los campos claves del ALV como de SOLO LECTURA (grisados)
  LOOP AT t_TABLA_DB_4_alv INTO wl_TABLA_DB_4.
    vl_index = sy-tabix.
    REFRESH lt_celltab.
    PERFORM grisar_campo USING tl_campos_clave
                         CHANGING lt_celltab.

    IF wl_TABLA_DB_4-cell IS INITIAL.
      INSERT LINES OF lt_celltab INTO TABLE wl_TABLA_DB_4-cell.
    ENDIF.
    MODIFY t_TABLA_DB_4_alv  FROM wl_TABLA_DB_4  INDEX vl_index.
  ENDLOOP.

  " Creación de objeto para manejar los eventos
  CREATE OBJECT ol_event_handler_cond_serv.

  SET HANDLER ol_event_handler_cond_serv->handle_user_command FOR o_alv_botones.
  SET HANDLER ol_event_handler_cond_serv->handle_data_changed FOR o_alv_botones.

  "Activamos el enter para disparar eventos
  CALL METHOD o_alv_botones->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  "Desactivo el log de errores al añadir un nuevo registro
*  o_alv_botones->activate_display_protocol( space ).

  CALL METHOD o_alv_botones->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  " Se llama al método para mostrar el ALV
  CALL METHOD o_alv_botones->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_layout_cond_serv
      it_toolbar_excluding          = tl_exclude_cond_serv
    CHANGING
      it_outtab                     = t_TABLA_DB_4_alv
      it_fieldcatalog               = tl_fieldcat_cond_serv
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.


FORM crear_obj_alv_botones.

  "Creo el objeto del container(Dynpro)
  CREATE OBJECT o_alv_container_botones
    EXPORTING
      container_name              = 'CC_ALV2'
      lifetime                    = cntl_lifetime_dynpro "Para que el objeto se desintancie al salir de la pantalla.
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "Creo la relacion entre mi objeto alv y el container creado anteriormente
  CREATE OBJECT o_alv_botones
    EXPORTING
      i_parent          = o_alv_container_botones
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
FORM agregar_titulo_alv_buttons.

  IF v_bonif EQ 'X'.
    SET TITLEBAR 'TIT_DESC_Y_BONIF'.

  ELSEIF v_plaz_topes EQ'X'.
    SET TITLEBAR 'TIT_PLAZ_TOP'.

  ELSEIF v_ac_dan EQ'X'.
    SET TITLEBAR 'TIT_AC_DAN'.

  ELSEIF v_desc_esp EQ'X'.
    SET TITLEBAR 'TIT_DESC_ESP'.

  ELSEIF v_ap_precio EQ 'X'.
    SET TITLEBAR 'TIT_AP_PRECIO'.

  ELSEIF v_cond_serv EQ 'X'.
    SET TITLEBAR 'TIT_COND_SERV'.

  ENDIF.

ENDFORM.
FORM bloquear_tablas.

  CALL FUNCTION 'ENQUEUE_EZ_TABLA_DB_1'
    EXPORTING
      mode_TABLA_DB_1 = 'E'
      mandt          = sy-mandt
      contrnum       = p_cntrum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CONCATENATE TEXT-002 p_cntrum TEXT-003 sy-msgv1
    INTO v_mensaje SEPARATED BY space.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_TABLA_DB_2'
    EXPORTING
      mode_TABLA_DB_2 = 'E'
      mandt          = sy-mandt
      contrnum       = p_cntrum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CONCATENATE TEXT-002 p_cntrum TEXT-003 sy-msgv1
    INTO v_mensaje SEPARATED BY space.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_TABLA_DB_3'
    EXPORTING
      mode_TABLA_DB_3 = 'E'
      mandt          = sy-mandt
      contrnum       = p_cntrum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CONCATENATE TEXT-002 p_cntrum TEXT-003 sy-msgv1
    INTO v_mensaje SEPARATED BY space.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_TABLA_DB_7'
    EXPORTING
      mode_TABLA_DB_7 = 'E'
      mandt          = sy-mandt
      contrnum       = p_cntrum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CONCATENATE TEXT-002 p_cntrum TEXT-003 sy-msgv1
    INTO v_mensaje SEPARATED BY space.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_TABLA_DB_4'
    EXPORTING
      mode_TABLA_DB_4 = 'E'
      mandt          = sy-mandt
      contrnum       = p_cntrum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CONCATENATE TEXT-002 p_cntrum TEXT-003 sy-msgv1
    INTO v_mensaje SEPARATED BY space.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_TABLA_DB_6'
    EXPORTING
      mode_TABLA_DB_6 = 'E'
      mandt          = sy-mandt
      contrnum       = p_cntrum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CONCATENATE TEXT-002 p_cntrum TEXT-003 sy-msgv1
    INTO v_mensaje SEPARATED BY space.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_TABLA_DB_4'
    EXPORTING
      mode_TABLA_DB_4 = 'E'
      mandt          = sy-mandt
      contrnum       = p_cntrum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CONCATENATE TEXT-002 p_cntrum TEXT-003 sy-msgv1
    INTO v_mensaje SEPARATED BY space.
    EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GRISAR_CAMPO
*&---------------------------------------------------------------------*
FORM grisar_campo  USING  pt_campos_clave TYPE tyt_tabla_campos_clave
                   CHANGING pt_celltab TYPE lvc_t_styl.

  DATA: ls_celltab      TYPE lvc_s_styl,     "Estructura de la tabla de celdas
        l_mode          TYPE raw4,           "Modo (grisado, editable)
        wl_campos_clave TYPE ty_campo_clave. "Work area para la tabla de campos clave

*   l_mode = cl_gui_alv_grid=>mc_style_enabled.
  l_mode = cl_gui_alv_grid=>mc_style_disabled. "Inhabilitado para edicion.

  LOOP AT pt_campos_clave INTO  wl_campos_clave.
    ls_celltab-fieldname = wl_campos_clave-campo_clave.
    ls_celltab-style = l_mode.
    INSERT ls_celltab INTO TABLE pt_celltab.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LOG_TABLA_DB_1
*&---------------------------------------------------------------------*
FORM log_TABLA_DB_1 USING er_data_changed TYPE REF TO cl_alv_changed_data_protocol."Tipo del objeto instanciado en el evento data changed

  DATA: wl_data_changed  TYPE lvc_s_modi, " Valor de los datos cambiados
        wl_DB1         TYPE ty_TABLA_DB_1,      " TABLA_DB_1
        wl_log_zmptLOG1 TYPE zmptLOG1. " Log
  DATA: vl_nombre_campo_anterior TYPE string.


  DATA: tl_DB1 TYPE STANDARD TABLE OF TABLA_DB_1. " TABLA_DB_1

  FIELD-SYMBOLS:
    <fsl_mod_rows_DB1>    TYPE ty_TABLA_DB_1.   "Se asigna a <fsl_mod_rows_standard>

  ASSIGN er_data_changed->mp_mod_rows->* TO <fs_mod_rows_standard>. "Se asigna al FS el tipo tabla

  IF <fs_mod_rows_standard> IS ASSIGNED AND <fs_mod_rows_standard> IS NOT INITIAL.

    READ TABLE  <fs_mod_rows_standard> ASSIGNING <fsl_mod_rows_DB1> INDEX 1. "Se asigna el FS con la tabla a mi tipo TABLA_DB_1
    IF sy-subrc EQ 0.
      READ TABLE er_data_changed->mt_good_cells INTO wl_data_changed INDEX 1. "Obtenemos los datos del campo modificado y el nuevo valor del mismo
    ENDIF.

    IF sy-subrc EQ 0.
      READ TABLE t_TABLA_DB_1_alv INTO wl_DB1 WITH KEY contrnum = <fsl_mod_rows_DB1>-contrnum. "Obtenemos el valor del registro completo sin modificar
    ENDIF.

    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_data_changed TO <fs_nombre_campo>. "Asignamos el nombre del campo modificado a <fsl_nombre_campo>
    ENDIF.

    IF <fs_nombre_campo> IS ASSIGNED.
      ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE wl_DB1 TO <fs_valor_anterior>.          "Valor anterior
      ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_mod_rows_DB1> TO <fs_valor_nuevo>. "Nuevo valor

      "Armo el log
      wl_log_zmptLOG1-valor_anterior = <fs_valor_anterior>.
      wl_log_zmptLOG1-valor_nuevo    = wl_data_changed-value.
      wl_log_zmptLOG1-contrnum       = wl_DB1-contrnum.
      wl_log_zmptLOG1-fieldname      = <fs_nombre_campo>.
      wl_log_zmptLOG1-udate          = sy-datum.
      wl_log_zmptLOG1-utime          = sy-uzeit.
      wl_log_zmptLOG1-mandt          = sy-mandt.
      wl_log_zmptLOG1-username       = sy-uname.
      wl_log_zmptLOG1-motivo         = p_motivo.
      wl_log_zmptLOG1-tcode          = 'TR'.

      CONDENSE wl_log_zmptLOG1-valor_anterior. "Borrado de espacios
      CONDENSE wl_log_zmptLOG1-valor_nuevo.    "Borrado de espacios

      " Si es la primer modificacion que se raliza
      IF t_log_zmptLOG1 IS INITIAL.

        APPEND wl_log_zmptLOG1 TO t_log_zmptLOG1.
        t_TABLA_DB_1_alv_aux[] =  t_TABLA_DB_1_alv.

        " Si la tabla ya cuenta con modificaciones
      ELSE.

        "Verifico si el nombre del campo a modificar ya se encuentra en la tabla de log
        LOOP AT t_log_zmptLOG1 INTO DATA(wl_LOG1).
          IF wl_LOG1-fieldname EQ <fs_nombre_campo>.
            DATA(vl_existe_registro) = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.

        "Si existe piso el registro por el nombre del campo
        IF vl_existe_registro EQ 'X'.

          UNASSIGN <fs_valor_anterior>.

          "Leemos el valor limpio levantado de la DB DB1
          READ TABLE t_TABLA_DB_1 INTO DATA(wl_DB1_db) WITH KEY contrnum = p_cntrum.
          ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE wl_DB1_db TO <fs_valor_anterior>.

          "Guardo el valor inicial obtenido al traer los datos de DB DB1 en el log
          wl_log_zmptLOG1-valor_anterior = <fs_valor_anterior>.
          CONDENSE wl_log_zmptLOG1-valor_anterior.

          CLEAR: wl_LOG1, vl_existe_registro.

          "Se realiza una modificacion al log donde haya coincidencia en FIELDNAME
          LOOP AT t_log_zmptLOG1 INTO wl_LOG1.
            IF wl_LOG1-fieldname = <fs_nombre_campo>.
              MODIFY t_log_zmptLOG1 FROM wl_log_zmptLOG1 INDEX sy-tabix.
            ENDIF.
          ENDLOOP.

          "Si no existe el registro en la tabla de LOG se hace un APPEND a la misma
        ELSE.

          APPEND wl_log_zmptLOG1 TO t_log_zmptLOG1.

        ENDIF.

      ENDIF.

      CLEAR wl_log_zmptLOG1.

      UNASSIGN: <fs_mod_rows_standard>, <fsl_mod_rows_DB1>,
                <fs_nombre_campo>, <fs_valor_anterior>, <fs_valor_nuevo>.

    ENDIF.
  ENDIF.

ENDFORM.

FORM actualizar_TABLA_DB_1.

  DATA: tl_TABLA_DB_1_aux TYPE STANDARD TABLE OF TABLA_DB_1.

  tl_TABLA_DB_1_aux[] = t_TABLA_DB_1[].

  MOVE-CORRESPONDING t_TABLA_DB_1_alv TO t_TABLA_DB_1.

  IF sy-subrc EQ 0.
    MODIFY TABLA_DB_1 FROM TABLE t_TABLA_DB_1.

    IF sy-subrc EQ 0.

      INSERT zmptLOG1 FROM TABLE t_log_zmptLOG1.

      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        t_TABLA_DB_1 = tl_TABLA_DB_1_aux[].
        ROLLBACK WORK.
      ENDIF.

    ELSE.
      t_TABLA_DB_1 = tl_TABLA_DB_1_aux[].
      ROLLBACK WORK.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GUARDO_TABLA_DB_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM guardo_TABLA_DB_2 USING  er_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: wl_data_changed TYPE lvc_s_modi,    " Valor de los datos cambiados
        wl_DB2        TYPE ty_TABLA_DB_2,  " TABLA_DB_2
        wl_DB2_aux    TYPE ty_TABLA_DB_2,  " TABLA_DB_2
        wl_deleted_rows TYPE lvc_s_moce,    " Registros eliminados
        wl_fieldcat_aux TYPE lvc_s_fcat.    " Nombre de los campos

  DATA: tl_DB2         TYPE STANDARD TABLE OF TABLA_DB_2. " TABLA_DB_2

  FIELD-SYMBOLS:
    <fsl_mod_rows_DB2>    TYPE ty_TABLA_DB_2.   "Se asigna a <fsl_mod_rows_standard>

  UNASSIGN: <fs_mod_rows_standard>.

  " Guardo el nombre de todos los campos del ALV en la tabla t_fieldcat_aux, esta misma se utiliza posteriormente en la ejecución del programa.
  IF t_fieldcat_aux IS INITIAL.
    LOOP AT er_data_changed->mt_fieldcatalog INTO  wl_fieldcat_aux.
      APPEND wl_fieldcat_aux TO t_fieldcat_aux.
    ENDLOOP.
  ENDIF.

  ASSIGN er_data_changed->mp_mod_rows->* TO <fs_mod_rows_standard>. "Se asigna al FS el tipo tabla

  " Situacion ---> Modificación / Nuevo registro
  IF <fs_mod_rows_standard> IS ASSIGNED AND <fs_mod_rows_standard> IS NOT INITIAL.

    READ TABLE  <fs_mod_rows_standard> ASSIGNING <fsl_mod_rows_DB2> INDEX 1. "Se asigna el FS con la tabla a mi tipo TABLA_DB_2

    IF sy-subrc EQ 0.
      "Si no cuenta con clave completa esta modificacion corresponde a NUEVO registro que aun NO esta completo, entonces se ignora.
      IF <fsl_mod_rows_DB2>-contrnum     IS NOT INITIAL AND
         <fsl_mod_rows_DB2>-fedesde      IS INITIAL OR
         <fsl_mod_rows_DB2>-fehasta      IS INITIAL OR
         <fsl_mod_rows_DB2>-tipo_periodo IS INITIAL OR
         <fsl_mod_rows_DB2>-tipo_db      IS INITIAL.

        EXIT.

        "Si cuenta con clave completa
      ELSE.

        "Se valida que no exista clave duplicada
        READ TABLE er_data_changed->mt_good_cells INTO wl_data_changed INDEX 1. "Obtenemos los datos del campo modificado y el nuevo valor del mismo

        IF wl_data_changed IS NOT INITIAL.

          LOOP AT t_TABLA_DB_2_alv INTO DATA(DB2_alv_aux) WHERE contrnum     EQ <fsl_mod_rows_DB2>-contrnum     AND
                                                                 fedesde      EQ <fsl_mod_rows_DB2>-fedesde      AND
                                                                 fehasta      EQ <fsl_mod_rows_DB2>-fehasta      AND
                                                                 tipo_periodo EQ <fsl_mod_rows_DB2>-tipo_periodo AND
                                                                 tipo_db      EQ <fsl_mod_rows_DB2>-tipo_db.
            IF sy-tabix NE wl_data_changed-row_id.
              v_duplicados = 'X'.
              EXIT.
            ENDIF.

          ENDLOOP.

        ENDIF.

        "Si existe clave duplicada salimos de la ejecucion de la rutina y no se appendea ninguna modificación a las tabla correspondiente.
        IF v_duplicados EQ 'X'.
          EXIT.
        ENDIF.

        "Si se valido que NO existe clave duplicada entonces verifico si el registro existe en la tabla de modificaciones
        LOOP AT t_DB2_mod INTO DATA(wl_DB2_mod).

          IF wl_DB2_mod-contrnum     EQ <fsl_mod_rows_DB2>-contrnum     AND
             wl_DB2_mod-fedesde      EQ <fsl_mod_rows_DB2>-fedesde      AND
             wl_DB2_mod-fehasta      EQ <fsl_mod_rows_DB2>-fehasta      AND
             wl_DB2_mod-tipo_periodo EQ <fsl_mod_rows_DB2>-tipo_periodo AND
             wl_DB2_mod-tipo_db      EQ <fsl_mod_rows_DB2>-tipo_db.

            DATA(vl_existe_registro) = 'X'.

            EXIT.

          ENDIF.
        ENDLOOP.

        "Si existe piso el registro de la tabla de modificaciones.
        IF vl_existe_registro EQ 'X'.

          UNASSIGN: <fs_valor_anterior>, <fs_nombre_campo>, <fs_valor_nuevo>.

          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_data_changed TO <fs_nombre_campo>.
          ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_mod_rows_DB2> TO <fs_valor_nuevo>.

          CLEAR: wl_DB2_mod, vl_existe_registro.

          LOOP AT t_DB2_mod INTO wl_DB2_mod.

            IF wl_DB2_mod-contrnum         EQ <fsl_mod_rows_DB2>-contrnum     AND
                   wl_DB2_mod-fedesde      EQ <fsl_mod_rows_DB2>-fedesde      AND
                   wl_DB2_mod-fehasta      EQ <fsl_mod_rows_DB2>-fehasta      AND
                   wl_DB2_mod-tipo_periodo EQ <fsl_mod_rows_DB2>-tipo_periodo AND
                   wl_DB2_mod-tipo_db      EQ <fsl_mod_rows_DB2>-tipo_db.

              MODIFY t_DB2_mod FROM <fsl_mod_rows_DB2> INDEX sy-tabix.

            ENDIF.

          ENDLOOP.

          "Si no existe se hace un APPEND del registro a la tabla de modificaciónes.
        ELSE.
          APPEND <fsl_mod_rows_DB2> TO t_DB2_mod.

        ENDIF.
      ENDIF.
    ENDIF.

    " Situacion ---> Borrado de registro
  ELSE.
    LOOP AT er_data_changed->mt_deleted_rows INTO wl_deleted_rows.

      READ TABLE t_TABLA_DB_2_alv INDEX wl_deleted_rows-row_id INTO wl_DB2.

      IF sy-subrc = 0.
        APPEND wl_DB2 TO t_DB2_del.
      ENDIF.
      CLEAR wl_DB2.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZO_TABLA_DB_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizo_TABLA_DB_2.

  DATA: tl_TABLA_DB_2_duplicados TYPE STANDARD TABLE OF ty_TABLA_DB_2.

  DATA:
    wl_fieldsname     TYPE lvc_s_fcat,
    wl_log_       TYPE zmptLOG,
    tl_TABLA_DB_2      TYPE STANDARD TABLE OF TABLA_DB_2,
    vl_secuencia(003) TYPE n VALUE 001.

  UNASSIGN: <fs_nombre_campo>, <fs_valor_anterior>, <fs_valor_nuevo>.

  " verifico que no hallan duplicados
  tl_TABLA_DB_2_duplicados[] = t_TABLA_DB_2_alv[].

  DELETE ADJACENT DUPLICATES FROM tl_TABLA_DB_2_duplicados COMPARING contrnum fedesde fehasta tipo_periodo tipo_db.

  IF sy-subrc EQ 0.
    v_duplicados = 'X'.
    REFRESH tl_TABLA_DB_2_duplicados.

    EXIT.
  ENDIF.

  "Armado de log.
  LOOP AT t_DB2_mod INTO DATA(wl_DB2_mod).

    READ TABLE t_TABLA_DB_2 INTO DATA(wl_DB2) WITH KEY contrnum = wl_DB2_mod-contrnum
                                                        fedesde = wl_DB2_mod-fedesde
                                                        fehasta = wl_DB2_mod-fehasta
                                                        tipo_periodo = wl_DB2_mod-tipo_periodo
                                                        tipo_db = wl_DB2_mod-tipo_db.

*    "Log modificado
    IF sy-subrc EQ 0.

      PERFORM armo_log_zmptLOG USING wl_DB2 wl_DB2_mod t_DB2_del 'M' 'TABLA_DB_2' vl_secuencia 'DESC_BONIF_SUST'.
      vl_secuencia = vl_secuencia + 1.

      " Log registro nuevo
    ELSE.

      READ TABLE t_TABLA_DB_2_alv INTO DATA(wl_DB2_alv) WITH KEY contrnum = wl_DB2_mod-contrnum
                                                                  fedesde = wl_DB2_mod-fedesde
                                                                  fehasta = wl_DB2_mod-fehasta
                                                                  tipo_periodo = wl_DB2_mod-tipo_periodo
                                                                  tipo_db = wl_DB2_mod-tipo_db.
      IF sy-subrc EQ 0.
        PERFORM armo_log_zmptLOG USING wl_DB2 wl_DB2_mod t_DB2_del 'N' 'TABLA_DB_2' vl_secuencia 'DESC_BONIF_SUST'.
        vl_secuencia = vl_secuencia + 1.
      ENDIF.

    ENDIF.

  ENDLOOP.

  " Log borrado
  IF t_DB2_del IS NOT INITIAL.

    PERFORM armo_log_zmptLOG USING wl_DB2 wl_DB2_mod t_DB2_del 'B' 'TABLA_DB_2' vl_secuencia 'DESC_BONIF_SUST'.
    vl_secuencia = vl_secuencia + 1.

  ENDIF.

  CLEAR vl_secuencia.

  MOVE-CORRESPONDING t_TABLA_DB_2_alv TO tl_TABLA_DB_2.

  IF tl_TABLA_DB_2 IS NOT INITIAL.

    MODIFY TABLA_DB_2 FROM TABLE tl_TABLA_DB_2.

    IF sy-subrc EQ 0.
      REFRESH tl_TABLA_DB_2.
      MOVE-CORRESPONDING t_DB2_del TO tl_TABLA_DB_2.

      IF sy-subrc EQ 0.
        DELETE TABLA_DB_2 FROM TABLE tl_TABLA_DB_2.

        IF sy-subrc EQ 0.
          INSERT zmptLOG FROM TABLE t_log_zmptLOG.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.

          ELSE.
            t_TABLA_DB_2_alv = t_TABLA_DB_2_alv_aux[].
            ROLLBACK WORK.

          ENDIF.

        ELSE.
          t_TABLA_DB_2_alv = t_TABLA_DB_2_alv_aux[].
          ROLLBACK WORK.

        ENDIF.

      ELSE.
        t_TABLA_DB_2_alv = t_TABLA_DB_2_alv_aux[].
        ROLLBACK WORK.

      ENDIF.

    ELSE.
      t_TABLA_DB_2_alv = t_TABLA_DB_2_alv_aux[].
      ROLLBACK WORK.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GUARDO_TABLA_DB_7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM guardo_TABLA_DB_7 USING  er_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: wl_data_changed TYPE lvc_s_modi,    " Valor de los datos cambiados
        wl_e3970        TYPE ty_TABLA_DB_7,  " TABLA_DB_7
        wl_e3970_aux    TYPE ty_TABLA_DB_7,  " TABLA_DB_7
        wl_deleted_rows TYPE lvc_s_moce,    " Registros eliminados
        wl_fieldcat_aux TYPE lvc_s_fcat.    " Nombre de los campos

  FIELD-SYMBOLS:
    <fsl_mod_rows_e3970>    TYPE ty_TABLA_DB_7.   "Se asigna a <fsl_mod_rows_standard>

  UNASSIGN: <fs_mod_rows_standard>.

  " Guardo el nombre de todos los campos del ALV en la tabla t_fieldcat_aux, esta misma se utiliza posteriormente en la ejecución del programa.
  IF t_fieldcat_aux IS INITIAL.
    LOOP AT er_data_changed->mt_fieldcatalog INTO  wl_fieldcat_aux.
      APPEND wl_fieldcat_aux TO t_fieldcat_aux.
    ENDLOOP.
  ENDIF.

  ASSIGN er_data_changed->mp_mod_rows->* TO <fs_mod_rows_standard>. "Se asigna al FS el tipo tabla

  " Situacion ---> Modificación / Nuevo registro
  IF <fs_mod_rows_standard> IS ASSIGNED AND <fs_mod_rows_standard> IS NOT INITIAL.

    READ TABLE  <fs_mod_rows_standard> ASSIGNING <fsl_mod_rows_e3970> INDEX 1. "Se asigna el FS con la tabla a mi tipo TABLA_DB_2

    IF sy-subrc EQ 0.
      "Si no cuenta con clave completa esta modificacion corresponde a NUEVO registro que aun NO esta completo, entonces se ignora.
      IF <fsl_mod_rows_e3970>-contrnum   IS NOT INITIAL AND
         <fsl_mod_rows_e3970>-codigo     IS INITIAL OR
*        <fsl_mod_rows_e3970>-porc_desde IS INITIAL OR " Puede ser 0
         <fsl_mod_rows_e3970>-porc_hasta IS INITIAL.

        EXIT.

        "Si cuenta con clave completa
      ELSE.

        "Se valida que no exista clave duplicada
        READ TABLE er_data_changed->mt_good_cells INTO wl_data_changed INDEX 1. "Obtenemos los datos del campo modificado y el nuevo valor del mismo

        IF wl_data_changed IS NOT INITIAL.

          LOOP AT t_TABLA_DB_7_alv INTO DATA(e3970_alv_aux) WHERE contrnum   EQ <fsl_mod_rows_e3970>-contrnum   AND
                                                                 codigo     EQ <fsl_mod_rows_e3970>-codigo     AND
                                                                 porc_desde EQ <fsl_mod_rows_e3970>-porc_desde AND
                                                                 porc_hasta EQ <fsl_mod_rows_e3970>-porc_hasta.
            IF sy-tabix NE wl_data_changed-row_id.
              v_duplicados = 'X'.
              EXIT.
            ENDIF.

          ENDLOOP.

        ENDIF.

        "Si existe clave duplicada salimos de la ejecucion de la rutina y no se appendea ninguna modificación a las tabla correspondiente.
        IF v_duplicados EQ 'X'.
          EXIT.
        ENDIF.

        "Si se valido que NO existe clave duplicada entonces verifico si el registro existe en la tabla de modificaciones
        LOOP AT t_e3970_mod INTO DATA(wl_e3970_mod).

          IF wl_e3970_mod-contrnum   EQ <fsl_mod_rows_e3970>-contrnum   AND
             wl_e3970_mod-codigo     EQ <fsl_mod_rows_e3970>-codigo     AND
             wl_e3970_mod-porc_desde EQ <fsl_mod_rows_e3970>-porc_desde AND
             wl_e3970_mod-porc_hasta EQ <fsl_mod_rows_e3970>-porc_hasta.

            DATA(vl_existe_registro) = 'X'.

            EXIT.

          ENDIF.
        ENDLOOP.

        "Si existe piso el registro de la tabla de modificaciones.
        IF vl_existe_registro EQ 'X'.

          UNASSIGN: <fs_valor_anterior>, <fs_nombre_campo>, <fs_valor_nuevo>.

          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_data_changed TO <fs_nombre_campo>.
          ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_mod_rows_e3970> TO <fs_valor_nuevo>.

          CLEAR: wl_e3970_mod, vl_existe_registro.

          LOOP AT t_e3970_mod INTO wl_e3970_mod.

            IF wl_e3970_mod-contrnum   EQ <fsl_mod_rows_e3970>-contrnum   AND
               wl_e3970_mod-codigo     EQ <fsl_mod_rows_e3970>-codigo     AND
               wl_e3970_mod-porc_desde EQ <fsl_mod_rows_e3970>-porc_desde AND
               wl_e3970_mod-porc_hasta EQ <fsl_mod_rows_e3970>-porc_hasta.

              MODIFY t_e3970_mod FROM <fsl_mod_rows_e3970> INDEX sy-tabix.

            ENDIF.

          ENDLOOP.

          "Si no existe se hace un APPEND del registro a la tabla de modificaciónes.
        ELSE.
          APPEND <fsl_mod_rows_e3970> TO t_e3970_mod.

        ENDIF.
      ENDIF.
    ENDIF.

    " Situacion ---> Borrado de registro
  ELSE.
    LOOP AT er_data_changed->mt_deleted_rows INTO wl_deleted_rows.

      READ TABLE t_TABLA_DB_7_alv INDEX wl_deleted_rows-row_id INTO wl_e3970.

      IF sy-subrc = 0.
        APPEND wl_e3970 TO t_e3970_del.
      ENDIF.
      CLEAR wl_e3970.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZO_TABLA_DB_7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizo_TABLA_DB_7.

  DATA: tl_TABLA_DB_7_duplicados TYPE STANDARD TABLE OF ty_TABLA_DB_7.

  DATA:
    wl_fieldsname     TYPE lvc_s_fcat,
    wl_log_       TYPE zmptLOG,
    tl_TABLA_DB_7      TYPE STANDARD TABLE OF TABLA_DB_7,
    vl_secuencia(003) TYPE n VALUE 001.

  UNASSIGN: <fs_nombre_campo>, <fs_valor_anterior>, <fs_valor_nuevo>.

  " verifico que no hallan duplicados
  tl_TABLA_DB_7_duplicados[] = t_TABLA_DB_7_alv[].

  DELETE ADJACENT DUPLICATES FROM tl_TABLA_DB_7_duplicados COMPARING contrnum codigo porc_desde porc_hasta.

  IF sy-subrc EQ 0.
    v_duplicados = 'X'.
    REFRESH tl_TABLA_DB_7_duplicados.

    EXIT.
  ENDIF.

  "Armado de log.
  LOOP AT t_e3970_mod INTO DATA(wl_e3970_mod).

    READ TABLE t_TABLA_DB_7 INTO DATA(wl_e3970) WITH KEY contrnum   = wl_e3970_mod-contrnum
                                                        codigo     = wl_e3970_mod-codigo
                                                        porc_desde = wl_e3970_mod-porc_desde
                                                        porc_hasta = wl_e3970_mod-porc_hasta.

*    "Log modificado
    IF sy-subrc EQ 0.

      PERFORM armo_log_zmptLOG USING wl_e3970 wl_e3970_mod t_e3970_del 'M' 'TABLA_DB_7' vl_secuencia 'ACT_DAN'.
      vl_secuencia = vl_secuencia + 1.

      " Log registro nuevo
    ELSE.

      READ TABLE t_TABLA_DB_7_alv INTO DATA(wl_e3970_alv) WITH KEY contrnum   = wl_e3970_mod-contrnum
                                                                  codigo     = wl_e3970_mod-codigo
                                                                  porc_desde = wl_e3970_mod-porc_desde
                                                                  porc_hasta = wl_e3970_mod-porc_hasta.
      IF sy-subrc EQ 0.

        PERFORM armo_log_zmptLOG USING wl_e3970 wl_e3970_mod t_e3970_del 'N' 'TABLA_DB_7' vl_secuencia 'ACT_DAN'.
        vl_secuencia = vl_secuencia + 1.

      ENDIF.

    ENDIF.

  ENDLOOP.

  " Log borrado
  IF t_e3970_del IS NOT INITIAL.

    PERFORM armo_log_zmptLOG USING wl_e3970 wl_e3970_mod t_e3970_del 'B' 'TABLA_DB_7' vl_secuencia 'ACT_DAN'.
    vl_secuencia = vl_secuencia + 1.

  ENDIF.

  CLEAR vl_secuencia.

  MOVE-CORRESPONDING t_TABLA_DB_7_alv TO tl_TABLA_DB_7.

  IF sy-subrc EQ 0.

    MODIFY TABLA_DB_7 FROM TABLE tl_TABLA_DB_7.

    IF sy-subrc EQ 0.
      REFRESH tl_TABLA_DB_7.
      MOVE-CORRESPONDING t_e3970_del TO tl_TABLA_DB_7.

      IF sy-subrc EQ 0.
        DELETE TABLA_DB_7 FROM TABLE tl_TABLA_DB_7.

        IF sy-subrc EQ 0.
          INSERT zmptLOG FROM TABLE t_log_zmptLOG.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.

          ELSE.
            t_TABLA_DB_7_alv = t_TABLA_DB_7_alv_aux[].
            ROLLBACK WORK.

          ENDIF.

        ELSE.
          t_TABLA_DB_7_alv = t_TABLA_DB_7_alv_aux[].
          ROLLBACK WORK.

        ENDIF.

      ELSE.
        t_TABLA_DB_7_alv = t_TABLA_DB_7_alv_aux[].
        ROLLBACK WORK.

      ENDIF.

    ELSE.
      t_TABLA_DB_7_alv = t_TABLA_DB_7_alv_aux[].
      ROLLBACK WORK.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GUARDO_TABLA_DB_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM guardo_TABLA_DB_4 USING  er_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: wl_data_changed TYPE lvc_s_modi,    " Valor de los datos cambiados
        wl_DB4        TYPE ty_TABLA_DB_4,  " TABLA_DB_4
        wl_DB4_aux    TYPE ty_TABLA_DB_4,  " TABLA_DB_4
        wl_deleted_rows TYPE lvc_s_moce,    " Registros eliminados
        wl_fieldcat_aux TYPE lvc_s_fcat.    " Nombre de los campos

  FIELD-SYMBOLS:
    <fsl_mod_rows_DB4>    TYPE ty_TABLA_DB_4.   "Se asigna a <fsl_mod_rows_standard>

  UNASSIGN: <fs_mod_rows_standard>.

  " Guardo el nombre de todos los campos del ALV en la tabla t_fieldcat_aux, esta misma se utiliza posteriormente en la ejecución del programa.
  IF t_fieldcat_aux IS INITIAL.
    LOOP AT er_data_changed->mt_fieldcatalog INTO  wl_fieldcat_aux.
      APPEND wl_fieldcat_aux TO t_fieldcat_aux.
    ENDLOOP.
  ENDIF.

  ASSIGN er_data_changed->mp_mod_rows->* TO <fs_mod_rows_standard>. "Se asigna al FS el tipo tabla

  " Situacion ---> Modificación / Nuevo registro
  IF <fs_mod_rows_standard> IS ASSIGNED AND <fs_mod_rows_standard> IS NOT INITIAL.

    READ TABLE  <fs_mod_rows_standard> ASSIGNING <fsl_mod_rows_DB4> INDEX 1. "Se asigna el FS con la tabla a mi tipo TABLA_DB_2

    IF sy-subrc EQ 0.
      "Si no cuenta con clave completa esta modificacion corresponde a NUEVO registro que aun NO esta completo, entonces se ignora.
      IF <fsl_mod_rows_DB4>-contrnum   IS NOT INITIAL AND
         <fsl_mod_rows_DB4>-codigo     IS INITIAL OR
*         <fsl_mod_rows_DB4>-porc_desde IS INITIAL OR " Puede ser 0
         <fsl_mod_rows_DB4>-porc_hasta IS INITIAL.

        EXIT.

        "Si cuenta con clave completa
      ELSE.

        "Se valida que no exista clave duplicada
        READ TABLE er_data_changed->mt_good_cells INTO wl_data_changed INDEX 1. "Obtenemos los datos del campo modificado y el nuevo valor del mismo

        IF wl_data_changed IS NOT INITIAL.

          LOOP AT t_TABLA_DB_4_alv INTO DATA(DB4_alv_aux) WHERE contrnum   EQ <fsl_mod_rows_DB4>-contrnum   AND
                                                                 codigo     EQ <fsl_mod_rows_DB4>-codigo     AND
                                                                 porc_desde EQ <fsl_mod_rows_DB4>-porc_desde AND
                                                                 porc_hasta EQ <fsl_mod_rows_DB4>-porc_hasta.
            IF sy-tabix NE wl_data_changed-row_id.
              v_duplicados = 'X'.
              EXIT.
            ENDIF.

          ENDLOOP.

        ENDIF.
        "Si existe clave duplicada salimos de la ejecucion de la rutina y no se appendea ninguna modificación a las tabla correspondiente.
        IF v_duplicados EQ 'X'.
          EXIT.
        ENDIF.

        "Si se valido que NO existe clave duplicada entonces verifico si el registro existe en la tabla de modificaciones
        LOOP AT t_DB4_mod INTO DATA(wl_DB4_mod).

          IF wl_DB4_mod-contrnum   EQ <fsl_mod_rows_DB4>-contrnum   AND
             wl_DB4_mod-codigo     EQ <fsl_mod_rows_DB4>-codigo     AND
             wl_DB4_mod-porc_desde EQ <fsl_mod_rows_DB4>-porc_desde AND
             wl_DB4_mod-porc_hasta EQ <fsl_mod_rows_DB4>-porc_hasta.

            DATA(vl_existe_registro) = 'X'.

            EXIT.

          ENDIF.
        ENDLOOP.

        "Si existe piso el registro de la tabla de modificaciones.
        IF vl_existe_registro EQ 'X'.

          UNASSIGN: <fs_valor_anterior>, <fs_nombre_campo>, <fs_valor_nuevo>.

          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_data_changed TO <fs_nombre_campo>.
          ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_mod_rows_DB4> TO <fs_valor_nuevo>.

          CLEAR: wl_DB4_mod, vl_existe_registro.

          LOOP AT t_DB4_mod INTO wl_DB4_mod.

            IF wl_DB4_mod-contrnum   EQ <fsl_mod_rows_DB4>-contrnum   AND
               wl_DB4_mod-codigo     EQ <fsl_mod_rows_DB4>-codigo     AND
               wl_DB4_mod-porc_desde EQ <fsl_mod_rows_DB4>-porc_desde AND
               wl_DB4_mod-porc_hasta EQ <fsl_mod_rows_DB4>-porc_hasta.

              MODIFY t_DB4_mod FROM <fsl_mod_rows_DB4> INDEX sy-tabix.

            ENDIF.

          ENDLOOP.

          "Si no existe se hace un APPEND del registro a la tabla de modificaciónes.
        ELSE.
          APPEND <fsl_mod_rows_DB4> TO t_DB4_mod.

        ENDIF.
      ENDIF.
    ENDIF.

    " Situacion ---> Borrado de registro
  ELSE.
    LOOP AT er_data_changed->mt_deleted_rows INTO wl_deleted_rows.

      READ TABLE t_TABLA_DB_4_alv INDEX wl_deleted_rows-row_id INTO wl_DB4.

      IF sy-subrc = 0.
        APPEND wl_DB4 TO t_DB4_del.
      ENDIF.
      CLEAR wl_DB4.

    ENDLOOP.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ACTUALIZO_TABLA_DB_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizo_TABLA_DB_4.

  DATA: tl_TABLA_DB_4_duplicados TYPE STANDARD TABLE OF ty_TABLA_DB_4.

  DATA:
    wl_fieldsname     TYPE lvc_s_fcat,
    wl_log_       TYPE zmptLOG,
    tl_TABLA_DB_4      TYPE STANDARD TABLE OF TABLA_DB_4,
    vl_secuencia(003) TYPE n VALUE 001.

  UNASSIGN: <fs_nombre_campo>, <fs_valor_anterior>, <fs_valor_nuevo>.

  " verifico que no hallan duplicados
  tl_TABLA_DB_4_duplicados[] = t_TABLA_DB_4_alv[].

  DELETE ADJACENT DUPLICATES FROM tl_TABLA_DB_4_duplicados COMPARING contrnum codigo porc_desde porc_hasta.

  IF sy-subrc EQ 0.
    v_duplicados = 'X'.
    REFRESH tl_TABLA_DB_4_duplicados.
    EXIT.
  ENDIF.

  "Armado de log.
  LOOP AT t_DB4_mod INTO DATA(wl_DB4_mod).

    READ TABLE t_TABLA_DB_4 INTO DATA(wl_DB4) WITH KEY contrnum   = wl_DB4_mod-contrnum
                                                        codigo     = wl_DB4_mod-codigo
                                                        porc_desde = wl_DB4_mod-porc_desde
                                                        porc_hasta = wl_DB4_mod-porc_hasta.

*    "Log modificado
    IF sy-subrc EQ 0.

      PERFORM armo_log_zmptLOG USING wl_DB4 wl_DB4_mod t_DB4_del 'M' 'TABLA_DB_4' vl_secuencia 'DESC_ESP_CALIDAD'.
      vl_secuencia = vl_secuencia + 1.

      " Log registro nuevo
    ELSE.

      READ TABLE t_TABLA_DB_4_alv INTO DATA(wl_DB4_alv) WITH KEY contrnum   = wl_DB4_mod-contrnum
                                                                  codigo     = wl_DB4_mod-codigo
                                                                  porc_desde = wl_DB4_mod-porc_desde
                                                                  porc_hasta = wl_DB4_mod-porc_hasta.
      IF sy-subrc EQ 0.

        PERFORM armo_log_zmptLOG USING wl_DB4 wl_DB4_mod t_DB4_del 'N' 'TABLA_DB_4' vl_secuencia 'DESC_ESP_CALIDAD'.
        vl_secuencia = vl_secuencia + 1.

      ENDIF.

    ENDIF.

  ENDLOOP.

  " Log borrado
  IF t_DB4_del IS NOT INITIAL.

    PERFORM armo_log_zmptLOG USING wl_DB4 wl_DB4_mod t_DB4_del 'B' 'TABLA_DB_4' vl_secuencia 'DESC_ESP_CALIDAD'.
    vl_secuencia = vl_secuencia + 1.

  ENDIF.

  CLEAR vl_secuencia.

  MOVE-CORRESPONDING t_TABLA_DB_4_alv TO tl_TABLA_DB_4.

  IF sy-subrc EQ 0.

    MODIFY TABLA_DB_4 FROM TABLE tl_TABLA_DB_4.

    IF sy-subrc EQ 0.
      REFRESH tl_TABLA_DB_4.
      MOVE-CORRESPONDING t_DB4_del TO tl_TABLA_DB_4.

      IF sy-subrc EQ 0.
        DELETE TABLA_DB_4 FROM TABLE tl_TABLA_DB_4.

        IF sy-subrc EQ 0.
          INSERT zmptLOG FROM TABLE t_log_zmptLOG.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.

          ELSE.
            t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
            ROLLBACK WORK.

          ENDIF.

        ELSE.
          t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
          ROLLBACK WORK.

        ENDIF.

      ELSE.
        t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
        ROLLBACK WORK.

      ENDIF.

    ELSE.
      t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
      ROLLBACK WORK.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GUARDO_TABLA_DB_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM guardo_TABLA_DB_4 USING  er_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: wl_data_changed TYPE lvc_s_modi,    " Valor de los datos cambiados
        wl_DB3        TYPE ty_TABLA_DB_4,  " TABLA_DB_4
        wl_DB3_aux    TYPE ty_TABLA_DB_4,  " TABLA_DB_4
        wl_deleted_rows TYPE lvc_s_moce,    " Registros eliminados
        wl_fieldcat_aux TYPE lvc_s_fcat.    " Nombre de los campos

  FIELD-SYMBOLS:
    <fsl_mod_rows_DB3>    TYPE ty_TABLA_DB_4.   "Se asigna a <fsl_mod_rows_standard>

  UNASSIGN: <fs_mod_rows_standard>.

  " Guardo el nombre de todos los campos del ALV en la tabla t_fieldcat_aux, esta misma se utiliza posteriormente en la ejecución del programa.
  IF t_fieldcat_aux IS INITIAL.
    LOOP AT er_data_changed->mt_fieldcatalog INTO  wl_fieldcat_aux.
      APPEND wl_fieldcat_aux TO t_fieldcat_aux.
    ENDLOOP.
  ENDIF.

  ASSIGN er_data_changed->mp_mod_rows->* TO <fs_mod_rows_standard>. "Se asigna al FS el tipo tabla

  " Situacion ---> Modificación / Nuevo registro
  IF <fs_mod_rows_standard> IS ASSIGNED AND <fs_mod_rows_standard> IS NOT INITIAL.

    READ TABLE  <fs_mod_rows_standard> ASSIGNING <fsl_mod_rows_DB3> INDEX 1. "Se asigna el FS con la tabla a mi tipo TABLA_DB_2

    IF sy-subrc EQ 0.
      "Si no cuenta con clave completa esta modificacion corresponde a NUEVO registro que aun NO esta completo, entonces se ignora.
      IF <fsl_mod_rows_DB3>-contrnum   IS NOT INITIAL AND
         <fsl_mod_rows_DB3>-codigo     IS INITIAL OR
*         <fsl_mod_rows_DB3>-porc_desde IS INITIAL OR " Puede ser 0
         <fsl_mod_rows_DB3>-porc_hasta IS INITIAL.

        EXIT.

        "Si cuenta con clave completa
      ELSE.

        "Se valida que no exista clave duplicada
        READ TABLE er_data_changed->mt_good_cells INTO wl_data_changed INDEX 1. "Obtenemos los datos del campo modificado y el nuevo valor del mismo

        IF wl_data_changed IS NOT INITIAL.

          LOOP AT t_TABLA_DB_4_alv INTO DATA(DB3_alv_aux) WHERE contrnum   EQ <fsl_mod_rows_DB3>-contrnum   AND
                                                                 codigo     EQ <fsl_mod_rows_DB3>-codigo     AND
                                                                 porc_desde EQ <fsl_mod_rows_DB3>-porc_desde AND
                                                                 porc_hasta EQ <fsl_mod_rows_DB3>-porc_hasta.
            IF sy-tabix NE wl_data_changed-row_id.
              v_duplicados = 'X'.
              EXIT.
            ENDIF.

          ENDLOOP.

        ENDIF.
        "Si existe clave duplicada salimos de la ejecucion de la rutina y no se appendea ninguna modificación a las tabla correspondiente.
        IF v_duplicados EQ 'X'.
          EXIT.
        ENDIF.

        "Si se valido que NO existe clave duplicada entonces verifico si el registro existe en la tabla de modificaciones
        LOOP AT t_DB3_mod INTO DATA(wl_DB3_mod).

          IF wl_DB3_mod-contrnum   EQ <fsl_mod_rows_DB3>-contrnum   AND
             wl_DB3_mod-codigo     EQ <fsl_mod_rows_DB3>-codigo     AND
             wl_DB3_mod-porc_desde EQ <fsl_mod_rows_DB3>-porc_desde AND
             wl_DB3_mod-porc_hasta EQ <fsl_mod_rows_DB3>-porc_hasta.

            DATA(vl_existe_registro) = 'X'.

            EXIT.

          ENDIF.
        ENDLOOP.

        "Si existe piso el registro de la tabla de modificaciones.
        IF vl_existe_registro EQ 'X'.

          UNASSIGN: <fs_valor_anterior>, <fs_nombre_campo>, <fs_valor_nuevo>.

          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_data_changed TO <fs_nombre_campo>.
          ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_mod_rows_DB3> TO <fs_valor_nuevo>.

          CLEAR: wl_DB3_mod, vl_existe_registro.

          LOOP AT t_DB3_mod INTO wl_DB3_mod.

            IF wl_DB3_mod-contrnum   EQ <fsl_mod_rows_DB3>-contrnum   AND
               wl_DB3_mod-codigo     EQ <fsl_mod_rows_DB3>-codigo     AND
               wl_DB3_mod-porc_desde EQ <fsl_mod_rows_DB3>-porc_desde AND
               wl_DB3_mod-porc_hasta EQ <fsl_mod_rows_DB3>-porc_hasta.

              MODIFY t_DB3_mod FROM <fsl_mod_rows_DB3> INDEX sy-tabix.

            ENDIF.

          ENDLOOP.

          "Si no existe se hace un APPEND del registro a la tabla de modificaciónes.
        ELSE.
          APPEND <fsl_mod_rows_DB3> TO t_DB3_mod.

        ENDIF.
      ENDIF.
    ENDIF.

    " Situacion ---> Borrado de registro
  ELSE.
    LOOP AT er_data_changed->mt_deleted_rows INTO wl_deleted_rows.

      READ TABLE t_TABLA_DB_4_alv INDEX wl_deleted_rows-row_id INTO wl_DB3.

      IF sy-subrc = 0.
        APPEND wl_DB3 TO t_DB3_del.
      ENDIF.
      CLEAR wl_DB3.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZO_TABLA_DB_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizo_TABLA_DB_4.

  DATA: tl_TABLA_DB_4_duplicados TYPE STANDARD TABLE OF ty_TABLA_DB_4.

  DATA:
    wl_fieldsname     TYPE lvc_s_fcat,
    wl_log_       TYPE zmptLOG,
    tl_TABLA_DB_4      TYPE STANDARD TABLE OF TABLA_DB_4,
    vl_secuencia(003) TYPE n VALUE 001.

  UNASSIGN: <fs_nombre_campo>, <fs_valor_anterior>, <fs_valor_nuevo>.

  " verifico que no hallan duplicados
  tl_TABLA_DB_4_duplicados[] = t_TABLA_DB_4_alv[].

  DELETE ADJACENT DUPLICATES FROM tl_TABLA_DB_4_duplicados COMPARING contrnum codigo porc_desde porc_hasta.

  IF sy-subrc EQ 0.
    v_duplicados = 'X'.
    REFRESH tl_TABLA_DB_4_duplicados.

    EXIT.
  ENDIF.

  "Armado de log.
  LOOP AT t_DB3_mod INTO DATA(wl_DB3_mod).

    READ TABLE t_TABLA_DB_4 INTO DATA(wl_DB3) WITH KEY contrnum   = wl_DB3_mod-contrnum
                                                        codigo     = wl_DB3_mod-codigo
                                                        porc_desde = wl_DB3_mod-porc_desde
                                                        porc_hasta = wl_DB3_mod-porc_hasta.

*    "Log modificado
    IF sy-subrc EQ 0.

      PERFORM armo_log_zmptLOG USING wl_DB3 wl_DB3_mod t_DB3_del 'M' 'TABLA_DB_4' vl_secuencia 'COND_SERV_CALIDAD'.
      vl_secuencia = vl_secuencia + 1.

      " Log registro nuevo
    ELSE.

      READ TABLE t_TABLA_DB_4_alv INTO DATA(wl_DB3_alv) WITH KEY contrnum   = wl_DB3_mod-contrnum
                                                                  codigo     = wl_DB3_mod-codigo
                                                                  porc_desde = wl_DB3_mod-porc_desde
                                                                  porc_hasta = wl_DB3_mod-porc_hasta.
      IF sy-subrc EQ 0.

        PERFORM armo_log_zmptLOG USING wl_DB3 wl_DB3_mod t_DB3_del 'N' 'TABLA_DB_4' vl_secuencia 'COND_SERV_CALIDAD'.
        vl_secuencia = vl_secuencia + 1.

      ENDIF.

    ENDIF.

  ENDLOOP.

  " Log borrado
  IF t_DB3_del IS NOT INITIAL.

    PERFORM armo_log_zmptLOG USING wl_DB3 wl_DB3_mod t_DB3_del 'B' 'TABLA_DB_4' vl_secuencia 'COND_SERV_CALIDAD'.
    vl_secuencia = vl_secuencia + 1.

  ENDIF.

  CLEAR vl_secuencia.

  MOVE-CORRESPONDING t_TABLA_DB_4_alv TO tl_TABLA_DB_4.

  IF sy-subrc EQ 0.

    MODIFY TABLA_DB_4 FROM TABLE tl_TABLA_DB_4.

    IF sy-subrc EQ 0.
      REFRESH tl_TABLA_DB_4.
      MOVE-CORRESPONDING t_DB3_del TO tl_TABLA_DB_4.

      IF sy-subrc EQ 0.
        DELETE TABLA_DB_4 FROM TABLE tl_TABLA_DB_4.

        IF sy-subrc EQ 0.
          INSERT zmptLOG FROM TABLE t_log_zmptLOG.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.

          ELSE.
            t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
            ROLLBACK WORK.

          ENDIF.

        ELSE.
          t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
          ROLLBACK WORK.

        ENDIF.

      ELSE.
        t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
        ROLLBACK WORK.

      ENDIF.

    ELSE.
      t_TABLA_DB_4_alv = t_TABLA_DB_4_alv_aux[].
      ROLLBACK WORK.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GUARDO_TABLA_DB_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM guardo_TABLA_DB_3 USING  er_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: wl_data_changed TYPE lvc_s_modi,    " Valor de los datos cambiados
        wl_DB5        TYPE ty_TABLA_DB_3,  " TABLA_DB_3
        wl_DB5_aux    TYPE ty_TABLA_DB_3,  " TABLA_DB_3
        wl_deleted_rows TYPE lvc_s_moce,    " Registros eliminados
        wl_fieldcat_aux TYPE lvc_s_fcat.    " Nombre de los campos

  DATA: tl_DB5        TYPE STANDARD TABLE OF TABLA_DB_3. " TABLA_DB_3

  FIELD-SYMBOLS:
    <fsl_mod_rows_DB5>    TYPE ty_TABLA_DB_3.   "Se asigna a <fsl_mod_rows_standard>

  UNASSIGN: <fs_mod_rows_standard>.

  " Guardo el nombre de todos los campos del ALV en la tabla t_fieldcat_aux, esta misma se utiliza posteriormente en la ejecución del programa.
  IF t_fieldcat_aux IS INITIAL.
    LOOP AT er_data_changed->mt_fieldcatalog INTO  wl_fieldcat_aux.
      APPEND wl_fieldcat_aux TO t_fieldcat_aux.
    ENDLOOP.
  ENDIF.

  ASSIGN er_data_changed->mp_mod_rows->* TO <fs_mod_rows_standard>. "Se asigna al FS el tipo tabla

  " Situacion ---> Modificación / Nuevo registro
  IF <fs_mod_rows_standard> IS ASSIGNED AND <fs_mod_rows_standard> IS NOT INITIAL.

    READ TABLE  <fs_mod_rows_standard> ASSIGNING <fsl_mod_rows_DB5> INDEX 1. "Se asigna el FS con la tabla a mi tipo TABLA_DB_2

    IF sy-subrc EQ 0.
      "Si no cuenta con clave completa esta modificacion corresponde a NUEVO registro que aun NO esta completo, entonces se ignora.
      IF <fsl_mod_rows_DB5>-contrnum   IS NOT INITIAL AND
         <fsl_mod_rows_DB5>-fe_desde IS INITIAL OR
         <fsl_mod_rows_DB5>-fe_hasta IS INITIAL.

        EXIT.

        "Si cuenta con clave completa
      ELSE.

        "Se valida que no exista clave duplicada
        READ TABLE er_data_changed->mt_good_cells INTO wl_data_changed INDEX 1. "Obtenemos los datos del campo modificado y el nuevo valor del mismo

        IF wl_data_changed IS NOT INITIAL.

          LOOP AT t_TABLA_DB_3_alv INTO DATA(DB5_alv_aux) WHERE contrnum EQ <fsl_mod_rows_DB5>-contrnum AND
                                                                 fe_desde EQ <fsl_mod_rows_DB5>-fe_desde AND
                                                                 fe_hasta EQ <fsl_mod_rows_DB5>-fe_hasta.
            IF sy-tabix NE wl_data_changed-row_id.
              v_duplicados = 'X'.
              EXIT.
            ENDIF.

          ENDLOOP.

        ENDIF.

        "Si existe clave duplicada salimos de la ejecucion de la rutina y no se appendea ninguna modificación a las tabla correspondiente.
        IF v_duplicados EQ 'X'.
          EXIT.
        ENDIF.

        "Si se valido que NO existe clave duplicada entonces verifico si el registro existe en la tabla de modificaciones
        LOOP AT t_DB5_mod INTO DATA(wl_DB5_mod).

          IF wl_DB5_mod-contrnum EQ <fsl_mod_rows_DB5>-contrnum AND
             wl_DB5_mod-fe_desde EQ <fsl_mod_rows_DB5>-fe_desde AND
             wl_DB5_mod-fe_hasta EQ <fsl_mod_rows_DB5>-fe_hasta.

            DATA(vl_existe_registro) = 'X'.

            EXIT.

          ENDIF.
        ENDLOOP.

        "Si existe piso el registro de la tabla de modificaciones.
        IF vl_existe_registro EQ 'X'.

          UNASSIGN: <fs_valor_anterior>, <fs_nombre_campo>, <fs_valor_nuevo>.

          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_data_changed TO <fs_nombre_campo>.
          ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_mod_rows_DB5> TO <fs_valor_nuevo>.

          CLEAR: wl_DB5_mod, vl_existe_registro.

          LOOP AT t_DB5_mod INTO wl_DB5_mod.

            IF wl_DB5_mod-contrnum EQ <fsl_mod_rows_DB5>-contrnum AND
               wl_DB5_mod-fe_desde EQ <fsl_mod_rows_DB5>-fe_desde AND
               wl_DB5_mod-fe_hasta EQ <fsl_mod_rows_DB5>-fe_hasta.

              MODIFY t_DB5_mod FROM <fsl_mod_rows_DB5> INDEX sy-tabix.

            ENDIF.

          ENDLOOP.

          "Si no existe se hace un APPEND del registro a la tabla de modificaciónes.
        ELSE.
          APPEND <fsl_mod_rows_DB5> TO t_DB5_mod.

        ENDIF.
      ENDIF.
    ENDIF.

    " Situacion ---> Borrado de registro
  ELSE.
    LOOP AT er_data_changed->mt_deleted_rows INTO wl_deleted_rows.

      READ TABLE t_TABLA_DB_3_alv INDEX wl_deleted_rows-row_id INTO wl_DB5.

      IF sy-subrc = 0.
        APPEND wl_DB5 TO t_DB5_del.
      ENDIF.
      CLEAR wl_DB5.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZO_TABLA_DB_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizo_TABLA_DB_3.

  DATA: tl_TABLA_DB_3_duplicados TYPE STANDARD TABLE OF ty_TABLA_DB_3.

  DATA:
    wl_fieldsname     TYPE lvc_s_fcat,
    wl_log_       TYPE zmptLOG,
    tl_TABLA_DB_3      TYPE STANDARD TABLE OF TABLA_DB_3,
    vl_secuencia(003) TYPE n VALUE 001.

  UNASSIGN: <fs_nombre_campo>, <fs_valor_anterior>, <fs_valor_nuevo>.

  " Se verfica que no existan claves duplicadas, si existen no se actualizan las tablas
  tl_TABLA_DB_3_duplicados[] = t_TABLA_DB_3_alv[].
  DELETE ADJACENT DUPLICATES FROM tl_TABLA_DB_3_duplicados COMPARING contrnum fe_desde fe_hasta.

  IF sy-subrc EQ 0.
    v_duplicados = 'X'.
    REFRESH tl_TABLA_DB_3_duplicados.
    EXIT.
  ENDIF.

  "Si no existen claves duplicadas, se arma el log.
  LOOP AT t_DB5_mod INTO DATA(wl_DB5_mod).

    READ TABLE t_TABLA_DB_3 INTO DATA(wl_DB5) WITH KEY contrnum = wl_DB5_mod-contrnum
                                                        fe_desde = wl_DB5_mod-fe_desde
                                                        fe_hasta = wl_DB5_mod-fe_hasta.

    " Log de registro modificado
    IF sy-subrc EQ 0.
      PERFORM armo_log_zmptLOG USING wl_DB5
                                       wl_DB5_mod
                                       t_DB5_del
                                       'M'
                                       'TABLA_DB_3'
                                       vl_secuencia
                                       'TOPEZ_FIJACION'.
      vl_secuencia = vl_secuencia + 1.

      " Log registro nuevo
    ELSE.
      READ TABLE t_TABLA_DB_3_alv INTO DATA(wl_DB5_alv) WITH KEY contrnum = wl_DB5_mod-contrnum
                                                                  fe_desde = wl_DB5_mod-fe_desde
                                                                  fe_hasta = wl_DB5_mod-fe_hasta.
      IF sy-subrc EQ 0.
        PERFORM armo_log_zmptLOG USING wl_DB5 wl_DB5_mod t_DB5_del 'N' 'TABLA_DB_3' vl_secuencia 'TOPEZ_FIJACION'.
        vl_secuencia = vl_secuencia + 1.

      ENDIF.

    ENDIF.

  ENDLOOP.

  " Log borrado
  IF t_DB5_del IS NOT INITIAL.

    PERFORM armo_log_zmptLOG USING wl_DB5 wl_DB5_mod t_DB5_del 'B' 'TABLA_DB_3' vl_secuencia 'TOPEZ_FIJACION'.
    vl_secuencia = vl_secuencia + 1.

  ENDIF.

  CLEAR vl_secuencia.

  MOVE-CORRESPONDING t_TABLA_DB_3_alv TO tl_TABLA_DB_3.

  IF sy-subrc EQ 0.

    MODIFY TABLA_DB_3 FROM TABLE tl_TABLA_DB_3.

    IF sy-subrc EQ 0.
      REFRESH tl_TABLA_DB_3.
      MOVE-CORRESPONDING t_DB5_del TO tl_TABLA_DB_3.

      IF sy-subrc EQ 0.
        DELETE TABLA_DB_3 FROM TABLE tl_TABLA_DB_3.

        IF sy-subrc EQ 0.
          INSERT zmptLOG FROM TABLE t_log_zmptLOG.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.

          ELSE.
            t_TABLA_DB_3_alv = t_TABLA_DB_3_alv_aux[].
            ROLLBACK WORK.

          ENDIF.

        ELSE.
          t_TABLA_DB_3_alv = t_TABLA_DB_3_alv_aux[].
          ROLLBACK WORK.

        ENDIF.

      ELSE.
        t_TABLA_DB_3_alv = t_TABLA_DB_3_alv_aux[].
        ROLLBACK WORK.

      ENDIF.

    ELSE.
      t_TABLA_DB_3_alv = t_TABLA_DB_3_alv_aux[].
      ROLLBACK WORK.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GUARDO_TABLA_DB_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM guardo_TABLA_DB_6 USING  er_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: wl_data_changed TYPE lvc_s_modi,    " Valor de los datos cambiados
        wl_e7580        TYPE ty_TABLA_DB_6,  " TABLA_DB_6
        wl_e7580_aux    TYPE ty_TABLA_DB_6,  " TABLA_DB_6
        wl_deleted_rows TYPE lvc_s_moce,    " Registros eliminados
        wl_fieldcat_aux TYPE lvc_s_fcat.    " Nombre de los campos

  DATA: tl_e7580        TYPE STANDARD TABLE OF TABLA_DB_6. " TABLA_DB_6

  FIELD-SYMBOLS:
    <fsl_mod_rows_e7580>    TYPE ty_TABLA_DB_6.   "Se asigna a <fsl_mod_rows_standard>

  UNASSIGN: <fs_mod_rows_standard>.

  " Guardo el nombre de todos los campos del ALV en la tabla t_fieldcat_aux, esta misma se utiliza posteriormente en la ejecución del programa.
  IF t_fieldcat_aux IS INITIAL.
    LOOP AT er_data_changed->mt_fieldcatalog INTO  wl_fieldcat_aux.
      APPEND wl_fieldcat_aux TO t_fieldcat_aux.
    ENDLOOP.
  ENDIF.

  ASSIGN er_data_changed->mp_mod_rows->* TO <fs_mod_rows_standard>. "Se asigna al FS el tipo tabla

  " Situacion ---> Modificación / Nuevo registro
  IF <fs_mod_rows_standard> IS ASSIGNED AND <fs_mod_rows_standard> IS NOT INITIAL.

    READ TABLE  <fs_mod_rows_standard> ASSIGNING <fsl_mod_rows_e7580> INDEX 1. "Se asigna el FS con la tabla a mi tipo TABLA_DB_2

    IF sy-subrc EQ 0.
      "Si no cuenta con clave completa esta modificacion corresponde a NUEVO registro que aun NO esta completo, entonces se ignora.
      IF <fsl_mod_rows_e7580>-contrnum IS NOT INITIAL AND
         <fsl_mod_rows_e7580>-pedido   IS INITIAL OR
         <fsl_mod_rows_e7580>-concepto IS INITIAL.

        EXIT.

        "Si cuenta con clave completa
      ELSE.

        "Se valida que no exista clave duplicada
        READ TABLE er_data_changed->mt_good_cells INTO wl_data_changed INDEX 1. "Obtenemos los datos del campo modificado y el nuevo valor del mismo

        IF wl_data_changed IS NOT INITIAL.

          LOOP AT t_TABLA_DB_6_alv INTO DATA(e7580_alv_aux) WHERE contrnum EQ <fsl_mod_rows_e7580>-contrnum AND
                                                                 pedido   EQ <fsl_mod_rows_e7580>-pedido   AND
                                                                 concepto EQ <fsl_mod_rows_e7580>-concepto.
            IF sy-tabix NE wl_data_changed-row_id.
              v_duplicados = 'X'.
              EXIT.
            ENDIF.

          ENDLOOP.

        ENDIF.

        "Si existe clave duplicada salimos de la ejecucion de la rutina y no se appendea ninguna modificación a las tabla correspondiente.
        IF v_duplicados EQ 'X'.
          EXIT.
        ENDIF.

        "Si se valido que NO existe clave duplicada entonces verifico si el registro existe en la tabla de modificaciones
        LOOP AT t_e7580_mod INTO DATA(wl_e7580_mod).

          IF wl_e7580_mod-contrnum EQ <fsl_mod_rows_e7580>-contrnum AND
             wl_e7580_mod-pedido   EQ <fsl_mod_rows_e7580>-pedido   AND
             wl_e7580_mod-concepto EQ <fsl_mod_rows_e7580>-concepto.

            DATA(vl_existe_registro) = 'X'.

            EXIT.

          ENDIF.
        ENDLOOP.

        "Si existe piso el registro de la tabla de modificaciones.
        IF vl_existe_registro EQ 'X'.

          UNASSIGN: <fs_valor_anterior>, <fs_nombre_campo>, <fs_valor_nuevo>.

          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_data_changed TO <fs_nombre_campo>.
          ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_mod_rows_e7580> TO <fs_valor_nuevo>.

          CLEAR: wl_e7580_mod, vl_existe_registro.

          LOOP AT t_e7580_mod INTO wl_e7580_mod.

            IF wl_e7580_mod-contrnum EQ <fsl_mod_rows_e7580>-contrnum AND
               wl_e7580_mod-pedido   EQ <fsl_mod_rows_e7580>-pedido   AND
               wl_e7580_mod-concepto EQ <fsl_mod_rows_e7580>-concepto.

              MODIFY t_e7580_mod FROM <fsl_mod_rows_e7580> INDEX sy-tabix.

            ENDIF.

          ENDLOOP.

          "Si no existe se hace un APPEND del registro a la tabla de modificaciónes.
        ELSE.
          APPEND <fsl_mod_rows_e7580> TO t_e7580_mod.

        ENDIF.
      ENDIF.
    ENDIF.

    " Situacion ---> Borrado de registro
  ELSE.
    LOOP AT er_data_changed->mt_deleted_rows INTO wl_deleted_rows.

      READ TABLE t_TABLA_DB_6_alv INDEX wl_deleted_rows-row_id INTO wl_e7580.

      IF sy-subrc = 0.
        APPEND wl_e7580 TO t_e7580_del.
      ENDIF.
      CLEAR wl_e7580.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZO_TABLA_DB_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizo_TABLA_DB_6.

  DATA: tl_TABLA_DB_6_duplicados TYPE STANDARD TABLE OF ty_TABLA_DB_6.

  DATA:
    wl_fieldsname     TYPE lvc_s_fcat,
    wl_log_       TYPE zmptLOG,
    tl_TABLA_DB_6      TYPE STANDARD TABLE OF TABLA_DB_6,
    vl_secuencia(003) TYPE n VALUE 001.

  UNASSIGN: <fs_nombre_campo>, <fs_valor_anterior>, <fs_valor_nuevo>.

  " verifico que no hallan duplicados
  tl_TABLA_DB_6_duplicados[] = t_TABLA_DB_6_alv[].

  DELETE ADJACENT DUPLICATES FROM tl_TABLA_DB_6_duplicados COMPARING contrnum pedido concepto.

  IF sy-subrc EQ 0.
    v_duplicados = 'X'.
    REFRESH tl_TABLA_DB_6_duplicados.

    EXIT.
  ENDIF.

  "Armado de log.
  LOOP AT t_e7580_mod INTO DATA(wl_e7580_mod).

    READ TABLE t_TABLA_DB_6 INTO DATA(wl_e7580) WITH KEY contrnum = wl_e7580_mod-contrnum
                                                        pedido   = wl_e7580_mod-pedido
                                                        concepto = wl_e7580_mod-concepto.

*    "Log modificado
    IF sy-subrc EQ 0.

      PERFORM armo_log_zmptLOG USING wl_e7580 wl_e7580_mod t_e7580_del 'M' 'TABLA_DB_6' vl_secuencia 'APERT_PRECIO'.
      vl_secuencia = vl_secuencia + 1.

      " Log registro nuevo
    ELSE.

      READ TABLE t_TABLA_DB_6_alv INTO DATA(wl_e7580_alv) WITH KEY contrnum = wl_e7580_mod-contrnum
                                                                  pedido   = wl_e7580_mod-pedido
                                                                  concepto = wl_e7580_mod-concepto.
      IF sy-subrc EQ 0.

        PERFORM armo_log_zmptLOG USING wl_e7580 wl_e7580_mod t_e7580_del 'N' 'TABLA_DB_6' vl_secuencia 'APERT_PRECIO'.
        vl_secuencia = vl_secuencia + 1.

      ENDIF.

    ENDIF.

  ENDLOOP.

  " Log borrado
  IF t_e7580_del IS NOT INITIAL.

    PERFORM armo_log_zmptLOG USING wl_e7580 wl_e7580_mod t_e7580_del 'B' 'TABLA_DB_6' vl_secuencia 'APERT_PRECIO'.
    vl_secuencia = vl_secuencia + 1.

  ENDIF.

  CLEAR vl_secuencia.

  MOVE-CORRESPONDING t_TABLA_DB_6_alv TO tl_TABLA_DB_6.

  IF sy-subrc EQ 0.

    MODIFY TABLA_DB_6 FROM TABLE tl_TABLA_DB_6.

    IF sy-subrc EQ 0.
      REFRESH tl_TABLA_DB_6.
      MOVE-CORRESPONDING t_e7580_del TO tl_TABLA_DB_6.

      IF sy-subrc EQ 0.
        DELETE TABLA_DB_6 FROM TABLE tl_TABLA_DB_6.

        IF sy-subrc EQ 0.
          INSERT zmptLOG FROM TABLE t_log_zmptLOG.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.

          ELSE.
            t_TABLA_DB_6_alv = t_TABLA_DB_6_alv_aux[].
            ROLLBACK WORK.

          ENDIF.

        ELSE.
          t_TABLA_DB_6_alv = t_TABLA_DB_6_alv_aux[].
          ROLLBACK WORK.

        ENDIF.

      ELSE.
        t_TABLA_DB_6_alv = t_TABLA_DB_6_alv_aux[].
        ROLLBACK WORK.

      ENDIF.

    ELSE.
      t_TABLA_DB_6_alv = t_TABLA_DB_6_alv_aux[].
      ROLLBACK WORK.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDAR_CAMPOS_CLAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_TABLA_DB_2_ALV  text
*      <--P_VL_FLAG  text
*----------------------------------------------------------------------*
FORM validar_campos_clave  USING pt_alv TYPE ANY TABLE
                                 pv_campo_excluido TYPE string
                           CHANGING pv_flag TYPE c.

  FIELD-SYMBOLS: <fsl_valor> TYPE any,
                 <fsl_alv>   TYPE any.

  DATA: wl_fieldcat      TYPE lvc_s_fcat.

  LOOP AT pt_alv ASSIGNING <fsl_alv>.

    LOOP AT t_fieldcat_aux INTO wl_fieldcat WHERE key EQ 'X'.
      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_fieldcat TO <fs_nombre_campo>. "Nombre del campo clave obtenido del fieldcat
      IF <fs_nombre_campo> <> 'MANDT' AND <fs_nombre_campo> <> pv_campo_excluido.
        ASSIGN COMPONENT <fs_nombre_campo> OF STRUCTURE <fsl_alv> TO <fsl_valor>.  "Valor anterior
        IF <fsl_valor> IS INITIAL.
          pv_flag = 'X'.
          EXIT.
        ELSE.
          CLEAR pv_flag.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  UNASSIGN <fs_nombre_campo>.
  CLEAR wl_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ARMO_LOG_ZMPTLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PE_ALV  text
*      -->PE_ALV_MOD  text
*      -->PT_ALV_DEL  text
*      -->PV_MODO  text
*      -->PV_NOMBRE_TABLA text
*      -->PV_SECUENCIA text
*      -->PV_NOMBRE_CAMPO  text
*----------------------------------------------------------------------*
FORM armo_log_zmptLOG USING pe_alv          TYPE any
                              pe_alv_mod      TYPE any
                              pt_alv_del      TYPE ANY TABLE
                              pv_modo         TYPE c
                              pv_nombre_tabla TYPE string
                              pv_secuencia    TYPE n
                              pv_nombre_campo TYPE string.

  DATA: vl_registro_anterior(254) TYPE c,
        vl_registro_nuevo(254)    TYPE c,
        vl_valor_campo            TYPE string,
        vl_strlenght              TYPE i,
        wl_fieldsname             TYPE lvc_s_fcat,
        wl_log_               TYPE zmptLOG,
        vl_secuencia(003)         TYPE n.

  FIELD-SYMBOLS: <fsl_deleted>    TYPE any,
                 <fsl_field_name> TYPE any,
                 <fsl_old_value>  TYPE any,
                 <fsl_new_value>  TYPE any.

  "Log registro modificado
  IF pv_modo EQ 'M'.

    CLEAR: wl_log_, vl_registro_anterior, vl_registro_nuevo,vl_strlenght.
    UNASSIGN: <fsl_field_name>, <fsl_new_value>,<fsl_old_value> .

    LOOP AT t_fieldcat_aux INTO wl_fieldsname.

      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE  wl_fieldsname TO <fsl_field_name>. "Nombre del campo obtenido del fieldcat
      ASSIGN COMPONENT <fsl_field_name> OF STRUCTURE pe_alv TO <fsl_old_value>.     "Valor anterior
      ASSIGN COMPONENT <fsl_field_name> OF STRUCTURE pe_alv_mod TO <fsl_new_value>. "Nuevo valor

      "Armo el log
      IF <fsl_field_name> <> 'CONTRNUM' AND <fsl_field_name> <> 'MANDT'.

        " --> Log registro anterior
        vl_valor_campo =  <fsl_old_value>.
        IF vl_registro_anterior IS INITIAL.
          vl_registro_anterior = vl_valor_campo.
        ELSE.
          CONCATENATE vl_registro_anterior vl_valor_campo INTO vl_registro_anterior SEPARATED BY ';'.
        ENDIF.

        CLEAR vl_valor_campo.

        " --> Log registro nuevo
        vl_valor_campo =  <fsl_new_value>.
        IF vl_registro_nuevo IS INITIAL.
          vl_registro_nuevo = vl_valor_campo.
        ELSE.
          CONCATENATE vl_registro_nuevo vl_valor_campo INTO vl_registro_nuevo SEPARATED BY ';'.
        ENDIF.

        CLEAR vl_valor_campo.

      ENDIF.

    ENDLOOP.

    "Se appendea al log
    wl_log_-valor_anterior = vl_registro_anterior.
    wl_log_-valor_nuevo    = vl_registro_nuevo.
    wl_log_-secuencia      = pv_secuencia.
    wl_log_-mandt          = sy-mandt.
    wl_log_-contrnum       = p_cntrum.
    wl_log_-udate          = sy-datum.
    wl_log_-utime          = sy-uzeit.
    wl_log_-fieldname      = pv_nombre_campo.
    wl_log_-tabla          = pv_nombre_tabla.
    wl_log_-username       = sy-uname.
    wl_log_-motivo         = p_motivo.
    wl_log_-tcode          = 'TR'.

    APPEND wl_log_ TO t_log_zmptLOG.

  ENDIF.

  " Log nuevo registro
  IF pv_modo EQ 'N'.

    UNASSIGN: <fsl_field_name>, <fsl_new_value>.

    CLEAR: wl_log_, vl_registro_anterior, vl_registro_nuevo,vl_strlenght.

    LOOP AT t_fieldcat_aux INTO wl_fieldsname.

      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_fieldsname TO <fsl_field_name>.

      ASSIGN COMPONENT <fsl_field_name> OF STRUCTURE pe_alv_mod TO <fsl_new_value>. "Nuevo valor

      "Armo el log
      IF <fsl_field_name> <> 'CONTRNUM' AND <fsl_field_name> <> 'MANDT'.

        " --> Log registro nuevo
        vl_valor_campo =  <fsl_new_value>.
        IF vl_registro_nuevo IS INITIAL.
          vl_registro_nuevo = vl_valor_campo.
        ELSE.
          CONCATENATE vl_registro_nuevo vl_valor_campo INTO vl_registro_nuevo SEPARATED BY ';'.
        ENDIF.

        CLEAR vl_valor_campo.
      ENDIF.

    ENDLOOP.

    " --> Log registro anterior
    vl_registro_anterior = space.

    "Se appendea al log
    wl_log_-valor_anterior = vl_registro_anterior.
    wl_log_-valor_nuevo    = vl_registro_nuevo.
    wl_log_-secuencia      = pv_secuencia.
    wl_log_-mandt          = sy-mandt.
    wl_log_-contrnum       = p_cntrum.
    wl_log_-udate          = sy-datum.
    wl_log_-utime          = sy-uzeit.
    wl_log_-fieldname      = pv_nombre_campo.
    wl_log_-tabla          = pv_nombre_tabla.
    wl_log_-username       = sy-uname.
    wl_log_-motivo         = p_motivo.
    wl_log_-tcode          = 'TR'.

    APPEND wl_log_ TO t_log_zmptLOG.

  ENDIF.

  " Log registro borrado
  IF pv_modo EQ 'B'.

    CLEAR: wl_log_, vl_registro_anterior, vl_registro_nuevo,vl_strlenght.

    UNASSIGN: <fsl_field_name>, <fsl_old_value>.

    vl_secuencia = pv_secuencia.

    LOOP AT pt_alv_del  ASSIGNING <fsl_deleted>.

      LOOP AT t_fieldcat_aux INTO wl_fieldsname.

        ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE wl_fieldsname TO <fsl_field_name>.
        ASSIGN COMPONENT <fsl_field_name> OF STRUCTURE <fsl_deleted> TO <fsl_old_value>.  "Valor anterior

        "Armo el log
        IF <fsl_field_name> <> 'CONTRNUM' AND <fsl_field_name> <> 'MANDT'.

          " --> Log registro anterior
          vl_valor_campo =  <fsl_old_value>.
          IF vl_registro_anterior IS INITIAL.
            vl_registro_anterior = vl_valor_campo.
          ELSE.
            CONCATENATE vl_registro_anterior vl_valor_campo INTO vl_registro_anterior SEPARATED BY ';'.
          ENDIF.

          CLEAR vl_valor_campo.
        ENDIF.

      ENDLOOP.

      " --> Log registro anterior
      vl_registro_nuevo = space.

      "Se appenda al log
      wl_log_-valor_anterior = vl_registro_anterior.
      wl_log_-valor_nuevo    = vl_registro_nuevo.
      wl_log_-secuencia      = vl_secuencia.
      wl_log_-mandt          = sy-mandt.
      wl_log_-contrnum       = p_cntrum.
      wl_log_-udate          = sy-datum.
      wl_log_-utime          = sy-uzeit.
      wl_log_-fieldname      = pv_nombre_campo.
      wl_log_-tabla          = pv_nombre_tabla.
      wl_log_-username       = sy-uname.
      wl_log_-motivo         = p_motivo.
      wl_log_-tcode          = 'TR'.

      APPEND wl_log_ TO t_log_zmptLOG.

      vl_secuencia = vl_secuencia + 1.

      CLEAR: wl_log_,vl_registro_anterior, vl_registro_nuevo,vl_strlenght.

    ENDLOOP.

  ENDIF.

  CLEAR vl_secuencia.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MENSAJE_DUPLICADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_DUPLICADOS  text
*----------------------------------------------------------------------*
FORM mensaje_clave_duplicada  USING pv_duplicados.

  IF pv_duplicados EQ 'X'.

    MESSAGE TEXT-008 TYPE 'I' DISPLAY LIKE 'E'.

    CLEAR v_duplicados.

  ENDIF.

ENDFORM.

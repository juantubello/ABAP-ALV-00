*&---------------------------------------------------------------------*
*&  Include           XXXXXX_TOP
*&---------------------------------------------------------------------*

* Tipos *
**********
  TYPES:
    " ZMPTE3030 Contratos
    BEGIN OF ty_DB1.
      INCLUDE TYPE DB1.
      TYPES:   cell TYPE lvc_t_styl,
    END OF ty_DB1,

    " DB_TABLA_2 - Descuentos y bonificaciones / Sustentable
    BEGIN OF ty_DB_TABLA_2.
      INCLUDE TYPE DB_TABLA_2.
      TYPES: cell TYPE lvc_t_styl,
    END OF ty_DB_TABLA_2,

    " DB_TABLA_3 - Plazos y Topes de fijación
    BEGIN OF ty_DB_TABLA_3.
      INCLUDE TYPE DB_TABLA_3.
      TYPES: cell TYPE lvc_t_styl,
    END OF ty_DB_TABLA_3,

    " DB_TABLA_4 - Act. dañados
    BEGIN OF ty_DB_TABLA_4.
      INCLUDE TYPE DB_TABLA_4.
      TYPES: cell TYPE lvc_t_styl,
    END OF ty_DB_TABLA_4,

    " DB_TABLA_3 - Desc especiales x calidad
    BEGIN OF ty_DB_TABLA_3.
      INCLUDE TYPE DB_TABLA_3.
      TYPES:  cell TYPE lvc_t_styl,
    END OF ty_DB_TABLA_3,

    " Apertura de precio
    BEGIN OF ty_DB_TABLA_5.
      INCLUDE TYPE DB_TABLA_5.
      TYPES: cell TYPE lvc_t_styl,
    END OF ty_DB_TABLA_5,

    " Cond. Servicios y Calidad
    BEGIN OF ty_DB_TABLA_3.
      INCLUDE TYPE DB_TABLA_3.
      TYPES: cell TYPE lvc_t_styl,
    END OF ty_DB_TABLA_3,

    BEGIN OF ty_campo_clave,
      campo_clave TYPE string,
    END OF  ty_campo_clave.

  TYPES: tyt_tabla_campos_clave TYPE STANDARD TABLE OF ty_campo_clave.

* Tablas *
**********
  DATA:
    " Catalogo global - reutilizable
    t_fieldcat_aux      TYPE lvc_t_fcat,

    t_zmpte3030_alv     TYPE STANDARD TABLE OF ty_zmpte3030,
    t_zmpte3030_alv_aux TYPE STANDARD TABLE OF ty_zmpte3030,
    t_zmpte3030         TYPE STANDARD TABLE OF zmpte3030,

    t_DB_TABLA_2_alv     TYPE STANDARD TABLE OF ty_DB_TABLA_2,
    t_DB_TABLA_2_alv_aux TYPE STANDARD TABLE OF ty_DB_TABLA_2,
    t_DB_TABLA_2         TYPE STANDARD TABLE OF DB_TABLA_2,
    t_e3010_mod         TYPE STANDARD TABLE OF ty_DB_TABLA_2,
    t_e3010_del         TYPE STANDARD TABLE OF ty_DB_TABLA_2,

    t_DB_TABLA_3_alv     TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_DB_TABLA_3_alv_aux TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_DB_TABLA_3         TYPE STANDARD TABLE OF DB_TABLA_3,
    t_e3100_mod         TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_e3100_del         TYPE STANDARD TABLE OF ty_DB_TABLA_3,

    t_DB_TABLA_4_alv     TYPE STANDARD TABLE OF ty_DB_TABLA_4,
    t_DB_TABLA_4_alv_aux TYPE STANDARD TABLE OF ty_DB_TABLA_4,
    t_DB_TABLA_4         TYPE STANDARD TABLE OF DB_TABLA_4,
    t_e3970_mod         TYPE STANDARD TABLE OF ty_DB_TABLA_4,
    t_e3970_del         TYPE STANDARD TABLE OF ty_DB_TABLA_4,

    t_DB_TABLA_3_alv     TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_DB_TABLA_3_alv_aux TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_DB_TABLA_3         TYPE STANDARD TABLE OF DB_TABLA_3,
    t_e3060_mod         TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_e3060_del         TYPE STANDARD TABLE OF ty_DB_TABLA_3,

    t_DB_TABLA_5_alv     TYPE STANDARD TABLE OF ty_DB_TABLA_5,
    t_DB_TABLA_5_alv_aux TYPE STANDARD TABLE OF ty_DB_TABLA_5,
    t_DB_TABLA_5         TYPE STANDARD TABLE OF DB_TABLA_5,
    t_e7580_mod         TYPE STANDARD TABLE OF ty_DB_TABLA_5,
    t_e7580_del         TYPE STANDARD TABLE OF ty_DB_TABLA_5,

    t_DB_TABLA_3_alv     TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_DB_TABLA_3_alv_aux TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_DB_TABLA_3         TYPE STANDARD TABLE OF DB_TABLA_3,
    t_e3070_mod         TYPE STANDARD TABLE OF ty_DB_TABLA_3,
    t_e3070_del         TYPE STANDARD TABLE OF ty_DB_TABLA_3,

    " Tablas de LOG
    t_log_zmptm3060     TYPE STANDARD TABLE OF zmptm3060,
    t_log_zmptm4600     TYPE STANDARD TABLE OF zmptm4600.

* Objetos *
***********
  DATA: o_alv                   TYPE REF TO cl_gui_alv_grid,
        o_alv_botones           TYPE REF TO cl_gui_alv_grid,
        o_alv_container_botones TYPE REF TO cl_gui_custom_container.

* Variables*
***********
  DATA:
    v_alv_principal       TYPE c,
    v_bonif               TYPE c,
    v_plaz_topes          TYPE c,
    v_ac_dan              TYPE c,
    v_desc_esp            TYPE c,
    v_ap_precio           TYPE c,
    v_cond_serv           TYPE c,
    v_mensaje             TYPE string,
    v_motivo              TYPE string,
    v_flag_add_delete_row TYPE c,
    v_duplicados          TYPE c.

* Fiels-Symbols*
***********
  FIELD-SYMBOLS:
    <fs_mod_rows_standard> TYPE STANDARD TABLE,
    <fs_nombre_campo>      TYPE any,
    <fs_valor_anterior>    TYPE any,
    <fs_valor_nuevo>       TYPE any.

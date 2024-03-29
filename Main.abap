*&---------------------------------------------------------------------*
*& Report XXXXXX
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Creador:     Fernandez Tubello, Juan Pablo
*----------------------------------------------------------------------*

REPORT zmpprr9480.

TYPE-POOLS : abap, slis.

INCLUDE: XXXXXX_sel,
         XXXXXX_top,
         XXXXXX_cls,
         XXXXXX_f01,
         XXXXXX_pbo,
         XXXXXX_pai.

AT SELECTION-SCREEN.

  PERFORM bloquear_tablas.

  IF v_mensaje IS INITIAL.

    PERFORM obtener_datos.

    "Llamada a la Dynpro 9000
    CALL SCREEN 9000.

  ELSE.

    MESSAGE v_mensaje TYPE 'I' DISPLAY LIKE 'E'.

  ENDIF.

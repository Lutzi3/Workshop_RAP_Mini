CLASS lhc_ZRAP_I_DDL_LUTZ DEFINITION INHERITING FROM cl_abap_behavior_handler.
  CLASS-DATA: lt_buffer TYPE TABLE OF zrap_i_ddl_lutz .
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE bupartner.

    METHODS read FOR READ
      IMPORTING keys FOR READ bupartner RESULT result.

ENDCLASS.

CLASS lhc_ZRAP_I_DDL_LUTZ IMPLEMENTATION.

  METHOD update.
    MOVE-CORRESPONDING entities TO lt_buffer .
  ENDMETHOD.

  METHOD read.
    IF lines(  keys ) > 0.
      SELECT * FROM zrap_i_ddl_lutz
      FOR ALL ENTRIES IN @keys WHERE partner = @keys-partner
      INTO TABLE       @lt_buffer .

    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZRAP_I_DDL_LUTZ DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_ZRAP_I_DDL_LUTZ IMPLEMENTATION.

  METHOD check_before_save.
    LOOP AT lhc_ZRAP_I_DDL_LUTZ=>lt_buffer ASSIGNING FIELD-SYMBOL(<f_buffer>) .
      DATA: ls_central   TYPE bapibus1006_central,
            ls_central_X TYPE bapibus1006_central_x,
            lt_return    TYPE bapiret2_t.

* leeres feld nicht ok
      IF <f_buffer>-bu_sort1 IS INITIAL.
        "fill failed return structure for the framework
        APPEND VALUE #( partner = <f_buffer>-partner ) TO failed-BuPartner .

        "fill failed return structure for the framework
        " LOOP AT messages INTO DATA(message).

        "fill reported structure to be displayed on the UI
        APPEND VALUE #( partner = <f_buffer>-partner
                        %msg = new_message( id = '65'
                                            number = '195'
                                            v1 = 'Suchfeld'
                                            v2 = ''
                                            v3 = ''
                                            v4 = ''
                                            severity = CONV #( 'E' ) )

       ) TO reported-BuPartner.
      ELSE.
        ls_central-searchterm1 = <f_buffer>-bu_sort1.
        ls_central_X-searchterm1 = 'X'.

        CALL FUNCTION 'BAPI_BUPA_CENTRAL_CHANGE'
          EXPORTING
            businesspartner = <f_buffer>-partner
            centraldata     = ls_central
            centraldata_x   = ls_central_X
          TABLES
            return          = lt_return.
        LOOP AT lt_return  ASSIGNING FIELD-SYMBOL(<f_msg>) WHERE type = 'E'.
          "fill failed return structure for the framework
          APPEND VALUE #( partner = <f_buffer>-partner ) TO failed-BuPartner .

          "fill failed return structure for the framework
          " LOOP AT messages INTO DATA(message).

          "fill reported structure to be displayed on the UI
          APPEND VALUE #( partner = <f_buffer>-partner
                          %msg = new_message( id = <f_msg>-id
                                              number = <f_msg>-number
                                              v1 = <f_msg>-message_v1
                                              v2 = <f_msg>-message_v2
                                              v3 = <f_msg>-message_v3
                                              v4 = <f_msg>-message_v4
                                              severity = CONV #( <f_msg>-type ) )

         ) TO reported-BuPartner.

        ENDLOOP.
        IF sy-subrc EQ 0. "war im Loop = Fehler
          "fill failed return structure for the framework
          APPEND VALUE #( partner = <f_buffer>-partner ) TO failed-BuPartner .

        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
    "alles passiert im check before save
  ENDMETHOD .
ENDCLASS.

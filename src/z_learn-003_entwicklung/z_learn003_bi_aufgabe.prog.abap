*&---------------------------------------------------------------------*
*& Modulpool        Z_LEARN003_BI_AUFGABE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
PROGRAM Z_LEARN003_BI_AUFGABE.



  CALL SCREEN 100.

  TYPES: BEGIN OF ERF_structure,
           artikelNR TYPE zaufgabe_art-artikelnr,
           kurztext  TYPE zaufgabe_art-kurztext,
           anzahl    TYPE i,
         END OF ERF_structure,



         BEGIN OF AUS_structure,
           artikelNR   TYPE zaufgabe_art-artikelnr,
           anzahl      TYPE i,
           kurztext    TYPE zaufgabe_art-kurztext,
           stuckpreis  TYPE zaufgabe_art-verkpreis,
           gesamtpreis TYPE zaufgabe_art-verkpreis,

         END OF AUS_structure,

         BEGIN OF datumstyp,
           jahr(4)  TYPE c,
           monat(2) TYPE c,
         END OF datumstyp.


  DATA:

*         Dynpro 100*
    benutzer     TYPE Z_Praxisaufgabe_key,
    passwort     TYPE Z_Praxisaufgabe_key,

*         Dynpro 200*
    itab         TYPE STANDARD TABLE OF erf_structure,
    ean          TYPE zaufgabe_art-artikelnr,
    anzahl       TYPE i,
*     Zeilenstruktur von erf_strucutre
    tab_satz     TYPE erf_structure,




*       Dynpro 300*
    aus_itab     TYPE STANDARD TABLE OF aus_structure,

*      Zeilenstruktur von aus_strucutre
    aus_tab_satz TYPE aus_structure,
    summe        TYPE zaufgabe_art-verkpreis,
    mwst         TYPE Z_Praxisaufgabe_betrag,
    mwstprozent  TYPE zaufgabe_mwst-mwstsatz,
    mwstclass    TYPE zaufgabe_mwst-mwstklasse,
    betrag       TYPE zaufgabe_art-verkpreis,
    rbetrag      TYPE zaufgabe_art-verkpreis,


*         Universäl attribute *

    ok_code      LIKE sy-ucomm,
    save_ok      LIKE ok_code,

*     Um Artikeln infos zu bringen
    tab_art      TYPE zaufgabe_art,
    mwststufe    TYPE z_praxisaufgabe_key,
    mwstbetrag   TYPE z_praxisaufgabe_prozent,



*     Attribute für Summenbericht Tabelle

    tab_bericht  LIKE  Zaufgabe_Bericht,

    date         TYPE d,
    datum        TYPE datumstyp.



END-OF-SELECTION.


*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR 'LOGIN'.

  CLEAR: benutzer, passwort.
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*


MODULE user_command_0100 INPUT.

  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'LOGON'.
      IF ( benutzer = 'USER' ) AND ( passwort = 'USER' ).
        LEAVE TO SCREEN 200 .
      ELSE.
        MESSAGE a012(zlearn_ENTWNACH).
        CLEAR: benutzer, passwort.
      ENDIF.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

MODULE status_0200 OUTPUT.
  SET PF-STATUS '200'.
  SET TITLEBAR 'ERFASSUNG'.

  CLEAR: ean,anzahl,tab_art,tab_satz, summe, betrag, rbetrag, mwst.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  save_ok = ok_code.

  CLEAR ok_code.

  CASE save_ok.
    WHEN'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 100.

    WHEN 'ADD'.

      IF ean IS INITIAL.
        MESSAGE i013(zlearn_ENTWNACH).
      ELSE.

        SELECT SINGLE * FROM zaufgabe_art INTO tab_art WHERE artikelnr = ean.

        IF sy-subrc = 4.
         MESSAGE i014(zlearn_ENTWNACH).
          CLEAR ean.
        ELSE.
          tab_satz-artikelnr = tab_art-artikelnr.
          tab_satz-kurztext = tab_art-kurztext.

          IF anzahl < 1 OR anzahl IS INITIAL.
            MESSAGE i015(zlearn_ENTWNACH).

          ELSE.
            tab_satz-anzahl = anzahl.

            APPEND tab_satz TO itab.

            IF sy-subrc = 0.
              CLEAR: ean, anzahl, tab_satz, tab_art.

            ELSE.
              ROLLBACK WORK.
              MESSAGE i016(zlearn_ENTWNACH).
            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

    WHEN 'BELEG'.

      IF  itab is INITIAL.
        MESSAGE i017(zlearn_ENTWNACH).

      ELSE.
        LOOP AT itab INTO tab_satz.

          aus_tab_satz-artikelnr = tab_satz-artikelnr.
          aus_tab_satz-anzahl = tab_satz-anzahl.
          aus_tab_satz-kurztext = tab_satz-kurztext.

          SELECT SINGLE verkpreis FROM zaufgabe_art INTO aus_tab_satz-stuckpreis
            WHERE artikelnr = tab_satz-artikelnr.

          aus_tab_satz-gesamtpreis = aus_tab_satz-anzahl * aus_tab_satz-stuckpreis.

          summe = summe + aus_tab_satz-gesamtpreis.

          SELECT SINGLE mwstklasse FROM zaufgabe_art INTO mwstclass WHERE artikelnr = tab_satz-artikelnr.

          SELECT SINGLE mwstsatz FROM zaufgabe_mwst INTO mwstprozent WHERE mwstklasse = mwstclass.

          mwst = ( mwstprozent / 100 )  * aus_tab_satz-stuckpreis.

          APPEND aus_tab_satz TO aus_itab.

          IF sy-subrc = 4.
            ROLLBACK WORK.
            MESSAGE i015(zlearn_ENTWNACH).
          ELSE.
            CLEAR: tab_satz, aus_tab_satz, mwstclass,mwstprozent.
          ENDIF.

        ENDLOOP.
        LEAVE TO SCREEN 300.
      ENDIF.

  ENDCASE.
ENDMODULE.



*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.


  SET PF-STATUS '300'.
  SET TITLEBAR 'BELEG'.

ENDMODULE.
MODULE user_command_0300 INPUT.

  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'NEXT'.
      IF betrag IS INITIAL.
        MESSAGE i018(zlearn_ENTWNACH).

      ELSE.
        CLEAR: save_ok, itab, tab_art, tab_satz, aus_itab, aus_tab_satz, betrag.

        LEAVE TO SCREEN 200.
      ENDIF.

    WHEN 'EXIT'.
      IF  betrag IS INITIAL.
        CLEAR save_ok.
        MESSAGE i019(zlearn_ENTWNACH).

      ELSE.
        LEAVE PROGRAM.
      ENDIF.

    WHEN 'BEZAHL'.


      IF betrag IS INITIAL.
        CLEAR: betrag, save_ok.
        MESSAGE i020(zlearn_ENTWNACH).

      ELSE.
        IF betrag < summe.
         MESSAGE i021(zlearn_ENTWNACH).
          CLEAR: betrag, save_ok.

        ELSE.
          CLEAR ok_code.
          rbetrag = betrag - summe.





          date = sy-datum.
          datum-jahr = date+0(4).
          datum-monat = date+4(2).


*          datum-jahr = '2024'.
*          datum-monat = '12'.



          LOOP AT aus_itab INTO aus_tab_satz.

            SELECT SINGLE * FROM zaufgabe_art INTO tab_art WHERE artikelnr = aus_tab_satz-artikelnr.

            mwststufe = tab_art-mwstklasse.

            SELECT SINGLE mwstsatz  FROM zaufgabe_mwst INTO mwstbetrag WHERE mwstklasse = mwststufe.


            SELECT SINGLE * FROM ZAUFGABE_Bericht INTO tab_bericht WHERE artikelnr = aus_tab_satz-artikelnr
              AND jahr = datum-jahr
              AND monat = datum-monat.

            IF sy-subrc = 0.

              tab_bericht-vmenge = tab_bericht-vmenge + aus_tab_satz-anzahl.
              tab_bericht-umsatz = tab_bericht-umsatz + aus_tab_satz-gesamtpreis.
              tab_bericht-erloes = tab_bericht-umsatz - ( tab_bericht-umsatz * ( mwstbetrag / 100 ) ).

              UPDATE zaufgabe_bericht SET
              vmenge = tab_bericht-vmenge
              umsatz = tab_bericht-umsatz
              erloes = tab_bericht-erloes
              WHERE artikelnr = aus_tab_satz-artikelnr
                            AND jahr = datum-jahr
                            AND monat = datum-monat.

              COMMIT WORK.

            ELSE.

              tab_bericht-artikelnr = aus_tab_satz-artikelnr.
              tab_bericht-monat = datum-monat.
              tab_bericht-jahr = datum-jahr.
              tab_bericht-kurztext = aus_tab_satz-kurztext.
              tab_bericht-vmenge = aus_tab_satz-anzahl.
              tab_bericht-vpreis = aus_tab_satz-stuckpreis.
              tab_bericht-umsatz = aus_tab_satz-gesamtpreis.
*              mwstberechnung = tab_bericht-umsatz * ( mwstbetrag / 100 ) .
              tab_bericht-erloes = tab_bericht-umsatz - ( tab_bericht-umsatz * ( mwstbetrag / 100 ) ) .

              INSERT INTO zaufgabe_bericht VALUES tab_bericht.

              COMMIT WORK.



            ENDIF.

          ENDLOOP.

          LEAVE TO LIST-PROCESSING.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TEST_TC200' ITSELF
CONTROLS: test_tc200 TYPE TABLEVIEW USING SCREEN 0200.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TEST_TC200'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE test_tc200_change_tc_attr OUTPUT.
  DESCRIBE TABLE itab LINES test_tc200-lines.
ENDMODULE.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TEST_TC300' ITSELF
CONTROLS: test_tc300 TYPE TABLEVIEW USING SCREEN 0300.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TEST_TC300'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE test_tc300_change_tc_attr OUTPUT.
  DESCRIBE TABLE aus_itab LINES test_tc300-lines.
ENDMODULE.

*          WRITE:/ 'TESTING',  tab_bericht-artikelnr, tab_bericht-monat,  '+' , tab_bericht-jahr,
*          tab_bericht-kurztext, tab_bericht-vmenge, tab_bericht-vpreis, tab_bericht-umsatz .

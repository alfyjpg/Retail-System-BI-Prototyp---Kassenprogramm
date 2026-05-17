*&---------------------------------------------------------------------*
*& Report Z_LEARN003_EAN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_LEARN003_EAN.

TYPES: betrag TYPE p DECIMALS 2,

       BEGIN OF datumstyp,
         jahr(4)  TYPE c,
         monat(2) TYPE c,
         tag(2)   TYPE c,
       END OF datumstyp.

PARAMETERS: EAN_Nr TYPE Z_PRAXISAUFGABE_Key,
            bar    TYPE betrag.

DATA: mwst     TYPE betrag,
      rubetrag TYPE betrag,
      datum    TYPE datumstyp,
      date     TYPE d,
      tab_art  TYPE ZAUFGABE_art,
      tab_mwst TYPE ZAUFGABE_mwst.

date = sy-datum.
datum-jahr = date+0(4).
datum-monat = date+4(2).
datum-tag = date+6(2).


START-OF-SELECTION.

*--------------Eingabefeldern überprüfen--------------

  IF EAN_Nr IS INITIAL OR bar IS INITIAL.
    MESSAGE 'Eigabefeldern dürfen nicht leer sein' TYPE 'E' .
  ENDIF.

*---------------Artikelinformation aufrufen--------------

  SELECT SINGLE * FROM ZAUFGABE_art INTO tab_art
  WHERE artikelnr = EAN_Nr.

  IF sy-subrc <> 0.
    MESSAGE  'Artikel ist nicht vorhanden' TYPE 'A'.


  ELSE.

*--------------Bezahlungsmöglichkeite überprüfen--------------

    IF bar < tab_art-verkpreis.
      MESSAGE 'Gegebene Beitrag reicht nicht zum Bezahlen aus!'  TYPE 'E'.
    ENDIF.

*--------------Artikel ausgeben--------------

    WRITE:/ ,25 'Kassenbeleg der Kaufrausch AG',/,
      25 'Ihr Einkauf vom', datum-tag, datum-monat, datum-jahr.

    WRITE:/ 'EAN_Numme', 15 'Artikel', 50 'Betrag',/,/,/.

    WRITE:/ EAN_Nr, 15 tab_art-kurztext, 45 tab_art-verkpreis,/,/,/,
    'erhaltene in Bar:', 40 bar,/,
    '-----------------------------------------------------------------------'.

*   --------------Rückbetrag berechnen--------------

    rubetrag = bar - tab_art-verkpreis.
    WRITE:/ 'Rückgabebetrag :', 40 rubetrag,/,/,/.

*  --------------MWST Klasse aufrufen und berechnen--------------

    SELECT SINGLE * FROM ZAUFGABE_mwst INTO tab_mwst WHERE mwstklasse = tab_art-mwstklasse.

    mwst = ( tab_mwst-mwstsatz / 100 ) * tab_art-verkpreis.
    WRITE:/ 'Erhaltene MWST: ', 40 mwst,/,/,/,
    '-------------------- Vielen Dank für Ihren Einkauf --------------------'.

  ENDIF.

END-OF-SELECTION.

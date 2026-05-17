*&---------------------------------------------------------------------*
*& Report Z_LEARN003_ARTIKELLISTE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_LEARN003_ARTIKELLISTE.


DATA tab_artikel LIKE zaufgabe_art.
DATA  mwst type zaufgabe_mwst.
DATA mwssatz TYPE p DECIMALS 2.
*&---------------------------------------------------------------------*
*& Processing Blocks called by the Runtime Environment #*
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  WRITE /10 'In Tabelle ZLEARNxxx_ART gespeicherte Datensätze:'.
  SKIP.
  WRITE: / 'Artikelnr.', 14 'Bezeichnung', 35 'Verkaufspreis', 57 'MWST-Satz'.
  SKIP.


  SELECT * FROM zaufgabe_art
      INTO tab_artikel.
    WRITE: / tab_artikel-artikelnr,
    tab_artikel-kurztext,
    tab_artikel-verkpreis.

    SELECT * FROM zaufgabe_mwst INTO mwst WHERE mwstklasse = tab_artikel-mwstklasse  .

      mwssatz = ( mwst-mwstsatz / 100 ) * tab_artikel-verkpreis.
      WRITE mwssatz.



    ENDSELECT.
  ENDSELECT.
  SKIP.
  WRITE: / '------------------------',
   ' Ende der Liste -------------------------'.

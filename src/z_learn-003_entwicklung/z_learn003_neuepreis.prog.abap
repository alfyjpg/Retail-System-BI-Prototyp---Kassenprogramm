*&---------------------------------------------------------------------*
*& Report Z_LEARN003_NEUEPREIS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_LEARN003_NEUEPREIS.



PARAMETERS: a_nummer TYPE z_PRAXISAUFGABE_key,
            neupreis TYPE z_PRAXISAUFGABE_betrag.


DATA: tab_art  TYPE ZAUFGABE_Art.

START-OF-SELECTION.

  IF a_nummer IS INITIAL AND neupreis IS INITIAL.
    WRITE :/ 'Eingabe Feldern dürfen nicht leer sein'.
  ENDIF.

*&--------------- Überprüfen der Artikelnummer --------------------*
  SELECT SINGLE * FROM ZAUFGABE_Art INTO tab_art
  WHERE artikelnr = a_nummer.

*&--------------- Datensatz aufbereiten und Änderungsmeldung ---------*

  IF sy-subrc = 0.

    WRITE:/ 'Artikel-Nummer: ', a_nummer, ' ', 50 tab_art-kurztext,/,
            'VK_Preis (alt): ', 50 tab_art-verkpreis,/.
    tab_art-verkpreis = neupreis.
    WRITE:        'VK_Preis (neu): ', 50 tab_art-verkpreis,/,/.

*&--------- geänderten Datensatz in Tabelle zurückschreiben ----------*
    UPDATE ZAUFGABE_ART SET verkpreis = neupreis WHERE artikelnr = a_nummer.

    IF sy-subrc = 0.
      COMMIT WORK.
      WRITE: '------------ Preis des Artikels wurde geändert.------------'.
    ELSE.
      MESSAGE E004(ZLEARN_ENTWNACH) .
      ROLLBACK WORK.
    ENDIF.

  ELSE.
        MESSAGE E005(ZLEARN_ENTWNACH) .
  ENDIF.


END-OF-SELECTION.

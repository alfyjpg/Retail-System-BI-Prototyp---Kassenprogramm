*&---------------------------------------------------------------------*
*& Report Z_LEARN003_ARTIKELLOESCHEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_LEARN003_ARTIKELLOESCHEN.


PARAMETERS: a_nummer TYPE z_PRAXISAUFGABE_key.

DATA: tab_art TYPE zaufgabe_art,
      old_art LIKE a_nummer.


START-OF-SELECTION.

  IF a_nummer IS INITIAL.
    MESSAGE i009(ZLEARN_ENTWNACH).
  ENDIF.

*&--------------- Überprüfen der Artikelnummer --------------------*

  SELECT SINGLE * FROM zaufgabe_art INTO tab_art
    WHERE artikelnr = a_nummer.

  CASE sy-subrc.
    WHEN 4.
      MESSAGE E010(ZLEARN_ENTWNACH).

*&--------- Datensatz in Tabelle löschen und Quittung ------*
    WHEN 0.
      old_art = a_nummer.
      DELETE FROM zaufgabe_art WHERE artikelnr = a_nummer.
      IF sy-subrc = 0.
        COMMIT WORK.
        WRITE : 'Der Artikel: ' , old_art , 'wurde erfolgreich gelöscht'.
      ELSE.
        ROLLBACK WORK.
        MESSAGE E011(ZLEARN_ENTWNACH).
      ENDIF.

  ENDCASE.

END-OF-SELECTION.

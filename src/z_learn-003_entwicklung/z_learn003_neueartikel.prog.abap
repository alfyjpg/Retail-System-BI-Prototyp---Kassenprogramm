*&---------------------------------------------------------------------*
*& Report Z_LEARN003_NEUEARTIKEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_LEARN003_NEUEARTIKEL.


PARAMETERS:
  a_nummer TYPE zaufgabe_art-artikelnr,
  kurztext TYPE zaufgabe_art-kurztext,
  langtext TYPE zaufgabe_art-langtext,
  vk_preis TYPE zaufgabe_art-verkpreis,
  mwst_kls TYPE zaufgabe_art-mwstklasse.

DATA: tab_mwst TYPE zaufgabe_mwst,
      tab_art  TYPE zaufgabe_art.

START-OF-SELECTION.

  IF a_nummer IS  INITIAL AND kurztext IS INITIAL AND vk_preis IS INITIAL AND mwst_kls IS INITIAL.
    MESSAGE 'Bitte Eingabe Feldern ausfüllen' TYPE 'E'.
  ENDIF.

*&--------------- Überprüfen der Artikelnummer --------------------*

  SELECT SINGLE * FROM zaufgabe_ART INTO tab_art WHERE artikelnr = a_nummer.

  CASE sy-subrc.
    WHEN 0.
      MESSAGE  a001(zlearn077).
    WHEN 4.

*&--------------- Überprüfen der MWST-Klasse --------------------*

      SELECT SINGLE * FROM zaufgabe_mwst INTO tab_mwst WHERE mwstklasse = mwst_kls.

      CASE sy-subrc.
        WHEN 4.
          MESSAGE 'Ungültige MWST-Klasse(Nicht in Tabelle enthalten)' TYPE 'E'.
        WHEN 0.

*&--------------- Datensatz aufbereiten -----------------*

          CLEAR tab_art.

          tab_art-artikelnr = a_nummer.
          tab_art-kurztext = kurztext.
          tab_art-langtext = langtext.
          tab_art-verkpreis = vk_preis.
          tab_art-mwstklasse = mwst_kls.

*&--------------- neuen Datensatz in Tabelle einfügen -----------------*

          INSERT INTO zaufgabe_art VALUES tab_art.

          IF sy-subrc <> 0.
            ROLLBACK WORK.
            MESSAGE a002(zlearn077).
          ELSE.
            WRITE 'Datensatz wurde hinzugefügt.'.
          ENDIF.
      ENDCASE.
  ENDCASE.

END-OF-SELECTION.

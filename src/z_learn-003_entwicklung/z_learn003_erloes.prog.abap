*&---------------------------------------------------------------------*
*& Report Z_LEARN003_ERLOES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_LEARN003_ERLOES.


DATA:

  berichtzeile TYPE zaufgabe_bericht,
  artikelinfo  TYPE zaufgabe_art,
  mwst         TYPE z_praxisaufgabe_betrag,
  nerloes      TYPE z_praxisaufgabe_betrag.


SELECT * FROM Zaufgabe_bericht INTO berichtzeile.

  SELECT SINGLE * FROM zaufgabe_art INTO artikelinfo WHERE artikelnr = berichtzeile-artikelnr.

  SELECT SINGLE mwstsatz FROM zaufgabe_mwst INTO mwst WHERE mwstklasse = artikelinfo-mwstklasse.

  nerloes = ( berichtzeile-umsatz - ( berichtzeile-umsatz * ( mwst / 100 ) ) ).

  UPDATE zaufgabe_bericht SET
    erloes = nerloes
    WHERE jahr = berichtzeile-jahr
    AND monat = berichtzeile-monat
    AND artikelnr = berichtzeile-artikelnr.

ENDSELECT.

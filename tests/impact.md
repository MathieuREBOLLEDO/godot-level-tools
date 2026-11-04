# Carte d'impact des tests

Quand une brique change : lancer ses tests pendant le travail, puis tous les
tests de l'addon (moins d'une seconde) avant d'annoncer la tâche finie, puis
les tests des jeux dont un éditeur utilise la brique.

Les tests tournent dans un jeu qui a l'addon et le test runner
(ProjetGringo, addons/level_tools) :
`.\tests\run_tests.ps1 -Dir res://addons/level_tools`, ou un seul test avec
`-Filter <texte>`.

| Brique (dossier) | Ses tests | Touche aussi |
|---|---|---|
| Tout fichier de l'addon (chargement, compilation) | `-Filter addon_files_load` | — |
| Textes (i18n/) | `-Filter translation` | textes de tous les éditeurs |
| Thème (theme/) | `-Filter theme` | apparence de tous les éditeurs ; vérifier sur capture (tests/demo_editor.tscn) |
| Annuler (undo/) | `-Filter test_history`, `-Filter shell_undo` | tous les éditeurs qui ont Ctrl+Z |
| Champ lié (fields/) | `-Filter value_field` | panneaux de réglages |
| Fichiers (document/lt_files.gd) | `-Filter test_documents` | import, dernier fichier rouvert |
| Document (document/lt_document.gd) | `-Filter document` | enregistrer, renommer, ouvrir un autre |
| Bibliothèque (document/lt_library*.gd) | `-Filter library` | listes des éditeurs |
| Coque (shell/) | `-Filter shell` | tous les éditeurs |
| Validateur (validator/) | `-Filter test_validator` | compteur du pied de tous les éditeurs ; tests des niveaux finis des jeux |
| Zone (view/lt_cell_selection.gd) | `-Filter cell_selection` | zones de Gringo Level, Pinball Modules, Rooms (annuler de chaque éditeur) |
| Mode chemin (view/lt_path_editor.gd) | `-Filter path_editor` | plateformes mobiles de Gringo, vagues de BatEmUp |
| Vue (view/) | `-Filter view` | canvas de Gringo Level, Pinball Modules, Rooms ; vérifier les gestes à la main |
| Palette (palette/) | `-Filter palette` | palettes de Pinball Modules et des Rooms (ordre et favoris dans user://) |
| Essayer (playtest/) | `-Filter playtest` | lancement du jeu depuis les éditeurs ; côté jeu, la lecture de la demande |
| Onglets ensemble ↔ pièce (workspace/) | `-Filter workspace` | Map \| Level de Gringo (onglet et niveau rouverts) |
| Marques (document/lt_flags.gd) | `-Filter flag` | LevelData de Gringo (`-Filter test_level_data`), filtres Flags des bibliothèques |
| Usages, import, grille (lt_library.gd) | `-Filter library_usage`, `-Filter library_import` | bibliothèque de la carte de Gringo |
| Colonne de réglages (shell/lt_settings.gd) | `-Filter settings_column` | colonnes de réglages des éditeurs |
| Annuler / Refaire de l'en-tête (LtShell.add_undo_buttons) | `-Filter shell_undo_buttons` | Map et Level de Gringo |
| Live edit (live/lt_live_edit.gd, LtHistory.checkpoint(état)) | `-Filter test_live_edit` | live edit de Gringo (game/level/tests/test_live_edit.gd) ; BatEmUp, Pinball, DungeonTactics : sans tests, à vérifier en jeu (debug menu > Live edit) |

Non couvert par les tests : la mise à la corbeille (LtFiles.trash, elle
remplirait la corbeille du système), le lancement réel du jeu
(LtPlaytest.play), les couleurs prises au thème de l'éditeur Godot
(follow_editor : seulement dans l'éditeur).

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
| Essayer (playtest/) | `-Filter playtest` | lancement du jeu depuis les éditeurs ; côté jeu, la lecture de la demande |

Non couvert par les tests : la mise à la corbeille (LtFiles.trash, elle
remplirait la corbeille du système), le lancement réel du jeu
(LtPlaytest.play), les couleurs prises au thème de l'éditeur Godot
(follow_editor : seulement dans l'éditeur).

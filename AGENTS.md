# Level Tools (addon Godot)

Addon Godot 4.7 : briques communes des éditeurs de niveaux des jeux
(thème, textes, coque d'écran, fichiers, bibliothèque, annuler, champs,
Essayer). Chaque jeu assemble ses éditeurs avec ces briques ; le contenu
(éléments, données, dessin) reste dans le jeu. GDScript typé uniquement.
État du travail en cours : PLAN.md (le lire en début de session ; en fin
de tâche, le mettre à jour).

## Règles de travail
- Ne pas ajouter de systèmes ou de fonctionnalités non demandés.
- Code simple et lisible plutôt qu'une architecture générique : une brique
  n'existe que si au moins deux éditeurs s'en servent.
- **Aucune fonctionnalité d'un éditeur ne disparaît** en passant sur les
  briques (Gringo Map et Level, RoguePinball, BatEmUp surtout) : un geste
  peut changer, tout doit rester faisable. Inventaire avant chaque
  migration : docs/inventory/<jeu>_<éditeur>.md, validé par l'utilisateur.
- Le travail avance par phase du plan (PLAN.md) ; compte rendu et
  validation en fin de phase.
- Ne pas modifier l'architecture sans proposer un plan et attendre
  validation. Ne pas commiter sans qu'on le demande.

## Contraintes de l'addon
- Aucune dépendance : ni autre addon (debug menu compris), ni fichier d'un
  jeu. Le jeu fournit son contenu par des Callable.
- Tous les chemins en res://addons/level_tools/...
- Godot 4.7 minimum (dictionnaires typés, variables statiques permis).
- Tourne en jeu et dans l'éditeur Godot : EditorInterface seulement par
  Engine.get_singleton(), après Engine.is_editor_hint().
- Classes globales préfixées Lt (LtTheme, LtHistory...) pour ne pas
  heurter celles des jeux.
- Dépôt Git à part, utilisé comme sous-module addons/level_tools par les
  jeux : un commit ici part dans ce dépôt.

## Règles d'interface
- Textes en anglais dans le code avec LtText.t("…"), traduits par
  i18n/fr.gd ; un jeu ajoute ses textes avec LtText.register().
  Commentaires en français, noms en anglais.
- Design : DESIGN.md (jetons lus dans res://design_tokens.cfg du jeu, thème
  dans theme/lt_theme.gd, pas de couleur en dur dans les briques).

## Dossiers
- i18n/ : LtText et dictionnaire français. theme/ : LtTheme.
- shell/ : LtShell (en-tête, corps, pied), LtSettings (colonne de réglages).
  document/ : LtFiles, LtDocument, LtLibrary et ses cartes (usages, import,
  grille), LtFlags (marques DPRC, EXCL). undo/ : LtHistory.
  fields/ : LtValueField.
- workspace/ : LtWorkspace (onglets ensemble ↔ pièce).
- playtest/ : LtPlaytest (Essayer en jeu).
- live/ : LtLiveEdit (live edit en jeu : pause, fenêtre flottante
  LtFloatingPanel, barre, annuler), LtLiveHost (ce que le jeu donne).
- layers/ : LtLayers (calques du réglage level_tools/layers).
- validator/ : LtValidator, LtProblem (règles du jeu, compteur du pied).
- view/ : LtView (zoom, déplacement, cadrage, rotation : gestes communs).
- palette/ : LtPalette, LtPaletteSlot (gomme, pages, touches, favoris).
- icons/ : LtIcons (icônes des en-têtes et de la palette).
- tests/ : tests et impact.md.
- docs/guide.md : comment assembler un éditeur. docs/inventory/ :
  inventaires des éditeurs avant migration.

## Conventions
- Fichiers et dossiers en snake_case ; un script par rôle.
- Variables et fonctions annotées (GDScript typé).

## Test
- Les tests tournent dans ProjetGringo, qui a l'addon et le test runner :
  `.\tests\run_tests.ps1 -Dir res://addons/level_tools` (ou `-Filter`).
- Chargement headless :
  `"G:\GameEngine\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path "G:\Projects\Godot\ProjetGringo" --quit`
- Quel test pour quel système : tests/impact.md ; une nouvelle fonction
  arrive avec ses tests et sa ligne dans ce tableau.
- L'affichage se vérifie à la main, sur capture d'écran.

# Plan

Plan D (2026-11-03) : briques communes des éditeurs, puis migration des
jeux un par un. Validation par l'utilisateur à la fin de chaque phase.
Règle : aucune fonctionnalité d'un éditeur ne disparaît (inventaire avant
chaque migration, docs/inventory/).

## Phase 1 : le socle (faite le 2026-11-03, à valider)
- [x] Thème (LtTheme), fusion de LevelToolsTheme (Gringo) et ToolsTheme
      (BatEmUp) ; variante LEGEND pour les pastilles de légende de Gringo.
- [x] Textes (LtText) : réglage du projet level_tools/language, register().
- [x] Coque (LtShell), fichiers (LtFiles), document (LtDocument),
      bibliothèque (LtLibrary, LtLibraryCard), annuler (LtHistory), champ
      (LtValueField), Essayer (LtPlaytest).
- [x] Tests (35) et tests/impact.md ; éditeur d'exemple tests/demo_editor.tscn.
- [ ] Dépôt GitHub à créer (utilisateur), puis sous-module dans ProjetGringo
      à la place du lien (jonction) addons/level_tools actuel.

## Phase 2 : migrations (BatEmUp, Gringo, RoguePinball, DungeonTactics)
- [ ] Inventaire de chaque éditeur (docs/inventory/), validé avant de
      toucher au code.
- [ ] RoguePinball et DungeonTactics n'ont pas de design_tokens.cfg : y
      écrire leurs couleurs actuelles pour garder leur apparence.
- [ ] Gringo : le fichier de la dernière carte reste user://map_editor.cfg
      (LtFiles.remember prend le chemin), rien à perdre.

## Phases suivantes
3 validateur, 4 canvas sur grille, 5 ensemble ↔ pièce, liens, puzzle
(détail dans le plan approuvé, résumé dans CLAUDE.md).

## Décisions
- 2026-11-03 : classes globales préfixées Lt plutôt que preload : plus
  simple à utiliser dans les jeux, sans heurter leurs classes.
- 2026-11-03 : pas de plugin.cfg ni de dossier editor/ pour l'instant :
  aucune brique n'en a besoin (EditorInterface passe par Engine).
- 2026-11-03 : colonnes de la coque redimensionnables (HSplitContainer),
  largeur de départ fixée par l'éditeur.

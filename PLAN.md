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
- [x] Dépôt GitHub (github.com/MathieuREBOLLEDO/godot-level-tools), poussé ;
      sous-module addons/level_tools de ProjetGringo (ajouté, pas encore
      commité dans ProjetGringo).
- [x] plugin.cfg (project_init exige un plugin.cfg) : déclare le réglage
      level_tools/language.
- [x] project_init installe et active level tools et écrit design_tokens.cfg
      (copie de celui de Gringo) ; project_updater installe déjà tout
      sous-module, rien à y ajouter.

## Phase 2 : migrations (BatEmUp, Gringo, RoguePinball, DungeonTactics)
- [x] Inventaires BatEmUp validés (Try des patterns : choix B + Assign).
- [x] Briques complétées : Entrée dans le nom = enregistrer, groupes
      d'en-tête à gauche, confirmation, Rename depuis la bibliothèque.
- [x] BatEmUp migré (Levels, Bullet Patterns) le 2026-11-03 : vérifié par
      capture et script ; pas commité dans BatEmUp (branche gameplay).
- [x] Inventaires Gringo, RoguePinball, DungeonTactics validés (les
      recommandations).
- [x] Gringo migré (Map, Level, navigateur, live edit ; textes en LtText
      avec table française game/level/level_tools_text.gd) : captures avant /
      après identiques, script de vérification, 239 tests du jeu.
- [x] RoguePinball migré (Tables : Table, Modules ; annuler de l'éditeur
      Godot gardé) et DungeonTactics migré (Map painter, Dungeons, Rooms ;
      annuler ajouté à Dungeons et Rooms, pipette corrigée) : vérifiés par
      script et captures. Non vérifié : les clics réels dans l'éditeur Godot.
- [ ] Rien n'est commité dans les jeux (BatEmUp, ProjetGringo, RoguePinball,
      DungeonTactics) ni dans project_init : à faire sur demande.
- [ ] Brique à venir si besoin : pied avec statut persistant et bouton
      (Map painter de DungeonTactics passe aujourd'hui par footer_label).
- [x] design_tokens.cfg de Gringo copié dans RoguePinball et DungeonTactics
      (mêmes valeurs que leurs défauts : rien ne change à l'écran).
- [ ] Gringo : le fichier de la dernière carte reste user://map_editor.cfg
      (LtFiles.remember prend le chemin), rien à perdre.

## Phases suivantes
3 validateur, 4 canvas sur grille, 5 ensemble ↔ pièce, liens, puzzle
(détail dans le plan approuvé, résumé dans CLAUDE.md).

## Décisions
- 2026-11-03 : design_tokens.cfg de ProjetGringo = la règle pour tous les
  projets ; une retouche s'y fait d'abord, puis se recopie (les autres
  projets ont chacun leur copie).
- 2026-11-03 : copie de travail = le sous-module de ProjetGringo (c'est lui
  que les tests lancent) ; le clone G:\Projects\Godot_Addons\godot-level-tools
  se remet à jour par git pull.
- 2026-11-03 : classes globales préfixées Lt plutôt que preload : plus
  simple à utiliser dans les jeux, sans heurter leurs classes.
- 2026-11-03 : pas de plugin.cfg ni de dossier editor/ pour l'instant :
  aucune brique n'en a besoin (EditorInterface passe par Engine).
- 2026-11-03 : colonnes de la coque redimensionnables (HSplitContainer),
  largeur de départ fixée par l'éditeur.

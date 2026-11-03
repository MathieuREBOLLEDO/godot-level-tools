# Inventaire de non-régression : 5 éditeurs (lecture seule, aucune modification)

## Bases et périmètre

Les fichiers sont cités relativement à leur dossier de base. Les lignes viennent de la lecture complète de chaque fichier.

- **RP** = `G:\Projects\Godot\RoguePinball\addons\table_editor\`
- **RL** = `G:\Projects\Godot\RoguePinball\game\gameplay\run_layout.gd`
- **DM** = `G:\Projects\Godot\DungeonTactics\addons\map_painter\`
- **DB** = `G:\Projects\Godot\DungeonTactics\addons\dungeon_builder\`

Scripts du jeu appelés mais non lus, donc hors inventaire : TableGeometry, ElementCatalog, SectionCatalog, TableLayout, ModulePlacement, TableSection, DungeonLayout, RoomTemplate, DungeonCatalog, RoomTemplates, DeckCatalog, map_palette.gd, map_marks.gd, map_position.gd, GameState, Log, les `.translation` de `game/ui/translations/`, `design_tokens.cfg`, `plugin.cfg`. Les props, couleurs et noms d'objets en viennent.

## Constats transverses (vérifiés par grep sur les 3 dossiers)

- Aucun `_input`, `_shortcut_input`, `_unhandled_input` ni `_unhandled_key_input`. Tous les raccourcis sont dans `_gui_input`, donc actifs seulement quand le contrôle a le focus. Le canvas prend le focus au clic gauche.
- Ctrl+S de l'éditeur est branché seulement sur DT Map (`DM/plugin.gd:34`) et DT Dungeons (`DB/plugin.gd:55`, qui enregistre aussi les pièces). Pinball Table et Pinball Modules n'ont pas de `_save_external_data`.
- Annulation : Pinball (historique de l'éditeur, `EditorUndoRedoManager`) et DT Map (pile interne) seulement. DT Dungeons et DT Rooms n'ont aucune annulation.
- Pas de confirmation avant de perdre des modifications. Pinball : Ouvrir, Nouvelle, changer de module écrasent les modifs non enregistrées. DT : changer de donjon ou de pièce enregistre la précédente automatiquement. Fermer l'éditeur sans enregistrer ne fait rien.
- Suppressions : DT envoie le fichier à la corbeille après confirmation. Pinball supprime immédiatement, annulable par Ctrl+Z de l'éditeur.

---

# 1. Pinball Table (onglet Table)

## 1.1 Onglet et plugin (RP/plugin.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_enter_tree` | Activation : enregistre le réglage de langue, crée l'onglet, écoute `settings_changed` | plugin.gd:22-26 |
| `_exit_tree` | Désactivation : déconnecte, libère l'onglet | plugin.gd:28-32 |
| `_create` | Crée le TabContainer, onglets « Table » (0) et « Modules » (1), branche `module_requested`, `module_saved`, `module_edited`, ajoute à la zone principale | plugin.gd:51-72 |
| `_has_main_screen` / `_make_visible` | Onglet principal « Tables », à côté de 2D, 3D, Script | plugin.gd:34-41 |
| `_get_plugin_name` / `_get_plugin_icon` | « Tables », icône GridContainer de l'éditeur | plugin.gd:43-48 |
| `_open_module` | Double-clic sur un module peint ou bouton « Modifier le module » : ouvre dans Modules et bascule l'onglet | plugin.gd:75-78 |
| `_rename_modules_tab` | Titre « Modules » ou « Modules · nom » | plugin.gd:81-83 |
| `_on_settings_changed` | Changement de langue ou de thème : onglet entier reconstruit (`Tokens.reload`). La zone est rouverte depuis la métadonnée (table_editor.gd:65-66), donc les modifs non enregistrées ne reviennent pas | plugin.gd:87-95 |

## 1.2 En-tête et fichiers (RP/table_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_ready` | Ouverture : rouvre la dernière zone (métadonnée `last_layout`), sinon `classic.tres`, en différé | table_editor.gd:53-66 |
| `_build_header` | Bandeau : surtitre « ROGUE PINBALL · TABLES », titre « nom · fichier » (• si modifié). Boutons : Nouvelle, Ouvrir, Enregistrer, Enregistrer sous, Cadrer, Modifier le module, Tester ▶ | table_editor.gd:71-96 |
| Bouton Nouvelle (`_new_layout`) | Zone « Zone sans nom » sans chemin, modifiée, avec 4 modules de départ (top, field, flippers, lane) | table_editor.gd:84, 285-296 ; STARTER_MODULES 26-31 |
| Bouton Ouvrir (`_ask_path` OPEN) | EditorFileDialog, accès ressources, filtre `*.tres`, dossier `res://game/level/layouts/` | table_editor.gd:85, 328-339 |
| `_on_file_selected` | Selon le mode du dialogue : ouvrir (`_open`) ou enregistrer sous (`_save`) | table_editor.gd:342-347 |
| `_open` | Charge avec `CACHE_MODE_IGNORE_DEEP` (« Enregistrer sous » n'altère pas la ressource d'origine), affiche, mémorise. Fichier illisible : rien, sans message | table_editor.gd:299-306 |
| `_remember` | Métadonnée projet (EditorSettings) `table_editor / last_layout` | table_editor.gd:308-310 ; 33-35 |
| Bouton Enregistrer (`_save`) | Sans chemin : ouvre Enregistrer sous. Sinon `_save_sections`, puis `ResourceSaver.save` de la zone, `update_file`, `dirty = false`, mémorise, rafraîchit la palette, affiche « Enregistré : … » (print) | table_editor.gd:86, 312-326 |
| `_save_sections` | Écrit dans `res://game/level/sections/` les modules peints sans chemin ou au chemin « :: ». Crée le dossier | table_editor.gd:259-269 |
| `_free_section_path` | Nom = display_name en snake_case (« module » si vide), puis `_2`, `_3`... si le fichier existe | table_editor.gd:271-280 |
| Bouton Enregistrer sous | `_ask_path` SAVE : ignoré si aucune zone ouverte ; `_path` = choix, puis `_save` | table_editor.gd:87, 328-347 |
| `_show_layout` | Affiche une zone (ou rien), `dirty = false`, désélectionne, cadre en différé | table_editor.gd:180-191 |
| `_refresh_status` | Titre et pied. Sans zone : « — » | table_editor.gd:193-204 |
| `_build_empty_state` | État vide : « Ouvrir Classic » (principal, `classic.tres`), « Nouvelle » | table_editor.gd:124-137 |
| Raccourcis clavier | Aucun raccourci propre (Ctrl+N, Ctrl+O, Ctrl+S non gérés) | — |

**E/S (fichiers)** : lit la métadonnée `last_layout`, les zones `.tres`, les modules `.tscn` de départ. Écrit les zones `.tres`, les sections `.tres` (`game/level/sections/`), la métadonnée et `user://table_editor_test_layout.txt` (Test).

## 1.3 Bibliothèque / palette (RP/palette.gd, palette_item.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_ready` (palette) | Panneau de 210 px à gauche, défilement vertical seulement | palette.gd:25-35 |
| `refresh` | Reconstruit la liste en 4 blocs : MODULES (scènes `game/level/modules/*.tscn`, nom + taille), MODULES PEINTS (« Nouveau module » puis sections `.tres`), ÉLÉMENTS (ElementCatalog.TYPES) | palette.gd:38-60 |
| `_module_paths` | Liste les `.tscn` de `game/level/modules/` | palette.gd:63-68 |
| `_add_header` | Titres de bloc (Overline), espacement sauf le premier | palette.gd:71-78 |
| `_add_item` | Un bouton par entrée ; clic émet `item_activated(data)` | palette.gd:81-86 |
| `_cascade` | Apparition en cascade : 25 ms par entrée, 0,18 s | palette.gd:89-97 |
| Clic sur une entrée | Ajoute au centre de la vue (`view_center`, arrondi 0,25 m) | table_editor.gd:104-107 |
| Glisser une entrée | `_get_drag_data` renvoie le dictionnaire ; aperçu = nom en accent | palette_item.gd:44-49 |
| Dépôt sur le canvas | `_can_drop_data` (clé `table_editor_item`) puis `_drop_data` | table_canvas.gd:422-427 |
| `drop_item` | module : `ModulePlacement` en cellule ; section : nouvelle `TableSection` (id vide) ou fichier ; élément : `ElementCatalog.new_placement` arrondi 0,25 m | table_canvas.gd:431-445 |
| `setup` (style) | Pastille 12 px, nom, détail en chasse fixe à droite (taille du module), survol `ink_raised`, focus désactivé | palette_item.gd:15-31 |
| `_draw` | Pastille + détail | palette_item.gd:34-41 |

## 1.4 Canvas, mode normal (RP/table_canvas.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_gui_input` | Ignoré si aucune zone. Dispatche souris et clavier (touches : press, sans echo) | table_canvas.gd:168-179 |
| `_on_mouse_button` (molette) | Molette haut/bas : zoom ×1,15 / ÷1,15 autour du curseur, bornes 15–220 px/m | table_canvas.gd:182-187 ; ZOOM 31-32 |
| Clic droit glissé | Déplace la vue (pan), ne sélectionne pas | table_canvas.gd:188-189 |
| Clic milieu glissé | Déplace la vue (pan) | table_canvas.gd:188-189 |
| Clic gauche sur objet | Sélectionne, prend le focus, prépare le déplacement | table_canvas.gd:196-198, 227-241 |
| Clic gauche glissé sur module | Déplace à la cellule (arrondi) | table_canvas.gd:211-214 |
| Clic gauche glissé sur élément | Déplace à 0,25 m ; Alt maintenu : pas libre | table_canvas.gd:216-217 |
| Clic gauche glissé sur bout de mur | Mur sélectionné : tire le bout « from » ou « to » (rayon de prise 10 px) ; Alt : pas libre | table_canvas.gd:229-234, 218-223 |
| Clic gauche dans le vide | Désélectionne et déplace la vue | table_canvas.gd:235-239 |
| Relâchement gauche | Enregistre l'action (déplacement, bout de mur) si la valeur a changé | table_canvas.gd:200, 244-252 |
| Double-clic gauche sur module peint | Ouvre la section dans l'onglet Modules (`section_requested`). Sur autre chose : rien | table_canvas.gd:191-195 |
| Suppr / Retour arrière | Supprime l'objet sélectionné (module ou élément) | table_canvas.gd:257-259 |
| R | Élément sélectionné : +15° ; Maj+R : -15° ; module : rien | table_canvas.gd:260-264 |
| M | Élément qui a un `side` : inverse le côté ; sinon rien | table_canvas.gd:265-271 |
| Ctrl+D | Duplique la sélection (élément +0,5 m en x et z ; module +1 cellule en x et y) via `add_item` | table_canvas.gd:272-279 |
| F | Cadrer tout (`frame_all`) | table_canvas.gd:280-281 |
| Touche non listée | Non consommée (passe à l'éditeur) | table_canvas.gd:282-283 |
| Mouvement souris | Émet `cursor_moved` (affichage x / z) | table_canvas.gd:204-206 |
| Non géré | Espace, Échap, Tab, double-clic élément, clic droit sur objet | — |

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| `select` | Sélection unique, émet `selection_changed` | table_canvas.gd:141-144 |
| `pick` | Élément sous le point (le dernier posé d'abord), puis module | table_canvas.gd:147-164 |
| `pick_radius` | Rayon de prise : cercle/anneau/fente = rayon ; flipper = 0,6 × longueur ; triangle 0,7 ; mur 0,2 ; défaut 0,35 | table_canvas.gd:120-128 |
| `add_item` | Action « Ajouter à la table », sélection, animation de pose (rebond 0,25 s) | table_canvas.gd:450-456 |
| `remove_item` | Action « Supprimer de la table » | table_canvas.gd:459-464 |
| `_commit_property` | Action à valeur déjà appliquée (`commit_action(false)`) | table_canvas.gd:467-477 |
| `_insert` / `_erase` / `_edited` | Opérations annulables : ajout, retrait (désélectionne si sélectionné), redessin | table_canvas.gd:480-500 |
| `frame_all` | Cadre la zone et les éléments (marge 1,5 m) | table_canvas.gd:105-116 |
| `view_center` | Centre de la vue en mètres, arrondi 0,25 m | table_canvas.gd:91-92 |

## 1.5 Inspecteur (RP/table_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_on_selection_changed` | Inspecteur : l'objet sélectionné, ou la zone (TableLayout) si rien. Active « Modifier le module » seulement si module peint | table_editor.gd:224-227 |
| `_on_inspector_edited` | Modif dans l'Inspecteur (zone, module, élément, section) : marque modifié et rafraîchit le titre. Pas d'action annulable propre à l'addon (c'est l'Inspecteur de Godot) | table_editor.gd:229-236 |
| Champs éditables (RP/README.md:28-29) | Zone : nom. Élément/module : props (points, couleur, série de cibles...) (noms exacts dans les scripts du jeu, non lus) | README.md:28-29 |

## 1.6 Pied et problèmes (RP/table_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_build_footer` | Pied : stats (Mono), curseur (Mono), problèmes (Problem), aide (Dim, à droite, ellipse, tooltip) | table_editor.gd:140-158 |
| `_refresh_status` (stats) | « N cellules   L × P m   N éléments » | table_editor.gd:193-204 ; texts.gd:20 |
| Curseur | « x 0.00  z 0.00 » à chaque mouvement | table_editor.gd:117 ; table_canvas.gd:206 |
| `_find_problems` | 1) « N cellules se chevauchent » (cellules en chevauchement). 2) « Pas de couloir de lancement » (aucun module avec `has_spawn`). 3) « Pas de sortie (bas ouvert) » (aucune cellule de sortie) | table_editor.gd:207-216 |
| Affichage des problèmes | Label rouge (variation Problem), pulsation d'alpha 0,45↔1 en boucle, 0,8 s (même vide) | table_editor.gd:149, 156-158 ; PROBLEM_PULSE 32 |
| Visuel chevauchement | Cellules en rouge translucide (0,45) | canvas_painter.gd:66-68 |
| Visuel sortie | Trait pointillé vert au bas des cellules de sortie | canvas_painter.gd:72-75 |
| Aide | Texte d'aide en bas à droite et en tooltip | table_editor.gd:150, 154 ; texts.gd:19 |

## 1.7 Annuler / refaire

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Câblage | `undo = get_undo_redo()` (historique global de l'éditeur) | plugin.gd:57 ; table_editor.gd:114 |
| Ctrl+Z / Ctrl+Y | Raccourcis de l'éditeur (pas de code dans l'addon) | README.md:25 |
| Granularité | Une action par : ajout (palette, dépôt, Ctrl+D), suppression, déplacement (au relâchement), bout de mur (au relâchement), rotation (chaque appui R), miroir (chaque appui M) | table_canvas.gd:450-477 |
| Non annulable | Ouvrir, Nouvelle, Enregistrer, changement de zone, pipette, zoom, vue | table_editor.gd:285-347 |

## 1.8 Essayer / Test

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_test` | Si sans chemin ou modifiée : Enregistrer. Si toujours sans chemin : arrêt (la boîte Enregistrer sous s'ouvre). Sinon écrit le chemin dans `user://table_editor_test_layout.txt` et lance `game/gameplay/main.tscn` (`play_custom_scene`). Pas de contrôle du succès d'écriture | table_editor.gd:351-361 ; GAME_SCENE 24 |
| `RunLayout.build` | En éditeur seulement : lit le fichier de test, le supprime, pose la zone dans GameState « layout » (persistance non vérifiée). Sinon zone GameState ou `classic.tres`. Ajoute les agrandissements du shop | run_layout.gd:16-38 |
| Constantes | TEST_FILE, DEFAULT_LAYOUT, LAYOUT_KEY | run_layout.gd:10-13 |

## 1.9 Thème (RP/table_editor_theme.gd)

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| Source des jetons | `res://design_tokens.cfg` (sections colors, sizes) si présent, sinon DEFAULTS | table_editor_theme.gd:9-16, 143-158 |
| DEFAULTS | ink 1d2229, ink_panel 252b34, ink_raised 363d4a, ink_line 414957, sand e0e0e0, sand_dim 8b929c, accent 70bbfa, good 45d17c, bad ff786b, info a5b6cc ; text 14, title 16, small 12, radius 3 | table_editor_theme.gd:11-16 |
| EDITOR_COLORS (dans l'éditeur) | ink = dark_color_2, ink_panel = dark_color_1, ink_raised = base_color, sand = font_color, accent = accent_color (type Editor) | table_editor_theme.gd:19-22, 152-158 |
| `color` / `size` | Lecture d'un jeton | table_editor_theme.gd:29-34 |
| `ui_font` | Police principale de l'éditeur (EditorFonts « main ») ou fallback | table_editor_theme.gd:37-44 |
| `mono_font` | SystemFont : JetBrains Mono, Cascadia Mono, Consolas, Menlo (MONO_FONTS) | table_editor_theme.gd:17, 46-51 |
| `condensed_font` | FontVariation sur la police UI, gras 0,6, espacement 1 : surtitres (Overline) seulement | table_editor_theme.gd:54-60 |
| `make_primary` | Bouton principal « Primary » : texte forcé à l'encre ; un par écran (Tester ▶, Ouvrir Classic) | table_editor_theme.gd:64-68 |
| `build_theme` | Thème : Button, Primary, Dim, Mono, Overline (accent), Title, Problem (bad), Label (sand) | table_editor_theme.gd:72-103 |
| `band_style` | Bandeau : fond ink_panel, filet 1 px sur le côté donné, marges 12/8 | table_editor_theme.gd:107-115 |
| `_button_style` | Boutons : normal, hover (+12 %), pressed (-15 %), disabled (-40 %), focus (contour accent) | table_editor_theme.gd:118-134 |
| `reload` | Vide les jetons, les polices mono et condensée | table_editor_theme.gd:162-165 |
| Couleurs en dur | Pastilles transparentes (palette_item.gd:24-25), vignette noir 0,45 (canvas_painter.gd:44), grille 0,9 / 0,35 (canvas_painter.gd:54-55) | voir fichiers |

## 1.10 Textes (RP/texts.gd)

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| `TEXTS` | Dictionnaires en et fr, clés de la table (surtitre, boutons, aide, problèmes, actions d'annulation, onglets) | texts.gd:9-80 |
| `t` | Texte de la langue, repli sur l'anglais, puis sur la clé | texts.gd:83-85 |
| `language` | Réglage « table_editor/language » (0 = en, 1 = fr) | texts.gd:88-92 |
| `register_setting` | Déclare le réglage dans Paramètres de l'éditeur : enum « English,Français », défaut English | texts.gd:96-102 |
| Changement de langue | Reconstruit l'onglet (plugin.gd:87-95) | — |
| Noms d'objets et de modules | Viennent des scripts du jeu (non traduits par l'addon) | — |

---

# 2. Pinball Modules (onglet Modules)

## 2.1 Onglet et liaison avec Table

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Titre d'onglet | « Modules » + « · nom » si ouvert. Tooltip « tab_modules_tip » | plugin.gd:62-64, 81-83 |
| `_open_module` | Module peint ouvert depuis Table : bascule sur Modules | plugin.gd:75-78 |
| `module_saved` | Enregistrement d'un module : palette Table rafraîchie et onglet renommé | plugin.gd:66-68 ; table_editor.gd:253-255 |
| `module_edited` | Modif : redessin Table et renommage | plugin.gd:69-71 ; table_editor.gd:246-250 |

## 2.2 En-tête et fichiers (RP/module_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_ready` | Thème, construction, Inspecteur branché (`property_edited`), état vide | module_editor.gd:36-45 |
| `_build_header` | Bandeau : surtitre « ROGUE PINBALL · MODULES », titre « nom · fichier » (• si modifié, « non enregistré » sans chemin). Boutons : Nouveau, Ouvrir, Enregistrer, Enregistrer sous, Cadrer | module_editor.gd:80-98 |
| Bouton Nouveau (`_new_module`) | `TableSection` « Module sans nom » ouvert, modifié | module_editor.gd:93, 207-213 |
| Bouton Ouvrir | `_ask_path` OPEN : dossier `game/level/sections/`, `*.tres`. `load` puis `open_section`. Ne demande pas confirmation | module_editor.gd:94, 231-244, 246-250 |
| Bouton Enregistrer (`_save`) | Sans chemin : Enregistrer sous. Sinon `make_dir`, `ResourceSaver.save`, `take_over_path`, `update_file`, `module_saved(path)`, « Enregistré : … » | module_editor.gd:95, 215-228 |
| Bouton Enregistrer sous | `_ask_path` SAVE, ignoré si rien d'ouvert | module_editor.gd:96, 231-237, 246-253 |
| Bouton Cadrer | `frame_section` | module_editor.gd:98 |
| `open_section` | Ouvre un module : chemin = resource_path (sinon vide). Crée un `ModulePlacement` dans un `TableLayout` de travail, inspecte le module, émet `module_edited` | module_editor.gd:49-70 |
| `tab_name` | Nom de l'onglet | module_editor.gd:74-75 |
| État vide | « Nouveau module » (principal) et « Ouvrir » | module_editor.gd:120-131 |

**E/S** : écrit et lit `game/level/sections/*.tres` (ou le chemin choisi). Charge `section_module.tscn` (preload, table_canvas et module_editor). Pas de raccourci clavier propre ; Ctrl+S de l'éditeur non branché.

## 2.3 Palette des outils (RP/section_palette.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_ready` | Panneau 210 px, titre « OUTILS DU MODULE », gomme en haut | section_palette.gd:26-37 |
| Gomme | Bouton bascule, couleur bad | section_palette.gd:36 |
| Flèches ‹ et › | Page précédente / suivante (boucle) | section_palette.gd:38-54, 92-94 |
| Titre de page | Nom de la page (clé de PAGES, ex. Gameplay, Walls) | section_palette.gd:45-49, 98 |
| Entrées | « n  nom » (numérotées 1 à 9), détail « L×H », pastille, bascule. Clic : `tool_selected(id)` | section_palette.gd:97-119 |
| `show_tool` | Surligne l'outil, change de page si besoin, affiche l'orientation (« quart 90° », « côté gauche » / « côté droit ») | section_palette.gd:67-82 |
| `select_index` | Touches 1 à 9 : outil n° de la page affichée | section_palette.gd:86-89 |
| `_refresh_marks` | Outil courant en accent, autres en sand | section_palette.gd:122-126 |
| `_on_tool_selected` (module_editor) | Change l'outil ; remet `turn` à 0 si l'outil ne tourne pas, `side` à 0 si pas de côté | module_editor.gd:193-203 |

## 2.4 Canvas, mode section (RP/table_canvas.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_section_input` (clic gauche) | Pose l'outil sur la case, prend le focus, démarre le coup | table_canvas.gd:329-334 |
| Clic gauche glissé | Peint case par case (au changement de case) | table_canvas.gd:343-347 |
| Relâchement gauche | `_end_stroke` : une action « Peindre le module » si la section a changé | table_canvas.gd:335-336, 394-407 |
| Clic droit | Pipette : l'objet sous la case devient l'outil (`tool_picked`) | table_canvas.gd:327-328, 410-417 |
| Clic droit glissé | Ne déplace PAS la vue (différence avec le mode table) | table_canvas.gd:327 |
| Clic milieu glissé | Déplace la vue | table_canvas.gd:325-326, 341-342 |
| Molette | Zoom | table_canvas.gd:322-324 |
| Survol | Fantôme de l'outil en transparence (accent si ça tient, rouge sinon) ; gomme = case rouge | canvas_painter.gd:180-213 |
| Mouvement | Curseur x/z ; change la case survolée | table_canvas.gd:338-347 |
| R | Tourne l'outil de 90° (si outil qui tourne) ; Maj+R : sens inverse | table_canvas.gd:355-357 |
| M | Miroir de l'outil (si outil à côtés) | table_canvas.gd:358-360 |
| F | Cadrer la section | table_canvas.gd:361-362 |
| 1 à 9 | Outil n° de la page (`tool_key`) | table_canvas.gd:364-365 ; module_editor.gd:118 |
| Autres touches (Suppr, Ctrl+D, Ctrl+Z) | Non consommées : passent à l'éditeur (Suppr ne supprime rien en mode section) | table_canvas.gd:363-368 |
| Double-clic | Non géré en mode section | — |

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| `edit_section` | Entre dans le mode section ; `frame_section` différé ; fin du coup en cours | table_canvas.gd:290-299 |
| `frame_section` | Cadre la section (marge 2 cases) | table_canvas.gd:301-310 |
| `section_cell` | Case sous la souris (-1 hors section) | table_canvas.gd:313-316 |
| `_paint` | Gomme : retire l'objet qui couvre la case. Pose : si `SectionCatalog.fits` (remplace ce qui est dessous), sinon ne fait rien. Même outil déjà posé : rien | table_canvas.gd:372-391 |
| `_end_stroke` | Une action annulable (`add_do_property` / `add_undo_property` sur `cells`) | table_canvas.gd:394-407 |
| `_pick_tool` | Copie l'outil de la case (`tool_picked`) | table_canvas.gd:410-417 |

## 2.5 Inspecteur (RP/module_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_on_inspector_edited` | Modif de la section dans l'Inspecteur : marque modifié, redessine | module_editor.gd:187-190 |
| `open_section` | Inspecte le module ouvert | module_editor.gd:65 |
| Champs (README) | Nom, taille (cases de 0,5 m), couleur du sol, bas ouvert | README.md:39 |

## 2.6 Pied (RP/module_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_build_footer` | Stats, curseur, aide (tooltip). Pas de contrôle de problèmes dans cet onglet | module_editor.gd:135-149 |
| `_refresh_status` | « W × H cases   N objets » | module_editor.gd:171-178 ; texts.gd:39 |
| Aide | « Clic poser · Glisser peindre · Clic droit pipette · R tourner · M miroir · 1-9 outils · Molette zoom · Clic milieu glissé vue · Ctrl+Z annuler » | texts.gd:42, 77 |

## 2.7 Annuler / refaire

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Câblage | `undo = get_undo_redo()` | plugin.gd:60 |
| Ctrl+Z / Ctrl+Y | Éditeur | texts.gd:42 |
| Granularité | Un coup de pinceau (du clic au relâchement) = une action « Peindre le module » | table_canvas.gd:394-407 ; texts.gd:43, 78 |
| Non annulable | Outil, pipette, zoom, vue, Ouvrir, Nouveau, Enregistrer | — |

## 2.8 Essayer / Test

Aucun dans cet onglet (le test est dans Table).

## 2.9 Thème et textes

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| Thème | `Tokens.build_theme()` (même fichier que Table) | module_editor.gd:38 ; table_editor_theme.gd:72 |
| Textes | Clés `modules_overline`, `painted_modules`, `new_module`, `empty_module_*`, `section_tools`, `eraser`, `turn`, `side_*`, `help_section`, `action_paint` | texts.gd:31-43, 73-78 |

---

# 3. DT Map painter (onglet Map)

## 3.1 Onglet et plugin (DM/plugin.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_enter_tree` | Crée MapEditor, le met dans la zone principale, masqué | plugin.gd:13-17 |
| `_exit_tree` | Libère l'éditeur | plugin.gd:20-23 |
| `_has_main_screen` / `_make_visible` | Onglet principal « Map » à côté de 2D, 3D, Script | plugin.gd:25-32 |
| `_save_external_data` | Ctrl+S de l'éditeur (et enregistrement de scène) : `save()` | plugin.gd:34-37 ; map_editor.gd:67-73 |
| `_get_plugin_name` / `_get_plugin_icon` | « Map », icône WorldEnvironment | plugin.gd:39-44 |

## 3.2 En-tête et fichiers (DM/map_editor.gd, map_document.gd)

Il n'y a pas d'en-tête à proprement parler. Le titre « CARTE » et le nom du fichier sont en haut de la colonne de gauche. Enregistrer est en bas de cette colonne.

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Chemins | `MAP_PATH` = `res://game/level/maps/world.png` ; marks = `world_marks.png` (même dossier, `_marks`) | map_editor.gd:19 ; map_document.gd:47-49 |
| `_ready` (chargement) | `load_map(MAP_PATH, NEW_COLOR)` ; NEW_COLOR `b8e08c` | map_editor.gd:21, 37-42 |
| `load_map` | Lit terrain et marks (RGBA8). Si terrain absent : nouvelle carte 256 × 256 de NEW_COLOR, `is_new = true`, dirty. Marks recréés si absents ou de taille différente | map_document.gd:31-45 ; NEW_SIZE 15 |
| Affichage titre | « CARTE » + nom du fichier (`MAP_PATH.get_file()`) | map_editor.gd:83-85 |
| Bouton Enregistrer (`_shelf`, primary) | Appelle `save_requested` → `save` | map_shelf.gd:163-168 ; map_editor.gd:95 |
| `save` (éditeur) | Si non modifié : rien. Sinon `_document.save()` puis `get_resource_filesystem().scan()`, statut | map_editor.gd:67-73 |
| `save` (document) | Crée le dossier, écrit `world.png` puis `world_marks.png` en PNG ; `dirty` et `is_new` remis à faux si OK | map_document.gd:64-71 |
| Statut | « Nouvelle carte : enregistrer pour la créer » (bad), « Modifications non enregistrées » (bad), « Enregistré » (good) | map_editor.gd:152-163 |
| Ctrl+S avec carte neuve | `dirty` est vrai dès le chargement : Ctrl+S crée `world.png` | map_document.gd:42 ; plugin.gd:34-37 |
| Nouvelle / Ouvrir / Enregistrer sous / dernier ouvert | Absents : une seule carte fixe | — |

**E/S** : lit `world.png`, `world_marks.png`, `user://map_position.cfg` (groupe). Écrit `world.png`, `world_marks.png`. Scan du système de fichiers après chaque enregistrement.

## 3.3 Bibliothèque / palette, colonne de gauche (DM/map_shelf.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `build` | Construit la colonne (250 px) : sections CARTE, CALQUE, OUTIL, PALETTE, PINCEAU, actions | map_shelf.gd:46-72 ; map_editor.gd:77-97 |
| Calque Terrain / Lieux | Deux boutons bascule (ButtonGroup) ; `_set_layer` règle le canvas, désactive les outils absents, revient au pinceau si besoin, restaure la couleur mémorisée par calque | map_shelf.gd:90-104, 208-221 |
| Outil Pinceau (icône Edit) | `canvas.tool = BRUSH`, sélectionné par défaut | map_shelf.gd:107-121 |
| Outil Pot (icône Bucket) | `FILL`, désactivé sur Lieux | map_shelf.gd:111, 212 |
| Outil Gomme (icône Eraser) | `ERASE`, seulement sur Lieux (désactivé sur Terrain) | map_shelf.gd:111, 213 |
| Pipette (icône ColorPick) | Bouton désactivé (inactif). La pipette est Alt+clic sur la carte | map_shelf.gd:124-130 |
| Palette (grille 5 colonnes) | Couleurs de `map_palette.gd` SWATCHES (Terrain) ou `map_marks.gd` SWATCHES (Lieux). Clic = choisit. Sélection = bordure accent 3 px ; autres bordure ink_line 1 px | map_shelf.gd:60-64, 224-247 |
| Libellé de couleur | « Nom  #hex » sous la palette | map_shelf.gd:65-66, 227 |
| Mémoire par calque | Terrain : « plaine » ; Lieux : « ruine » au démarrage | map_shelf.gd:43 |
| `NAMES` | Nom affiché de chaque id (plaine, bois, forêt...) | map_shelf.gd:21-29 |
| `pick` (pipette) | Couleur pipetée : si égale à un swatch Terrain, sélectionne ce swatch. Sinon garde la couleur et affiche « #hex » | map_shelf.gd:77-85 |
| Taille | Curseur 1 à 40, pas 1, défaut 6, valeur « %d » | map_shelf.gd:134-138 |
| Force | Curseur 5 à 100, pas 5, défaut 100 %, valeur « %d % », tooltip | map_shelf.gd:139-143 |
| Bord doux | Case, défaut cochée | map_shelf.gd:144 |
| Grille des zones | Case, défaut cochée ; redessine | map_shelf.gd:145-147 |
| `_slider` | Curseur et valeur ; l'étiquette initiale se règle en différé | map_shelf.gd:178-195 |
| `_check` | Case à cocher | map_shelf.gd:198-203 |
| `_icon` | Icônes de l'éditeur (aucune hors éditeur) | map_shelf.gd:251-252 |

**Observation à vérifier en exécution (lecture du code)** : `pick()` (map_shelf.gd:77-85) parcourt `_swatches[0]` (Terrain) et appelle `_select(id)`. Si le calque actif est Lieux, `_select` lit `_swatches[1][id]` avec un id de Terrain. Alt+clic sur un pixel Lieux (pipette lit toujours le Terrain, map_canvas.gd:295-296) peut donc tomber sur une clé absente. Non exécuté.

## 3.4 Canvas (DM/map_canvas.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_gui_input` | Dispatche boutons, mouvement, clavier (tout clavier, sans echo) | map_canvas.gd:236-245 |
| Molette | Zoom ×1,2 / ÷1,2 autour du curseur ; bornes 1 à 48 px/case ; coupe le cadrage auto | map_canvas.gd:248-249 ; 341-346 |
| Bouton milieu glissé | Déplace la vue | map_canvas.gd:250-251, 262-266 |
| Espace maintenu + clic gauche glissé | Déplace la vue (`_space` via `_on_key`) | map_canvas.gd:250, 278-280 |
| Clic gauche, Terrain, pinceau | Touches rondes (diamètre = taille, bord doux selon la case) | map_canvas.gd:252-256, 302-313, 316-323 |
| Clic gauche glissé, Terrain | Touches régulières le long du trait (pas = rayon × 0,4) | map_canvas.gd:271-273, 316-323 |
| Clic gauche, Terrain, pot | Remplit la zone contiguë de même couleur d'origine (4 voisins). Un seul clic, pas de glisser | map_canvas.gd:299-301 ; map_document.gd:104-115 |
| Clic gauche, Lieux, pinceau | Pose un pixel plein (un lieu, une tache = un lieu) | map_canvas.gd:302-307 |
| Clic gauche glissé, Lieux, pinceau | Trace un trait de pixels pleins (chemin, route) | map_canvas.gd:268-269, 326-333 |
| Clic gauche, Lieux, gomme | Efface en disque (alpha 0), dureté sans bord doux | map_canvas.gd:308-311, 316-323 |
| Alt + clic gauche | Pipette : couleur du Terrain sous la case (aussi sur calque Lieux) | map_canvas.gd:255, 295-296 |
| Clic droit | Aucune action (consommé) | map_canvas.gd:247-259 |
| Relâchement gauche | Fin du coup (`end_stroke`) si peint | map_canvas.gd:256-258 |
| Survol | Case dans le pied ; curseur carré (Lieux pinceau) ou cercle de diamètre = taille (sinon) | map_canvas.gd:262-267 ; 216-228 |
| Sortie de la souris | Efface le survol | map_canvas.gd:68-70 |
| Ctrl+Z | Annuler | map_canvas.gd:285-288 |
| Ctrl+Y ou Ctrl+Maj+Z | Refaire | map_canvas.gd:281-284 |
| Espace (seul) | Maintien : déplacement (voir ligne ci-dessus) | map_canvas.gd:278-280 |
| Focus | Le clic gauche prend le focus ; les touches ne vont qu'à la carte focusée (focus_mode ALL) | map_canvas.gd:57-58, 253 |
| Non géré | F, Suppr, Échap, Ctrl+S (hors éditeur), clic droit | — |

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| `set_document` | Lie le document, textures, marks, cadrage | map_canvas.gd:73-81 |
| `fit` (bouton « Voir toute la carte ») | Carte entière, centrée, zoom × 0,92 du plus petit ratio | map_canvas.gd:85-92 |
| `center_on` (bouton « Centrer sur le groupe ») | Zoom 8 centré sur la case du groupe | map_canvas.gd:94-98 ; map_editor.gd:113-115 |
| Auto-cadrage | Vue suit la taille de l'onglet jusqu'au premier zoom, déplacement ou centrage | map_canvas.gd:78-80 |
| `_draw_grids` | Grille des cases à partir de 10 px/case ; grille des zones de 16 cases (désactivable) | map_canvas.gd:164-179 |
| `_draw_marks` | Lieux en pastilles avec lettre (1re lettre du nom traduit) ; chemins en carrés pleins | map_canvas.gd:181-199 |
| `_draw_party` | Anneau bleu + libellé « Party » / « Groupe » | map_canvas.gd:202-213 |
| Voile des lieux | Calque Lieux : terrain atténué (ink 0,35) | map_canvas.gd:140-141 |
| Ombre portée, fond | Ombre noire 0,35 ; fond diagonal ink_line 0,35 | map_canvas.gd:125-129, 154-161 |
| `_scan_marks` | Lit les pixels de marks (alpha > 0,5) | map_canvas.gd:108-114 |

## 3.5 Pied (DM/map_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_build_footer` | Pied : case (« x  y », 90 px), biome (« Nom  NN % », 150 px), groupe (Mono, bleu), bouton Centrer sur le groupe, extension, statut, bouton Voir toute la carte | map_editor.gd:100-123 |
| `_on_hovered` | Case et biome (`TERRAIN_SCRIPT.read` : biome et force). Hors carte : « — » | map_editor.gd:142-150 |
| Bouton Centrer sur le groupe | Si position connue : centre sur la case, zoom 8 | map_editor.gd:113-115 ; map_canvas.gd:94-98 |
| Bouton Voir toute la carte | `canvas.fit` | map_editor.gd:121 |
| `_read_party` | Timer 1 s. Relit `user://map_position.cfg` (section `party`, clé `cell`) si le fichier a changé. Hors onglet visible, ne relit pas après la première fois. Absent : « Groupe : pas encore vu (lancer le jeu) » ; présent : « Groupe en x, y » | map_editor.gd:58-63, 167-180 |
| Constantes | `PARTY_FILE` = `user://map_position.cfg` ; écrit par le jeu (game/level/map_position.gd, non lu) | map_editor.gd:23 |
| Contrôle de validation de la carte | Aucun | — |

## 3.6 Annuler / refaire (DM/map_document.gd, map_canvas.gd, map_shelf.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Système | Pile interne au document, pas l'historique de l'éditeur | map_document.gd:24-25 |
| Taille | 50 pas (MAX_UNDO = 16 : ligne à relire, voir ci-dessous) | map_document.gd:15-16 |
| `begin_stroke` | Un coup = une entrée : copie de l'image du calque, vide la pile de refaire | map_document.gd:76-85 |
| Granularité | Un clic (pot, lieu) ou un glisser (du press au release) = un pas. Un pas enregistre le calque entier | map_canvas.gd:291-313 |
| Plafond | `MAX_UNDO` = 50 (constante à 16 ligne 16 ; voir lecture) | map_document.gd:16, 82-83 |
| Force | Chaque pixel ne dépasse jamais la force du coup (poids max) | map_document.gd:137-145 |
| `undo` / `redo` | Échange l'image du calque, `dirty` vrai, signal `changed` | map_document.gd:154-171 |
| Boutons Annuler / Refaire | Icônes Undo / Redo (infobulles « Undo » / « Redo ») | map_shelf.gd:155-161 ; map_editor.gd:89-94 |
| Ctrl+Z / Ctrl+Y / Ctrl+Maj+Z | Dans la carte (focus requis) | map_canvas.gd:281-288 |
| Sauvegarde | Ne vide pas la pile. Seul `load_map` la vide | map_document.gd:43-44 |

Note de lecture : `MAX_UNDO` vaut 50 (map_document.gd:16) ; la pile est tronquée à 50 par `pop_front` (map_document.gd:82-83).

## 3.7 Thème (DM/map_theme.gd)

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| Fichier de jetons | `res://design_tokens.cfg` (PATH), lu une fois par session (`_config` statique) | map_theme.gd:10, 195-200 |
| DEFAULT_COLORS | ink 1d2229, ink_panel 252b34, ink_raised 363d4a, ink_line 414957, sand e0e0e0, sand_dim 8b929c, accent 70bbfa, good 45d17c, bad ff786b, info a5b6cc | map_theme.gd:11-15 |
| DEFAULT_MONO | JetBrains Mono, Cascadia Mono, Consolas, Menlo | map_theme.gd:16 |
| DEFAULT_SIZES | text 14, title 16, small 12, radius 3 | map_theme.gd:17 |
| `color` | Éditeur d'abord si `profile.follow_editor` (vrai par défaut), sinon config, sinon défaut | map_theme.gd:28-30 |
| `_editor_color` | ink = fond Content ; ink_panel = fond Panel ; ink_raised = fond Button normal ; ink_line = bordure Button normal ; sand = font_color ; sand_dim = font mélangé à base_color (0,45) ; accent = accent_color ; good = success_color ; bad = error_color. info : pas de correspondance (config ou défaut) | map_theme.gd:159-185 |
| `mono_font` | SystemFont, liste `fonts.mono` du cfg ou défaut | map_theme.gd:37-40 |
| `build` | Thème : Label, KICKER (accent, small), DIM, MONO, Button (5 états), TOOL (transparent, survol 0,8), PRIMARY (accent), HSlider, CheckBox, TooltipPanel, séparateur HSplit | map_theme.gd:43-100 |
| `band` / `label` / `box` / `framed` | Bandeaux, étiquettes, styles | map_theme.gd:105-141 |
| Taille de texte par défaut | `theme.default_font_size = size("text")` ; police UI : celle de l'éditeur (non surchargée) | map_theme.gd:52 |
| Couleurs en dur (hors jetons) | Noir alpha : grilles (0,12 / 0,3), ombre (0,35), contour des pastilles (0,4), cercle du pinceau (0,5). Couleur de départ NEW_COLOR `b8e08c` | map_canvas.gd:167-169, 128, 194, 226 ; map_editor.gd:21 |

## 3.8 Textes (DM/i18n/)

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| `t` | Français si la langue est fr, sinon texte anglais. Un texte sans traduction reste en anglais | i18n/t.gd:12-15 |
| `get_language` | Langue de l'éditeur : `interface/editor/editor_language`, 2 premières lettres | i18n/t.gd:18-22 |
| `TEXTS` (fr) | Clé = texte anglais, valeur = français (~50 entrées) | i18n/fr.gd:6-60 |
| Pas de réglage propre | Suit la langue de l'éditeur Godot | — |
| Auto-traduction | Désactivée sur l'éditeur (`auto_translate_mode = 2`) | map_editor.gd:39-40 |

---

# 4. DT Dungeons (onglet Dungeons, donjons et grottes)

## 4.1 Onglet et plugin (DB/plugin.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_enter_tree` | Charge `game/ui/translations/ui_text.en.translation` et `.fr.translation` dans le domaine `dungeon_builder` ; crée l'éditeur, `set_translation_domain` avant `add_child` | plugin.gd:21-33 ; TRANSLATIONS 11-14 |
| `_exit_tree` | Libère l'éditeur, retire les traductions | plugin.gd:36-42 |
| `_has_main_screen` | Onglet principal « Dungeons » | plugin.gd:44-45 |
| `_make_visible` | Affichage : `reload()` (liste à jour) | plugin.gd:48-53 |
| `_save_external_data` | Ctrl+S de l'éditeur : `save()` (donjon et pièces) | plugin.gd:55-58 |
| `_get_plugin_name` / `_get_plugin_icon` | « Dungeons », icône GridMap | plugin.gd:60-65 |

## 4.2 En-tête, liste et fichiers (DB/dungeon_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_ready` | Construction, puis `reload()` | dungeon_editor.gd:44-77 |
| `_build_header` | Titre (DUNGEON_EDITOR_TITLE, majuscules, taille title). Boutons Nouveau, Supprimer, Salles, état, Enregistrer | dungeon_editor.gd:82-107 |
| Bouton Nouveau (`_create`) | `nouveau_donjon.tres` (puis `nouveau_donjon_2`...), nom = id capitalisé, graine aléatoire 0–999999, `generate()`, `ResourceSaver`, `update_file`, sélection. Erreur : `Log.err` | dungeon_editor.gd:92, 415-435 |
| Bouton Supprimer | Ouvre une confirmation (chemin → Supprimer) | dungeon_editor.gd:93-94, 438-443 |
| `_delete` | `OS.move_to_trash` (corbeille), scan du système de fichiers, `reload` | dungeon_editor.gd:446-453 |
| Bouton Salles | Bascule vers l'éditeur de pièces (voir partie 5) | dungeon_editor.gd:96, 386-395 |
| Bouton Enregistrer (primary) | `save` : pièces ouvertes d'abord, puis le donjon si modifié (`ResourceSaver` sur `resource_path`). Désactivé tant que rien n'a changé. Erreur : `Log.err` | dungeon_editor.gd:103-107, 398-411 |
| Statut (en-tête) | « non enregistré » (bad) après modif ; « Enregistré : id » (good) | dungeon_editor.gd:377-382, 409-410 |
| `_build_list` | Liste ItemList (nom affiché ou id), tooltip = chemin | dungeon_editor.gd:110-118 |
| Clic sur un donjon | `_select` : enregistre le donjon précédent s'il est modifié (sans demande), charge le nouveau | dungeon_editor.gd:116, 283-303 |
| `reload` | Liste les donjons (`DungeonCatalog.ids`), garde la sélection si elle existe, sinon premier | dungeon_editor.gd:265-281 |
| Donjon sans placement | Génère au chargement | dungeon_editor.gd:298-299 |
| Raccourcis clavier | Aucun propre. Ctrl+S via l'éditeur uniquement | plugin.gd:55-58 |

**E/S** : lit et écrit `game/level/dungeon/*.tres` (DungeonCatalog.DIR, non lu). Lit `game/level/deck_catalog.gd` (DeckCatalog). Corbeille via `OS.move_to_trash`. Pas de métadonnée de projet.

## 4.3 Aperçu et légende (DB/dungeon_preview.gd, dungeon_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_build_preview` | Aperçu ≥ 240 × 240 px, légende, statistiques | dungeon_editor.gd:120-148 |
| Légende (8 entrées) | Départ, Sortie, Ennemi, Boss, Coffre, Piège, Chemin, Mur (clés DUNGEON_LEGEND_*) | dungeon_preview.gd:18-23 ; dungeon_editor.gd:133-145 |
| Statistiques | « taille, pièces, graine (x → y si différente), départ (x, y) » + « trajet N pas » ou « aucun trajet » | dungeon_editor.gd:146-148, 363-375 |
| `layout` (setter) | Reconstruit la carte | dungeon_preview.gd:30-33 |
| `_rebuild` | Cases et pièces (pièce numérotée à partir de 2 ; la 1re est l'entrée) ; rôle par `role_of` | dungeon_preview.gd:87-111, 75-84 |
| `_find_path` | Plus court chemin (4 directions) de P à K, ou au centre de la salle boss ; bloqué par `#RC ` | dungeon_preview.gd:116-147 ; BLOCKING 16 |
| `_draw` | Roche avec grille (un trait tous les 8), murs, sols, pièces teintées par rôle (13 %), chemin, repères, cartouches | dungeon_preview.gd:166-207 |
| Chemin | Pointillé : un segment sur deux (boucle par pas de 2) | dungeon_preview.gd:210-214 |
| Repères | G, S, X (lettre) ; E (sans lettre) ; K (grand) ; C coffre ; T piège ; P départ ; `<` sortie ; R / B rocher | dungeon_preview.gd:219-249 |
| Cartouche | « n  Rôle » en haut à gauche de la pièce | dungeon_preview.gd:200-207 |
| Survol | Pièce survolée : contour accent (`_gui_input`) | dungeon_preview.gd:258-263 |
| Sortie de la souris | Efface le survol | dungeon_preview.gd:266-272 |
| Tooltip | « (x, y) · n nom (rôle) · N ennemis · caractère » | dungeon_preview.gd:286-301 |
| Clic | Aucune action | — |
| `color_of` | Couleurs par catégorie : départ good, sortie info, ennemi bad, boss `b06ad8` (en dur), coffre sand, piège `e0a040` (en dur), chemin accent | dungeon_preview.gd:51-71 |
| `role_of` | Entrée (P ou <), boss (K), combat (ennemi), trésor (C), sinon salle | dungeon_preview.gd:75-84 |

## 4.4 Réglages (DB/dungeon_editor.gd, panneau de droite, 270 px)

Chaque réglage régénère le donjon, sauf ceux indiqués. Un flag `_filling` bloque les modifications pendant le remplissage (dungeon_editor.gd:338-339).

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Nom (LineEdit) | Saisie : `display_name`, met à jour la liste, sans régénérer | dungeon_editor.gd:164-166, 338-344 |
| Type (OptionButton) | Salles / Grotte : `kind`, régénère, affiche les champs du type | dungeon_editor.gd:167-171, 331-334 |
| Graine (SpinBox 0 à 2 147 483 647) | `dungeon_seed`, régénère | dungeon_editor.gd:172-173 |
| Dé (bouton Reroll) | Graine aléatoire 0 à 999 999, régénère | dungeon_editor.gd:177-178, 351-355 |
| Largeur (SpinBox 24 à 128) | `size.x`, régénère | dungeon_editor.gd:182-183 |
| Hauteur (SpinBox 24 à 128) | `size.y`, régénère | dungeon_editor.gd:184-185 |
| Pièces (SpinBox 2 à 20) | `room_count`, régénère | dungeon_editor.gd:186-187 |
| Boucles (SpinBox 0 à 1, pas 0,05) | `loop_chance`, régénère. Visible seulement pour Salles | dungeon_editor.gd:188-189, 331-334 |
| Remplissage (SpinBox 0,3 à 0,6, pas 0,01) | `cave_fill`, régénère. Visible seulement pour Grotte | dungeon_editor.gd:190-191, 331-334 |
| Deck (OptionButton) | « Modèle » (vide) ou un deck de DeckCatalog, régénère | dungeon_editor.gd:194-196 |
| Entrée X et Y (SpinBox -1 à 4095) | `entrance`, sans régénérer | dungeon_editor.gd:197-205 |
| Problème | Label rouge : texte renvoyé par `generate()` (DUNGEON_PROBLEM) | dungeon_editor.gd:207-210, 357-361 |
| Infobulles | Par champ (DUNGEON_TIP_*) sur le libellé et le contrôle | dungeon_editor.gd:223-233 |
| `_field` / `_spin` / `_section` / `_tool_button` | Briques des lignes de réglages | dungeon_editor.gd:213-259 |
| `_regenerate` | `generate()`, problème, aperçu | dungeon_editor.gd:357-361 |
| `_show_result` | Aperçu + statistiques | dungeon_editor.gd:363-375 |
| `_mark_dirty` | Marque modifié, active Enregistrer, statut rouge | dungeon_editor.gd:377-382 |

## 4.5 Pied

Pas de pied. Les statistiques sont sous l'aperçu (dungeon_editor.gd:146-148), le statut dans l'en-tête.

## 4.6 Annuler / refaire

Aucune annulation (ni Ctrl+Z, ni historique). Chaque réglage change le donjon en mémoire ; seul Enregistrer ou le changement de donjon écrit sur disque. Fermer l'éditeur sans enregistrer : rien n'est écrit.

## 4.7 Essayer / Test

Aucun.

## 4.8 Thème

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| Thème | `theme = MapTheme.build()` (thème de DM) | dungeon_editor.gd:10, 45 |
| Couleurs | `MapTheme.color(...)` (jetons de DM) ; boss et piège en dur (dungeon_preview.gd:60, 68) | dungeon_preview.gd:51-71 |
| Polices | Mono pour les statistiques et les champs de nombres (`MapTheme.mono_font`) ; police du thème pour les cartouches (`get_theme_default_font`) ; police de secours pour les lettres des repères | dungeon_editor.gd:146, 246 ; dungeon_preview.gd:194, 251-255 |
| Titre | Taille title, majuscules | dungeon_editor.gd:88-89 |

## 4.9 Textes

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| Domaine | `dungeon_builder` (partagé par l'éditeur et ses enfants, `set_translation_domain` avant `add_child`) | plugin.gd:15, 31 |
| Traductions | `tr("CLE")` avec les clés `DUNGEON_*` et `ROOM_*` des `.translation` du jeu (non lus). Langue suivant la locale de TranslationServer | plugin.gd:11-14 |
| Pas de réglage propre | Pas de paramètre de langue dans l'addon | — |
| Clés utilisées (échantillon) | DUNGEON_EDITOR_TITLE, _NEW, _DELETE, _SAVE, _SAVED, _UNSAVED, _EMPTY, DUNGEON_SECTION_*, DUNGEON_FIELD_*, DUNGEON_TIP_*, DUNGEON_REROLL, DUNGEON_KIND_*, DUNGEON_DECK_TEMPLATE, DUNGEON_PROBLEM, DUNGEON_STATS, DUNGEON_PATH_INFO, DUNGEON_PATH_NONE, DUNGEON_ROOM_ENEMIES, DUNGEON_ROLE_*, DUNGEON_LEGEND_*, ROOM_OPEN, ROOM_TIP_OPEN | dungeon_editor.gd, dungeon_preview.gd |

---

# 5. DT Rooms (pièces types, sous Dungeons > Salles)

## 5.1 Navigation (DB/dungeon_editor.gd, DB/room_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Entrée | Bouton « Salles » de l'en-tête des donjons | dungeon_editor.gd:96, 386-395 |
| `_show_rooms(true)` | Cache l'en-tête et le corps des donjons, affiche l'éditeur de pièces, `reload()` | dungeon_editor.gd:386-395 |
| Retour (bouton Back) | `back_requested` → `_show_rooms(false)` : `save()` des pièces, réaffiche les donjons, régénère le donjon courant | room_editor.gd:93 ; dungeon_editor.gd:57, 386-395 |
| Ctrl+S de l'éditeur | `DungeonEditor.save` appelle `_rooms.save()` | dungeon_editor.gd:398-402 ; plugin.gd:55-58 |

## 5.2 En-tête, liste et fichiers (DB/room_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_ready` | Construction, `reload()` | room_editor.gd:50-82 |
| `_build_header` | Retour, titre (ROOM_EDITOR_TITLE en majuscules), Nouvelle, Supprimer, état, Enregistrer | room_editor.gd:87-118 |
| Bouton Retour | Icône Back, `back_requested` | room_editor.gd:93 |
| Bouton Nouvelle (`_create`) | Pièce `NN_nouvelle_salle.tres` (NN = nombre + 1, suffixe si existant), 7 × 5 de sol « . », rôle combat, nom ROOM_NEW_NAME. Sélectionne | room_editor.gd:99, 378-396 |
| Bouton Supprimer | Confirmation (chemin → Supprimer) | room_editor.gd:100-107 |
| `_delete` | Corbeille (`OS.move_to_trash`), scan, `reload` | room_editor.gd:400-409 |
| Bouton Enregistrer (primary) | `save` : `ResourceSaver`, statut vert, renomme l'entrée de liste (« rôle · nom »). Désactivé tant que rien n'a changé | room_editor.gd:114-118, 361-374 |
| Statut | « non enregistré » (bad) / « Enregistré : id » (good) | room_editor.gd:111, 318-323, 368-371 |
| Liste (ItemList) | Entrées « rôle · nom » ; tooltip = chemin ; clic → `_select` | room_editor.gd:61-64, 248-249 |
| `_select` | Enregistre la pièce précédente si modifiée (sans demande), charge la nouvelle, remplit les champs, contrôle | room_editor.gd:253-283 |
| `reload` | Liste `RoomTemplates.templates()`, garde la sélection si elle existe, sinon première | room_editor.gd:240-250 |
| Raccourcis clavier | Aucun | — |

**E/S** : lit et écrit `game/level/dungeon/rooms/*.tres` (RoomTemplates.DIR, non lu). Lit DeckCatalog. Corbeille.

## 5.3 Palette des cases (DB/room_editor.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Palette (grille 2 colonnes, boutons bascule) | Un bouton par caractère : `.` Sol, `#` Mur, `·` (espace) Libre, `R` Rocher, `C` Coffre, `T` Piège, `P` Départ, `<` Sortie, `E` Ennemi (deck), `K` Boss (deck), `G` Gobelin, `S` Araignée, `X` Bandit. Libellé « c  nom », police mono | room_editor.gd:23-29, 165-183 |
| Choix du pinceau | Bouton → `_set_brush` → `canvas.brush` ; défaut « . » | room_editor.gd:172-183, 286-287 |
| Pinceau de hauteur | Case « Peindre les hauteurs » (`paint_heights`) + valeur 0 à 9 (défaut 1, `height_brush`) | room_editor.gd:184-195 |
| Raccourcis clavier pour le pinceau | Aucun | — |

## 5.4 Canvas (DB/room_canvas.gd)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| `_gui_input` (clic gauche) | Pose le pinceau (ou la hauteur en mode hauteur) | room_canvas.gd:106-122, 133-151 |
| Clic gauche glissé | Peint case par case (au changement de case) | room_canvas.gd:116-121 |
| Clic droit (et glissé) | Efface : case libre `' '` ; en mode hauteur : hauteur 1 | room_canvas.gd:110-111, 133-151 |
| Relâchement | Arrête le coup | room_canvas.gd:111 |
| Sortie de la souris | Arrête le coup, efface le survol | room_canvas.gd:124-128 |
| Survol | Case contour accent ; tooltip « (x, y) · « c » · h N » | room_canvas.gd:90-91, 174-181 |
| Molette / clavier | Aucun | — |
| Taille de la pièce (SpinBox largeur, hauteur 2 à 20) | `resize_room` : complète de sol « . » ou coupe ; hauteurs complétées à 1 | room_editor.gd:308-311 ; room_canvas.gd:159-172 |
| Taille de case | Entière, bornée de 8 à 56 px, centrée | room_canvas.gd:45-52 |
| Dessin | Fond roche ; case libre hachurée ; cases ; repères (`DungeonPreview.draw_mark`) ; hauteur ≠ 1 en petit chiffre (info) | room_canvas.gd:60-91 |
| Repère boss | Plus grand (1,9 × rayon) | dungeon_preview.gd:228-231 |
| `room_size` | Largeur max des lignes × nombre de lignes | room_canvas.gd:35-41 |
| `_paint` | Hauteur : crée une grille de « 1 » si vide. Sinon écrit le caractère (ou « libre » en gomme) | room_canvas.gd:133-151 |
| `painted` | Signal : marque modifié | room_canvas.gd:76, 151, 171 |

## 5.5 Réglages (DB/room_editor.gd, panneau de droite, 300 px)

| Fonction | Geste ou contrôle exact | Fichier:ligne |
|---|---|---|
| Nom (LineEdit) | `display_name`, modifié (la liste ne change qu'à l'enregistrement) | room_editor.gd:134-136, 290-294 |
| Rôle (OptionButton) | Entrée / Combat / Trésor / Boss (ROLE_KEYS) → `role` | room_editor.gd:137-141 |
| Types de donjon (2 cases) | Salles, Grotte → `kinds` | room_editor.gd:142-149, 297-305 |
| Deck (OptionButton) | « Pas de deck » ou un id de DeckCatalog → `deck` | room_editor.gd:150-152 |
| Taille (2 SpinBox 2 à 20) | Largeur, hauteur → `resize_room` | room_editor.gd:153-163, 308-311 |
| Hauteurs | Voir 5.3 | room_editor.gd:184-195 |
| `_check` | Liste les problèmes en rouge, ou « ROOM_OK » en vert. Appelé à la sélection et à chaque modification | room_editor.gd:327-333 |
| `problems_of` | ROOM_PROBLEM_KINDS (aucun type) ; ROOM_PROBLEM_ENTRANCE (entrée sans P et <) ; ROOM_PROBLEM_START_ELSEWHERE (P ou < hors entrée) ; ROOM_PROBLEM_BOSS (boss sans K ni E) ; ROOM_PROBLEM_TREASURE (trésor sans C) ; ROOM_PROBLEM_DECK (E ou K sans deck, hors boss) ; ROOM_PROBLEM_K_ALONE (K sans E) ; ROOM_PROBLEM_FLOOR (pas de sol) | room_editor.gd:337-358 |
| Aide | « ROOM_HINT » sous la grille | room_editor.gd:78-80 |
| Problèmes ne bloquent pas l'enregistrement | Enregistrer reste possible | room_editor.gd:361-374 |

## 5.6 Pied

Pas de pied. Le contrôle des problèmes est dans le panneau de droite.

## 5.7 Annuler / refaire

Aucune annulation.

## 5.8 Essayer / Test

Aucun.

## 5.9 Thème

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| Thème | `MapTheme.build()` (DM) appliqué via `MapTheme.label` et `band` ; fond de la grille = ink assombri 0,25 | room_editor.gd:11, 58 ; room_canvas.gd:61 |
| Couleurs | Jetons de DM ; couleurs des cases par `DungeonPreview.color_of` | room_canvas.gd:78, 89 |
| Hachures | ink_line 0,6 (case libre) ; contours ink_line 0,5 | room_canvas.gd:75-79 |
| Couleur de hauteur | info | room_canvas.gd:89 |

## 5.10 Textes

| Fonction | Rôle | Fichier:ligne |
|---|---|---|
| Domaine | `dungeon_builder` (hérité de l'éditeur des donjons) | plugin.gd:31 |
| Clés | ROOM_* (ROOM_BRUSH_*, ROOM_PROBLEM_*, ROOM_OK, ROOM_HINT, ROOM_BACK, ROOM_NO_DECK, ROOM_FIELD_*, ROOM_TIP_*, ROOM_SECTION_*, ROOM_PAINT_HEIGHT, ROOM_NEW_NAME, ROOM_EDITOR_TITLE) et DUNGEON_* partagées | room_editor.gd:23-30, 86-199 |
| Rôles | Clés DUNGEON_ROLE_* | room_editor.gd:30 |

---

## Points que je n'ai pas pu vérifier

- Les scripts du jeu (TableGeometry, ElementCatalog, SectionCatalog, DungeonLayout, RoomTemplate, DeckCatalog, map_palette.gd, map_marks.gd, map_position.gd, GameState) et les `.translation` ne sont pas lus. Les noms, props, couleurs et règles métier qui en dépendent ne sont donc pas inventoriés. Le détail des `copy()` de `ElementPlacement` et `ModulePlacement` (utilisés par Ctrl+D) n'est pas vérifié.
- Persistance de `GameState` pour la zone de test (RL:37) : non vérifiée.
- Le comportement réel (exécution, capture d'écran) n'a pas été testé. Tout ce qui précède est tiré de la lecture du code.

## Observations de lecture (à vérifier en exécution, sans recommandation)

1. DM/map_shelf.gd:77-85 : Alt+clic sur un pixel du calque Lieux, quand la couleur pipetée correspond à un swatch Terrain, appelle `_select` qui lit `_swatches[1][id]` avec un id de Terrain. Erreur possible.
2. DM/map_theme.gd:195-200 : `design_tokens.cfg` est lu une fois par session (`_config` statique). Une modification du fichier demande un redémarrage.
3. DB/dungeon_preview.gd:210-214 : le chemin P→K est dessiné en pointillés, un segment sur deux.
4. RP/table_editor.gd:351-361 : Test sur une zone neuve ouvre seulement la boîte Enregistrer sous, sans lancer le jeu. Le jeu est lancé au Test suivant.
5. RP/plugin.gd:87-95 : un changement de langue ou de thème reconstruit l'onglet et perd les modifs non enregistrées de la zone et du module ouvert.

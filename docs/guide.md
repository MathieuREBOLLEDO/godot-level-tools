# Assembler un éditeur avec les briques

Exemple complet et lançable : tests/demo_editor.gd (scène
tests/demo_editor.tscn).

## Squelette
```gdscript
var shell := LtShell.new()                 # en-tête, corps, pied, thème
var document := LtDocument.new("res://game/level/levels/")
shell.bind_document(document)              # messages, « non enregistré », Ctrl+S
shell.set_title("LEVEL", "")
shell.set_help("click: place · right click: pick · wheel: zoom")
add_child(shell)
```

## Étendre LtShell
Un éditeur peut étendre LtShell (BatEmUp, Gringo, RoguePinball). LtShell a
des membres et fonctions privés (`_build_header`, `_build_body`,
`_build_footer`, `_empty`, `_help`, `_spacer`, `_confirm`...) : une
sous-classe ne doit pas utiliser ces noms (GDScript refuse une signature
différente). Préférer `_build_level_header`, `_fill_...`.
Ctrl+S : `save_shortcut = false` le laisse à l'éditeur Godot (un plugin qui
enregistre par `_save_external_data`).

## En-tête
```gdscript
var files := shell.add_group()             # un groupe = boutons serrés + filet
LtTheme.button(files, "New", "New level", func(): document.create(MyLevel.new(), "new_level"))
var save := LtTheme.button(files, "Save", "Ctrl+S", func(): document.save(shell.name_edit.text))
shell.set_primary(save)                    # un seul par écran
shell.add_group(true)                      # groupe à gauche, après le nom
shell.add_header(back_button, "start")     # avant le nom (Retour)
shell.add_header(fields, "left", true)     # des champs qui prennent la place libre
shell.confirm("Move x.tres to the trash?", "Move to trash", on_ok)
shell.add_undo_buttons(history)            # Annuler / Refaire en icônes, grisés quand vides
```
Ordre et forme des groupes : DESIGN.md, « Disposition commune ». Chaque
éditeur a les mêmes fichiers : Nouveau, Ouvrir, Dupliquer, Supprimer
(corbeille, confirmation qui dit où le document sert), Enregistrer ; et
Ctrl+S de l'éditeur Godot (`_save_external_data` du plugin).

## Ensemble ↔ pièce (onglets)
```gdscript
var workspace := LtWorkspace.new()
workspace.config_path = "user://my_editor.cfg"   # onglet et pièce retenus
add_child(workspace)
workspace.setup(map_shell, "Map", level_editor, "Level", "Double click a level to edit it here.")
workspace.whole_shown.connect(reload_pieces)      # retour sur l'ensemble : relire
workspace.show_piece("cave_02", path)             # double-clic sur une pièce
# une fois l'éditeur rempli :
var last := workspace.last_piece()                # rouvrir la dernière pièce
workspace.restore_tab()
```

## Marques (DPRC, EXCL)
`LtFlags.add_filter(library)` (cachées par défaut) ;
`settings.flags(section, func(flag, on): LtFlags.set_flag(res, flag, on))`
puis `LtFlags.show_checks(checks, res)` à l'ouverture. Rangées dans les
propriétés `deprecated` / `exclude_from_game` de la ressource si elle les a,
sinon dans ses métadonnées. Le jeu ignore ce qui est exclu :
`LtFlags.is_excluded(res)`.

## Bibliothèque
```gdscript
var library := LtLibrary.new()
library.describe = func(path, data): return {"detail": "...", "thumbnail": tex, "badge": "on this map", "drag": {"level": path}}
library.add_filter("Biome", ["All biomes", "Desert"], func(path, data, choice): return choice == 0 or ...)
library.add_sort(["Name", "Newest"], func(a, b, choice): return LtLibrary.by_newest(a, b) if choice == 1 else LtLibrary.by_name(a, b))
library.picked.connect(document.open)
shell.left.add_child(library)
library.set_paths(document.paths())
```
Grille de miniatures (navigateur) : `library.set_layout(LtLibraryCard.Layout.GRID)`,
ou un bouton liste / grille : `library.add_layout_toggle()`.

Usages (bibliothèque des pièces d'un ensemble) : badge, estompé, bulle et
filtre d'usage d'un coup :
```gdscript
library.set_usage(func(path): return table.uses(path),          # dans l'ensemble ouvert
	func(path): return other_tables_using(path),                 # PackedStringArray de noms
	{"badge_here": "on this table", "badge_elsewhere": "on %s"})
library.used_elsewhere(path)   # avant de supprimer : avertir
```
Import : `library.enable_import(dir, func(res): return res is MyLevel)` puis
`library.imported.connect(func(written, rejected): ...)`.

## Annuler
```gdscript
shell.history = LtHistory.for_resource(document.resource)   # Ctrl+Z / Ctrl+Y
# après chaque modification :
shell.history.changed()          # ajout, retrait, coup de pinceau : un pas
shell.history.changed(true)      # curseur glissé : un pas pour la série
```
Instantané maison (état fait de plusieurs ressources) :
`LtHistory.new(capture_callable, restore_callable)`.
Autre façon : `history.checkpoint()` AVANT la modification (début d'un coup
de pinceau, éditeur de niveaux de Gringo) ; ne pas mélanger avec changed().

## Renommer depuis la bibliothèque
`library.renamable = true` (clic droit sur une carte > Rename) et
`library.rename_requested.connect(document.rename_file)`. Quand d'autres
fichiers retiennent le chemin, le jeu les met à jour lui-même (Gringo :
game/level/level_files.gd, cartes, niveau de départ, trous noirs).

## Réglages
Colonne de droite, à la place de l'Inspecteur de Godot :
```gdscript
var settings := shell.settings()                 # LtSettings dans shell.right
var module := settings.section("MODULE")
settings.text(module, "Name", res.display_name, func(t): res.display_name = t)
settings.size_pair(module, "Size", res.size, Vector2i.ONE, Vector2i(20, 20), func(v): resize(v))
settings.option(module, "Role", roles, index, func(i): ...)
settings.color(module, "Floor", res.floor_color, func(c): ...)
var checks := settings.flags(module, func(flag, on): LtFlags.set_flag(res, flag, on))
settings.clear()                                 # autre élément choisi
```
`LtValueField.create(resource, &"speed", "Speed", "help", " m/s")` : curseur
et nombre, bornes lues dans `@export_range`.

## Vérifier (problèmes)
Les règles vont dans un fichier du jeu (`level_rules.gd`) : chacune est un
Callable `(document) -> Array[LtProblem]`, avec `LtProblem.error(message,
endroit)` ou `LtProblem.warning(...)`. L'endroit est ce que l'éditeur sait
cadrer (case, position, index de vague) ; null pour tout le document.
```gdscript
validator = LtValidator.new().add_rule(_no_exit).add_rule(_paths)
problem_picked.connect(func(problem: LtProblem) -> void: _canvas.center_on(problem.where))
# après chaque modification (et à l'ouverture) :
validate(document.resource)
```
Pied : « 1 error(s) · 2 warning(s) » (rouge qui bat, orange, ou « No
problem » en vert), la liste en bulle ; un clic montre le problème suivant.
Tests du jeu : `validator.errors_in(chemins, load)` rend les erreurs
(« fichier : message ») ; les avertissements ne font pas échouer.
## Canvas sur grille (vue et palette)
Le canvas garde son dessin et confie la vue à un LtView :
```gdscript
var view: LtView = LtView.new()   # dans _ready : view.changed.connect(queue_redraw)
func _gui_input(event):
	if view.handle_input(event):  # molette, Maj + molette, milieu, Espace + clic
		accept_event()
		return
	# ... peindre avec view.cell_at(event.position)
func _draw():
	view.fit(Rect2(Vector2.ZERO, Vector2(grid)), size)   # cadre tant qu'on n'a pas zoomé
	draw_rect(view.cell_rect(cell), color)
```
L'éditeur passe les touches quand la souris est sur le canvas :
`view.handle_key(event)` (F, R, Espace) puis `palette.handle_key(event)`.
Palette : `palette.setup(items, ["Terrain", "Objects"], "Eraser")`, un élément
= {id, name, page, tooltip, draw (Callable(case, rect)) ou color + letter} ;
`item_selected(id)` ("" : la gomme), `select(id, false)` pour la pipette ;
`store_path` (user://) garde l'ordre et les favoris.

## Essayer en jeu
Éditeur : `LtPlaytest.play(document.resource, "res://game/main.tscn")`.
Jeu, au démarrage : `var level = LtPlaytest.consume("level")` (null : partie
normale) ; `LtPlaytest.is_playtest()` pour proposer « retour à l'éditeur »
(`LtPlaytest.back_to_editor()`).

## Textes
`LtText.t("Save")` ; les textes du jeu en français :
`LtText.register("fr", {"Biome": "Biome"})`. Langue : réglage du projet
`level_tools/language`, ou `LtText.set_language()`.

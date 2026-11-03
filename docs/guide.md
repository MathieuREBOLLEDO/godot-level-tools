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
```

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
Grille de miniatures (navigateur) : `library.set_layout(LtLibraryCard.Layout.GRID)`.

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
`library.rename_requested.connect(document.rename_file)`. Laisser faux quand
un autre fichier retient le chemin (cartes du monde de Gringo, ordre des
pièces de DungeonTactics).

## Réglages
`LtValueField.create(resource, &"speed", "Speed", "help", " m/s")` : bornes
lues dans `@export_range`.

## Essayer en jeu
Éditeur : `LtPlaytest.play(document.resource, "res://game/main.tscn")`.
Jeu, au démarrage : `var level = LtPlaytest.consume("level")` (null : partie
normale) ; `LtPlaytest.is_playtest()` pour proposer « retour à l'éditeur »
(`LtPlaytest.back_to_editor()`).

## Textes
`LtText.t("Save")` ; les textes du jeu en français :
`LtText.register("fr", {"Biome": "Biome"})`. Langue : réglage du projet
`level_tools/language`, ou `LtText.set_language()`.

@tool
class_name LtPaletteLayout
extends Resource

## Disposition d'une palette réglée par l'auteur du jeu (fenêtre
## LtPaletteEditor), enregistrée dans le projet (res://, commitée) : noms des
## pages, page de chaque élément, image qui remplace le dessin d'un élément.
## Tout ce qui n'y est pas garde la valeur donnée par le jeu (pages et page
## par défaut, dessin du code). L'ordre et les favoris restent à la machine
## (user://, la palette).
## Le jeu lit une seule copie par chemin : open() ; après un changement,
## l'éditeur l'enregistre (save()) et la copie lue est la même.

## Noms des pages 1, 2... (la page 0, les favoris, n'y est pas) ; vide : les
## pages du jeu.
@export var pages: Array[String] = []
## Page (1, 2...) de chaque élément (id) déplacé par l'auteur.
@export var item_pages: Dictionary[String, int] = {}
## Image de chaque élément (id) qui remplace son dessin.
@export var textures: Dictionary[String, Texture2D] = {}

static var _opened: Dictionary[String, LtPaletteLayout] = {}


## Disposition enregistrée à [param path], ou une vide (rien n'est écrit tant
## qu'on ne la change pas) ; la même copie à chaque appel.
static func open(path: String) -> LtPaletteLayout:
	if _opened.has(path):
		return _opened[path]
	var layout: LtPaletteLayout = null
	if ResourceLoader.exists(path):
		layout = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE) as LtPaletteLayout
	if layout == null:
		layout = LtPaletteLayout.new()
	_opened[path] = layout
	return layout


## Oublie la copie lue (relue au prochain open()).
static func forget(path: String) -> void:
	_opened.erase(path)


## Enregistre dans [param path] ; vrai si c'est fait.
func save(path: String) -> bool:
	var error: Error = ResourceSaver.save(self, path)
	return error == OK


## Noms des pages 1, 2... : ceux de l'auteur, sinon [param defaults].
func page_names(defaults: Array[String]) -> Array[String]:
	return pages.duplicate() if not pages.is_empty() else defaults.duplicate()


## Page (1, 2...) de l'élément [param id] : celle choisie par l'auteur, sinon
## [param default] ; ramenée à la dernière page si elle n'existe plus.
func page_of(id: String, default: int, page_count: int) -> int:
	return clampi(item_pages.get(id, default), 1, maxi(page_count, 1))


## Image qui remplace le dessin de [param id] (null : le dessin du jeu).
func texture_of(id: String) -> Texture2D:
	return textures.get(id, null)


## Revient aux pages, aux places et aux dessins du jeu.
func reset() -> void:
	pages.clear()
	item_pages.clear()
	textures.clear()


## Pose [param texture] sur [param area] (pixels, dans [param parent]) case
## par case ([param cell] pixels de côté) : l'image d'un élément en jeu.
## Rend le conteneur des images (enfant de [param parent]).
static func cover(parent: Node, area: Rect2, texture: Texture2D, cell: float) -> Control:
	var holder: Control = Control.new()
	holder.position = area.position
	holder.size = area.size
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var columns: int = maxi(roundi(area.size.x / cell), 1)
	var rows: int = maxi(roundi(area.size.y / cell), 1)
	for y: int in rows:
		for x: int in columns:
			var image: TextureRect = TextureRect.new()
			image.texture = texture
			image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode = TextureRect.STRETCH_SCALE
			image.position = Vector2(x * cell, y * cell)
			image.size = Vector2(cell, minf(cell, area.size.y - y * cell))
			image.mouse_filter = Control.MOUSE_FILTER_IGNORE
			holder.add_child(image)
	parent.add_child(holder)
	return holder

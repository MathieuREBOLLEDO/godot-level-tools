@tool
class_name LtLayers
extends RefCounted

## Calques d'un projet, les mêmes pour l'éditeur et le jeu : réglage du
## projet level_tools/layers, une liste dans l'ordre du dessin (du fond vers
## le devant). Chaque calque : {id, name, collides, front, reveal}.
## - id : rangé dans les fichiers des niveaux (ne pas le changer après coup) ;
## - name : affiché dans l'éditeur ;
## - collides : ses cases solides bloquent le joueur ;
## - front : dessiné devant le joueur ;
## - reveal : opaque, chaque groupe de cases s'efface quand le joueur y entre
##   (caches des secrets) ; le jeu s'en charge.
## Le calque GAME (les éléments de jeu : départ, pièges, ennemis...) est
## toujours là, même si le réglage l'oublie. Sans réglage : DEFAULT (fond,
## jeu, secret, devant).

const SETTING: String = "level_tools/layers"
const GAME: String = "game"
const DEFAULT: Array[Dictionary] = [
	{"id": "back", "name": "Back", "collides": false, "front": false, "reveal": false},
	{"id": "game", "name": "Game", "collides": true, "front": false, "reveal": false},
	{"id": "secret", "name": "Secret", "collides": false, "front": true, "reveal": true},
	{"id": "front", "name": "Front", "collides": false, "front": true, "reveal": false},
]


## Les calques du projet, nettoyés : un id par calque, GAME présent, clés
## manquantes à leur défaut.
static func list() -> Array[Dictionary]:
	var raw: Variant = ProjectSettings.get_setting(SETTING, DEFAULT)
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	if raw is Array:
		for entry: Variant in raw:
			if not entry is Dictionary:
				continue
			var id: String = str((entry as Dictionary).get("id", "")).strip_edges()
			if id == "" or seen.has(id):
				continue
			seen[id] = true
			result.append({
				"id": id,
				"name": str((entry as Dictionary).get("name", id.capitalize())),
				"collides": bool((entry as Dictionary).get("collides", id == GAME)),
				"front": bool((entry as Dictionary).get("front", false)),
				"reveal": bool((entry as Dictionary).get("reveal", false)),
			})
	if result.is_empty():
		return DEFAULT.duplicate(true)
	if not seen.has(GAME):
		# Le calque du jeu au milieu : derrière les calques de devant.
		var at: int = result.size()
		for index: int in result.size():
			if result[index]["front"]:
				at = index
				break
		result.insert(at, DEFAULT[1].duplicate())
	return result


## Identifiants, dans l'ordre du dessin.
static func ids() -> PackedStringArray:
	var result: PackedStringArray = []
	for layer: Dictionary in list():
		result.append(layer["id"])
	return result


## Le calque [param id] ({} s'il n'est pas dans le réglage).
static func info(id: String) -> Dictionary:
	for layer: Dictionary in list():
		if layer["id"] == id:
			return layer
	return {}


## Déclare le réglage dans Paramètres du projet (plugin de l'addon).
static func register_setting() -> void:
	if not ProjectSettings.has_setting(SETTING):
		ProjectSettings.set_setting(SETTING, DEFAULT.duplicate(true))
	ProjectSettings.set_initial_value(SETTING, DEFAULT.duplicate(true))
	ProjectSettings.add_property_info({"name": SETTING, "type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING, "hint_string": "%d:" % TYPE_DICTIONARY})
	ProjectSettings.set_as_basic(SETTING, true)

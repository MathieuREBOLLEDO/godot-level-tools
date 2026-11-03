@tool
class_name LtPlaytest
extends RefCounted

## « Essayer en jeu » : l'éditeur écrit une demande dans user://, lance la
## scène du jeu ; le jeu lit la demande une seule fois (consume()) puis
## l'efface. La demande porte un document à jouer : une ressource (copiée,
## même non enregistrée : niveau de Gringo) ou un chemin (zone de
## RoguePinball, niveau de BatEmUp), et un genre pour qu'un jeu à plusieurs
## éditeurs sache ce qu'on lui demande (« level », « pattern »...).
## Repris de LevelData.PLAY_PATH (Gringo), run_layout.gd (RoguePinball) et
## level_runner.gd (BatEmUp).

const REQUEST_PATH: String = "user://level_tools/playtest.cfg"
const RESOURCE_PATH: String = "user://level_tools/playtest.tres"
# Rangé dans les métadonnées d'Engine : vrai pendant une partie d'essai.
const META: StringName = &"level_tools_playtest"


## Demande de jouer [param document] (Resource ou chemin) ; [param kind] : le
## genre de document.
static func request(document: Variant, kind: String = "level") -> Error:
	DirAccess.make_dir_recursive_absolute(REQUEST_PATH.get_base_dir())
	var config: ConfigFile = ConfigFile.new()
	config.set_value("request", "kind", kind)
	if document is Resource:
		var error: Error = ResourceSaver.save(document, RESOURCE_PATH)
		if error != OK:
			return error
		config.set_value("request", "resource", RESOURCE_PATH)
	else:
		config.set_value("request", "path", str(document))
	return config.save(REQUEST_PATH)


## Demande puis lance [param scene_path] : dans l'éditeur Godot, comme
## « Lancer une scène » ; en jeu, en changeant de scène.
static func play(document: Variant, scene_path: String, kind: String = "level") -> Error:
	var error: Error = request(document, kind)
	if error != OK:
		return error
	if Engine.is_editor_hint() and Engine.has_singleton(&"EditorInterface"):
		Engine.get_singleton(&"EditorInterface").play_custom_scene(scene_path)
		return OK
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	return tree.change_scene_to_file(scene_path) if tree != null else ERR_UNAVAILABLE


## Côté jeu : la demande de genre [param kind] (la ressource chargée, ou le
## chemin), effacée aussitôt ; null s'il n'y en a pas. [param editor_only] :
## seulement dans une partie lancée depuis l'éditeur Godot (une demande
## oubliée ne change pas une vraie partie).
static func consume(kind: String = "level", editor_only: bool = true) -> Variant:
	if editor_only and not OS.has_feature("editor"):
		return null
	if not FileAccess.file_exists(REQUEST_PATH):
		return null
	var config: ConfigFile = ConfigFile.new()
	if config.load(REQUEST_PATH) != OK or str(config.get_value("request", "kind", "")) != kind:
		return null
	var result: Variant = null
	if config.has_section_key("request", "resource"):
		result = ResourceLoader.load(RESOURCE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		result = str(config.get_value("request", "path", ""))
	clear()
	Engine.set_meta(META, true)
	return result


## Vrai si la partie a été lancée par « Essayer » (bouton « retour à
## l'éditeur » dans la pause...).
static func is_playtest() -> bool:
	return Engine.get_meta(META, false)


## Retour à l'éditeur : ferme la partie lancée depuis l'éditeur Godot.
static func back_to_editor() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and OS.has_feature("editor"):
		tree.quit()


## Efface une demande en attente.
static func clear() -> void:
	for path: String in [REQUEST_PATH, RESOURCE_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)

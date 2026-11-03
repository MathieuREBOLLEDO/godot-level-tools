@tool
class_name LtFiles
extends RefCounted

## Opérations sur les fichiers des éditeurs : liste d'un dossier, nom libre,
## nom nettoyé, enregistrement, renommage, corbeille, import, et mémoire de
## l'éditeur (dernier fichier ouvert...) dans un .cfg de user://.
## Repris de BatEmUp (corbeille, renommage), Gringo (import, dernière carte
## rouverte) et RoguePinball (dernière zone rouverte).


## Fichiers de [param dir] qui finissent par [param extension], triés.
## Marche aussi dans un jeu exporté (ResourceLoader.list_directory).
static func list(dir: String, extension: String = ".tres") -> PackedStringArray:
	var paths: PackedStringArray = []
	if not DirAccess.dir_exists_absolute(dir):
		return paths
	var folder: String = dir if dir.ends_with("/") else dir + "/"
	for file: String in ResourceLoader.list_directory(folder):
		if file.ends_with(extension):
			paths.append(folder + file)
	paths.sort()
	return paths


## Charge sans le cache : relit le fichier tel qu'il est sur le disque.
static func load_fresh(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)


## Nom de fichier en snake_case, sans caractère interdit (« Boss 2 » ->
## « boss_2 »).
static func clean_name(text: String) -> String:
	var cleaned: String = text.strip_edges().to_snake_case().replace(" ", "_")
	var result: String = ""
	for character: String in cleaned:
		if character.is_valid_identifier() or character.is_valid_int() or character == "_":
			result += character
	return result


## Chemin libre dans [param dir] : base.tres, sinon base_2.tres, base_3...
static func free_path(dir: String, base_name: String, extension: String = ".tres") -> String:
	var folder: String = dir if dir.ends_with("/") else dir + "/"
	var candidate: String = folder + base_name + extension
	var number: int = 2
	while FileAccess.file_exists(candidate):
		candidate = folder + "%s_%d%s" % [base_name, number, extension]
		number += 1
	return candidate


## Enregistre [param resource] dans [param path] (dossier créé au besoin) ;
## la ressource prend ce chemin.
static func save(resource: Resource, path: String) -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var error: Error = ResourceSaver.save(resource, path)
	if error == OK:
		resource.take_over_path(path)
	return error


## Renomme le fichier de [param resource] ; la ressource prend le nouveau
## chemin. ERR_ALREADY_EXISTS si la cible existe.
static func rename(resource: Resource, from: String, to: String) -> Error:
	if from == to:
		return OK
	if FileAccess.file_exists(to):
		return ERR_ALREADY_EXISTS
	var error: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(from), ProjectSettings.globalize_path(to))
	if error == OK and resource != null:
		resource.take_over_path(to)
	return error


## Met le fichier à la corbeille du système (récupérable).
static func trash(path: String) -> Error:
	return OS.move_to_trash(ProjectSettings.globalize_path(path))


## Copie des ressources (n'importe où sur le disque) dans [param dir] ; un nom
## déjà pris reçoit un numéro. [param accept] : (Resource) -> bool, refuse ce
## qui n'est pas du bon type ; [param on_copy] : (copie, chemin) -> void, avant
## l'écriture (renommer le contenu...). Rend les chemins écrits.
static func import_files(sources: PackedStringArray, dir: String, accept: Callable = Callable(), on_copy: Callable = Callable()) -> PackedStringArray:
	var written: PackedStringArray = []
	for source: String in sources:
		if not FileAccess.file_exists(source):
			continue
		var loaded: Resource = ResourceLoader.load(source, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded == null or (accept.is_valid() and not accept.call(loaded)):
			continue
		var copy: Resource = loaded.duplicate(true)
		var target: String = free_path(dir, source.get_file().get_basename(), "." + source.get_extension())
		if on_copy.is_valid():
			on_copy.call(copy, target)
		if save(copy, target) == OK:
			written.append(target)
	return written


# --- Mémoire de l'éditeur ---

## Garde une valeur dans [param config_path] (user://<éditeur>.cfg).
static func remember(config_path: String, section: String, key: String, value: Variant) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(config_path)
	config.set_value(section, key, value)
	config.save(config_path)


static func recall(config_path: String, section: String, key: String, default: Variant = null) -> Variant:
	var config: ConfigFile = ConfigFile.new()
	if config.load(config_path) != OK:
		return default
	return config.get_value(section, key, default)


## Fichier à rouvrir : le dernier gardé s'il est encore dans
## [param candidates], sinon le premier, sinon « ».
static func last_or_first(config_path: String, section: String, key: String, candidates: PackedStringArray) -> String:
	var last: String = str(recall(config_path, section, key, ""))
	if candidates.has(last):
		return last
	return candidates[0] if not candidates.is_empty() else ""

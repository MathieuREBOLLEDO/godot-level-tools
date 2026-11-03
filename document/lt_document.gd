@tool
class_name LtDocument
extends RefCounted

## Le document ouvert dans un éditeur : une ressource enregistrée dans
## [member dir]. Ouvrir, créer, dupliquer, mettre à la corbeille,
## enregistrer (renommer le fichier si le nom a changé), état modifié ; un
## document modifié est enregistré avant d'en ouvrir ou d'en créer un autre
## ([member save_before_switch]).
## Les messages (réussite, erreur) partent par [signal message] : la coque les
## affiche dans son pied. Repris de BatEmUp (éditeurs de niveaux et de
## patterns).

## Un document est ouvert (ou plus aucun : resource null).
signal opened(resource: Resource)
## Le document a été enregistré.
signal saved(path: String)
## Un fichier a été écrit, renommé ou supprimé (relire la bibliothèque,
## scanner le système de fichiers de l'éditeur).
signal files_changed
## modifié / enregistré.
signal dirty_changed(dirty: bool)
## Texte pour le pied ; [param kind] : « info », « good » ou « bad ».
signal message(text: String, kind: String)

## Dossier des documents (res://… ou user://…).
var dir: String
var extension: String = ".tres"
var save_before_switch: bool = true
var resource: Resource = null
var path: String = ""
var dirty: bool = false:
	set(value):
		if dirty != value:
			dirty = value
			dirty_changed.emit(value)


func _init(p_dir: String, p_extension: String = ".tres") -> void:
	dir = p_dir if p_dir.ends_with("/") else p_dir + "/"
	extension = p_extension


## Documents du dossier, triés.
func paths() -> PackedStringArray:
	return LtFiles.list(dir, extension)


## Nom du document ouvert (nom du fichier sans extension).
func file_name() -> String:
	return path.get_file().get_basename()


func open(file_path: String) -> bool:
	if file_path == path and resource != null:
		return true
	if not _leave_current():
		return false
	var loaded: Resource = load(file_path)
	if loaded == null:
		message.emit(LtText.t("Cannot open %s.") % file_path.get_file(), "bad")
		return false
	resource = loaded
	path = file_path
	dirty = false
	opened.emit(resource)
	message.emit(LtText.t("Opened %s.") % file_path.get_file(), "info")
	return true


## Ouvre le dernier document gardé dans [param config_path], sinon le premier
## du dossier. Rend faux s'il n'y en a aucun.
func open_last(config_path: String) -> bool:
	var file_path: String = LtFiles.last_or_first(config_path, "document", dir, paths())
	return file_path != "" and open(file_path)


## Garde le document ouvert pour open_last().
func remember(config_path: String) -> void:
	if path != "":
		LtFiles.remember(config_path, "document", dir, path)


## Enregistre [param created] sous un nom libre tiré de [param base_name],
## puis l'ouvre.
func create(created: Resource, base_name: String) -> bool:
	if not _leave_current():
		return false
	var file_path: String = LtFiles.free_path(dir, base_name, extension)
	var error: Error = LtFiles.save(created, file_path)
	if error != OK:
		message.emit(LtText.t("Cannot write %s (%s).") % [file_path.get_file(), error_string(error)], "bad")
		return false
	files_changed.emit()
	resource = null
	path = ""
	return open(file_path)


## Copie du document ouvert (nom_copy), ouverte.
func duplicate_current() -> bool:
	if resource == null:
		return false
	return create(resource.duplicate(true), file_name() + "_copy")


## Met le document ouvert à la corbeille ; ouvre le premier qui reste.
func trash_current() -> bool:
	if path == "":
		return false
	var error: Error = LtFiles.trash(path)
	if error != OK:
		message.emit(LtText.t("Cannot delete %s (%s).") % [path.get_file(), error_string(error)], "bad")
		return false
	message.emit(LtText.t("%s moved to the trash.") % path.get_file(), "info")
	var deleted: String = path
	resource = null
	path = ""
	dirty = false
	files_changed.emit()
	var left: PackedStringArray = paths()
	if left.has(deleted):
		left.remove_at(left.find(deleted))
	if not left.is_empty():
		open(left[0])
	else:
		opened.emit(null)
	return true


## Renomme le fichier [param file_path] (carte de la bibliothèque) ; le
## document ouvert est enregistré sous ce nom, un autre est seulement
## renommé sur le disque.
func rename_file(file_path: String, wanted_name: String) -> bool:
	if file_path == path:
		return save(wanted_name)
	var cleaned: String = LtFiles.clean_name(wanted_name)
	if cleaned == "":
		message.emit(LtText.t("The name is empty."), "bad")
		return false
	var target: String = dir + cleaned + extension
	if FileAccess.file_exists(target):
		message.emit(LtText.t("%s already exists: choose another name.") % target.get_file(), "bad")
		return false
	var cached: Resource = ResourceLoader.get_cached_ref(file_path) if ResourceLoader.has_cached(file_path) else null
	var error: Error = LtFiles.rename(cached, file_path, target)
	if error != OK:
		message.emit(LtText.t("Cannot rename (%s).") % error_string(error), "bad")
		return false
	message.emit(LtText.t("Renamed %s.") % target.get_file(), "good")
	files_changed.emit()
	return true


## Enregistre ; [param wanted_name] (le nom de l'en-tête) renomme le fichier
## s'il a changé (« » : garde le nom).
func save(wanted_name: String = "") -> bool:
	if resource == null or path == "":
		return false
	if wanted_name != "":
		var cleaned: String = LtFiles.clean_name(wanted_name)
		if cleaned == "":
			message.emit(LtText.t("The name is empty."), "bad")
			return false
		var target: String = dir + cleaned + extension
		if target != path:
			if FileAccess.file_exists(target):
				message.emit(LtText.t("%s already exists: choose another name.") % target.get_file(), "bad")
				return false
			var moved: Error = LtFiles.rename(resource, path, target)
			if moved != OK:
				message.emit(LtText.t("Cannot rename (%s).") % error_string(moved), "bad")
				return false
			path = target
	var error: Error = LtFiles.save(resource, path)
	if error != OK:
		message.emit(LtText.t("Cannot save %s (%s).") % [path.get_file(), error_string(error)], "bad")
		return false
	dirty = false
	message.emit(LtText.t("Saved %s.") % path.get_file(), "good")
	saved.emit(path)
	files_changed.emit()
	return true


# Avant d'ouvrir ou de créer un autre document : enregistre le document
# modifié ([member save_before_switch]). Faux si l'enregistrement a échoué.
func _leave_current() -> bool:
	if dirty and save_before_switch and resource != null:
		return save()
	return true

@tool
class_name LtHistory
extends RefCounted

## Annuler / refaire par instantanés : marche en jeu et dans l'éditeur Godot.
## Un instantané est ce que rend [member capture] (un Resource copié, un
## Dictionary...) ; [member restore] le remet en place.
## Après chaque modification, l'éditeur appelle changed() : l'état d'avant
## (gardé depuis la modification précédente) part dans la pile. Des
## modifications rapprochées (moins de [member pause] s, un curseur qu'on
## glisse) font un seul pas si elles sont marquées grouped ; une modification
## de structure (ajout, retrait, coup de pinceau) en fait toujours un.
## Repris de BatEmUp (éditeurs de niveaux et de patterns) et de l'éditeur de
## niveaux de Gringo.

## La pile a changé (activer / griser les boutons).
signal stack_changed
## Un état a été remis par undo() ou redo().
signal restored

## Nombre de pas gardés.
var limit: int = 100
## Délai (s) sous lequel des modifications groupées font un seul pas.
var pause: float = 0.5

var _capture: Callable
var _restore: Callable
var _undo: Array = []
var _redo: Array = []
var _shadow: Variant = null
var _last_change_msec: int = -100000


## [param capture] : () -> instantané ; [param restore] : (instantané) -> void.
func _init(capture: Callable, restore: Callable) -> void:
	_capture = capture
	_restore = restore
	_shadow = _capture.call()


## Historique d'une ressource : copie profonde, remise en place dans la même
## ressource (une scène qui la référence la garde).
static func for_resource(resource: Resource) -> LtHistory:
	return LtHistory.new(func() -> Resource: return resource.duplicate(true),
		func(snapshot: Resource) -> void: copy_into(resource, snapshot))


## Recopie les propriétés enregistrées de [param source] dans [param target].
static func copy_into(target: Object, source: Object) -> void:
	for info: Dictionary in source.get_property_list():
		if not (info.usage & PROPERTY_USAGE_STORAGE):
			continue
		var name: String = info.name
		if name == "script" or name.begins_with("resource_"):
			continue
		var value: Variant = source.get(name)
		# Une copie : l'instantané ne doit pas partager ses tableaux.
		if value is Array or value is Dictionary:
			value = value.duplicate(true)
		target.set(name, value)


## Repart de l'état courant, piles vides (document ouvert, nouveau...).
func reset() -> void:
	_undo.clear()
	_redo.clear()
	_shadow = _capture.call()
	_last_change_msec = -100000
	stack_changed.emit()


## À appeler après chaque modification. [param grouped] : se fond dans le pas
## précédent si elle arrive moins de [member pause] s après.
func changed(grouped: bool = false) -> void:
	var now: int = Time.get_ticks_msec()
	if not grouped or now - _last_change_msec > pause * 1000.0:
		_undo.append(_shadow)
		if _undo.size() > limit:
			_undo.pop_front()
		_redo.clear()
	_last_change_msec = now if grouped else -100000
	_shadow = _capture.call()
	stack_changed.emit()


func can_undo() -> bool:
	return not _undo.is_empty()


func can_redo() -> bool:
	return not _redo.is_empty()


func undo() -> bool:
	return _step(_undo, _redo)


func redo() -> bool:
	return _step(_redo, _undo)


## Ctrl+Z, Ctrl+Y, Ctrl+Maj+Z (Cmd sur macOS) ; ignorés quand un champ texte a
## le focus (il a son propre annuler). Rend vrai si la touche a été prise.
func handle_key(event: InputEvent, focus_owner: Control = null) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo or not key.is_command_or_control_pressed():
		return false
	if focus_owner is LineEdit or focus_owner is TextEdit:
		return false
	if key.keycode == KEY_Z and not key.shift_pressed:
		undo()
		return true
	if key.keycode == KEY_Y or (key.keycode == KEY_Z and key.shift_pressed):
		redo()
		return true
	return false


# L'état courant passe dans [param to], le dernier de [param from] revient.
func _step(from: Array, to: Array) -> bool:
	if from.is_empty():
		return false
	to.append(_capture.call())
	_restore.call(from.pop_back())
	_shadow = _capture.call()
	_last_change_msec = -100000
	stack_changed.emit()
	restored.emit()
	return true

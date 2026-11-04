@tool
class_name LtCellSelection
extends RefCounted

## Sélection de zone d'un canvas sur grille, la même partout (Gringo Level,
## Pinball Modules, Rooms) :
## - Maj + clic gauche glissé : trace la zone (case de départ à case
##   d'arrivée) ;
## - Ctrl+D : la zone est dupliquée juste à sa droite, la sélection suit la
##   copie ; Suppr : la zone est vidée ; Échap : plus de sélection.
## Le canvas donne ses cases (cell_at, cell_rect) ; l'éditeur fait le travail
## sur ses données (signal action_requested), une action annulable.

## La zone a changé (redessiner).
signal changed
## Ctrl+D (« duplicate ») ou Suppr (« delete ») sur la zone [param rect].
## Pour « duplicate », [param offset] : où va la copie (en cases).
signal action_requested(action: String, rect: Rect2i, offset: Vector2i)

## Zone choisie, en cases ; taille nulle : rien.
var rect: Rect2i = Rect2i()

var _dragging: bool = false
var _start: Vector2i = Vector2i.ZERO


func has() -> bool:
	return rect.size.x > 0 and rect.size.y > 0


func clear() -> void:
	if has() or _dragging:
		rect = Rect2i()
		_dragging = false
		changed.emit()


## Maj + clic gauche glissé ; [param cell_at] : (position à l'écran) ->
## Vector2i. Vrai si l'événement a servi (le canvas ne peint pas).
func handle_input(event: InputEvent, cell_at: Callable) -> bool:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		if button.pressed and button.shift_pressed:
			_dragging = true
			_start = cell_at.call(button.position)
			_set_corners(_start, _start)
			return true
		if not button.pressed and _dragging:
			_dragging = false
			return true
		if button.pressed:
			# Un clic sans Maj : on peint, la zone s'en va.
			clear()
		return false
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and _dragging:
		_set_corners(_start, cell_at.call(motion.position))
		return true
	return false


## Ctrl+D, Suppr, Échap ; vrai si la touche a servi.
func handle_key(event: InputEvent) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo or not has():
		return false
	if key.keycode == KEY_ESCAPE:
		clear()
		return true
	if key.keycode == KEY_DELETE and not key.is_command_or_control_pressed():
		action_requested.emit("delete", rect, Vector2i.ZERO)
		return true
	if key.keycode == KEY_D and key.is_command_or_control_pressed():
		var offset: Vector2i = Vector2i(rect.size.x, 0)
		action_requested.emit("duplicate", rect, offset)
		rect.position += offset
		changed.emit()
		return true
	return false


## Cadre de la zone sur le canvas ; [param cell_rect] : (Vector2i) -> Rect2
## à l'écran d'une case.
func draw(canvas: CanvasItem, cell_rect: Callable) -> void:
	if not has():
		return
	var top_left: Rect2 = cell_rect.call(rect.position)
	var bottom_right: Rect2 = cell_rect.call(rect.end - Vector2i.ONE)
	var area: Rect2 = Rect2(top_left.position, bottom_right.end - top_left.position)
	canvas.draw_rect(area, Color(LtTheme.ACCENT, 0.12))
	canvas.draw_rect(area, LtTheme.ACCENT, false, 2.0)


## Cases de [param area], ligne par ligne.
static func cells_of(area: Rect2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			cells.append(Vector2i(x, y))
	return cells


func _set_corners(a: Vector2i, b: Vector2i) -> void:
	var low: Vector2i = Vector2i(mini(a.x, b.x), mini(a.y, b.y))
	var high: Vector2i = Vector2i(maxi(a.x, b.x), maxi(a.y, b.y))
	rect = Rect2i(low, high - low + Vector2i.ONE)
	changed.emit()

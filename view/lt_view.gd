@tool
class_name LtView
extends RefCounted

## Vue d'un canvas d'éditeur, les mêmes gestes partout (DESIGN.md) :
## - molette : zoom centré sur le curseur ;
## - clic du milieu glissé, ou Espace + clic gauche glissé : déplacer ;
## - F : cadrer tout le contenu (la vue suit alors la taille du canvas) ;
## - Maj + molette, R / Maj + R : tourner l'élément choisi (turn_requested).
## Le canvas garde son dessin : il passe ses événements à handle_input() et
## handle_key(), dessine avec to_screen() et unit() (px par unité : une case,
## un mètre...), et appelle fit() quand son contenu change de taille.
## Tant qu'on n'a ni zoomé ni déplacé, la vue reste cadrée (auto_fit) :
## comme avant dans les éditeurs qui faisaient tenir le niveau dans le cadre.

## La vue a bougé (redessiner).
signal changed
## Tourner l'élément choisi de [param step] quarts de tour (1 : sens horaire).
signal turn_requested(step: int)

## Facteur d'un cran de molette.
const ZOOM_STEP: float = 1.15

## Px à l'écran par unité du contenu.
var zoom: float = 32.0
## Position à l'écran de l'origine du contenu.
var pan: Vector2 = Vector2.ZERO
## Bornes du zoom (px par unité).
var zoom_range: Vector2 = Vector2(4.0, 160.0)
## Vrai : fit() recadre à chaque appel (on n'a pas encore zoomé ni déplacé).
var auto_fit: bool = true
## Marge autour du contenu cadré (px).
var margin: float = 16.0
## Zoom le plus fort au cadrage (des cases pas trop grosses pour une petite
## grille) ; on peut zoomer plus à la molette.
var fit_max_zoom: float = INF
## Zoom arrondi à l'entier au cadrage (cases nettes).
var whole_pixels: bool = true

var _content: Rect2 = Rect2()
var _view_size: Vector2 = Vector2.ZERO
var _panning: bool = false
var _space: bool = false


## Point du contenu (unités) vers l'écran (px du canvas).
func to_screen(at: Vector2) -> Vector2:
	return pan + at * zoom


## Point de l'écran vers le contenu.
func to_content(at: Vector2) -> Vector2:
	return (at - pan) / zoom


## Case (unités entières) sous un point de l'écran.
func cell_at(at: Vector2) -> Vector2i:
	return Vector2i(to_content(at).floor())


## Rectangle à l'écran d'une case.
func cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(to_screen(Vector2(cell)), Vector2.ONE * zoom)


func unit() -> float:
	return zoom


## Contenu à montrer ([param content], en unités) dans un canvas de taille
## [param view_size] : recadre si auto_fit (ou [param force]).
func fit(content: Rect2, view_size: Vector2, force: bool = false) -> void:
	_content = content
	_view_size = view_size
	if force:
		auto_fit = true
	if not auto_fit or content.size.x <= 0.0 or content.size.y <= 0.0 or view_size.x <= 0.0 or view_size.y <= 0.0:
		return
	var room: Vector2 = (view_size - Vector2.ONE * margin * 2.0).max(Vector2.ONE)
	var scale: float = minf(room.x / content.size.x, room.y / content.size.y)
	if whole_pixels and scale >= 1.0:
		scale = floorf(scale)
	var new_zoom: float = clampf(scale, zoom_range.x, minf(zoom_range.y, fit_max_zoom))
	var new_pan: Vector2 = ((view_size - content.size * new_zoom) * 0.5 - content.position * new_zoom).floor()
	# Rien ne change : pas de signal (un canvas peut cadrer dans son _draw).
	if is_equal_approx(new_zoom, zoom) and new_pan == pan:
		return
	zoom = new_zoom
	pan = new_pan
	changed.emit()


## Recadre tout le contenu (touche F).
func frame() -> void:
	fit(_content, _view_size, true)


## Zoom de [param factor] autour du point [param at] de l'écran (il reste
## sous le curseur).
func zoom_at(at: Vector2, factor: float) -> void:
	var before: Vector2 = to_content(at)
	zoom = clampf(zoom * factor, zoom_range.x, zoom_range.y)
	pan = at - before * zoom
	auto_fit = false
	changed.emit()


## Gestes de la souris pour la vue ; vrai si l'événement a servi (le canvas
## l'accepte alors et ne peint pas).
func handle_input(event: InputEvent) -> bool:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null:
		if button.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			if button.pressed:
				var up: bool = button.button_index == MOUSE_BUTTON_WHEEL_UP
				if button.shift_pressed:
					turn_requested.emit(-1 if up else 1)
				else:
					zoom_at(button.position, ZOOM_STEP if up else 1.0 / ZOOM_STEP)
			return true
		if button.button_index == MOUSE_BUTTON_MIDDLE or (button.button_index == MOUSE_BUTTON_LEFT and (_space or _panning)):
			_panning = button.pressed
			return true
		return false
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and _panning:
		pan += motion.relative
		auto_fit = false
		changed.emit()
		return true
	return false


## Touches de la vue (F, R, Maj + R, Espace) ; le canvas les passe quand la
## souris est dessus. Vrai si la touche a servi.
func handle_key(event: InputEvent) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key == null or key.is_command_or_control_pressed() or key.alt_pressed:
		return false
	if key.keycode == KEY_SPACE:
		_space = key.pressed
		if not key.pressed:
			_panning = false
		return true
	if not key.pressed or key.echo:
		return false
	match key.keycode:
		KEY_F:
			frame()
			return true
		KEY_R:
			turn_requested.emit(-1 if key.shift_pressed else 1)
			return true
	return false


## La souris a quitté le canvas : plus de déplacement en cours.
func release() -> void:
	_panning = false
	_space = false


func is_panning() -> bool:
	return _panning

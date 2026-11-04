@tool
class_name LtPathEditor
extends RefCounted

## Mode chemin, le même partout (plateformes mobiles de Gringo, vagues de
## BatEmUp ; un futur objet mobile de Pinball) : un chemin est une suite de
## points, dans les unités du jeu.
## - Gestes, quand [member active] : clic gauche = un point de plus (à la
##   fin), clic droit = retirer le dernier point.
## - draw() : le tracé, ses points numérotés (1, 2...), fermé si le chemin
##   boucle.
## Le jeu garde ses points où il veut (Curve2D, tableau de cases) : il
## répond aux signaux et donne les points à l'écran pour le dessin.

## Clic gauche : [param at], le point dans les unités du contenu.
signal point_added(at: Vector2)
## Clic droit : retirer le dernier point.
signal last_point_removed

const POINT_RADIUS: float = 6.0
const NUMBER_SIZE: int = 13

## Vrai pendant l'édition d'un chemin (les clics vont au chemin).
var active: bool = false


## Gestes du mode chemin ; [param to_content] : (position à l'écran) -> point.
## Vrai si l'événement a servi.
func handle_input(event: InputEvent, to_content: Callable) -> bool:
	if not active:
		return false
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button == null or not button.pressed:
		return false
	if button.button_index == MOUSE_BUTTON_LEFT:
		point_added.emit(to_content.call(button.position))
		return true
	if button.button_index == MOUSE_BUTTON_RIGHT:
		last_point_removed.emit()
		return true
	return false


## Tracé de [param points] (déjà à l'écran du canvas) ; [param numbered] :
## numéros à côté des points ; [param closed] : retour au premier point.
## [param scale] : taille des points et du trait (un canvas dessiné à une
## autre échelle) ; les numéros gardent la leur.
static func draw(canvas: CanvasItem, points: PackedVector2Array, color: Color, numbered: bool = true, closed: bool = false, scale: float = 1.0) -> void:
	if points.is_empty():
		return
	var line: PackedVector2Array = points.duplicate()
	if closed and points.size() > 2:
		line.append(points[0])
	if line.size() > 1:
		canvas.draw_polyline(line, Color(color, 0.8), 2.0 * scale, true)
	var font: Font = LtTheme.mono_font()
	for index: int in points.size():
		canvas.draw_circle(points[index], POINT_RADIUS * scale, color)
		if numbered:
			# Les numéros gardent leur taille (lisibles même avec de petits points).
			canvas.draw_string(font, points[index] + Vector2(POINT_RADIUS + 3.0, -POINT_RADIUS) * scale, str(index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, NUMBER_SIZE, color)

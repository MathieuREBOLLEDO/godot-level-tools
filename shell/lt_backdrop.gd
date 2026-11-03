@tool
class_name LtBackdrop
extends Control

## Fond commun derrière le canvas ou l'aperçu de la coque (LtShell) : le
## fond INK, une grille discrète et un vignettage. Un canvas qui peint son
## propre fond le recouvre ; il se voit autour du contenu.

## Pas de la grille (px).
const STEP: int = 32
## Opacité des lignes de la grille et du vignettage aux bords.
const GRID_ALPHA: float = 0.35
const VIGNETTE_ALPHA: float = 0.35


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vignette: TextureRect = TextureRect.new()
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0, 0, 0, VIGNETTE_ALPHA))
	gradient.set_offset(0, 0.55)
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 1.0)
	vignette.texture = texture
	add_child(vignette)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), LtTheme.INK)
	var line: Color = Color(LtTheme.INK_LINE, GRID_ALPHA)
	for x: int in range(STEP, int(size.x), STEP):
		draw_line(Vector2(x, 0), Vector2(x, size.y), line)
	for y: int in range(STEP, int(size.y), STEP):
		draw_line(Vector2(0, y), Vector2(size.x, y), line)

@tool
class_name LtPaletteSlot
extends Button

## Case carrée de LtPalette (repris de ElementSlot de Gringo) : l'élément
## dessiné par le jeu (draw), ou une pastille de couleur et sa lettre ; la
## touche en petit en haut à gauche, l'étoile des favoris en haut à droite.
## Clic droit : favori. Glisser sur une autre case de la même page : ordre.

const SIZE: float = 40.0
const PADDING: float = 6.0
const ERASER_COLOR: Color = Color(0.95, 0.55, 0.6)
const ERASER_BAND_COLOR: Color = Color(0.9, 0.9, 0.9)

## Élément de la palette ({} : case vide de la grille) ; id "" : la gomme.
var item: Dictionary = {}
var page: int = -1
var palette: LtPalette
var favorite: bool = false
var key_hint: String = ""
var eraser: bool = false


func _init() -> void:
	custom_minimum_size = Vector2(SIZE, SIZE)
	toggle_mode = true
	focus_mode = Control.FOCUS_NONE


func _ready() -> void:
	if item.is_empty() and not eraser:
		disabled = true
		self_modulate.a = 0.35


func _gui_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.pressed and button.button_index == MOUSE_BUTTON_RIGHT and palette != null and not item.is_empty() and not eraser:
		palette.toggle_favorite(item["id"])
		accept_event()


func _get_drag_data(_at: Vector2) -> Variant:
	if item.is_empty() or eraser or palette == null:
		return null
	var preview: LtPaletteSlot = LtPaletteSlot.new()
	preview.item = item
	preview.modulate.a = 0.7
	set_drag_preview(preview)
	return {"lt_palette_item": item["id"], "page": page}


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("lt_palette_item") and data["page"] == page and not item.is_empty() and not eraser


func _drop_data(_at: Vector2, data: Variant) -> void:
	palette.move_item(page, data["lt_palette_item"], item["id"])


func _draw() -> void:
	if key_hint != "":
		draw_string(LtTheme.mono_font(), Vector2(3.0, 10.0), key_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, LtTheme.ACCENT if button_pressed else LtTheme.SAND_DIM)
	if favorite:
		_draw_star(Vector2(size.x - 6.0, 6.0), 3.5, LtTheme.ACCENT)
	var box: Rect2 = Rect2(Vector2.ZERO, size).grow(-PADDING)
	if eraser:
		var side: float = minf(box.size.x, box.size.y)
		draw_set_transform(box.get_center(), -PI / 4.0, Vector2.ONE * side / 24.0)
		draw_rect(Rect2(-11.0, -5.0, 22.0, 10.0), ERASER_COLOR)
		draw_rect(Rect2(-11.0, -5.0, 8.0, 10.0), ERASER_BAND_COLOR)
		draw_set_transform(Vector2.ZERO)
	elif item.has("draw"):
		(item["draw"] as Callable).call(self, box)
	elif item.has("color"):
		var swatch: Rect2 = box.grow(-2.0)
		draw_rect(swatch, item["color"])
		draw_rect(swatch, LtTheme.INK_LINE, false, 1.0)
		var letter: String = item.get("letter", "")
		if letter != "":
			var font: Font = LtTheme.mono_font()
			var font_size: int = 14
			var width: float = font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			var ink: Color = Color.BLACK if (item["color"] as Color).get_luminance() > 0.5 else Color.WHITE
			draw_string(font, swatch.get_center() + Vector2(-width * 0.5, font_size * 0.35), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink)


func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in 10:
		var angle: float = -PI * 0.5 + index * PI / 5.0
		points.append(center + Vector2.from_angle(angle) * (radius if index % 2 == 0 else radius * 0.45))
	draw_colored_polygon(points, color)

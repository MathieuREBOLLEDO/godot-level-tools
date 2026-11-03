@tool
class_name LtLibraryCard
extends Control

## Un élément de la bibliothèque (LtLibrary) : miniature, nom, détail en
## chasse fixe, pastille d'usage (« on this map » en vert, « on <autre> » en
## bleu...). Survol animé, filet d'accent quand il est choisi, estompé s'il
## est déjà utilisé ici. Clic : le choisir ; double-clic : l'ouvrir ; glisser
## : déposer [member drag_data] ailleurs (un canvas qui l'accepte).
## Repris de MapLevelCard (éditeur de carte de Gringo).

signal picked(key: String)
signal activated(key: String)
## Nouveau nom tapé sur la carte (clic droit > Rename, si [member renamable]).
signal rename_requested(key: String, new_name: String)

enum Layout { LIST, GRID }

const LIST_HEIGHT: float = 64.0
const LIST_THUMB_HEIGHT: float = 40.0
const GRID_SIZE: Vector2 = Vector2(230.0, 132.0)
const GRID_THUMB_HEIGHT: float = 76.0
const PAD: float = 8.0

## Identifiant rendu par les signaux (le chemin du fichier).
var key: String = ""
var title: String = ""
var detail: String = ""
var thumbnail: Texture2D = null
var badge: String = ""
var badge_color: Color = LtTheme.GOOD
## Déjà utilisé ici : estompé.
var dimmed: bool = false
## Donnée du glisser-déposer ; null : pas de glisser.
var drag_data: Variant = null
var layout: Layout = Layout.LIST
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()
## Clic droit > Rename : le nom se change sur la carte.
var renamable: bool = false

var _hover: float = 0.0 # 0 à 1, animé
var _hovering: bool = false
var _menu: PopupMenu = null
var _name_edit: LineEdit = null


## [param info] : title, detail, thumbnail, badge, badge_color, dimmed,
## tooltip, drag (clés absentes : valeur par défaut).
func _init(p_key: String, info: Dictionary, p_layout: Layout = Layout.LIST) -> void:
	key = p_key
	layout = p_layout
	title = info.get("title", p_key.get_file().get_basename())
	detail = info.get("detail", "")
	thumbnail = info.get("thumbnail", null)
	badge = info.get("badge", "")
	badge_color = info.get("badge_color", LtTheme.GOOD)
	dimmed = info.get("dimmed", false)
	drag_data = info.get("drag", null)
	tooltip_text = info.get("tooltip", p_key)
	if layout == Layout.GRID:
		custom_minimum_size = GRID_SIZE
	else:
		custom_minimum_size.y = LIST_HEIGHT
	mouse_default_cursor_shape = Control.CURSOR_DRAG if drag_data != null else Control.CURSOR_POINTING_HAND


func _ready() -> void:
	mouse_entered.connect(func() -> void: _hovering = true)
	mouse_exited.connect(func() -> void: _hovering = false)


func _process(delta: float) -> void:
	var target: float = 1.0 if _hovering else 0.0
	if not is_equal_approx(_hover, target):
		_hover = move_toward(_hover, target, delta * 6.0)
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button == null or not button.pressed:
		return
	if button.button_index == MOUSE_BUTTON_RIGHT and renamable:
		_open_menu(get_screen_position() + button.position)
		accept_event()
	elif button.button_index == MOUSE_BUTTON_LEFT:
		if button.double_click:
			activated.emit(key)
		else:
			picked.emit(key)


## Champ de saisie sur le nom de la carte ; Entrée valide, Échap annule.
func start_rename() -> void:
	if _name_edit != null:
		return
	_name_edit = LineEdit.new()
	_name_edit.text = key.get_file().get_basename()
	_name_edit.select_all_on_focus = true
	_name_edit.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	_name_edit.offset_left = PAD + 4.0
	_name_edit.offset_right = -PAD
	_name_edit.text_submitted.connect(func(text: String) -> void: _end_rename(text))
	_name_edit.focus_exited.connect(func() -> void: _end_rename(""))
	_name_edit.gui_input.connect(func(event: InputEvent) -> void:
		var key_event: InputEventKey = event as InputEventKey
		if key_event != null and key_event.pressed and key_event.keycode == KEY_ESCAPE:
			_end_rename(""))
	add_child(_name_edit)
	_name_edit.grab_focus()


func _end_rename(text: String) -> void:
	if _name_edit == null:
		return
	var edit: LineEdit = _name_edit
	_name_edit = null
	edit.queue_free()
	var wanted: String = text.strip_edges()
	if wanted != "" and wanted != key.get_file().get_basename():
		rename_requested.emit(key, wanted)


func _open_menu(at: Vector2) -> void:
	if _menu == null:
		_menu = PopupMenu.new()
		_menu.add_item(LtText.t("Rename…"), 0)
		_menu.id_pressed.connect(func(_id: int) -> void: start_rename.call_deferred())
		add_child(_menu)
	_menu.position = Vector2i(at)
	_menu.popup()


func _get_drag_data(_at: Vector2) -> Variant:
	if drag_data == null:
		return null
	if thumbnail != null:
		var preview: TextureRect = TextureRect.new()
		preview.texture = thumbnail
		preview.modulate = Color(1.0, 1.0, 1.0, 0.75)
		set_drag_preview(preview)
	picked.emit(key)
	return drag_data


func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, size).grow(-2.0)
	var fill: Color = LtTheme.INK_RAISED.lerp(LtTheme.INK_LINE, _hover * 0.5)
	draw_rect(rect, fill if not selected else LtTheme.INK_RAISED.lightened(0.05))
	# Filet à gauche : accent si choisi, sable au survol.
	var edge: Color = LtTheme.ACCENT if selected else Color(LtTheme.SAND_DIM, _hover)
	draw_rect(Rect2(rect.position, Vector2(3.0, rect.size.y)), edge)

	var alpha: float = 0.45 if dimmed and not selected else 1.0
	var font: Font = LtTheme.ui_font(true)
	var mono: Font = LtTheme.mono_font()
	var text_origin: Vector2
	var width: float
	if layout == Layout.GRID:
		var thumb_box: Rect2 = Rect2(Vector2(PAD + 4.0, PAD), Vector2(size.x - PAD * 2.0 - 4.0, GRID_THUMB_HEIGHT))
		_draw_thumbnail(thumb_box, alpha)
		text_origin = Vector2(PAD + 4.0, thumb_box.end.y + PAD + LtTheme.FONT_SIZE)
		width = size.x - text_origin.x - PAD
	else:
		var text_x: float = PAD + 4.0
		if thumbnail != null:
			var thumb_size: Vector2 = Vector2(thumbnail.get_size()) * (LIST_THUMB_HEIGHT / maxf(thumbnail.get_height(), 1.0))
			var thumb_rect: Rect2 = Rect2(Vector2(PAD + 4.0, (size.y - LIST_THUMB_HEIGHT) * 0.5), thumb_size)
			draw_rect(thumb_rect.grow(1.0), LtTheme.INK)
			draw_texture_rect(thumbnail, thumb_rect, false, Color(1.0, 1.0, 1.0, alpha))
			text_x = thumb_rect.end.x + PAD
		text_origin = Vector2(text_x, size.y * 0.5 - 2.0)
		width = size.x - text_x - PAD
	draw_string(font, text_origin, title, HORIZONTAL_ALIGNMENT_LEFT, width, LtTheme.FONT_SIZE + 1, Color(LtTheme.SAND, alpha))
	if detail != "":
		draw_string(mono, text_origin + Vector2(0.0, 16.0), detail, HORIZONTAL_ALIGNMENT_LEFT, width, LtTheme.SMALL_SIZE, Color(LtTheme.SAND_DIM, alpha))
	if badge != "":
		var badge_width: float = font.get_string_size(badge, HORIZONTAL_ALIGNMENT_LEFT, -1, LtTheme.SMALL_SIZE).x
		var badge_y: float = 16.0 if layout == Layout.LIST else text_origin.y + 32.0
		draw_string(font, Vector2(size.x - PAD - badge_width, badge_y), badge, HORIZONTAL_ALIGNMENT_LEFT, -1, LtTheme.SMALL_SIZE, badge_color)


# Miniature centrée dans [param area], à l'échelle, sans la déformer.
func _draw_thumbnail(area: Rect2, alpha: float) -> void:
	draw_rect(area, LtTheme.INK)
	if thumbnail == null:
		return
	var source: Vector2 = Vector2(thumbnail.get_size())
	var scale_factor: float = minf(area.size.x / maxf(source.x, 1.0), area.size.y / maxf(source.y, 1.0))
	var drawn: Vector2 = source * scale_factor
	draw_texture_rect(thumbnail, Rect2(area.position + (area.size - drawn) * 0.5, drawn), false, Color(1.0, 1.0, 1.0, alpha))

@tool
class_name LtFloatingPanel
extends PanelContainer

## Fenêtre flottante (palette du live edit, LtLiveEdit) : on la déplace par
## sa barre de titre, on la redimensionne par le coin en bas à droite ; elle
## reste dans l'écran. Apparence : LtTheme. Reprise du live edit de Gringo.

const MIN_SIZE: Vector2 = Vector2(140.0, 180.0)
const GRIP_SIZE: float = 12.0 # px du coin de redimensionnement

# Souris moins position (déplacement) ou moins taille (redimensionnement)
# pendant qu'on tire ; INF sinon.
var _move_from: Vector2 = Vector2.INF
var _resize_from: Vector2 = Vector2.INF


func _init(title: String, content: Control) -> void:
	theme = LtTheme.build()
	var style: StyleBoxFlat = LtTheme.box(LtTheme.INK_PANEL, LtTheme.INK_LINE, LtTheme.RADIUS, Vector4.ONE, Vector4(6, 4, 6, 4))
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	style.shadow_size = 10
	add_theme_stylebox_override(&"panel", style)
	custom_minimum_size = MIN_SIZE
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 2)
	add_child(column)

	var bar: Label = LtTheme.label(title, LtTheme.KICKER)
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
	bar.tooltip_text = LtText.t("Drag to move")
	bar.gui_input.connect(_on_bar_input)
	column.add_child(bar)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(content)

	var grip: Control = Control.new()
	grip.custom_minimum_size = Vector2(GRIP_SIZE, GRIP_SIZE)
	grip.size_flags_horizontal = Control.SIZE_SHRINK_END
	grip.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	grip.tooltip_text = LtText.t("Drag to resize")
	grip.gui_input.connect(_on_grip_input)
	grip.draw.connect(_draw_grip.bind(grip))
	column.add_child(grip)


func _on_bar_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		_move_from = get_global_mouse_position() - position if button.pressed else Vector2.INF
	elif event is InputEventMouseMotion and _move_from != Vector2.INF:
		position = get_global_mouse_position() - _move_from
		_keep_on_screen()


func _on_grip_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		_resize_from = get_global_mouse_position() - size if button.pressed else Vector2.INF
	elif event is InputEventMouseMotion and _resize_from != Vector2.INF:
		size = (get_global_mouse_position() - _resize_from).max(get_combined_minimum_size())
		_keep_on_screen()


func _keep_on_screen() -> void:
	var screen: Vector2 = get_viewport_rect().size
	size = size.min(screen)
	position = position.clamp(Vector2.ZERO, screen - size)


# Trois traits en biais dans le coin.
func _draw_grip(grip: Control) -> void:
	var corner: Vector2 = grip.size
	for step: float in [4.0, 8.0, 12.0]:
		grip.draw_line(corner - Vector2(step, 0.0), corner - Vector2(0.0, step), LtTheme.SAND_DIM, 1.0)

@tool
class_name LtValueField
extends HBoxContainer

## Une ligne de réglage : légende (bulle d'aide au survol), curseur, champ
## numérique en chasse fixe. Liée à target.property ; bornes lues dans
## l'indication d'export de la propriété (@export_range), sinon
## [param fallback] (min, max, pas). Reprise de ValueField (BatEmUp).

signal value_changed(property: StringName, value: float)

const CAPTION_WIDTH: float = 100.0
const SPIN_WIDTH: float = 116.0 # « 1000 px/s² » et les flèches

var target: Object
var property: StringName

var _slider: HSlider = HSlider.new()
var _spin: SpinBox = SpinBox.new()
var _syncing: bool = false


static func create(p_target: Object, p_property: StringName, caption: String, help: String, suffix: String = "", fallback: Vector3 = Vector3(0, 100, 1)) -> LtValueField:
	var field: LtValueField = LtValueField.new()
	field.target = p_target
	field.property = p_property
	field._build(caption, help, suffix, range_of(p_target, p_property, fallback))
	return field


func _build(caption: String, help: String, suffix: String, range_values: Vector3) -> void:
	add_theme_constant_override(&"separation", 8)
	var label: Label = LtTheme.label(caption, LtTheme.DIM)
	label.custom_minimum_size.x = CAPTION_WIDTH
	label.tooltip_text = help
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.mouse_default_cursor_shape = Control.CURSOR_HELP
	label.clip_text = true
	add_child(label)

	for range_control: Range in [_slider, _spin]:
		range_control.min_value = range_values.x
		range_control.max_value = range_values.y
		range_control.step = range_values.z
		range_control.value = float(target.get(property))
		range_control.value_changed.connect(_on_value_changed)
	_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_slider.focus_mode = Control.FOCUS_NONE
	_slider.tooltip_text = help
	add_child(_slider)
	_spin.custom_minimum_size.x = SPIN_WIDTH
	_spin.suffix = suffix
	_spin.allow_greater = false
	_spin.select_all_on_focus = true
	var line: LineEdit = _spin.get_line_edit()
	line.add_theme_font_override(&"font", LtTheme.mono_font())
	line.add_theme_font_size_override(&"font_size", LtTheme.SMALL_SIZE)
	line.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_spin)


## Relit la valeur de target (après un annuler, un choix rapide...).
func refresh() -> void:
	_syncing = true
	var value: float = float(target.get(property))
	_slider.value = value
	_spin.value = value
	_syncing = false


func _on_value_changed(value: float) -> void:
	if _syncing:
		return
	_syncing = true
	_slider.value = value
	_spin.value = value
	_syncing = false
	if target.get(property) is int:
		target.set(property, roundi(value))
	else:
		target.set(property, value)
	value_changed.emit(property, value)


## Bornes (min, max, pas) de l'@export_range de la propriété, sinon
## [param fallback].
static func range_of(p_target: Object, p_property: StringName, fallback: Vector3) -> Vector3:
	for info: Dictionary in p_target.get_property_list():
		if info.name != p_property or info.hint != PROPERTY_HINT_RANGE:
			continue
		var parts: PackedStringArray = String(info.hint_string).split(",")
		if parts.size() >= 2:
			var step: float = float(parts[2]) if parts.size() >= 3 and parts[2].is_valid_float() else 1.0
			return Vector3(float(parts[0]), float(parts[1]), step)
	return fallback

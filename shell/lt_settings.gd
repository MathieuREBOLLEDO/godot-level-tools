@tool
class_name LtSettings
extends ScrollContainer

## Colonne de réglages, la même dans tous les éditeurs (colonne de droite de
## la coque : LtShell.settings()) : des sections titrées (« LEVEL »,
## « SELECTION »), et dans chacune des lignes « légende | contrôle », la
## légende à largeur fixe, la bulle d'aide sur toute la ligne. Les valeurs en
## chasse fixe. Remplace l'Inspecteur de Godot pour les réglages d'un
## document et de l'élément choisi.
## Reprise des colonnes de réglages de DungeonTactics (Dungeons, Rooms) et de
## BatEmUp (panneau de vague).
##
## Exemple :
##   var level: VBoxContainer = settings.section("LEVEL")
##   settings.number(level, "Width (m)", data.size.x, 8, 80, 1, func(v): ...)
##   settings.flags(level, func(flag, on): LtFlags.set_flag(data, flag, on))

const CAPTION_WIDTH: float = 96.0

var _column: VBoxContainer


func _init() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_column = VBoxContainer.new()
	_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_column.add_theme_constant_override(&"separation", 14)
	add_child(_column)


## Nouvelle section, son titre en surtitre ; rend le conteneur de ses lignes.
func section(title: String) -> VBoxContainer:
	var block: VBoxContainer = VBoxContainer.new()
	block.add_theme_constant_override(&"separation", 6)
	block.add_child(LtTheme.label(title, LtTheme.KICKER))
	_column.add_child(block)
	return block


## Vide la colonne (autre élément choisi...).
func clear() -> void:
	for child: Node in _column.get_children():
		_column.remove_child(child)
		child.queue_free()


## Ligne « légende | [param control] » ; [param tooltip] sur toute la ligne.
func row(parent: Container, caption: String, control: Control, tooltip: String = "") -> HBoxContainer:
	var line: HBoxContainer = HBoxContainer.new()
	line.add_theme_constant_override(&"separation", 8)
	line.tooltip_text = tooltip
	var label: Label = LtTheme.label(caption, LtTheme.DIM)
	label.custom_minimum_size.x = CAPTION_WIDTH
	label.clip_text = true
	label.tooltip_text = tooltip
	label.mouse_filter = Control.MOUSE_FILTER_STOP if tooltip != "" else Control.MOUSE_FILTER_IGNORE
	line.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if control.tooltip_text == "":
		control.tooltip_text = tooltip
	line.add_child(control)
	parent.add_child(line)
	return line


func text(parent: Container, caption: String, value: String, on_changed: Callable, tooltip: String = "") -> LineEdit:
	var edit: LineEdit = LineEdit.new()
	edit.text = value
	edit.text_changed.connect(on_changed)
	row(parent, caption, edit, tooltip)
	return edit


## Nombre en chasse fixe ; [param on_changed] : (valeur) -> void.
func number(parent: Container, caption: String, value: float, min_value: float, max_value: float, step: float, on_changed: Callable, tooltip: String = "", suffix: String = "") -> SpinBox:
	var spin: SpinBox = SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = step
	spin.suffix = suffix
	spin.set_value_no_signal(value)
	spin.get_line_edit().add_theme_font_override(&"font", LtTheme.mono_font())
	spin.value_changed.connect(on_changed)
	row(parent, caption, spin, tooltip)
	return spin


## Deux nombres côte à côte (largeur × hauteur) ; [param on_changed] :
## (Vector2i) -> void.
func size_pair(parent: Container, caption: String, value: Vector2i, min_value: Vector2i, max_value: Vector2i, on_changed: Callable, tooltip: String = "") -> Array[SpinBox]:
	var pair: HBoxContainer = HBoxContainer.new()
	pair.add_theme_constant_override(&"separation", 4)
	var spins: Array[SpinBox] = []
	for axis: int in 2:
		var spin: SpinBox = SpinBox.new()
		spin.min_value = min_value[axis]
		spin.max_value = max_value[axis]
		spin.step = 1.0
		spin.set_value_no_signal(value[axis])
		spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spin.get_line_edit().add_theme_font_override(&"font", LtTheme.mono_font())
		pair.add_child(spin)
		spins.append(spin)
		if axis == 0:
			pair.add_child(LtTheme.label("×", LtTheme.DIM))
	for spin: SpinBox in spins:
		spin.value_changed.connect(func(_value: float) -> void: on_changed.call(Vector2i(int(spins[0].value), int(spins[1].value))))
	row(parent, caption, pair, tooltip)
	return spins


## Liste de choix ; [param on_selected] : (index) -> void.
func option(parent: Container, caption: String, items: Array[String], selected: int, on_selected: Callable, tooltip: String = "") -> OptionButton:
	var choice: OptionButton = OptionButton.new()
	choice.focus_mode = Control.FOCUS_NONE
	choice.clip_text = true
	choice.fit_to_longest_item = false
	for item: String in items:
		choice.add_item(item)
	choice.select(selected)
	choice.item_selected.connect(on_selected)
	row(parent, caption, choice, tooltip)
	return choice


func check(parent: Container, caption: String, on: bool, on_toggled: Callable, tooltip: String = "") -> CheckBox:
	var box: CheckBox = CheckBox.new()
	box.focus_mode = Control.FOCUS_NONE
	box.set_pressed_no_signal(on)
	box.toggled.connect(on_toggled)
	row(parent, caption, box, tooltip)
	return box


## Couleur ; [param on_changed] : (Color) -> void.
func color(parent: Container, caption: String, value: Color, on_changed: Callable, tooltip: String = "") -> ColorPickerButton:
	var picker: ColorPickerButton = ColorPickerButton.new()
	picker.color = value
	picker.custom_minimum_size.y = 24.0
	picker.color_changed.connect(on_changed)
	row(parent, caption, picker, tooltip)
	return picker


## Cases DPRC et EXCL (LtFlags) ; rend {flag: CheckBox} pour
## LtFlags.show_checks().
func flags(parent: Container, on_toggled: Callable) -> Dictionary:
	var boxes: HBoxContainer = HBoxContainer.new()
	boxes.add_theme_constant_override(&"separation", 8)
	var checks: Dictionary = LtFlags.build_checks(boxes, on_toggled)
	row(parent, LtText.t("Flags"), boxes)
	return checks


## Texte d'information sur toute la largeur (problème, aide courte).
func note(parent: Container, text_value: String, variation: StringName = LtTheme.DIM) -> Label:
	var label: Label = LtTheme.label(text_value, variation)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

@tool
class_name LtShell
extends Control

## Coque d'un écran d'éditeur, la même partout :
## - en-tête : surtitre, nom du document (renommer = renommer le fichier),
##   « non enregistré », puis les groupes de boutons ([member actions],
##   add_group()), un seul bouton principal (set_primary()) ;
## - corps : trois colonnes redimensionnables, [member left] (bibliothèque),
##   [member center] (canvas, aperçu), [member right] (réglages) ; une colonne
##   vide est cachée ;
## - pied : [member legend] à gauche (pastilles), message à droite, qui revient
##   à l'aide (set_help()) après quelques secondes.
## Un état vide (set_empty()) remplace le centre par un texte qui guide et
## ses boutons. Avec [member history] : Ctrl+Z / Ctrl+Y ; Ctrl+S émet
## [signal save_requested].
## Repris des coques de BatEmUp (Levels, Bullet Patterns), de l'éditeur de
## carte de Gringo et de l'onglet Table de RoguePinball.

signal save_requested
## Le nom de l'en-tête a été changé (le document est à marquer modifié).
signal name_edited(text: String)

## Durée d'un message dans le pied (s).
const MESSAGE_TIME: float = 4.0

var kicker: Label
var name_edit: LineEdit
var dirty_label: Label
## Rangée de l'en-tête où vont les groupes de boutons.
var actions: HBoxContainer
var left: PanelContainer
var center: Control
var right: PanelContainer
var legend: HBoxContainer
var footer_label: Label
var history: LtHistory = null
## Ctrl+S émet save_requested (faux : laisser Ctrl+S à l'éditeur Godot).
var save_shortcut: bool = true

var _spacer: Control
var _confirm: ConfirmationDialog
var _empty: CenterContainer
var _empty_label: Label
var _empty_actions: HBoxContainer
var _outer_split: HSplitContainer
var _inner_split: HSplitContainer
var _help: String = ""
var _message_left: float = 0.0


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = LtTheme.build()
	var background: Panel = Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_theme_stylebox_override(&"panel", LtTheme.box(LtTheme.INK))
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override(&"separation", 0)
	add_child(root)
	root.add_child(_build_header())
	root.add_child(_build_body())
	root.add_child(_build_footer())
	_update_columns()


func _process(delta: float) -> void:
	if _message_left <= 0.0:
		return
	_message_left -= delta
	if _message_left <= 0.0:
		footer_label.text = _help
		footer_label.add_theme_color_override(&"font_color", LtTheme.SAND_DIM)


func _shortcut_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var focus: Control = get_viewport().gui_get_focus_owner()
	if history != null and history.handle_key(event, focus):
		get_viewport().set_input_as_handled()
		return
	var key: InputEventKey = event as InputEventKey
	if save_shortcut and key != null and key.pressed and not key.echo and key.is_command_or_control_pressed() and key.keycode == KEY_S:
		save_requested.emit()
		get_viewport().set_input_as_handled()


# --- En-tête ---

## Surtitre (« WORLD MAP ») et nom du document ; [param editable] faux : pas
## de nom (un écran sans document).
func set_title(kicker_text: String, document_name: String = "", editable: bool = true) -> void:
	kicker.text = kicker_text
	name_edit.text = document_name
	name_edit.visible = editable


func set_dirty(dirty: bool) -> void:
	dirty_label.visible = dirty


## Nouveau groupe de boutons dans l'en-tête, séparé du précédent par un filet ;
## à droite par défaut, [param left] : à gauche, après le nom.
func add_group(left: bool = false) -> HBoxContainer:
	if not left:
		return LtTheme.group(actions)
	var index: int = _spacer.get_index()
	if actions.get_child(index - 1) is HBoxContainer:
		var rule: VSeparator = VSeparator.new()
		rule.add_theme_stylebox_override(&"separator", LtTheme.box(LtTheme.INK_LINE, Color.TRANSPARENT, 0, Vector4.ZERO, Vector4(1, 0, 0, 0)))
		actions.add_child(rule)
		actions.move_child(rule, index)
		index += 1
	var group: HBoxContainer = HBoxContainer.new()
	group.add_theme_constant_override(&"separation", 4)
	group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	actions.add_child(group)
	actions.move_child(group, index)
	return group


## Demande confirmation (« Move level_01.tres to the trash? ») ;
## [param on_confirmed] n'est appelé que sur OK.
func confirm(text: String, ok_text: String, on_confirmed: Callable, title: String = "") -> void:
	if _confirm == null:
		_confirm = ConfirmationDialog.new()
		add_child(_confirm)
	for connection: Dictionary in _confirm.confirmed.get_connections():
		_confirm.confirmed.disconnect(connection.callable)
	_confirm.title = title
	_confirm.dialog_text = text
	_confirm.ok_button_text = ok_text
	_confirm.confirmed.connect(on_confirmed, CONNECT_ONE_SHOT)
	_confirm.popup_centered()


## Le bouton principal de l'écran (Enregistrer...) : plein, dans l'accent.
func set_primary(button: Button) -> void:
	button.theme_type_variation = LtTheme.PRIMARY


# --- Corps ---

## Largeur de départ des colonnes ; 0 : colonne cachée.
func set_column_widths(left_width: float, right_width: float) -> void:
	left.custom_minimum_size.x = left_width
	right.custom_minimum_size.x = right_width
	left.visible = left_width > 0.0
	right.visible = right_width > 0.0
	_update_columns()


## État vide : [param text] guide (« No level yet: click New... ») ; les
## boutons ajoutés à empty_actions() s'affichent dessous. « » : le cache.
func set_empty(text: String) -> void:
	_empty_label.text = text
	_empty.visible = text != ""


func empty_actions() -> HBoxContainer:
	return _empty_actions


# --- Pied ---

## Texte d'aide du pied (gestes de la souris...), affiché quand aucun message
## n'est en cours.
func set_help(text: String) -> void:
	_help = text
	if _message_left <= 0.0:
		footer_label.text = text


## Message dans le pied pendant MESSAGE_TIME s ; [param kind] : « info »,
## « good » ou « bad » (couleur de sens).
func show_message(text: String, kind: String = "info") -> void:
	footer_label.text = text
	var colors: Dictionary[String, Color] = {"good": LtTheme.GOOD, "bad": LtTheme.BAD, "info": LtTheme.SAND}
	footer_label.add_theme_color_override(&"font_color", colors.get(kind, LtTheme.SAND))
	_message_left = MESSAGE_TIME


## Relie un document : ses messages vont au pied, son état modifié à
## l'en-tête, Ctrl+S l'enregistre sous le nom de l'en-tête.
func bind_document(document: LtDocument) -> void:
	document.message.connect(show_message)
	document.dirty_changed.connect(set_dirty)
	document.opened.connect(func(_resource: Resource) -> void: name_edit.text = document.file_name())
	# Nom nettoyé (« Boss Room » -> boss_room) ou renommé depuis la bibliothèque.
	document.saved.connect(func(_path: String) -> void: name_edit.text = document.file_name())
	save_requested.connect(func() -> void: document.save(name_edit.text))
	name_edited.connect(func(_text: String) -> void: document.dirty = true)


# --- Construction ---

func _build_header() -> Control:
	var band: PanelContainer = LtTheme.band(Vector2i.DOWN, Vector4(18, 10, 14, 10))
	actions = HBoxContainer.new()
	actions.add_theme_constant_override(&"separation", 10)
	band.add_child(actions)
	var identity: VBoxContainer = VBoxContainer.new()
	identity.add_theme_constant_override(&"separation", 0)
	actions.add_child(identity)
	kicker = LtTheme.label("", LtTheme.KICKER)
	identity.add_child(kicker)
	name_edit = LineEdit.new()
	name_edit.theme_type_variation = LtTheme.TITLE
	name_edit.custom_minimum_size.x = 260.0
	name_edit.text_changed.connect(func(text: String) -> void: name_edited.emit(text))
	# Entrée dans le nom : enregistrer (sous ce nom).
	name_edit.text_submitted.connect(func(_text: String) -> void: save_requested.emit())
	identity.add_child(name_edit)
	dirty_label = LtTheme.label("●  " + LtText.t("unsaved"), LtTheme.DIM)
	dirty_label.add_theme_color_override(&"font_color", LtTheme.ACCENT)
	dirty_label.size_flags_vertical = Control.SIZE_SHRINK_END
	dirty_label.visible = false
	actions.add_child(dirty_label)
	_spacer = Control.new()
	_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(_spacer)
	return band


func _build_body() -> Control:
	_outer_split = HSplitContainer.new()
	_outer_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outer_split.add_theme_constant_override(&"separation", 0)
	left = LtTheme.band(Vector2i.RIGHT, Vector4(10, 14, 10, 10))
	left.custom_minimum_size.x = 290.0
	_outer_split.add_child(left)
	_inner_split = HSplitContainer.new()
	_inner_split.add_theme_constant_override(&"separation", 0)
	_outer_split.add_child(_inner_split)
	var stack: Control = Control.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inner_split.add_child(stack)
	center = Control.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.add_child(center)
	_empty = CenterContainer.new()
	_empty.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_empty.visible = false
	stack.add_child(_empty)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 12)
	_empty.add_child(column)
	_empty_label = LtTheme.label("", LtTheme.DIM)
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.add_theme_font_size_override(&"font_size", LtTheme.FONT_SIZE)
	column.add_child(_empty_label)
	_empty_actions = HBoxContainer.new()
	_empty_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	_empty_actions.add_theme_constant_override(&"separation", 8)
	column.add_child(_empty_actions)
	right = LtTheme.band(Vector2i.LEFT, Vector4(10, 14, 10, 10))
	right.custom_minimum_size.x = 300.0
	_inner_split.add_child(right)
	return _outer_split


func _build_footer() -> Control:
	var band: PanelContainer = LtTheme.band(Vector2i.UP, Vector4(10, 6, 14, 6))
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 4)
	band.add_child(row)
	legend = HBoxContainer.new()
	legend.add_theme_constant_override(&"separation", 4)
	row.add_child(legend)
	footer_label = LtTheme.label("", LtTheme.DIM)
	footer_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	footer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(footer_label)
	return band


# Une colonne cachée ne laisse pas de poignée de séparation.
func _update_columns() -> void:
	_outer_split.dragger_visibility = SplitContainer.DRAGGER_VISIBLE if left.visible else SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	_inner_split.dragger_visibility = SplitContainer.DRAGGER_VISIBLE if right.visible else SplitContainer.DRAGGER_HIDDEN_COLLAPSED

class_name LtLiveEdit
extends CanvasLayer

## Live edit, le même dans tous les jeux (repris de Gringo) : on modifie le
## niveau joué sans quitter le jeu. Ouvert par le jeu (son debug menu) avec
## open(parent, host) ; le jeu donne un LtLiveHost.
## - Le jeu est figé (pause de l'arbre, sans le menu pause).
## - Palette du jeu dans une fenêtre flottante (LtFloatingPanel) qu'on
##   déplace et redimensionne.
## - Clic gauche : poser (glisser : sur chaque case, si le jeu le veut), clic
##   droit : retirer ; Ctrl+Z, Ctrl+Y : annuler, refaire (un pas par clic ou
##   glissé) ; gestes en plus du jeu (host.handle_input).
## - Chaque changement refait le niveau (host.rebuild(), une fois par image
##   au plus) : le joueur, la caméra... restent où ils sont si le jeu le fait.
## - Enregistrer (si le jeu le permet) ; Reprendre ou Échap : le jeu repart.
## Les clics passent par _unhandled_input : une fenêtre du debug menu ou la
## palette les prend d'abord.

signal closed

const NODE_NAME: String = "LtLiveEdit"
const LAYER: int = 90 # sous le debug menu (100)
const PALETTE_POSITION: Vector2 = Vector2(12.0, 12.0) # fenêtre à l'ouverture
const BAR_MARGIN: float = 8.0 # px entre la barre et les bords de l'écran
const HELP_END: String = "ctrl+z, ctrl+y: undo, redo · Esc: resume"

var host: LtLiveHost
var history: LtHistory

var _status: Label
var _bar: PanelContainer
var _buttons_row: HBoxContainer
var _overlay: Control
var _undo_button: Button
var _redo_button: Button
var _painting: int = 0 # 0 : rien, 1 : pose, 2 : retire
var _hover: Variant = null
var _last_cell: Variant = null # dernière case peinte du glissé
var _before: Variant = null # instantané pris à l'appui
var _stroke_changed: bool = false
var _dirty: bool = false
var _was_paused: bool = false


## Ouvre le live edit dans [param parent] (une seule fois à la fois : rend
## celui qui est ouvert).
static func open(parent: Node, new_host: LtLiveHost) -> LtLiveEdit:
	var existing: LtLiveEdit = parent.get_node_or_null(NODE_NAME) as LtLiveEdit
	if existing != null:
		return existing
	var live_edit: LtLiveEdit = LtLiveEdit.new()
	live_edit.name = NODE_NAME
	live_edit.host = new_host
	parent.add_child(live_edit)
	return live_edit


## Le live edit ouvert dans [param parent], ou null.
static func find(parent: Node) -> LtLiveEdit:
	return parent.get_node_or_null(NODE_NAME) as LtLiveEdit if parent != null else null


func _ready() -> void:
	layer = LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	history = LtHistory.new(host.snapshot, host.restore)
	history.restored.connect(func() -> void: _dirty = true)
	history.stack_changed.connect(_update_undo_buttons)
	_build_ui()
	_was_paused = get_tree().paused
	get_tree().paused = true
	host.opened(self)


func _process(_delta: float) -> void:
	if _dirty:
		_dirty = false
		host.rebuild()
	_overlay.queue_redraw()


func _input(event: InputEvent) -> void:
	# Avant le menu pause du jeu, qui prendrait Échap pour reprendre.
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _unhandled_input(event: InputEvent) -> void:
	if history.handle_key(event, get_viewport().gui_get_focus_owner()):
		get_viewport().set_input_as_handled()
		return
	var mouse_button: InputEventMouseButton = event as InputEventMouseButton
	if mouse_button != null and mouse_button.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		if mouse_button.pressed:
			_painting = 1 if mouse_button.button_index == MOUSE_BUTTON_LEFT else 2
			_before = host.snapshot()
			_stroke_changed = false
			_last_cell = null
			_paint(host.cell_at(mouse_button.position))
		else:
			_painting = 0
		get_viewport().set_input_as_handled()
		return
	if host.handle_input(event):
		get_viewport().set_input_as_handled()
		return
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null:
		_hover = host.cell_at(motion.position)
		if _painting != 0 and host.drag_paint:
			_paint(_hover)


## Ferme le live edit : le jeu repart.
func close() -> void:
	if _dirty:
		_dirty = false
		host.rebuild()
	get_tree().paused = _was_paused
	host.closed()
	closed.emit()
	queue_free()


## Message de la barre du bas (remplace l'aide).
func show_message(text: String) -> void:
	_status.text = text
	_fit_bar()


## Refaire le niveau à la prochaine image (un réglage de la fenêtre du jeu a
## changé, sans passer par paint()).
func request_rebuild() -> void:
	_dirty = true


func _paint(cell: Variant) -> void:
	if cell == null or _same(cell, _last_cell):
		return
	_last_cell = cell
	if host.paint(cell, _painting == 2):
		if not _stroke_changed:
			_stroke_changed = true
			history.checkpoint(_before)
		_dirty = true


static func _same(a: Variant, b: Variant) -> bool:
	return typeof(a) == typeof(b) and a == b


func _save() -> void:
	var error: Error = host.save()
	if error == OK:
		_status.text = LtText.t("Saved: %s") % host.save_path()
	else:
		_status.text = LtText.t("Save failed (%s).") % error_string(error)
		push_error("Live edit: saving %s failed: %s" % [host.save_path(), error_string(error)])


func _update_undo_buttons() -> void:
	if _undo_button != null:
		_undo_button.disabled = not history.can_undo()
		_redo_button.disabled = not history.can_redo()


func _build_ui() -> void:
	# Repères du jeu (case survolée...), sous la palette et la barre.
	_overlay = Control.new()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.draw.connect(func() -> void: host.draw_overlay(_overlay, _hover))
	add_child(_overlay)

	var window: LtFloatingPanel = LtFloatingPanel.new(LtText.t(host.title), host.palette())
	window.position = PALETTE_POSITION
	window.size = host.palette_size
	add_child(window)

	var bar: PanelContainer = PanelContainer.new()
	_bar = bar
	bar.theme = LtTheme.build()
	bar.add_theme_stylebox_override(&"panel", LtTheme.box(LtTheme.INK_PANEL, LtTheme.INK_LINE, LtTheme.RADIUS, Vector4.ONE, Vector4(10, 4, 6, 4)))
	bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(bar)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	bar.add_child(row)
	_status = LtTheme.label(LtText.t("Live edit") + " · " + LtText.t(host.help) + " · " + LtText.t(HELP_END), LtTheme.DIM)
	_status.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_status)
	_buttons_row = HBoxContainer.new()
	_buttons_row.add_theme_constant_override(&"separation", 8)
	row.add_child(_buttons_row)
	var undo: HBoxContainer = LtTheme.group(_buttons_row)
	_undo_button = LtTheme.button(undo, "", LtText.t("Undo (Ctrl+Z)"), func() -> void: history.undo(), LtIcons.UNDO)
	_redo_button = LtTheme.button(undo, "", LtText.t("Redo (Ctrl+Y)"), func() -> void: history.redo(), LtIcons.REDO)
	_update_undo_buttons()
	var buttons: HBoxContainer = LtTheme.group(_buttons_row)
	var resume: Button = LtTheme.button(buttons, LtText.t("Resume"), LtText.t("Close live edit and resume the game (Esc)"), close)
	if host.can_save():
		var save: Button = LtTheme.button(buttons, LtText.t("Save"), LtText.t("Save the level to its file"), _save, LtIcons.SAVE)
		save.theme_type_variation = LtTheme.PRIMARY
	else:
		resume.theme_type_variation = LtTheme.PRIMARY
		resume.tooltip_text += "\n" + LtText.t("Changes last until the end of the run.")
	get_viewport().size_changed.connect(_fit_bar)
	_fit_bar.call_deferred()


# Barre plus large que l'écran (jeu en portrait) : l'aide passe à la ligne.
func _fit_bar() -> void:
	var screen: float = get_viewport().get_visible_rect().size.x
	_status.autowrap_mode = TextServer.AUTOWRAP_OFF
	_status.custom_minimum_size.x = 0.0
	var wide: float = _bar.get_combined_minimum_size().x
	if wide > screen - 2.0 * BAR_MARGIN:
		_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_status.custom_minimum_size.x = maxf(80.0, screen - 2.0 * BAR_MARGIN - (wide - _status.get_combined_minimum_size().x))
	_bar.reset_size()
	_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)

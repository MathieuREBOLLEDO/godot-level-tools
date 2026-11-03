@tool
extends Control

## Éditeur d'exemple : toutes les briques assemblées, sur des documents de
## test (tests/sample_document.gd) rangés dans user://level_tools_demo/.
## Sert de modèle (docs/guide.md) et de vérification à l'œil.
## Lancer la scène tests/demo_editor.tscn ; avec « -- --screenshot <fichier> »,
## une capture est écrite puis la partie se ferme.

const SampleDocument = preload("res://addons/level_tools/tests/sample_document.gd")
const DIR: String = "user://level_tools_demo/"
const CONFIG: String = "user://level_tools_demo/editor.cfg"
const BIOMES: Array[String] = ["All biomes", "Desert", "Cave"]

var _shell: LtShell
var _document: LtDocument
var _library: LtLibrary
var _fields: VBoxContainer


func _ready() -> void:
	_make_samples()
	_shell = LtShell.new()
	add_child(_shell)
	_document = LtDocument.new(DIR)
	_shell.bind_document(_document)
	_shell.set_title("SAMPLE EDITOR", "")
	_shell.set_help("click: select · double click: open · wheel: zoom · middle drag: pan")

	var files: HBoxContainer = _shell.add_group()
	LtTheme.button(files, "New", "New document", func() -> void: _document.create(SampleDocument.new(), "new_document"))
	LtTheme.button(files, "Duplicate", "Copy the open document", _document.duplicate_current)
	var edit: HBoxContainer = _shell.add_group()
	LtTheme.button(edit, "Undo", "Ctrl+Z", func() -> void: _shell.history.undo())
	LtTheme.button(edit, "Redo", "Ctrl+Y", func() -> void: _shell.history.redo())
	var play: HBoxContainer = _shell.add_group()
	LtTheme.button(play, "Try ▶", "Save and play", func() -> void: pass)
	var save: Button = LtTheme.button(play, "Save", "Ctrl+S", func() -> void: _document.save(_shell.name_edit.text))
	_shell.set_primary(save)

	_library = LtLibrary.new()
	var kicker: Label = LtTheme.label("LIBRARY", LtTheme.KICKER)
	kicker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_library.header.add_child(kicker)
	_library.describe = _describe
	_library.count_text = func(total: int, shown: int) -> String: return "%d documents · %d shown" % [total, shown]
	_library.add_filter("Biome", BIOMES, func(path: String, _data: Variant, choice: int) -> bool:
		return choice == 0 or _biome_of(path) == BIOMES[choice])
	_library.add_sort(["Name", "Newest"] as Array[String], func(a: String, b: String, choice: int) -> bool:
		return LtLibrary.by_newest(a, b) if choice == 1 else LtLibrary.by_name(a, b))
	_library.picked.connect(func(path: String) -> void: _document.open(path))
	_shell.left.add_child(_library)

	_fields = VBoxContainer.new()
	_fields.add_theme_constant_override(&"separation", 8)
	_shell.right.add_child(_fields)

	for entry: Array in [["Open on both sides", LtTheme.GOOD], ["Dead end", LtTheme.BAD], ["Toward nothing", LtTheme.INFO]]:
		var chip: Button = Button.new()
		chip.text = entry[0]
		chip.theme_type_variation = LtTheme.LEGEND
		chip.focus_mode = Control.FOCUS_NONE
		chip.add_theme_color_override(&"font_color", entry[1])
		_shell.legend.add_child(chip)

	var canvas: ColorRect = ColorRect.new()
	canvas.color = Color(LtTheme.INK, 0.0)
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.draw.connect(func() -> void: _draw_grid(canvas))
	_shell.center.add_child(canvas)

	_document.opened.connect(_on_opened)
	_document.files_changed.connect(func() -> void: _library.set_paths(_document.paths()))
	_library.set_paths(_document.paths())
	if not _document.open_last(CONFIG):
		_shell.set_empty("No document yet.\nClick New to start one.")
	_screenshot_if_asked.call_deferred()


func _on_opened(resource: Resource) -> void:
	_library.select(_document.path)
	_document.remember(CONFIG)
	_shell.set_empty("" if resource != null else "No document yet.\nClick New to start one.")
	for child: Node in _fields.get_children():
		child.queue_free()
	if resource == null:
		return
	_shell.history = LtHistory.for_resource(resource)
	_shell.history.restored.connect(func() -> void:
		_document.dirty = true
		for field: Node in _fields.get_children():
			if field is LtValueField:
				(field as LtValueField).refresh())
	_fields.add_child(LtTheme.label("SETTINGS", LtTheme.KICKER))
	for entry: Array in [[&"speed", "Speed", "Scroll speed", " m/s"], [&"count", "Count", "How many", ""]]:
		var field: LtValueField = LtValueField.create(resource, entry[0], entry[1], entry[2], entry[3])
		field.value_changed.connect(func(_property: StringName, _value: float) -> void:
			_document.dirty = true
			_shell.history.changed(true))
		_fields.add_child(field)


func _describe(path: String, data: Variant) -> Dictionary:
	var document: Resource = data as Resource
	var image: Image = Image.create(30, 17, false, Image.FORMAT_RGBA8)
	image.fill(LtTheme.INK_RAISED)
	var count: int = document.get("count") if document != null else 0
	image.fill_rect(Rect2i(0, 12, 30, 5), Color("c98a4b"))
	image.fill_rect(Rect2i(4 * count % 26, 8, 4, 4), LtTheme.ACCENT)
	var info: Dictionary = {
		"detail": "30×17 · %s" % _biome_of(path),
		"thumbnail": ImageTexture.create_from_image(image),
		"drag": {"path": path},
	}
	if path.get_file().begins_with("desert"):
		info["badge"] = "on this map"
		info["dimmed"] = true
	elif path.get_file().begins_with("cave"):
		info["badge"] = "on world_2"
		info["badge_color"] = LtTheme.INFO
	return info


func _biome_of(path: String) -> String:
	return "Cave" if path.get_file().begins_with("cave") else "Desert"


func _draw_grid(canvas: Control) -> void:
	var step: float = 32.0
	var line: Color = Color(LtTheme.INK_LINE, 0.35)
	for x: int in int(canvas.size.x / step) + 1:
		canvas.draw_line(Vector2(x * step, 0), Vector2(x * step, canvas.size.y), line)
	for y: int in int(canvas.size.y / step) + 1:
		canvas.draw_line(Vector2(0, y * step), Vector2(canvas.size.x, y * step), line)


func _make_samples() -> void:
	if not LtFiles.list(DIR).is_empty():
		return
	for entry: Array in [["desert_intro", 2], ["desert_jumps", 4], ["cave_dark", 6], ["sandbox", 1]]:
		var document: Resource = SampleDocument.new()
		document.count = entry[1]
		LtFiles.save(document, DIR + entry[0] + ".tres")


func _screenshot_if_asked() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var index: int = args.find("--screenshot")
	if index < 0 or index + 1 >= args.size():
		return
	for i: int in 20:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(args[index + 1])
	get_tree().quit()

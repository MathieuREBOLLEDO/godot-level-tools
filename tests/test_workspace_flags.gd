extends TestCase

## Cadre ensemble ↔ pièce (LtWorkspace), marques (LtFlags), usages et import
## de la bibliothèque, colonne de réglages (LtSettings), Annuler / Refaire de
## la coque.

const CONFIG: String = "user://level_tools_tests_workspace.cfg"
const IMPORT_DIR: String = "user://level_tools_tests_import/"


func after_each() -> void:
	if FileAccess.file_exists(CONFIG):
		DirAccess.remove_absolute(CONFIG)
	if DirAccess.dir_exists_absolute(IMPORT_DIR):
		for file: String in DirAccess.get_files_at(IMPORT_DIR):
			DirAccess.remove_absolute(IMPORT_DIR + file)
		DirAccess.remove_absolute(IMPORT_DIR)


# --- LtWorkspace ---

func test_workspace_titles_and_remembers_the_piece() -> void:
	var workspace: LtWorkspace = LtWorkspace.new()
	workspace.config_path = CONFIG
	workspace.setup(Control.new(), "Map", Control.new(), "Level", "Double click a level")
	add_test_node(workspace)
	var shown: Array[String] = []
	workspace.whole_shown.connect(func() -> void: shown.append("whole"))
	workspace.piece_shown.connect(func() -> void: shown.append("piece"))
	workspace.restore_tab()
	assert_false(workspace.is_piece_shown(), "starts on the whole")
	workspace.show_piece("cave_02", "res://levels/cave_02.tres")
	assert_true(workspace.is_piece_shown())
	assert_eq(workspace.get_tab_title(LtWorkspace.PIECE), "Level · cave_02")
	workspace.show_whole()
	workspace.show_piece()
	assert_eq(workspace.get_tab_title(LtWorkspace.PIECE), "Level · cave_02", "no name: the title stays")
	assert_eq(shown, ["piece", "whole", "piece"] as Array[String])
	assert_eq(workspace.last_piece(), "res://levels/cave_02.tres")

	var next: LtWorkspace = LtWorkspace.new()
	next.config_path = CONFIG
	next.setup(Control.new(), "Map", Control.new(), "Level")
	add_test_node(next)
	assert_eq(LtFiles.recall(CONFIG, "workspace", "tab", -1), LtWorkspace.PIECE, "building the next one does not overwrite the tab")
	next.restore_tab()
	assert_true(next.is_piece_shown(), "the last tab comes back")


# --- LtFlags ---

func test_flags_on_any_resource() -> void:
	var plain: Resource = Resource.new()
	var old: Resource = Resource.new()
	LtFlags.set_flag(old, LtFlags.DEPRECATED, true)
	var excluded: Resource = Resource.new()
	LtFlags.set_flag(excluded, LtFlags.EXCLUDED, true)
	assert_true(LtFlags.is_deprecated(old))
	assert_true(LtFlags.is_excluded(excluded))
	assert_eq(LtFlags.text(old), "DPRC")
	assert_eq(LtFlags.text(plain), "")
	LtFlags.set_flag(old, LtFlags.DEPRECATED, false)
	assert_false(old.has_meta("lt_deprecated"), "unset: no metadata left")
	LtFlags.set_flag(old, LtFlags.DEPRECATED, true)
	# Choix : 0 cacher les marqués, 1 tout, 2 seulement DPRC, 3 seulement exclus.
	var rows: Array = [[true, false, false], [true, true, true], [false, true, false], [false, false, true]]
	for choice: int in rows.size():
		assert_eq(LtFlags.passes(plain, choice), rows[choice][0], "plain, choice %d" % choice)
		assert_eq(LtFlags.passes(old, choice), rows[choice][1], "DPRC, choice %d" % choice)
		assert_eq(LtFlags.passes(excluded, choice), rows[choice][2], "EXCL, choice %d" % choice)
	assert_true(LtFlags.passes(null, 0), "unreadable file shown by default")
	assert_false(LtFlags.passes(null, 2))


func test_flags_saved_with_the_file() -> void:
	var path: String = "user://level_tools_tests_flags.tres"
	var resource: Resource = Resource.new()
	LtFlags.set_flag(resource, LtFlags.EXCLUDED, true)
	assert_eq(ResourceSaver.save(resource, path), OK)
	assert_true(LtFlags.is_excluded(LtFiles.load_fresh(path)), "metadata written in the .tres")
	DirAccess.remove_absolute(path)


func test_flag_checks_and_library_filter() -> void:
	var resource: Resource = Resource.new()
	var row: HBoxContainer = HBoxContainer.new()
	add_test_node(row)
	var checks: Dictionary = LtFlags.build_checks(row, func(flag: String, on: bool) -> void: LtFlags.set_flag(resource, flag, on))
	(checks[LtFlags.DEPRECATED] as CheckBox).button_pressed = true
	assert_true(LtFlags.is_deprecated(resource), "the check sets the flag")
	LtFlags.set_flag(resource, LtFlags.DEPRECATED, false)
	LtFlags.show_checks(checks, resource)
	assert_false((checks[LtFlags.DEPRECATED] as CheckBox).button_pressed)

	var library: LtLibrary = LtLibrary.new()
	add_test_node(library)
	var flagged: Resource = Resource.new()
	LtFlags.set_flag(flagged, LtFlags.DEPRECATED, true)
	# « c » : un élément de catalogue (texte, pas une ressource) : sans marque.
	var items: Dictionary = {"a": Resource.new(), "b": flagged, "c": "element:post"}
	library.load_item = func(path: String) -> Variant: return items[path]
	var filter: OptionButton = LtFlags.add_filter(library)
	library.set_paths(PackedStringArray(["a", "b", "c"]))
	assert_eq(library.shown_paths(), ["a", "c"] as Array[String], "flagged hidden by default")
	filter.select(1)
	assert_eq(library.shown_paths(), ["a", "b", "c"] as Array[String])
	filter.select(2)
	assert_eq(library.shown_paths(), ["b"] as Array[String], "only DPRC")


# --- LtLibrary : usages, import ---

func test_library_usage_badges_and_filter() -> void:
	var library: LtLibrary = LtLibrary.new()
	add_test_node(library)
	library.load_item = func(_path: String) -> Variant: return null
	var here: PackedStringArray = ["a"]
	var elsewhere: Dictionary = {"b": PackedStringArray(["world_2", "world_3"])}
	var filter: OptionButton = library.set_usage(func(path: String) -> bool: return here.has(path),
		func(path: String) -> PackedStringArray: return elsewhere.get(path, PackedStringArray()),
		{"badge_here": "on this map", "badge_elsewhere": "on %s"})
	library.set_paths(PackedStringArray(["a", "b", "c"]))
	var cards: Dictionary = {}
	for card: LtLibraryCard in _cards(library):
		cards[card.key] = card
	assert_eq(cards["a"].badge, "on this map")
	assert_true(cards["a"].dimmed, "already here: dimmed")
	assert_eq(cards["b"].badge, "on world_2 +1")
	assert_eq(cards["c"].badge, "", "used nowhere: no badge")
	for row: Array in [[1, ["b", "c"]], [2, ["a"]], [3, ["b"]], [4, ["c"]]]:
		filter.select(row[0])
		assert_eq(library.shown_paths(), Array(row[1], TYPE_STRING, "", null), "usage choice %d" % row[0])
	assert_eq(library.used_elsewhere("b"), PackedStringArray(["world_2", "world_3"]))


func test_library_import_and_layout_toggle() -> void:
	var library: LtLibrary = LtLibrary.new()
	add_test_node(library)
	var got: Array = []
	library.imported.connect(func(written: PackedStringArray, rejected: PackedStringArray) -> void: got.append([written, rejected]))
	var button: Button = library.enable_import(IMPORT_DIR, func(resource: Resource) -> bool: return resource is Gradient)
	assert_eq(button.text, "Import")
	var source: String = "user://level_tools_tests_source.tres"
	ResourceSaver.save(Gradient.new(), source)
	var dialog: FileDialog = null
	for child: Node in library.get_children():
		if child is FileDialog:
			dialog = child
	dialog.files_selected.emit(PackedStringArray([source]))
	assert_eq(got.size(), 1)
	assert_eq((got[0][0] as PackedStringArray).size(), 1, "copied into the folder")
	assert_true(FileAccess.file_exists(IMPORT_DIR + "level_tools_tests_source.tres"))
	DirAccess.remove_absolute(source)

	var toggle: Button = library.add_layout_toggle()
	toggle.pressed.emit()
	assert_eq(library.layout, LtLibraryCard.Layout.GRID)
	toggle.pressed.emit()
	assert_eq(library.layout, LtLibraryCard.Layout.LIST)


# --- LtSettings, Annuler / Refaire de la coque ---

func test_settings_column() -> void:
	var shell: LtShell = LtShell.new()
	add_test_node(shell)
	var settings: LtSettings = shell.settings()
	assert_true(shell.right.visible, "the column shows")
	assert_eq(shell.settings(), settings, "one column")
	var section: VBoxContainer = settings.section("MODULE")
	var sizes: Array[Vector2i] = []
	var spins: Array[SpinBox] = settings.size_pair(section, "Size", Vector2i(4, 6), Vector2i.ONE, Vector2i(20, 20), func(value: Vector2i) -> void: sizes.append(value))
	spins[1].value = 8
	assert_eq(sizes, [Vector2i(4, 8)] as Array[Vector2i])
	var picked: Array[int] = []
	var option: OptionButton = settings.option(section, "Role", ["Combat", "Boss"] as Array[String], 1, func(index: int) -> void: picked.append(index))
	assert_eq(option.selected, 1)
	var flagged: Resource = Resource.new()
	var checks: Dictionary = settings.flags(section, func(flag: String, on: bool) -> void: LtFlags.set_flag(flagged, flag, on))
	(checks[LtFlags.EXCLUDED] as CheckBox).button_pressed = true
	assert_true(LtFlags.is_excluded(flagged))
	settings.clear()
	await frames(1)
	assert_eq(settings.get_child(0).get_child_count(), 0, "cleared")


func test_shell_undo_buttons_follow_the_stack() -> void:
	var shell: LtShell = LtShell.new()
	add_test_node(shell)
	var state: Array[int] = [0]
	var history: LtHistory = LtHistory.new(func() -> int: return state[0], func(value: int) -> void: state[0] = value)
	var group: HBoxContainer = shell.add_undo_buttons(history)
	var undo_button: Button = group.get_child(0)
	var redo_button: Button = group.get_child(1)
	assert_true(undo_button.disabled and redo_button.disabled, "nothing to undo yet")
	state[0] = 1
	history.changed()
	assert_false(undo_button.disabled)
	undo_button.pressed.emit()
	assert_eq(state[0], 0, "the button undoes")
	assert_false(redo_button.disabled)


func _cards(library: LtLibrary) -> Array[LtLibraryCard]:
	var result: Array[LtLibraryCard] = []
	var stack: Array[Node] = [library]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is LtLibraryCard:
			result.append(node)
		stack.append_array(node.get_children())
	return result

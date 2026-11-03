extends TestCase

## Champ lié (LtValueField), coque (LtShell) et Essayer (LtPlaytest).

const SampleDocument = preload("res://addons/level_tools/tests/sample_document.gd")
const DIR: String = "user://level_tools_tests_ui/"


func after_each() -> void:
	LtPlaytest.clear()
	Engine.remove_meta(LtPlaytest.META)
	if DirAccess.dir_exists_absolute(DIR):
		for file: String in DirAccess.get_files_at(DIR):
			DirAccess.remove_absolute(DIR + file)
		DirAccess.remove_absolute(DIR)


# --- LtValueField ---

func test_value_field_reads_the_export_range() -> void:
	var document: Resource = SampleDocument.new()
	assert_eq(LtValueField.range_of(document, &"speed", Vector3.ZERO), Vector3(0, 10, 0.5))
	assert_eq(LtValueField.range_of(document, &"count", Vector3.ZERO), Vector3(1, 9, 1))
	assert_eq(LtValueField.range_of(document, &"title", Vector3(0, 5, 1)), Vector3(0, 5, 1), "no range: fallback")


func test_value_field_writes_and_refreshes() -> void:
	var document: Resource = SampleDocument.new()
	var field: LtValueField = add_test_node(LtValueField.create(document, &"count", "Count", "How many"))
	var changes: Array[float] = []
	field.value_changed.connect(func(_property: StringName, value: float) -> void: changes.append(value))
	var spin: SpinBox = field.get_child(2) as SpinBox
	spin.value = 6.0
	assert_eq(document.count, 6, "int property gets an int")
	assert_eq(changes, [6.0] as Array[float])
	document.count = 2
	field.refresh()
	assert_eq(spin.value, 2.0)
	assert_eq(changes.size(), 1, "refresh does not emit")


# --- LtShell ---

func test_shell_builds_header_body_footer() -> void:
	var shell: LtShell = add_test_node(LtShell.new())
	shell.set_title("WORLD MAP", "my_map")
	var files: HBoxContainer = shell.add_group()
	var save: Button = LtTheme.button(files, "Save", "", func() -> void: pass)
	shell.set_primary(save)
	await frames(2)
	assert_eq(shell.kicker.text, "WORLD MAP")
	assert_eq(shell.name_edit.text, "my_map")
	assert_eq(save.theme_type_variation, LtTheme.PRIMARY)
	shell.set_column_widths(0.0, 250.0)
	assert_false(shell.left.visible, "no library column")
	assert_true(shell.right.visible)
	shell.set_empty("No level yet.")
	assert_true(shell._empty.visible)
	shell.set_empty("")
	assert_false(shell._empty.visible)


func test_shell_left_groups_and_enter_saves() -> void:
	var shell: LtShell = add_test_node(LtShell.new())
	var right: HBoxContainer = shell.add_group()
	var first: HBoxContainer = shell.add_group(true)
	var second: HBoxContainer = shell.add_group(true)
	var spacer: int = shell._spacer.get_index()
	assert_lt(first.get_index(), spacer, "left of the spacer")
	assert_lt(second.get_index(), spacer)
	assert_gt(second.get_index(), first.get_index(), "in the order added")
	assert_true(shell.actions.get_child(second.get_index() - 1) is VSeparator, "rule between left groups")
	assert_gt(right.get_index(), spacer)
	var saves: Array[int] = [0]
	shell.save_requested.connect(func() -> void: saves[0] += 1)
	shell.name_edit.text_submitted.emit("x")
	assert_eq(saves[0], 1, "Enter in the name saves")


func test_shell_confirm() -> void:
	var shell: LtShell = add_test_node(LtShell.new())
	var done: Array[int] = [0]
	shell.confirm("Move a.tres to the trash?", "Move to trash", func() -> void: done[0] += 1)
	shell._confirm.confirmed.emit()
	shell.confirm("Again?", "OK", func() -> void: done[0] += 10)
	shell._confirm.confirmed.emit()
	assert_eq(done[0], 11, "each confirm calls only its own action")
	shell._confirm.hide()


func test_shell_footer_message_then_help() -> void:
	var shell: LtShell = add_test_node(LtShell.new())
	shell.set_help("click: select")
	assert_eq(shell.footer_label.text, "click: select")
	shell.show_message("Saved.", "good")
	assert_eq(shell.footer_label.text, "Saved.")
	shell.set_help("wheel: zoom")
	assert_eq(shell.footer_label.text, "Saved.", "a message stays until it times out")
	shell._message_left = 0.01
	await frames(3)
	assert_eq(shell.footer_label.text, "wheel: zoom")


func test_shell_bound_to_a_document() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var shell: LtShell = add_test_node(LtShell.new())
	var document: LtDocument = LtDocument.new(DIR)
	shell.bind_document(document)
	document.create(SampleDocument.new(), "first")
	assert_eq(shell.name_edit.text, "first")
	shell.name_edit.text = "renamed"
	shell.name_edit.text_changed.emit("renamed")
	assert_true(document.dirty)
	assert_true(shell.dirty_label.visible)
	shell.save_requested.emit()
	assert_eq(document.path, DIR + "renamed.tres")
	assert_false(shell.dirty_label.visible)


func test_shell_undo_shortcut() -> void:
	var document: Resource = SampleDocument.new()
	var shell: LtShell = add_test_node(LtShell.new())
	shell.history = LtHistory.for_resource(document)
	document.count = 8
	shell.history.changed()
	await frames(1)
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_Z
	key.ctrl_pressed = true
	key.pressed = true
	shell._shortcut_input(key)
	assert_eq(document.count, 3)


# --- LtPlaytest ---

func test_playtest_resource_request_is_read_once() -> void:
	var document: Resource = SampleDocument.new()
	document.title = "unsaved level"
	assert_eq(LtPlaytest.request(document), OK)
	assert_null(LtPlaytest.consume("pattern", false), "another kind is not consumed")
	var played: Resource = LtPlaytest.consume("level", false) as Resource
	if assert_not_null(played, "level to play"):
		assert_eq(played.get("title"), "unsaved level")
	assert_null(LtPlaytest.consume("level", false), "read once")
	assert_true(LtPlaytest.is_playtest())


func test_playtest_path_request() -> void:
	assert_eq(LtPlaytest.request("res://levels/classic.tres", "layout"), OK)
	assert_eq(LtPlaytest.consume("layout", false), "res://levels/classic.tres")

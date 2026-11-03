extends TestCase

## Annuler / refaire par instantanés (LtHistory).

const SampleDocument = preload("res://addons/level_tools/tests/sample_document.gd")


func test_undo_and_redo_restore_the_same_resource() -> void:
	var document: Resource = SampleDocument.new()
	var history: LtHistory = LtHistory.for_resource(document)
	document.speed = 4.0
	document.items.append(7)
	history.changed()
	assert_true(history.undo())
	assert_eq(document.speed, 1.0)
	assert_eq(document.items.size(), 0)
	assert_true(history.redo())
	assert_eq(document.speed, 4.0)
	assert_eq(document.items, [7] as Array[int])
	assert_false(history.redo(), "nothing left to redo")


func test_structural_changes_are_separate_steps() -> void:
	var document: Resource = SampleDocument.new()
	var history: LtHistory = LtHistory.for_resource(document)
	document.count = 4
	history.changed()
	document.count = 5
	history.changed()
	history.undo()
	assert_eq(document.count, 4)
	history.undo()
	assert_eq(document.count, 3)


func test_grouped_changes_make_one_step() -> void:
	var document: Resource = SampleDocument.new()
	var history: LtHistory = LtHistory.for_resource(document)
	for value: float in [2.0, 3.0, 4.0]:
		document.speed = value
		history.changed(true)
	history.undo()
	assert_eq(document.speed, 1.0, "a slider drag undoes in one step")


func test_new_change_clears_redo_and_limit_applies() -> void:
	var document: Resource = SampleDocument.new()
	var history: LtHistory = LtHistory.for_resource(document)
	history.limit = 3
	for value: int in range(4, 9):
		document.count = value
		history.changed()
	var steps: int = 0
	while history.undo():
		steps += 1
	assert_eq(steps, 3, "only the last %d steps are kept" % history.limit)
	history.redo()
	document.count = 1
	history.changed()
	assert_false(history.can_redo())


func test_custom_snapshots() -> void:
	var state: Dictionary = {"cells": [1]}
	# Le dictionnaire est remis en place (une lambda ne peut pas réassigner
	# une variable locale).
	var history: LtHistory = LtHistory.new(func() -> Dictionary: return state.duplicate(true),
		func(snapshot: Dictionary) -> void:
			state.clear()
			state.merge(snapshot))
	state.cells.append(2)
	history.changed()
	history.undo()
	assert_eq(state.cells, [1])


func test_keys() -> void:
	var document: Resource = SampleDocument.new()
	var history: LtHistory = LtHistory.for_resource(document)
	document.count = 6
	history.changed()
	assert_true(history.handle_key(_key(KEY_Z)), "Ctrl+Z")
	assert_eq(document.count, 3)
	assert_true(history.handle_key(_key(KEY_Z, true)), "Ctrl+Shift+Z")
	assert_eq(document.count, 6)
	history.undo()
	assert_true(history.handle_key(_key(KEY_Y)), "Ctrl+Y")
	assert_eq(document.count, 6)
	var line: LineEdit = add_test_node(LineEdit.new())
	assert_false(history.handle_key(_key(KEY_Z), line), "left to a text field")
	assert_eq(document.count, 6)


func _key(keycode: Key, shift: bool = false) -> InputEventKey:
	var key: InputEventKey = InputEventKey.new()
	key.keycode = keycode
	key.pressed = true
	key.ctrl_pressed = true
	key.shift_pressed = shift
	return key

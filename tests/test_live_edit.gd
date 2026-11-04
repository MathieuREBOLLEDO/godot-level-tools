extends TestCase

## LtLiveEdit (live edit commun) avec un hôte d'essai : pause, poser au clic
## et au glissé, retirer, un pas d'annulation par coup, reconstruction une
## fois par image, fermeture. LtHistory.checkpoint(état).


## Hôte d'essai : une rangée de cases (Dictionary case -> valeur).
class FakeHost extends LtLiveHost:
	var cells: Dictionary = {}
	var rebuilds: int = 0
	var closed_count: int = 0
	var saving: bool = true

	func palette() -> Control:
		return Label.new()

	func cell_at(screen_position: Vector2) -> Variant:
		var cell: int = int(screen_position.x / 10.0)
		return cell if cell >= 0 and cell < 10 else null

	func paint(cell: Variant, erase: bool) -> bool:
		var before: Variant = cells.get(cell)
		if erase:
			cells.erase(cell)
		else:
			cells[cell] = 1
		return cells.get(cell) != before

	func rebuild() -> void:
		rebuilds += 1

	func can_save() -> bool:
		return saving

	func snapshot() -> Variant:
		return cells.duplicate()

	func restore(state: Variant) -> void:
		cells = (state as Dictionary).duplicate()

	func closed() -> void:
		closed_count += 1


var _parent: Node


func before_each() -> void:
	_parent = Node.new()
	add_test_node(_parent)


func after_each() -> void:
	get_tree().paused = false


func _press(live: LtLiveEdit, x: float, button: MouseButton, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = Vector2(x, 5.0)
	live._unhandled_input(event)


func _move(live: LtLiveEdit, x: float) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = Vector2(x, 5.0)
	live._unhandled_input(event)


func _open(host: FakeHost) -> LtLiveEdit:
	return LtLiveEdit.open(_parent, host)


func test_open_pauses_and_close_resumes() -> void:
	var host: FakeHost = FakeHost.new()
	var live: LtLiveEdit = _open(host)
	assert_true(get_tree().paused, "game paused")
	assert_eq(LtLiveEdit.find(_parent), live)
	assert_eq(LtLiveEdit.open(_parent, FakeHost.new()), live, "one at a time")
	live.close()
	assert_false(get_tree().paused, "game resumed")
	assert_eq(host.closed_count, 1)


func test_drag_paints_each_cell_once_and_makes_one_undo_step() -> void:
	var host: FakeHost = FakeHost.new()
	var live: LtLiveEdit = _open(host)
	_press(live, 15.0, MOUSE_BUTTON_LEFT, true)
	_move(live, 18.0) # même case
	_move(live, 25.0)
	_move(live, 35.0)
	_press(live, 35.0, MOUSE_BUTTON_LEFT, false)
	assert_eq(host.cells.keys().size(), 3, "cells 1, 2, 3")
	live.history.undo()
	assert_true(host.cells.is_empty(), "one undo removes the whole stroke")
	live.history.redo()
	assert_eq(host.cells.keys().size(), 3, "redo")


func test_click_without_change_makes_no_undo_step() -> void:
	var host: FakeHost = FakeHost.new()
	var live: LtLiveEdit = _open(host)
	_press(live, 15.0, MOUSE_BUTTON_RIGHT, true)
	_press(live, 15.0, MOUSE_BUTTON_RIGHT, false)
	assert_false(live.history.can_undo(), "nothing erased, nothing to undo")
	_press(live, 200.0, MOUSE_BUTTON_LEFT, true) # hors du niveau
	_press(live, 200.0, MOUSE_BUTTON_LEFT, false)
	assert_false(live.history.can_undo())


func test_no_drag_paint_places_once() -> void:
	var host: FakeHost = FakeHost.new()
	host.drag_paint = false
	var live: LtLiveEdit = _open(host)
	_press(live, 15.0, MOUSE_BUTTON_LEFT, true)
	_move(live, 25.0)
	_press(live, 25.0, MOUSE_BUTTON_LEFT, false)
	assert_eq(host.cells.keys(), [1], "only the clicked cell")


func test_rebuild_once_per_frame() -> void:
	var host: FakeHost = FakeHost.new()
	var live: LtLiveEdit = _open(host)
	_press(live, 15.0, MOUSE_BUTTON_LEFT, true)
	_move(live, 25.0)
	_press(live, 25.0, MOUSE_BUTTON_LEFT, false)
	assert_eq(host.rebuilds, 0, "not during the stroke")
	live._process(0.0)
	live._process(0.0)
	assert_eq(host.rebuilds, 1, "one rebuild for two cells")
	live.request_rebuild()
	live._process(0.0)
	assert_eq(host.rebuilds, 2, "request_rebuild")


func test_without_save_resume_is_primary() -> void:
	var host: FakeHost = FakeHost.new()
	host.saving = false
	var live: LtLiveEdit = _open(host)
	var save_found: bool = false
	for button: Node in live.find_children("*", "Button", true, false):
		if (button as Button).text == LtText.t("Save"):
			save_found = true
	assert_false(save_found, "no Save button")


func test_history_checkpoint_with_a_state_taken_earlier() -> void:
	var value: Array = [1]
	var history: LtHistory = LtHistory.new(func() -> Variant: return value.duplicate(), func(state: Variant) -> void: value.assign(state))
	var before: Variant = [0]
	history.checkpoint(before)
	assert_true(history.undo())
	assert_eq(value, [0], "back to the state given to checkpoint()")

extends TestCase

## Vue d'un canvas (LtView) et palette (LtPalette, LtPaletteSlot).

const STORE: String = "user://level_tools_tests_palette.cfg"


func after_each() -> void:
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(STORE)


# --- LtView ---

func test_view_fits_then_follows_the_user() -> void:
	var view: LtView = LtView.new()
	view.margin = 0.0
	view.fit(Rect2(0, 0, 10, 5), Vector2(200, 200))
	assert_eq(view.zoom, 20.0, "10 cells in 200 px")
	assert_eq(view.to_screen(Vector2(5, 2.5)), Vector2(100, 100), "centered")
	view.zoom_at(Vector2(100, 100), 2.0)
	assert_false(view.auto_fit, "zoomed: no more auto fit")
	assert_eq(view.to_content(Vector2(100, 100)), Vector2(5, 2.5), "the point under the cursor stays")
	view.fit(Rect2(0, 0, 10, 5), Vector2(400, 400))
	assert_eq(view.zoom, 40.0, "resize keeps the user's zoom")
	view.frame()
	assert_true(view.auto_fit)
	assert_eq(view.zoom, 40.0, "F: 10 cells in 400 px")
	assert_eq(view.cell_at(view.to_screen(Vector2(3.5, 1.5))), Vector2i(3, 1))


func test_view_gestures() -> void:
	var view: LtView = LtView.new()
	view.fit(Rect2(0, 0, 10, 10), Vector2(200, 200))
	var turns: Array[int] = []
	view.turn_requested.connect(func(step: int) -> void: turns.append(step))
	var wheel: InputEventMouseButton = InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	wheel.shift_pressed = true
	assert_true(view.handle_input(wheel))
	assert_eq(turns, [-1] as Array[int], "shift + wheel turns")
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_R
	key.pressed = true
	assert_true(view.handle_key(key))
	assert_eq(turns, [-1, 1] as Array[int], "R turns")
	var middle: InputEventMouseButton = InputEventMouseButton.new()
	middle.button_index = MOUSE_BUTTON_MIDDLE
	middle.pressed = true
	assert_true(view.handle_input(middle))
	var before: Vector2 = view.pan
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(7, -3)
	assert_true(view.handle_input(motion))
	assert_eq(view.pan, before + Vector2(7, -3), "middle drag moves")
	middle.pressed = false
	view.handle_input(middle)
	var left: InputEventMouseButton = InputEventMouseButton.new()
	left.button_index = MOUSE_BUTTON_LEFT
	left.pressed = true
	assert_false(view.handle_input(left), "left click paints")
	var space: InputEventKey = InputEventKey.new()
	space.keycode = KEY_SPACE
	space.pressed = true
	view.handle_key(space)
	assert_true(view.handle_input(left), "space + left click moves")


# --- LtPalette ---

func test_palette_pages_keys_and_favorites() -> void:
	var palette: LtPalette = add_test_node(LtPalette.new())
	palette.store_path = STORE
	palette.setup(_items(), ["Ground", "Things"] as Array[String])
	assert_eq(palette.page(), 1)
	var picked: Array[String] = []
	palette.item_selected.connect(func(id: String) -> void: picked.append(id))
	assert_true(palette.handle_key(_digit(KEY_2)))
	assert_eq(palette.selected, "wall", "key 2: second of the page")
	assert_false(palette.handle_key(_digit(KEY_9)), "no ninth element")
	palette.select("chest")
	assert_eq(palette.page(), 2, "picking shows its page")
	palette.select("")
	assert_eq(picked, ["wall", "chest", ""] as Array[String], "eraser is \"\"")
	palette.toggle_favorite("chest")
	palette.move_item(1, "wall", "floor")
	assert_eq(palette.page_items(1), ["wall", "floor"])
	var again: LtPalette = add_test_node(LtPalette.new())
	again.store_path = STORE
	again.setup(_items(), ["Ground", "Things"] as Array[String])
	assert_eq(again.page_items(1), ["wall", "floor"], "order kept")
	assert_eq(again.page_items(LtPalette.FAVORITES_PAGE), ["chest"], "favorites kept")


func _items() -> Array[Dictionary]:
	return [
		{"id": "floor", "name": "Floor", "page": 1, "color": Color.GRAY, "letter": "."},
		{"id": "wall", "name": "Wall", "page": 1, "color": Color.DIM_GRAY, "letter": "#"},
		{"id": "chest", "name": "Chest", "page": 2, "color": Color.GOLD, "letter": "C"},
	]


func _digit(code: Key) -> InputEventKey:
	var key: InputEventKey = InputEventKey.new()
	key.keycode = code
	key.pressed = true
	return key

extends TestCase

## Vue d'un canvas (LtView) et palette (LtPalette, LtPaletteSlot).

const STORE: String = "user://level_tools_tests_palette.cfg"
const LAYOUT: String = "user://level_tools_tests_palette_layout.tres"


func after_each() -> void:
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(STORE)
	if FileAccess.file_exists(LAYOUT):
		DirAccess.remove_absolute(LAYOUT)
	LtPaletteLayout.forget(LAYOUT)


# --- LtCellSelection ---

func test_cell_selection_drag_and_keys() -> void:
	var selection: LtCellSelection = LtCellSelection.new()
	var cell_at: Callable = func(at: Vector2) -> Vector2i: return Vector2i((at / 10.0).floor())
	var actions: Array = []
	selection.action_requested.connect(func(action: String, area: Rect2i, offset: Vector2i) -> void: actions.append([action, area, offset]))
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(35, 15)
	assert_false(selection.handle_input(press, cell_at), "without Shift: painting, not selecting")
	press.shift_pressed = true
	assert_true(selection.handle_input(press, cell_at))
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = Vector2(12, 41)
	assert_true(selection.handle_input(motion, cell_at))
	var release: InputEventMouseButton = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	selection.handle_input(release, cell_at)
	assert_eq(selection.rect, Rect2i(1, 1, 3, 4), "corners in any order")
	assert_eq(LtCellSelection.cells_of(Rect2i(0, 0, 2, 2)).size(), 4)
	var key: InputEventKey = InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_D
	key.ctrl_pressed = true
	assert_true(selection.handle_key(key))
	assert_eq(actions[0], ["duplicate", Rect2i(1, 1, 3, 4), Vector2i(3, 0)])
	assert_eq(selection.rect.position, Vector2i(4, 1), "the selection follows the copy")
	key.ctrl_pressed = false
	key.keycode = KEY_DELETE
	selection.handle_key(key)
	assert_eq(actions[1][0], "delete")
	key.keycode = KEY_ESCAPE
	selection.handle_key(key)
	assert_false(selection.has(), "Esc: no selection")
	assert_false(selection.handle_key(key), "no selection: keys pass through")


# --- LtPathEditor ---

func test_path_editor_gestures() -> void:
	var editor: LtPathEditor = LtPathEditor.new()
	var added: Array[Vector2] = []
	var removed: Array[bool] = []
	editor.point_added.connect(func(at: Vector2) -> void: added.append(at))
	editor.last_point_removed.connect(func() -> void: removed.append(true))
	var to_content: Callable = func(at: Vector2) -> Vector2: return at * 0.5
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(40, 20)
	assert_false(editor.handle_input(click, to_content), "inactive: clicks go elsewhere")
	editor.active = true
	assert_true(editor.handle_input(click, to_content))
	assert_eq(added, [Vector2(20, 10)] as Array[Vector2], "left click adds a point")
	click.button_index = MOUSE_BUTTON_RIGHT
	assert_true(editor.handle_input(click, to_content))
	assert_eq(removed.size(), 1, "right click removes the last point")


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


# --- LtPaletteLayout, LtPaletteEditor ---

func test_palette_layout_pages_and_images() -> void:
	var layout: LtPaletteLayout = LtPaletteLayout.open(LAYOUT)
	assert_eq(layout, LtPaletteLayout.open(LAYOUT), "one copy per path")
	assert_eq(layout.page_names(["Ground", "Things"] as Array[String]), ["Ground", "Things"] as Array[String], "game pages by default")
	assert_eq(layout.page_of("chest", 2, 2), 2, "game page by default")
	layout.item_pages["chest"] = 5
	assert_eq(layout.page_of("chest", 2, 2), 2, "a page that no longer exists: the last one")
	layout.textures["wall"] = PlaceholderTexture2D.new()
	assert_not_null(layout.texture_of("wall"))
	assert_null(layout.texture_of("floor"), "no image: the game's drawing")
	var holder: Node = add_test_node(Node.new())
	var cover: Control = LtPaletteLayout.cover(holder, Rect2(0, 0, 30, 10), layout.texture_of("wall"), 10.0)
	assert_eq(cover.get_child_count(), 3, "one image per cell")


func test_palette_editor_add_rename_remove_pages() -> void:
	var editor: LtPaletteEditor = add_test_node(LtPaletteEditor.new())
	var items: Array[Dictionary] = _items()
	items.append({"id": "set_a", "name": "Set A", "page": 0}) # une image seulement, sans page
	editor.setup(LAYOUT, items, ["Ground", "Things"] as Array[String])
	editor.add_page("Mechanics")
	assert_eq(editor.page_names(), ["Ground", "Things", "Mechanics"] as Array[String])
	editor.set_item_page("wall", 3)
	editor.rename_page(1, "Blocks")
	assert_eq(editor.page_names()[0], "Blocks")
	editor.remove_page(2)
	assert_eq(editor.page_names(), ["Blocks", "Mechanics"] as Array[String])
	assert_eq(editor.layout.page_of("chest", 2, 2), 1, "elements of a removed page go to page 1")
	assert_eq(editor.layout.page_of("wall", 1, 2), 2, "later pages move back one rank")
	assert_false(editor.layout.item_pages.has("set_a"), "a row without page gets no page")
	editor.set_item_texture("set_a", PlaceholderTexture2D.new())
	assert_not_null(editor.layout.texture_of("set_a"))
	assert_true(FileAccess.file_exists(LAYOUT), "saved at each change")
	LtPaletteLayout.forget(LAYOUT)
	var again: LtPaletteLayout = LtPaletteLayout.open(LAYOUT)
	assert_eq(again.pages, ["Blocks", "Mechanics"] as Array[String], "read back from the file")
	editor.remove_page(1)
	editor.remove_page(1)
	assert_eq(editor.page_names().size(), 1, "one page is always left")
	editor.reset_layout()
	assert_eq(editor.page_names(), ["Ground", "Things"] as Array[String], "reset: the game's pages")


func test_palette_editor_rename_items() -> void:
	var editor: LtPaletteEditor = add_test_node(LtPaletteEditor.new())
	editor.setup(LAYOUT, _items(), ["Ground", "Things"] as Array[String])
	editor.reset_layout()
	assert_eq(editor.item_name("wall"), "Wall", "the game's name by default")
	editor.rename_item("wall", "  Stone  ")
	assert_eq(editor.item_name("wall"), "Stone")
	assert_eq(editor.layout.name_of("wall", "Wall"), "Stone", "kept in the layout")
	assert_eq(editor.layout.name_of("floor", "Floor"), "Floor", "others keep the game's name")
	LtPaletteLayout.forget(LAYOUT)
	assert_eq(LtPaletteLayout.open(LAYOUT).name_of("wall", "Wall"), "Stone", "read back from the file")
	editor.setup(LAYOUT, _items(), ["Ground", "Things"] as Array[String])
	editor.rename_item("wall", "")
	assert_false(editor.layout.names.has("wall"), "empty: back to the game's name")
	editor.rename_item("chest", "Chest")
	assert_false(editor.layout.names.has("chest"), "the game's name is not stored")
	editor.rename_item("chest", "Box")
	editor.reset_layout()
	assert_eq(editor.item_name("chest"), "Chest", "reset: the game's names")


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

@tool
class_name LtPalette
extends VBoxContainer

## Palette d'un canvas sur grille (reprise de la palette de l'éditeur de
## niveaux de Gringo) : la gomme en haut, puis des pages changées avec ‹ ›
## (la première : les favoris), une grille de cases (LtPaletteSlot), le nom
## de l'élément choisi en bas.
## - Touches 1 à 9 puis 0 : les cases de la page affichée (handle_key()).
## - Clic droit sur une case : favori ; glisser une case sur une autre de la
##   même page : ordre. Ordre et favoris retenus dans [member store_path].
## Le jeu donne ses éléments à setup() : {id, name, page (1, 2...), tooltip,
## et draw (Callable(case, rect)) ou color + letter}.

## Élément choisi ; "" : la gomme.
signal item_selected(id: String)

const FAVORITES_PAGE: int = 0

## Colonnes et rangées de la grille d'une page.
var columns: int = 3
var rows: int = 5
## Fichier de user:// où l'ordre et les favoris sont retenus ("" : rien).
var store_path: String = ""
## Élément choisi ("" : la gomme).
var selected: String = ""

var _items: Dictionary[String, Dictionary] = {}
var _page_names: Array[String] = []
var _orders: Dictionary[int, Array] = {}
var _favorites: Array = []
var _page: int = 1
var _page_label: Label
var _name_label: Label
var _eraser: LtPaletteSlot
var _grid: GridContainer
var _slots: Array[LtPaletteSlot] = []
var _group: ButtonGroup = ButtonGroup.new()
var _eraser_name: String = ""


func _init() -> void:
	add_theme_constant_override(&"separation", 6)


## Éléments et pages ([param pages] : noms des pages 1, 2... ; la page 0 est
## celle des favoris) ; [param eraser_name] : nom de la gomme ("" : pas de
## gomme).
func setup(items: Array[Dictionary], pages: Array[String], eraser_name: String = "Eraser") -> void:
	_items.clear()
	for entry: Dictionary in items:
		_items[entry["id"]] = entry
	_page_names = [LtText.t("Favorites")]
	_page_names.append_array(pages)
	_eraser_name = eraser_name
	var config: ConfigFile = _config()
	_favorites = []
	for id: Variant in config.get_value("favorites", "items", []):
		if id is String and _items.has(id) and not _favorites.has(id):
			_favorites.append(id)
	for page: int in range(1, _page_names.size()):
		var order: Array = []
		for id: Variant in config.get_value("order", "page_%d" % page, []):
			if id is String and _items.has(id) and _items[id].get("page", 1) == page and not order.has(id):
				order.append(id)
		for entry: Dictionary in items:
			if entry.get("page", 1) == page and not order.has(entry["id"]):
				order.append(entry["id"])
		_orders[page] = order
	if selected != "" and not _items.has(selected):
		selected = ""
	_build()
	show_page(_items[selected].get("page", 1) if _items.has(selected) else 1)


## Choisit un élément ("" : la gomme) et montre sa page ; [param notify] :
## émet item_selected.
func select(id: String, notify: bool = true) -> void:
	if id != "" and not _items.has(id):
		return
	selected = id
	for slot: LtPaletteSlot in _slots:
		slot.set_pressed_no_signal(not slot.item.is_empty() and slot.item["id"] == id)
	if _eraser != null:
		_eraser.set_pressed_no_signal(id == "")
	if id != "" and not (_page == FAVORITES_PAGE and _favorites.has(id)):
		show_page(_items[id].get("page", 1))
	_update_name()
	if notify:
		item_selected.emit(id)


## Affiche une page (les flèches font le tour).
func show_page(index: int) -> void:
	_page = wrapi(index, 0, _page_names.size())
	_page_label.text = _page_names[_page]
	_page_label.tooltip_text = LtText.t("Right click an element of another page to add it here.") if _page == FAVORITES_PAGE else ""
	if _page == FAVORITES_PAGE and _favorites.is_empty():
		_page_label.text = LtText.t("Favorites (right click to add)")
	_fill_grid()


func page() -> int:
	return _page


## Éléments de la page [param index], dans leur ordre.
func page_items(index: int) -> Array:
	return _favorites.duplicate() if index == FAVORITES_PAGE else (_orders.get(index, []) as Array).duplicate()


## Touches 1 à 9 puis 0 : les cases de la page affichée ; vrai si la touche
## a servi.
func handle_key(event: InputEvent) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo or key.is_command_or_control_pressed() or key.alt_pressed:
		return false
	if key.keycode < KEY_0 or key.keycode > KEY_9:
		return false
	return select_index(9 if key.keycode == KEY_0 else key.keycode - KEY_1)


## Choisit la case numéro [param index] (0 : la première) de la page
## affichée ; vrai si elle existe.
func select_index(index: int) -> bool:
	var ids: Array = page_items(_page)
	if index < 0 or index >= ids.size():
		return false
	select(ids[index])
	return true


## Ordre d'une page : [param moved] passe juste avant [param before].
func move_item(page_index: int, moved: String, before: String) -> void:
	var ids: Array = page_items(page_index)
	if moved == before or not ids.has(moved) or not ids.has(before):
		return
	ids.erase(moved)
	ids.insert(ids.find(before), moved)
	if page_index == FAVORITES_PAGE:
		_favorites = ids
	else:
		_orders[page_index] = ids
	_store()
	_fill_grid()


## Favori ou plus (clic droit sur une case).
func toggle_favorite(id: String) -> void:
	if _favorites.has(id):
		_favorites.erase(id)
	else:
		_favorites.append(id)
	_store()
	show_page(_page)


func is_favorite(id: String) -> bool:
	return _favorites.has(id)


# --- Construction ---

func _build() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_slots.clear()
	_eraser = null
	if _eraser_name != "":
		_eraser = LtPaletteSlot.new()
		_eraser.eraser = true
		_eraser.palette = self
		_eraser.button_group = _group
		_eraser.tooltip_text = LtText.t(_eraser_name) + "\n" + LtText.t("Right click on the grid: pick an element")
		_eraser.pressed.connect(select.bind(""))
		add_child(_eraser)
	var header: HBoxContainer = HBoxContainer.new()
	add_child(header)
	_arrow(header, LtIcons.PREVIOUS, LtText.t("Previous page"), func() -> void: show_page(_page - 1))
	_page_label = LtTheme.label("")
	_page_label.add_theme_font_override(&"font", LtTheme.ui_font(true))
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_label.mouse_filter = Control.MOUSE_FILTER_PASS
	header.add_child(_page_label)
	_arrow(header, LtIcons.NEXT, LtText.t("Next page"), func() -> void: show_page(_page + 1))
	_grid = GridContainer.new()
	_grid.columns = columns
	_grid.add_theme_constant_override(&"h_separation", 4)
	_grid.add_theme_constant_override(&"v_separation", 4)
	add_child(_grid)
	_name_label = LtTheme.label("", LtTheme.DIM)
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(_name_label)


func _fill_grid() -> void:
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_slots.clear()
	var ids: Array = page_items(_page)
	for index: int in ids.size():
		var entry: Dictionary = _items[ids[index]]
		var slot: LtPaletteSlot = LtPaletteSlot.new()
		slot.item = entry
		slot.page = _page
		slot.palette = self
		slot.button_group = _group
		slot.favorite = _favorites.has(entry["id"])
		slot.key_hint = str((index + 1) % 10) if index < 10 else ""
		slot.tooltip_text = LtText.t(entry.get("name", entry["id"]))
		if entry.get("tooltip", "") != "":
			slot.tooltip_text += "\n" + entry["tooltip"]
		slot.tooltip_text += "\n" + LtText.t("Right click: favorite · drag: reorder")
		slot.set_pressed_no_signal(entry["id"] == selected)
		slot.pressed.connect(select.bind(entry["id"]))
		_grid.add_child(slot)
		_slots.append(slot)
	while _grid.get_child_count() < maxi(columns * rows, ids.size()):
		var empty: LtPaletteSlot = LtPaletteSlot.new()
		empty.page = _page
		empty.palette = self
		_grid.add_child(empty)


func _update_name() -> void:
	_name_label.text = LtText.t(_eraser_name) if selected == "" else LtText.t(_items[selected].get("name", selected))


func _arrow(parent: Container, icon: Texture2D, tooltip: String, on_pressed: Callable) -> void:
	var button: Button = Button.new()
	button.icon = icon
	button.tooltip_text = tooltip
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(on_pressed)
	parent.add_child(button)


func _store() -> void:
	if store_path == "":
		return
	var config: ConfigFile = _config()
	for page_index: int in _orders:
		config.set_value("order", "page_%d" % page_index, _orders[page_index])
	config.set_value("favorites", "items", _favorites)
	config.save(store_path)


func _config() -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	if store_path != "":
		config.load(store_path)
	return config

@tool
class_name LtPaletteEditor
extends VBoxContainer

## Fenêtre « Edit palette » : l'auteur range les éléments d'une palette dans
## ses pages (créer, renommer, retirer une page ; page de chaque élément) et
## remplace le dessin d'un élément par une image du projet. Chaque changement
## est enregistré tout de suite dans la disposition (LtPaletteLayout, res://)
## et annoncé par [signal layout_changed] : la palette se refait.
## Ouverture : LtPaletteEditor.popup(parent, ...) la pose dans une fenêtre
## flottante (LtFloatingPanel) au-dessus de [param parent].
## Le jeu donne ses éléments : {id, name, page (page par défaut, 1, 2...),
## draw (facultatif, Callable(control, rect) : son dessin), image (facultatif,
## faux : pas d'image possible), image_hint (facultatif : bulle du bouton,
## la taille attendue par exemple), draws_image (facultatif, vrai : draw
## montre déjà l'image choisie)}. Page 0 : une ligne sans page (une image
## seulement, les sets du sol d'un jeu par exemple).

signal layout_changed
## Bouton Close : la fenêtre flottante s'en va.
signal closed

## Taille de départ de la fenêtre et côté d'un aperçu (px).
const START_SIZE: Vector2 = Vector2(380.0, 460.0)
const PREVIEW_SIZE: float = 26.0
const IMAGE_BUTTON_WIDTH: float = 80.0
const IMAGE_FILTERS: PackedStringArray = ["*.png, *.svg, *.webp, *.jpg ; Images"]

var layout: LtPaletteLayout
var layout_path: String = ""

var _items: Array[Dictionary] = []
var _default_pages: Array[String] = []
var _pages_box: VBoxContainer
var _items_box: VBoxContainer
var _status: Label
var _file_dialog: FileDialog
var _image_for: String = "" # élément dont on choisit l'image


## Fenêtre flottante posée sur [param parent], au centre ; rend l'éditeur
## (son signal layout_changed). Une seule à la fois par parent.
static func popup(parent: Control, path: String, items: Array[Dictionary], default_pages: Array[String]) -> LtPaletteEditor:
	for child: Node in parent.get_children():
		if child is LtFloatingPanel and child.has_meta(&"lt_palette_editor"):
			child.queue_free()
	var editor: LtPaletteEditor = LtPaletteEditor.new()
	editor.setup(path, items, default_pages)
	var window: LtFloatingPanel = LtFloatingPanel.new(LtText.t("EDIT PALETTE"), editor)
	window.set_meta(&"lt_palette_editor", true)
	window.top_level = true
	window.size = START_SIZE
	window.z_index = 100
	parent.add_child(window)
	var screen: Vector2 = parent.get_viewport_rect().size
	window.position = ((screen - START_SIZE) * 0.5).max(Vector2.ZERO)
	editor.closed.connect(window.queue_free)
	return editor


func setup(path: String, items: Array[Dictionary], default_pages: Array[String]) -> void:
	layout_path = path
	layout = LtPaletteLayout.open(path)
	_items = items
	_default_pages = default_pages
	if is_inside_tree():
		_refresh()


func _ready() -> void:
	add_theme_constant_override(&"separation", 6)
	custom_minimum_size = Vector2(300.0, 320.0)
	_build()
	_refresh()


## Pages affichées (celles de l'auteur, sinon celles du jeu).
func page_names() -> Array[String]:
	return layout.page_names(_default_pages)


## Nouvelle page à la fin.
func add_page(page_name: String = "") -> void:
	_own_pages()
	layout.pages.append(page_name if page_name != "" else LtText.t("Page %d") % (layout.pages.size() + 1))
	_commit()


func rename_page(page: int, page_name: String) -> void:
	page_name = page_name.strip_edges()
	if page_name == "" or page < 1 or page > page_names().size() or page_names()[page - 1] == page_name:
		return
	_own_pages()
	layout.pages[page - 1] = page_name
	_commit()


## Retire la page [param page] : ses éléments vont à la première page, les
## pages d'après reculent d'un rang. Il reste toujours une page.
func remove_page(page: int) -> void:
	var count: int = page_names().size()
	if count <= 1 or page < 1 or page > count:
		return
	_own_pages()
	# Chaque élément garde sa page en clair avant que les numéros bougent.
	for entry: Dictionary in _items:
		if not _has_page(entry):
			continue
		var id: String = entry["id"]
		var current: int = _page_of(entry)
		if current == page:
			layout.item_pages[id] = 1
		elif current > page:
			layout.item_pages[id] = current - 1
		else:
			layout.item_pages[id] = current
	layout.pages.remove_at(page - 1)
	_commit()


func set_item_page(id: String, page: int) -> void:
	_own_pages()
	layout.item_pages[id] = page
	_commit()


## Image qui remplace le dessin de [param id] (null : le dessin du jeu).
func set_item_texture(id: String, texture: Texture2D) -> void:
	if texture == null:
		layout.textures.erase(id)
	else:
		layout.textures[id] = texture
	_commit()


func reset_layout() -> void:
	layout.reset()
	_commit()


# --- Interne ---

func _has_page(entry: Dictionary) -> bool:
	return entry.get("page", 1) != 0


func _page_of(entry: Dictionary) -> int:
	return layout.page_of(entry["id"], entry.get("page", 1), page_names().size())


# Avant de toucher aux pages : la disposition garde ses propres noms (ceux
# du jeu au départ).
func _own_pages() -> void:
	if layout.pages.is_empty():
		layout.pages = _default_pages.duplicate()


func _commit() -> void:
	var saved: bool = layout_path == "" or layout.save(layout_path)
	_refresh()
	if _status != null:
		_status.text = LtText.t("Saved in %s") % layout_path.get_file() if saved else LtText.t("Could not save %s") % layout_path
		_status.theme_type_variation = LtTheme.DIM if saved else &""
		_status.modulate = Color.WHITE if saved else LtTheme.BAD
	layout_changed.emit()


func _build() -> void:
	add_child(LtTheme.label(LtText.t("PAGES"), LtTheme.KICKER))
	_pages_box = VBoxContainer.new()
	_pages_box.add_theme_constant_override(&"separation", 2)
	add_child(_pages_box)
	var add_row: HBoxContainer = HBoxContainer.new()
	add_child(add_row)
	LtTheme.button(add_row, LtText.t("Add page"), LtText.t("New page at the end; then pick it for some elements below."), add_page.bind(""), LtIcons.NEW)

	add_child(LtTheme.label(LtText.t("ELEMENTS"), LtTheme.KICKER))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	_items_box = VBoxContainer.new()
	_items_box.add_theme_constant_override(&"separation", 2)
	_items_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_items_box)

	_status = LtTheme.label("", LtTheme.DIM)
	_status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(_status)
	var footer: HBoxContainer = HBoxContainer.new()
	footer.add_theme_constant_override(&"separation", 4)
	add_child(footer)
	LtTheme.button(footer, LtText.t("Reset"), LtText.t("Back to the game's pages, places and drawings (removes all changes made here)."), reset_layout)
	LtTheme.spacer(footer)
	var close: Button = LtTheme.button(footer, LtText.t("Close"), LtText.t("Changes are already saved."), closed.emit)
	close.theme_type_variation = LtTheme.PRIMARY

	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = IMAGE_FILTERS
	_file_dialog.title = LtText.t("Image of the element")
	_file_dialog.file_selected.connect(_on_image_chosen)
	add_child(_file_dialog)


func _refresh() -> void:
	if _pages_box == null or layout == null:
		return
	for box: VBoxContainer in [_pages_box, _items_box]:
		for child: Node in box.get_children():
			box.remove_child(child)
			child.queue_free()
	var names: Array[String] = page_names()
	var counts: Array[int] = []
	counts.resize(names.size() + 1)
	for entry: Dictionary in _items:
		if _has_page(entry):
			counts[_page_of(entry)] += 1
	for page: int in range(1, names.size() + 1):
		_pages_box.add_child(_page_row(page, names[page - 1], counts[page], names.size() > 1))
	for entry: Dictionary in _items:
		_items_box.add_child(_item_row(entry, names))


func _page_row(page: int, page_name: String, count: int, removable: bool) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 4)
	var number: Label = LtTheme.label(str(page), LtTheme.MONO)
	number.custom_minimum_size.x = 16.0
	row.add_child(number)
	var edit: LineEdit = LineEdit.new()
	edit.text = LtText.t(page_name)
	edit.tooltip_text = LtText.t("Page name (Enter to rename)")
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text_submitted.connect(func(text: String) -> void: rename_page(page, text))
	edit.focus_exited.connect(func() -> void: rename_page(page, edit.text))
	row.add_child(edit)
	var amount: Label = LtTheme.label(str(count), LtTheme.MONO)
	amount.tooltip_text = LtText.t("Elements on this page")
	row.add_child(amount)
	var remove: Button = LtTheme.button(row, "", LtText.t("Remove this page: its elements go to page 1."), remove_page.bind(page), LtIcons.DELETE)
	remove.flat = true
	remove.disabled = not removable
	return row


func _item_row(entry: Dictionary, names: Array[String]) -> HBoxContainer:
	var id: String = entry["id"]
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 4)
	var preview: Control = Control.new()
	preview.custom_minimum_size = Vector2.ONE * PREVIEW_SIZE
	preview.draw.connect(_draw_preview.bind(preview, entry))
	row.add_child(preview)
	var title: Label = LtTheme.label(LtText.t(entry.get("name", id)))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(title)
	var pages: OptionButton = OptionButton.new()
	pages.focus_mode = Control.FOCUS_NONE
	pages.tooltip_text = LtText.t("Page of this element")
	for index: int in names.size():
		pages.add_item(LtText.t(names[index]), index + 1)
	pages.select(_page_of(entry) - 1)
	pages.item_selected.connect(func(index: int) -> void: set_item_page(id, index + 1))
	row.add_child(pages)
	# Ligne sans page : le nom prend la place du menu.
	pages.visible = _has_page(entry)
	var has_image: bool = layout.texture_of(id) != null
	var image: Button = LtTheme.button(row, LtText.t("Image") if not has_image else "", LtText.t("Replace its drawing with an image of the project (editor and game)."), _choose_image.bind(id), LtIcons.OPEN)
	image.flat = has_image
	image.custom_minimum_size.x = IMAGE_BUTTON_WIDTH # colonnes alignées, avec ou sans image
	# Élément sans image possible (le jeu le dit) : la place reste, vide.
	if not entry.get("image", true):
		image.disabled = true
		image.modulate.a = 0.0
	if entry.get("image_hint", "") != "":
		image.tooltip_text += "\n" + LtText.t(entry["image_hint"])
	if has_image:
		image.tooltip_text = layout.texture_of(id).resource_path
	var clear: Button = LtTheme.button(row, "", LtText.t("Back to the game's drawing"), set_item_texture.bind(id, null), LtIcons.DELETE)
	clear.flat = true
	clear.disabled = not has_image
	clear.modulate.a = 1.0 if has_image else 0.0
	return row


# Aperçu : l'image choisie, sinon le dessin du jeu.
func _draw_preview(preview: Control, entry: Dictionary) -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, preview.size)
	preview.draw_rect(rect, LtTheme.INK)
	var texture: Texture2D = layout.texture_of(entry["id"])
	if texture != null and not entry.get("draws_image", false):
		preview.draw_texture_rect(texture, rect.grow(-2.0), false)
	elif entry.get("draw", Callable()) is Callable and (entry.get("draw", Callable()) as Callable).is_valid():
		(entry["draw"] as Callable).call(preview, rect.grow(-2.0))
	preview.draw_rect(rect, LtTheme.INK_LINE, false, 1.0)


func _choose_image(id: String) -> void:
	_image_for = id
	_file_dialog.popup_centered_ratio(0.6)


func _on_image_chosen(path: String) -> void:
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		_status.text = LtText.t("Not an image: %s") % path.get_file()
		_status.modulate = LtTheme.BAD
		return
	set_item_texture(_image_for, texture)

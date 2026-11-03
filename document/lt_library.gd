@tool
class_name LtLibrary
extends VBoxContainer

## Bibliothèque des documents d'un éditeur : recherche, filtres et tris
## fournis par le jeu, compte, cartes (LtLibraryCard) en liste ou en grille,
## état vide qui guide. Le jeu décrit chaque élément par [member describe] ;
## rien n'est propre à un type de document.
## Reprise de la bibliothèque de l'éditeur de carte de Gringo (filtres
## d'usage, Flags, tri, pastilles) et du navigateur de niveaux (grille).
##
## Exemple :
##   library.describe = func(path, data): return {"detail": "...", "thumbnail": ...}
##   library.add_filter("Biome", ["All biomes", ...], func(path, data, index): ...)
##   library.add_sort(["Name", "Newest"], func(a, b, index): ...)
##   library.set_paths(LtFiles.list("res://levels/"))

signal picked(path: String)
signal activated(path: String)
## Nouveau nom tapé sur une carte (clic droit > Rename, si [member renamable]) ;
## LtDocument.rename_file() le fait.
signal rename_requested(path: String, new_name: String)

## (path) -> donnée de l'élément (par défaut : la ressource, relue du disque).
var load_item: Callable = func(path: String) -> Variant: return LtFiles.load_fresh(path)
## (path, donnée) -> Dictionary pour LtLibraryCard (title, detail, thumbnail,
## badge, badge_color, dimmed, tooltip, drag).
var describe: Callable = func(_path: String, _data: Variant) -> Dictionary: return {}
## (total, affichés) -> texte du compte.
var count_text: Callable = func(_total: int, shown: int) -> String: return LtText.t("%d shown") % shown
var empty_text: String = LtText.t("No item yet.")
var no_match_text: String = LtText.t("Nothing matches the filters.")
var layout: LtLibraryCard.Layout = LtLibraryCard.Layout.LIST
var selected_path: String = ""
## Clic droit sur une carte > Rename. Faux quand d'autres fichiers retiennent
## le chemin (une carte du monde qui liste ses niveaux par chemin).
var renamable: bool = false

## Rangée du haut : le jeu y met son surtitre et ses boutons (Import...).
var header: HBoxContainer
var search: LineEdit
var count_label: Label

var _filters_row: HFlowContainer
var _cards: Container
var _data: Dictionary[String, Variant] = {}
## [OptionButton, Callable(path, data, index) -> bool]
var _filters: Array[Array] = []
var _sort: OptionButton = null
var _sort_before: Callable


func _init() -> void:
	add_theme_constant_override(&"separation", 6)
	header = HBoxContainer.new()
	add_child(header)
	count_label = LtTheme.label("", LtTheme.DIM)
	add_child(count_label)
	search = LineEdit.new()
	search.placeholder_text = LtText.t("search")
	search.clear_button_enabled = true
	search.text_changed.connect(func(_text: String) -> void: refresh())
	add_child(search)
	_filters_row = HFlowContainer.new()
	_filters_row.add_theme_constant_override(&"h_separation", 6)
	_filters_row.add_theme_constant_override(&"v_separation", 6)
	add_child(_filters_row)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_cards = VBoxContainer.new()
	_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards.add_theme_constant_override(&"separation", 4)
	scroll.add_child(_cards)


## Passe en grille (miniatures au-dessus) ou en liste ; à appeler avant
## set_paths().
func set_layout(p_layout: LtLibraryCard.Layout) -> void:
	layout = p_layout
	var scroll: Node = _cards.get_parent()
	scroll.remove_child(_cards)
	_cards.queue_free()
	if layout == LtLibraryCard.Layout.GRID:
		var flow: HFlowContainer = HFlowContainer.new()
		flow.add_theme_constant_override(&"h_separation", 6)
		flow.add_theme_constant_override(&"v_separation", 6)
		_cards = flow
	else:
		var column: VBoxContainer = VBoxContainer.new()
		column.add_theme_constant_override(&"separation", 4)
		_cards = column
	_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_cards)


## Liste déroulante de filtre ; [param passes] : (path, donnée, choix) -> bool.
## Le choix 0 est en général « tout ».
func add_filter(caption: String, items: Array[String], passes: Callable) -> OptionButton:
	var option: OptionButton = _option(caption, items)
	_filters.append([option, passes])
	return option


## Liste des tris ; [param before] : (path_a, path_b, choix) -> bool (a avant
## b). by_name() et by_newest() servent de base.
func add_sort(names: Array[String], before: Callable) -> OptionButton:
	_sort = _option(LtText.t("Sort by"), names)
	_sort_before = before
	return _sort


## Change les choix d'un filtre en gardant le choix en cours s'il existe
## encore (biomes présents dans la bibliothèque...).
func set_filter_items(option: OptionButton, items: Array[String]) -> void:
	var current: String = option.get_item_text(option.selected) if option.selected >= 0 else ""
	option.clear()
	for item: String in items:
		option.add_item(item)
	option.select(maxi(items.find(current), 0))


## Relit les éléments de [param paths] (load_item) et refait la liste.
func set_paths(paths: PackedStringArray) -> void:
	_data.clear()
	for path: String in paths:
		_data[path] = load_item.call(path)
	refresh()


func get_data(path: String) -> Variant:
	return _data.get(path, null)


func paths() -> PackedStringArray:
	return PackedStringArray(_data.keys())


func select(path: String) -> void:
	selected_path = path
	for card: Node in _cards.get_children():
		if card is LtLibraryCard:
			(card as LtLibraryCard).selected = (card as LtLibraryCard).key == path


## Une carte par élément qui passe la recherche et les filtres, dans l'ordre
## du tri.
func refresh() -> void:
	for child: Node in _cards.get_children():
		_cards.remove_child(child)
		child.queue_free()
	var shown: Array[String] = shown_paths()
	for path: String in shown:
		var card: LtLibraryCard = LtLibraryCard.new(path, describe.call(path, _data[path]), layout)
		card.selected = path == selected_path
		card.renamable = renamable
		card.picked.connect(_on_picked)
		card.rename_requested.connect(func(key: String, new_name: String) -> void: rename_requested.emit(key, new_name))
		card.activated.connect(func(key: String) -> void: activated.emit(key))
		_cards.add_child(card)
	count_label.text = count_text.call(_data.size(), shown.size())
	if shown.is_empty():
		var empty: Label = LtTheme.label(no_match_text if not _data.is_empty() else empty_text, LtTheme.DIM)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_cards.add_child(empty)


## Chemins qui passent la recherche (nom du fichier) et les filtres, triés.
func shown_paths() -> Array[String]:
	var query: String = search.text.strip_edges().to_lower()
	var shown: Array[String] = []
	for path: String in _data:
		if query != "" and not path.get_file().get_basename().to_lower().contains(query):
			continue
		var passes: bool = true
		for filter: Array in _filters:
			var option: OptionButton = filter[0]
			if not (filter[1] as Callable).call(path, _data[path], option.selected):
				passes = false
				break
		if passes:
			shown.append(path)
	if _sort != null:
		shown.sort_custom(func(a: String, b: String) -> bool: return _sort_before.call(a, b, _sort.selected))
	else:
		shown.sort_custom(by_name)
	return shown


## Tri par nom de fichier (ordre naturel : level_2 avant level_10).
static func by_name(a: String, b: String) -> bool:
	return a.get_file().naturalnocasecmp_to(b.get_file()) < 0


## Le plus récemment modifié d'abord.
static func by_newest(a: String, b: String) -> bool:
	return FileAccess.get_modified_time(a) > FileAccess.get_modified_time(b)


func _on_picked(key: String) -> void:
	select(key)
	picked.emit(key)


# Liste déroulante avec sa légende au-dessus, qui refait la liste au choix.
func _option(caption: String, items: Array[String]) -> OptionButton:
	var option: OptionButton = OptionButton.new()
	option.focus_mode = Control.FOCUS_NONE
	option.clip_text = true
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for item: String in items:
		option.add_item(item)
	option.item_selected.connect(func(_index: int) -> void: refresh())
	var field: Control = LtTheme.field(_filters_row, caption, option)
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.custom_minimum_size.x = 120.0
	return option

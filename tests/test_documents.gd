extends TestCase

## Fichiers (LtFiles), document ouvert (LtDocument) et bibliothèque
## (LtLibrary), dans un dossier temporaire de user://.

const SampleDocument = preload("res://addons/level_tools/tests/sample_document.gd")
const DIR: String = "user://level_tools_tests/"
const CONFIG: String = "user://level_tools_tests/editor.cfg"


func before_each() -> void:
	_clear()
	DirAccess.make_dir_recursive_absolute(DIR)


func after_each() -> void:
	_clear()


# --- LtFiles ---

func test_clean_name() -> void:
	assert_eq(LtFiles.clean_name("  Boss Level 2 "), "boss_level_2")
	assert_eq(LtFiles.clean_name("a/b:c"), "abc")
	assert_eq(LtFiles.clean_name("   "), "")


func test_free_path_numbers_taken_names() -> void:
	assert_eq(LtFiles.free_path(DIR, "level"), DIR + "level.tres")
	_write("level")
	assert_eq(LtFiles.free_path(DIR, "level"), DIR + "level_2.tres")
	_write("level_2")
	assert_eq(LtFiles.free_path(DIR, "level"), DIR + "level_3.tres")


func test_list_save_and_rename() -> void:
	var document: Resource = _write("b")
	_write("a")
	assert_eq(LtFiles.list(DIR), PackedStringArray([DIR + "a.tres", DIR + "b.tres"]))
	assert_eq(LtFiles.rename(document, DIR + "b.tres", DIR + "a.tres"), ERR_ALREADY_EXISTS, "target taken")
	assert_eq(LtFiles.rename(document, DIR + "b.tres", DIR + "c.tres"), OK)
	assert_eq(document.resource_path, DIR + "c.tres", "resource follows its file")
	assert_eq(LtFiles.list(DIR), PackedStringArray([DIR + "a.tres", DIR + "c.tres"]))
	assert_eq(LtFiles.list("user://level_tools_no_such_dir/").size(), 0)


func test_import_copies_with_free_names() -> void:
	var source_dir: String = DIR + "source/"
	DirAccess.make_dir_recursive_absolute(source_dir)
	var source: Resource = SampleDocument.new()
	source.title = "imported"
	ResourceSaver.save(source, source_dir + "level.tres")
	_write("level")
	var written: PackedStringArray = LtFiles.import_files(PackedStringArray([source_dir + "level.tres", source_dir + "missing.tres"]), DIR,
		func(resource: Resource) -> bool: return resource.get_script() == SampleDocument,
		func(copy: Resource, target: String) -> void: copy.title = target.get_file().get_basename())
	assert_eq(written, PackedStringArray([DIR + "level_2.tres"]))
	assert_eq((LtFiles.load_fresh(DIR + "level_2.tres") as Resource).get("title"), "level_2", "on_copy ran")


func test_remember_and_reopen_the_last_file() -> void:
	var candidates: PackedStringArray = [DIR + "a.tres", DIR + "b.tres"]
	assert_eq(LtFiles.last_or_first(CONFIG, "map", "last", candidates), DIR + "a.tres", "nothing kept: the first")
	LtFiles.remember(CONFIG, "map", "last", DIR + "b.tres")
	assert_eq(LtFiles.last_or_first(CONFIG, "map", "last", candidates), DIR + "b.tres")
	candidates.remove_at(1)
	assert_eq(LtFiles.last_or_first(CONFIG, "map", "last", candidates), DIR + "a.tres", "kept file gone: the first")
	assert_eq(LtFiles.last_or_first(CONFIG, "map", "last", PackedStringArray()), "")


# --- LtDocument ---

func test_document_create_save_and_rename() -> void:
	var document: LtDocument = LtDocument.new(DIR)
	var messages: Array[String] = []
	document.message.connect(func(_text: String, kind: String) -> void: messages.append(kind))
	assert_true(document.create(SampleDocument.new(), "new_level"))
	assert_eq(document.path, DIR + "new_level.tres")
	document.resource.set("count", 7)
	document.dirty = true
	assert_true(document.save("Boss Room"), "save under the header name")
	assert_eq(document.path, DIR + "boss_room.tres")
	assert_false(FileAccess.file_exists(DIR + "new_level.tres"), "file renamed, not copied")
	assert_false(document.dirty)
	assert_eq((LtFiles.load_fresh(document.path) as Resource).get("count"), 7)
	assert_has(messages, "good")


func test_document_refuses_a_taken_or_empty_name() -> void:
	_write("taken")
	var document: LtDocument = LtDocument.new(DIR)
	document.create(SampleDocument.new(), "mine")
	assert_false(document.save("taken"))
	assert_false(document.save("   "))
	assert_eq(document.path, DIR + "mine.tres")


func test_document_saves_before_switching() -> void:
	_write("other")
	var document: LtDocument = LtDocument.new(DIR)
	document.create(SampleDocument.new(), "first")
	document.resource.set("speed", 9.0)
	document.dirty = true
	assert_true(document.open(DIR + "other.tres"))
	assert_eq((LtFiles.load_fresh(DIR + "first.tres") as Resource).get("speed"), 9.0, "modified document saved first")
	assert_true(document.duplicate_current())
	assert_eq(document.path, DIR + "other_copy.tres")


func test_document_reopens_the_last_one() -> void:
	_write("a")
	_write("b")
	var document: LtDocument = LtDocument.new(DIR)
	assert_true(document.open_last(CONFIG))
	assert_eq(document.path, DIR + "a.tres")
	document.open(DIR + "b.tres")
	document.remember(CONFIG)
	var again: LtDocument = LtDocument.new(DIR)
	again.open_last(CONFIG)
	assert_eq(again.path, DIR + "b.tres")


# --- LtLibrary ---

func test_library_search_filter_and_sort() -> void:
	for entry: Array in [["cave", 2], ["desert_1", 5], ["desert_10", 1], ["desert_2", 3]]:
		var document: Resource = SampleDocument.new()
		document.count = entry[1]
		LtFiles.save(document, DIR + entry[0] + ".tres")
	var library: LtLibrary = add_test_node(LtLibrary.new())
	library.describe = func(_path: String, data: Variant) -> Dictionary: return {"detail": "%d" % (data as Resource).get("count")}
	var size_filter: OptionButton = library.add_filter("Size", ["Any", "Big"] as Array[String],
		func(_path: String, data: Variant, choice: int) -> bool: return choice == 0 or (data as Resource).get("count") >= 3)
	var sort: OptionButton = library.add_sort(["Name", "Largest"] as Array[String], func(a: String, b: String, choice: int) -> bool:
		if choice == 1:
			return library.get_data(a).get("count") > library.get_data(b).get("count")
		return LtLibrary.by_name(a, b))
	library.set_paths(LtFiles.list(DIR))
	assert_eq(_names(library.shown_paths()), ["cave", "desert_1", "desert_2", "desert_10"], "natural name order")
	library.search.text = "DESERT"
	library.refresh()
	assert_eq(library.shown_paths().size(), 3, "search ignores case")
	size_filter.select(1)
	sort.select(1)
	library.refresh()
	assert_eq(_names(library.shown_paths()), ["desert_1", "desert_2"])


func test_library_cards_and_empty_states() -> void:
	var library: LtLibrary = add_test_node(LtLibrary.new())
	library.empty_text = "No level yet."
	library.set_paths(PackedStringArray())
	await frames(1)
	assert_eq(_labels(library), ["No level yet."], "guides when empty")
	_write("one")
	library.set_paths(LtFiles.list(DIR))
	var picked: Array[String] = []
	library.picked.connect(func(path: String) -> void: picked.append(path))
	var cards: Array[Node] = _cards(library)
	assert_eq(cards.size(), 1)
	(cards[0] as LtLibraryCard).picked.emit(DIR + "one.tres")
	assert_eq(picked, [DIR + "one.tres"] as Array[String])
	assert_eq(library.selected_path, DIR + "one.tres")
	library.search.text = "zzz"
	library.refresh()
	await frames(1)
	assert_eq(_labels(library), [library.no_match_text])


func test_library_grid_layout() -> void:
	_write("one")
	var library: LtLibrary = add_test_node(LtLibrary.new())
	library.set_layout(LtLibraryCard.Layout.GRID)
	library.set_paths(LtFiles.list(DIR))
	var cards: Array[Node] = _cards(library)
	assert_eq(cards.size(), 1)
	assert_true(cards[0].get_parent() is HFlowContainer)
	assert_eq((cards[0] as LtLibraryCard).custom_minimum_size, LtLibraryCard.GRID_SIZE)


func test_library_filter_items_keep_the_choice() -> void:
	var library: LtLibrary = add_test_node(LtLibrary.new())
	var biome: OptionButton = library.add_filter("Biome", ["All", "Desert"] as Array[String], func(_p: String, _d: Variant, _c: int) -> bool: return true)
	biome.select(1)
	library.set_filter_items(biome, ["All", "Cave", "Desert"] as Array[String])
	assert_eq(biome.get_item_text(biome.selected), "Desert")
	library.set_filter_items(biome, ["All", "Cave"] as Array[String])
	assert_eq(biome.selected, 0, "choice gone: back to the first")


# --- Outils ---

func _write(base_name: String) -> Resource:
	var document: Resource = SampleDocument.new()
	LtFiles.save(document, DIR + base_name + ".tres")
	return document


func _cards(library: LtLibrary) -> Array[Node]:
	var cards: Array[Node] = []
	cards.assign(library.find_children("*", "Control", true, false).filter(func(node: Node) -> bool: return node is LtLibraryCard))
	return cards


func _names(paths: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for path: String in paths:
		result.append(path.get_file().get_basename())
	return result


func _labels(library: LtLibrary) -> Array[String]:
	var result: Array[String] = []
	for node: Node in library.find_children("*", "Label", true, false):
		if not node.is_queued_for_deletion() and node != library.count_label and not (node.get_parent() is VBoxContainer and node.get_parent().get_parent() is HFlowContainer):
			result.append((node as Label).text)
	return result


func _clear() -> void:
	_remove(DIR)


func _remove(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	for file: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + file)
	for sub: String in DirAccess.get_directories_at(dir):
		_remove(dir + sub + "/")
	DirAccess.remove_absolute(dir)

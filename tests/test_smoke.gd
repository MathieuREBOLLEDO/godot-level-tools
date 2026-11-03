extends TestCase

## Fumée : chaque script de l'addon compile et se charge.

const ADDON_DIR: String = "res://addons/level_tools/"


func test_addon_files_load() -> void:
	var paths: PackedStringArray = []
	_collect(ADDON_DIR, paths)
	assert_gt(paths.size(), 10, "files found in %s" % ADDON_DIR)
	for path: String in paths:
		assert_not_null(load(path), path)


func _collect(dir: String, paths: PackedStringArray) -> void:
	for file: String in DirAccess.get_files_at(dir):
		if file.ends_with(".gd"):
			paths.append(dir + file)
	for sub: String in DirAccess.get_directories_at(dir):
		if not sub.begins_with("."):
			_collect(dir + sub + "/", paths)

@tool
extends EditorPlugin

## Déclare le réglage du projet level_tools/language (English, Français) dans
## Paramètres du projet. Les briques marchent aussi sans le plugin activé
## (langue anglaise par défaut).
## Dans un jeu sans test runner (addons/test_runner), les tests de l'addon
## sont cachés à Godot (tests/.gdignore, ignoré par git) : sans lui, leur
## classe TestCase manque et l'éditeur affiche une erreur par fichier.

const TESTS_IGNORE: String = "res://addons/level_tools/tests/.gdignore"
const TEST_RUNNER: String = "res://addons/test_runner/test_case.gd"


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(LtText.SETTING):
		ProjectSettings.set_setting(LtText.SETTING, "en")
	ProjectSettings.set_initial_value(LtText.SETTING, "en")
	ProjectSettings.add_property_info({"name": LtText.SETTING, "type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM, "hint_string": ",".join(LtText.LANGUAGES)})
	ProjectSettings.set_as_basic(LtText.SETTING, true)
	if not FileAccess.file_exists(TEST_RUNNER) and not FileAccess.file_exists(TESTS_IGNORE):
		var file: FileAccess = FileAccess.open(TESTS_IGNORE, FileAccess.WRITE)
		if file != null:
			file.store_string("")
			file.close()
			EditorInterface.get_resource_filesystem().scan()

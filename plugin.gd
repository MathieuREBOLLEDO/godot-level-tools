@tool
extends EditorPlugin

## Déclare le réglage du projet level_tools/language (English, Français) dans
## Paramètres du projet. Les briques marchent aussi sans le plugin activé
## (langue anglaise par défaut).


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(LtText.SETTING):
		ProjectSettings.set_setting(LtText.SETTING, "en")
	ProjectSettings.set_initial_value(LtText.SETTING, "en")
	ProjectSettings.add_property_info({"name": LtText.SETTING, "type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM, "hint_string": ",".join(LtText.LANGUAGES)})
	ProjectSettings.set_as_basic(LtText.SETTING, true)

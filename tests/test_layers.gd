extends TestCase

## Calques (LtLayers) : défaut sans réglage, clé reveal.

var _saved: Variant = null
var _had_setting: bool = false


func before_each() -> void:
	_had_setting = ProjectSettings.has_setting(LtLayers.SETTING)
	_saved = ProjectSettings.get_setting(LtLayers.SETTING) if _had_setting else null


func after_each() -> void:
	ProjectSettings.set_setting(LtLayers.SETTING, _saved if _had_setting else null)


func test_layers_default_has_a_secret_layer_before_front() -> void:
	ProjectSettings.set_setting(LtLayers.SETTING, null)
	assert_eq(Array(LtLayers.ids()), ["back", "game", "secret", "front"])
	assert_true(LtLayers.info("secret")["reveal"], "secret reveals")
	assert_true(LtLayers.info("secret")["front"], "secret drawn in front")
	assert_false(LtLayers.info("front")["reveal"], "front stays")


func test_layers_reveal_defaults_to_false() -> void:
	ProjectSettings.set_setting(LtLayers.SETTING, [{"id": "game"}, {"id": "hide", "front": true, "reveal": true}, {"id": "deco", "front": true}])
	assert_true(LtLayers.info("hide")["reveal"])
	assert_false(LtLayers.info("deco")["reveal"], "missing key -> false")
	assert_false(LtLayers.info("game")["reveal"])

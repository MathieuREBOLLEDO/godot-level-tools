extends TestCase

## Textes (LtText) et thème (LtTheme).


func after_each() -> void:
	LtText.set_language("")


func test_translation_defaults_to_english() -> void:
	LtText.set_language("en")
	assert_eq(LtText.t("Sort by"), "Sort by")


func test_translation_in_french() -> void:
	LtText.set_language("fr")
	assert_eq(LtText.t("Sort by"), "Trier par")
	assert_eq(LtText.t("A text nobody translated"), "A text nobody translated", "missing text stays in English")
	assert_eq(LtText.t("Saved %s.") % "a.tres", "a.tres enregistré.", "keeps its %s")


func test_translation_registered_by_a_game() -> void:
	LtText.register("fr", {"Biome": "Biome du jeu", "Sort by": "Ordre"})
	LtText.set_language("fr")
	assert_eq(LtText.t("Biome"), "Biome du jeu")
	assert_eq(LtText.t("Sort by"), "Ordre", "a game text wins over the addon's")
	LtText.register("fr", {"Sort by": "Trier par"})


func test_unknown_language_falls_back_to_english() -> void:
	LtText.set_language("xx")
	assert_eq(LtText.get_language(), "en")


func test_theme_reads_the_design_tokens() -> void:
	var tokens: ConfigFile = ConfigFile.new()
	if tokens.load(LtTheme.TOKENS_PATH) != OK:
		return # pas de jetons dans ce jeu : les défauts s'appliquent
	assert_eq(LtTheme.ACCENT, Color(String(tokens.get_value("colors", "accent", "70bbfa"))), "accent from design_tokens.cfg")
	assert_eq(LtTheme.FONT_SIZE, int(tokens.get_value("sizes", "text", 14)))


func test_theme_builds_its_variations() -> void:
	var theme: Theme = LtTheme.build()
	for variation: StringName in [LtTheme.TITLE, LtTheme.PRIMARY, LtTheme.CHIP, LtTheme.LEGEND, LtTheme.DIM, LtTheme.KICKER, LtTheme.MONO, LtTheme.CARD]:
		assert_true(theme.is_type_variation(variation, theme.get_type_variation_base(variation)), "variation %s" % variation)
	assert_not_null(theme.default_font, "interface font")
	assert_eq(LtTheme.color("bad"), LtTheme.BAD)


func test_theme_builders() -> void:
	var row: HBoxContainer = add_test_node(HBoxContainer.new())
	var first: HBoxContainer = LtTheme.group(row)
	LtTheme.button(first, "Save", "tooltip", func() -> void: pass)
	LtTheme.group(row)
	assert_eq(row.get_child_count(), 3, "second group starts with a rule")
	assert_true(row.get_child(1) is VSeparator)
	var field: Control = LtTheme.field(row, "Caption", LineEdit.new())
	assert_eq((field.get_child(0) as Label).text, "Caption")
	var band: PanelContainer = LtTheme.band(Vector2i.DOWN, Vector4(4, 4, 4, 4))
	var box: StyleBoxFlat = band.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.border_width_bottom, 1, "rule on the bottom side")
	assert_eq(box.border_width_top, 0)
	band.free()

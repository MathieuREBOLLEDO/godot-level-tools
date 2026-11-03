@tool
class_name LtTheme
extends RefCounted

## Apparence des éditeurs : comme l'éditeur Godot. Fonds gris-bleu, texte
## clair, un seul accent pour ce qu'on manipule ; couleurs de sens : GOOD
## (ouvert, valide), BAD (problème), INFO (vide, information).
## Valeurs lues dans les jetons de design du jeu (res://design_tokens.cfg) ;
## une valeur absente garde son défaut ci-dessous. Avec [profile]
## follow_editor=true, dans l'éditeur Godot, les couleurs viennent du thème
## de l'éditeur ouvert. Polices du système (SystemFont, rien à télécharger).
## Fusion de LevelToolsTheme (ProjetGringo) et ToolsTheme (BatEmUp).

const TOKENS_PATH: String = "res://design_tokens.cfg"
const BUTTON_MARGIN: Vector4 = Vector4(6, 3, 6, 3)

## Variantes de thème (theme_type_variation).
const TITLE: StringName = &"ToolTitle" ## nom du document (LineEdit), grand, souligné
const PRIMARY: StringName = &"ToolPrimary" ## bouton principal, un seul par écran
const CHIP: StringName = &"ToolChip" ## pastille à bascule (filtre, choix rapide)
const LEGEND: StringName = &"ToolLegend" ## pastille de légende, sans cadre
const DIM: StringName = &"ToolDim" ## texte secondaire
const KICKER: StringName = &"ToolKicker" ## surtitre étroit dans l'accent
const MONO: StringName = &"ToolMono" ## valeurs, durées, compteurs
const CARD: StringName = &"ToolCard" ## carte relevée, ombre discrète

static var INK: Color
static var INK_PANEL: Color
static var INK_RAISED: Color
static var INK_LINE: Color
static var SAND: Color
static var SAND_DIM: Color
static var ACCENT: Color
static var GOOD: Color
static var BAD: Color
static var INFO: Color

static var UI_FONT_NAMES: PackedStringArray
static var MONO_FONT_NAMES: PackedStringArray
static var CONDENSED_WIDTH: int
static var CONDENSED_WEIGHT: int
static var FONT_SIZE: int
static var TITLE_SIZE: int
static var SMALL_SIZE: int
static var RADIUS: int
static var ICON_SIZE: int

static var _tokens: ConfigFile
static var _ui_font: Font = null
static var _condensed_font: Font = null
static var _mono_font: Font = null


static func _static_init() -> void:
	reload()


## Relit les jetons (et le thème de l'éditeur) : après un changement de
## design_tokens.cfg ou du thème de l'éditeur. Les thèmes déjà construits
## ne changent pas : les reconstruire (build()).
static func reload() -> void:
	_tokens = ConfigFile.new()
	if FileAccess.file_exists(TOKENS_PATH):
		_tokens.load(TOKENS_PATH)
	INK = _color("ink", "1d2229")
	INK_PANEL = _color("ink_panel", "252b34")
	INK_RAISED = _color("ink_raised", "363d4a")
	INK_LINE = _color("ink_line", "414957")
	SAND = _color("sand", "e0e0e0")
	SAND_DIM = _color("sand_dim", "8b929c")
	ACCENT = _color("accent", "70bbfa")
	GOOD = _color("good", "45d17c")
	BAD = _color("bad", "ff786b")
	INFO = _color("info", "a5b6cc")
	UI_FONT_NAMES = _token("fonts", "ui", PackedStringArray(["@engine"]))
	MONO_FONT_NAMES = _token("fonts", "mono", PackedStringArray(["JetBrains Mono", "Cascadia Mono", "Consolas", "Menlo"]))
	CONDENSED_WIDTH = _token("fonts", "condensed_width", 100)
	CONDENSED_WEIGHT = _token("fonts", "condensed_weight", 600)
	FONT_SIZE = _token("sizes", "text", 14)
	TITLE_SIZE = _token("sizes", "title", 16)
	SMALL_SIZE = _token("sizes", "small", 12)
	RADIUS = _token("sizes", "radius", 3)
	ICON_SIZE = _token("sizes", "button_icon", 16)
	_ui_font = null
	_condensed_font = null
	_mono_font = null


## Couleur de sens ou de base par son nom de jeton (« accent », « bad »...).
static func color(key: String) -> Color:
	match key:
		"ink": return INK
		"ink_panel": return INK_PANEL
		"ink_raised": return INK_RAISED
		"ink_line": return INK_LINE
		"sand": return SAND
		"sand_dim": return SAND_DIM
		"accent": return ACCENT
		"good": return GOOD
		"bad": return BAD
		"info": return INFO
	return SAND


# --- Polices ---

## Police de l'interface ; [param condensed] : version étroite, plus grasse
## (titres, étiquettes). Nom « @engine » : celle de l'éditeur Godot dans
## l'éditeur, celle de Godot par défaut en jeu.
static func ui_font(condensed: bool = false) -> Font:
	if _ui_font == null:
		var base: Font
		if UI_FONT_NAMES.has("@engine"):
			base = _engine_font()
		else:
			var system: SystemFont = SystemFont.new()
			system.font_names = UI_FONT_NAMES
			base = system
		_ui_font = base
		var narrow: FontVariation = FontVariation.new()
		narrow.base_font = base
		narrow.variation_opentype = {"wdth": CONDENSED_WIDTH, "wght": CONDENSED_WEIGHT}
		_condensed_font = narrow
	return _condensed_font if condensed else _ui_font


static func mono_font() -> Font:
	if _mono_font == null:
		var system: SystemFont = SystemFont.new()
		system.font_names = MONO_FONT_NAMES
		_mono_font = system
	return _mono_font


static func _engine_font() -> Font:
	var editor_theme: Theme = _editor_theme()
	if editor_theme != null and editor_theme.default_font != null:
		return editor_theme.default_font
	return ThemeDB.fallback_font


# --- Thème ---

## Thème d'un éditeur (à poser sur son nœud racine).
static func build() -> Theme:
	var theme: Theme = Theme.new()
	theme.default_font = ui_font()
	theme.default_font_size = FONT_SIZE

	theme.set_stylebox(&"panel", &"PanelContainer", box(INK_PANEL, INK_LINE, 0, Vector4(0, 0, 0, 1)))
	theme.set_stylebox(&"panel", &"Panel", box(INK_PANEL))
	theme.set_color(&"font_color", &"Label", SAND)

	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		theme.set_stylebox(state, &"Button", _button_box(state, INK_RAISED, INK_LINE))
		theme.set_stylebox(state, &"MenuButton", _button_box(state, INK_RAISED, INK_LINE))
	for type: StringName in [&"Button", &"MenuButton"]:
		theme.set_color(&"font_color", type, SAND)
		theme.set_color(&"font_hover_color", type, ACCENT)
		theme.set_color(&"font_pressed_color", type, ACCENT)
		theme.set_color(&"font_hover_pressed_color", type, ACCENT)
		theme.set_color(&"font_disabled_color", type, SAND_DIM)
		theme.set_color(&"icon_normal_color", type, SAND)
		theme.set_color(&"icon_hover_color", type, ACCENT)
		theme.set_color(&"icon_pressed_color", type, ACCENT)
		theme.set_constant(&"h_separation", type, 4)
		theme.set_constant(&"icon_max_width", type, ICON_SIZE)

	# Bouton principal : plein, couleur d'accent (un seul par écran).
	theme.set_type_variation(PRIMARY, &"Button")
	theme.set_stylebox(&"normal", PRIMARY, box(ACCENT, ACCENT, RADIUS, Vector4.ONE, BUTTON_MARGIN))
	theme.set_stylebox(&"hover", PRIMARY, box(ACCENT.lightened(0.15), ACCENT.lightened(0.15), RADIUS, Vector4.ONE, BUTTON_MARGIN))
	theme.set_stylebox(&"pressed", PRIMARY, box(ACCENT.darkened(0.15), ACCENT.darkened(0.15), RADIUS, Vector4.ONE, BUTTON_MARGIN))
	theme.set_stylebox(&"disabled", PRIMARY, box(Color(ACCENT, 0.35), Color.TRANSPARENT, RADIUS, Vector4.ONE, BUTTON_MARGIN))
	for color_name: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_disabled_color", &"icon_normal_color", &"icon_hover_color", &"icon_pressed_color"]:
		theme.set_color(color_name, PRIMARY, INK)

	# Pastille à bascule (filtre, choix rapide) : transparente, contour au
	# survol, accent quand elle est choisie.
	var chip_margin: Vector4 = Vector4(9, 2, 9, 2)
	theme.set_type_variation(CHIP, &"Button")
	theme.set_stylebox(&"normal", CHIP, box(Color.TRANSPARENT, INK_LINE, 10, Vector4.ONE, chip_margin))
	theme.set_stylebox(&"hover", CHIP, box(INK_RAISED, INK_LINE, 10, Vector4.ONE, chip_margin))
	theme.set_stylebox(&"pressed", CHIP, box(Color(ACCENT, 0.18), ACCENT, 10, Vector4.ONE, chip_margin))
	theme.set_stylebox(&"hover_pressed", CHIP, box(Color(ACCENT, 0.25), ACCENT, 10, Vector4.ONE, chip_margin))
	theme.set_stylebox(&"focus", CHIP, StyleBoxEmpty.new())
	theme.set_color(&"font_hover_color", CHIP, SAND)
	theme.set_font_size(&"font_size", CHIP, SMALL_SIZE)

	# Pastille de légende (pied : passages, problèmes) : sans cadre, contour
	# au survol ; la couleur du texte est celle du sens.
	var legend_margin: Vector4 = Vector4(10, 3, 10, 3)
	theme.set_type_variation(LEGEND, &"Button")
	theme.set_stylebox(&"normal", LEGEND, box(Color.TRANSPARENT, Color.TRANSPARENT, 10, Vector4.ONE, legend_margin))
	theme.set_stylebox(&"hover", LEGEND, box(INK_RAISED, INK_LINE, 10, Vector4.ONE, legend_margin))
	theme.set_stylebox(&"pressed", LEGEND, box(INK_RAISED, ACCENT, 10, Vector4.ONE, legend_margin))
	theme.set_stylebox(&"disabled", LEGEND, box(Color.TRANSPARENT, Color.TRANSPARENT, 10, Vector4.ONE, legend_margin))
	theme.set_stylebox(&"focus", LEGEND, StyleBoxEmpty.new())
	theme.set_color(&"font_hover_color", LEGEND, SAND)

	# Nom du document : grand, sans cadre, souligné.
	theme.set_type_variation(TITLE, &"LineEdit")
	theme.set_font(&"font", TITLE, ui_font(true))
	theme.set_font_size(&"font_size", TITLE, TITLE_SIZE)
	theme.set_stylebox(&"normal", TITLE, box(Color.TRANSPARENT, INK_LINE, 0, Vector4(0, 0, 0, 1), Vector4(2, 2, 2, 4)))
	theme.set_stylebox(&"focus", TITLE, box(Color.TRANSPARENT, ACCENT, 0, Vector4(0, 0, 0, 2), Vector4(2, 2, 2, 4)))
	theme.set_color(&"font_color", TITLE, SAND)
	theme.set_color(&"caret_color", TITLE, ACCENT)
	theme.set_color(&"selection_color", TITLE, Color(ACCENT, 0.35))

	theme.set_type_variation(DIM, &"Label")
	theme.set_color(&"font_color", DIM, SAND_DIM)
	theme.set_font_size(&"font_size", DIM, SMALL_SIZE)

	theme.set_type_variation(MONO, &"Label")
	theme.set_font(&"font", MONO, mono_font())
	theme.set_font_size(&"font_size", MONO, SMALL_SIZE)
	theme.set_color(&"font_color", MONO, SAND)

	theme.set_type_variation(KICKER, &"Label")
	theme.set_font(&"font", KICKER, ui_font(true))
	theme.set_font_size(&"font_size", KICKER, SMALL_SIZE)
	theme.set_color(&"font_color", KICKER, ACCENT)

	theme.set_type_variation(CARD, &"PanelContainer")
	var card: StyleBoxFlat = box(INK_RAISED.darkened(0.25), INK_LINE, RADIUS + 1, Vector4.ONE, Vector4(10, 8, 10, 10))
	card.shadow_color = Color(0, 0, 0, 0.25)
	card.shadow_size = 4
	card.shadow_offset = Vector2(0, 2)
	theme.set_stylebox(&"panel", CARD, card)

	# Champs de saisie : creusés dans l'encre ; filet d'accent au focus.
	theme.set_stylebox(&"normal", &"LineEdit", box(INK, INK_LINE, RADIUS, Vector4.ONE, Vector4(8, 4, 8, 4)))
	theme.set_stylebox(&"focus", &"LineEdit", box(Color.TRANSPARENT, ACCENT, RADIUS, Vector4.ONE))
	theme.set_stylebox(&"read_only", &"LineEdit", box(INK_PANEL, INK_LINE, RADIUS, Vector4.ONE, Vector4(8, 4, 8, 4)))
	theme.set_color(&"font_color", &"LineEdit", SAND)
	theme.set_color(&"font_placeholder_color", &"LineEdit", SAND_DIM)
	theme.set_color(&"caret_color", &"LineEdit", ACCENT)
	theme.set_color(&"selection_color", &"LineEdit", Color(ACCENT, 0.35))

	theme.set_stylebox(&"panel", &"PopupMenu", box(INK_PANEL, INK_LINE, RADIUS, Vector4.ONE, Vector4(4, 4, 4, 4)))
	theme.set_stylebox(&"hover", &"PopupMenu", box(INK_RAISED, INK_RAISED, 2))
	theme.set_color(&"font_color", &"PopupMenu", SAND)
	theme.set_color(&"font_hover_color", &"PopupMenu", ACCENT)
	theme.set_color(&"font_disabled_color", &"PopupMenu", SAND_DIM)

	# Onglets (ensemble | pièce) : l'onglet ouvert est relevé, filet d'accent
	# en haut.
	theme.set_stylebox(&"panel", &"TabContainer", box(INK))
	theme.set_stylebox(&"tabbar_background", &"TabContainer", box(INK_PANEL, INK_LINE, 0, Vector4(0, 0, 0, 1), Vector4.ZERO))
	theme.set_stylebox(&"tab_selected", &"TabContainer", box(INK_RAISED, ACCENT, 0, Vector4(0, 2, 0, 0), Vector4(14, 5, 14, 5)))
	theme.set_stylebox(&"tab_unselected", &"TabContainer", box(Color.TRANSPARENT, Color.TRANSPARENT, 0, Vector4.ZERO, Vector4(14, 5, 14, 5)))
	theme.set_stylebox(&"tab_hovered", &"TabContainer", box(Color(INK_RAISED, 0.5), Color.TRANSPARENT, 0, Vector4.ZERO, Vector4(14, 5, 14, 5)))
	theme.set_color(&"font_selected_color", &"TabContainer", SAND)
	theme.set_color(&"font_unselected_color", &"TabContainer", SAND_DIM)
	theme.set_color(&"font_hovered_color", &"TabContainer", SAND)

	theme.set_stylebox(&"panel", &"TooltipPanel", box(INK_RAISED, INK_LINE, RADIUS, Vector4.ONE, Vector4(8, 5, 8, 5)))
	theme.set_color(&"font_color", &"TooltipLabel", SAND)

	theme.set_stylebox(&"panel", &"ItemList", box(Color.TRANSPARENT, Color.TRANSPARENT, 0, Vector4.ZERO, Vector4(0, 4, 0, 4)))
	theme.set_stylebox(&"selected", &"ItemList", box(Color(ACCENT, 0.16), ACCENT, RADIUS, Vector4(2, 0, 0, 0)))
	theme.set_stylebox(&"selected_focus", &"ItemList", box(Color(ACCENT, 0.16), ACCENT, RADIUS, Vector4(2, 0, 0, 0)))
	theme.set_stylebox(&"hovered", &"ItemList", box(Color(INK_RAISED, 0.6), Color.TRANSPARENT, RADIUS))
	theme.set_stylebox(&"focus", &"ItemList", StyleBoxEmpty.new())
	theme.set_color(&"font_color", &"ItemList", SAND)
	theme.set_color(&"font_selected_color", &"ItemList", SAND)
	theme.set_constant(&"v_separation", &"ItemList", 6)

	# Curseurs : rail fin, partie remplie dans l'accent (la valeur manipulée).
	theme.set_stylebox(&"slider", &"HSlider", box(INK_LINE, Color.TRANSPARENT, 2, Vector4.ZERO, Vector4(0, 2, 0, 2)))
	theme.set_stylebox(&"grabber_area", &"HSlider", box(Color(ACCENT, 0.55), Color.TRANSPARENT, 2, Vector4.ZERO, Vector4(0, 2, 0, 2)))
	theme.set_stylebox(&"grabber_area_highlight", &"HSlider", box(ACCENT, Color.TRANSPARENT, 2, Vector4.ZERO, Vector4(0, 2, 0, 2)))
	theme.set_icon(&"grabber", &"HSlider", _dot(10, SAND))
	theme.set_icon(&"grabber_highlight", &"HSlider", _dot(12, ACCENT))

	var scroll: StyleBoxFlat = box(Color(INK_LINE, 0.6), Color.TRANSPARENT, 3)
	theme.set_stylebox(&"grabber", &"VScrollBar", scroll)
	theme.set_stylebox(&"grabber_highlight", &"VScrollBar", box(SAND_DIM, Color.TRANSPARENT, 3))
	theme.set_stylebox(&"grabber_pressed", &"VScrollBar", box(ACCENT, Color.TRANSPARENT, 3))
	theme.set_stylebox(&"scroll", &"VScrollBar", box(Color.TRANSPARENT))
	return theme


# --- Construction des interfaces ---

static func label(text: String, variation: StringName = &"") -> Label:
	var result: Label = Label.new()
	result.text = text
	result.theme_type_variation = variation
	return result


## Bouton texte (et icône) sans focus clavier, ajouté à [param parent].
static func button(parent: Container, text: String, tooltip: String, on_pressed: Callable, icon: Texture2D = null) -> Button:
	var result: Button = Button.new()
	result.text = text
	result.icon = icon
	result.tooltip_text = tooltip
	result.focus_mode = Control.FOCUS_NONE
	result.pressed.connect(on_pressed)
	parent.add_child(result)
	return result


## Bouton à menu (Ouvrir) : icône et flèche ; [param on_open] remplit le
## menu à chaque ouverture, [param on_id] reçoit l'élément choisi.
static func menu_button(parent: Container, tooltip: String, icon: Texture2D, on_open: Callable, on_id: Callable) -> MenuButton:
	var result: MenuButton = MenuButton.new()
	result.text = "▾"
	result.icon = icon
	result.tooltip_text = tooltip
	result.flat = false
	result.focus_mode = Control.FOCUS_NONE
	result.about_to_popup.connect(on_open)
	result.get_popup().id_pressed.connect(on_id)
	parent.add_child(result)
	return result


## Groupe de boutons serrés, séparé du groupe précédent par un filet.
static func group(parent: Container) -> HBoxContainer:
	if parent.get_child_count() > 0 and parent.get_child(parent.get_child_count() - 1) is HBoxContainer:
		var rule: VSeparator = VSeparator.new()
		rule.add_theme_stylebox_override(&"separator", box(INK_LINE, Color.TRANSPARENT, 0, Vector4.ZERO, Vector4(1, 0, 0, 0)))
		parent.add_child(rule)
	var result: HBoxContainer = HBoxContainer.new()
	result.add_theme_constant_override(&"separation", 4)
	result.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(result)
	return result


## Champ avec sa légende au-dessus (petite, estompée).
static func field(parent: Container, caption: String, control: Control) -> Control:
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 1)
	column.size_flags_vertical = Control.SIZE_SHRINK_END
	column.add_child(label(caption, DIM))
	column.add_child(control)
	parent.add_child(column)
	return column


## Espace qui pousse la suite à droite.
static func spacer(parent: Container) -> void:
	var result: Control = Control.new()
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(result)


## Bandeau (en-tête, pied, bibliothèque) : fond panneau, filet du côté
## [param side] (Vector2i.DOWN : filet en bas...).
static func band(side: Vector2i, margin: Vector4) -> PanelContainer:
	var result: PanelContainer = PanelContainer.new()
	var border: Vector4 = Vector4(maxi(-side.x, 0), maxi(-side.y, 0), maxi(side.x, 0), maxi(side.y, 0))
	result.add_theme_stylebox_override(&"panel", box(INK_PANEL, INK_LINE, 0, border, margin))
	return result


## Icône de l'éditeur Godot (null hors de l'éditeur).
static func editor_icon(name: StringName) -> Texture2D:
	var editor_theme: Theme = _editor_theme()
	if editor_theme != null and editor_theme.has_icon(name, &"EditorIcons"):
		return editor_theme.get_icon(name, &"EditorIcons")
	return null


## Boîte de style plate : fond, bord, rayon, épaisseurs (gauche, haut, droite,
## bas) et marges intérieures.
static func box(fill: Color, border: Color = Color.TRANSPARENT, radius: int = 0, border_width: Vector4 = Vector4.ZERO, margin: Vector4 = Vector4(8, 4, 8, 4)) -> StyleBoxFlat:
	var result: StyleBoxFlat = StyleBoxFlat.new()
	result.bg_color = fill
	result.border_color = border
	result.border_width_left = int(border_width.x)
	result.border_width_top = int(border_width.y)
	result.border_width_right = int(border_width.z)
	result.border_width_bottom = int(border_width.w)
	result.set_corner_radius_all(radius)
	result.content_margin_left = margin.x
	result.content_margin_top = margin.y
	result.content_margin_right = margin.z
	result.content_margin_bottom = margin.w
	return result


# Pastille ronde (poignée des curseurs).
static func _dot(diameter: int, dot_color: Color) -> ImageTexture:
	var image: Image = Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(diameter, diameter) * 0.5
	for y: int in diameter:
		for x: int in diameter:
			var distance: float = (Vector2(x, y) + Vector2(0.5, 0.5)).distance_to(center)
			image.set_pixel(x, y, Color(dot_color, clampf(center.x - distance, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)


static func _button_box(state: String, fill: Color, border: Color) -> StyleBox:
	match state:
		"hover":
			return box(fill.lightened(0.06), ACCENT, RADIUS, Vector4.ONE, BUTTON_MARGIN)
		"pressed":
			return box(INK, ACCENT, RADIUS, Vector4.ONE, BUTTON_MARGIN)
		"disabled":
			return box(Color(fill, 0.4), Color(border, 0.4), RADIUS, Vector4.ONE, BUTTON_MARGIN)
		"focus":
			return StyleBoxEmpty.new()
	return box(fill, border, RADIUS, Vector4.ONE, BUTTON_MARGIN)


# --- Jetons ---

static func _token(section: String, key: String, default: Variant) -> Variant:
	return _tokens.get_value(section, key, default)


static func _color(key: String, default: String) -> Color:
	var from_editor: Variant = editor_color(key) if _token("profile", "follow_editor", false) else null
	return from_editor if from_editor != null else Color(String(_token("colors", key, default)))


## Couleur du thème de l'éditeur Godot qui tient lieu du jeton [param key]
## ([profile] follow_editor) : fond, panneaux, boutons, texte et accent de
## l'éditeur ouvert. null hors de l'éditeur ou pour un jeton sans
## équivalent (info).
static func editor_color(key: String) -> Variant:
	var editor_theme: Theme = _editor_theme()
	if editor_theme == null:
		return null
	var font: Color = editor_theme.get_color(&"font_color", &"Editor")
	match key:
		"ink":
			return _box_color(editor_theme, &"Content", &"EditorStyles", false)
		"ink_panel":
			return _box_color(editor_theme, &"panel", &"Panel", false)
		"ink_raised":
			return _box_color(editor_theme, &"normal", &"Button", false)
		"ink_line":
			return _box_color(editor_theme, &"normal", &"Button", true)
		"sand":
			return font
		"sand_dim":
			return font.lerp(editor_theme.get_color(&"base_color", &"Editor"), 0.45)
		"accent":
			return editor_theme.get_color(&"accent_color", &"Editor")
		"good":
			return editor_theme.get_color(&"success_color", &"Editor")
		"bad":
			return editor_theme.get_color(&"error_color", &"Editor")
	return null


# EditorInterface n'existe pas en jeu exporté : passé par Engine.
static func _editor_theme() -> Theme:
	if not Engine.is_editor_hint() or not Engine.has_singleton(&"EditorInterface"):
		return null
	return Engine.get_singleton(&"EditorInterface").get_editor_theme()


static func _box_color(editor_theme: Theme, style: StringName, type: StringName, border: bool) -> Variant:
	var style_box: StyleBoxFlat = editor_theme.get_stylebox(style, type) as StyleBoxFlat
	if style_box == null:
		return null
	return style_box.border_color if border else style_box.bg_color

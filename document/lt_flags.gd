@tool
class_name LtFlags
extends RefCounted

## Marques d'un document, les mêmes dans tous les éditeurs :
## - DPRC (obsolète) : gardé pour mémoire, caché des bibliothèques par défaut ;
## - EXCL (exclu du jeu) : caché aussi, et le jeu ne doit pas s'en servir
##   (is_excluded()).
## Rangées dans la ressource : propriétés « deprecated » et
## « exclude_from_game » si elle les a (LevelData de Gringo), sinon ses
## métadonnées (enregistrées avec elle dans le .tres).
## Repris de l'éditeur de niveaux de Gringo (cases DPRC, EXCL, filtre Flags).

const DEPRECATED: String = "DPRC"
const EXCLUDED: String = "EXCL"
## Choix du filtre Flags d'une bibliothèque (passes()).
const FILTERS: Array[String] = ["Hide flagged", "All", "Only DPRC", "Only excluded"]

const _PROPERTIES: Dictionary[String, String] = {DEPRECATED: "deprecated", EXCLUDED: "exclude_from_game"}
const _TIPS: Dictionary[String, String] = {
	DEPRECATED: "Deprecated: kept for reference, hidden from the libraries (Flags filter).",
	EXCLUDED: "Exclude from game: hidden from the libraries, and the game does not use it.",
}


static func has(resource: Object, flag: String) -> bool:
	if resource == null:
		return false
	var property: String = _PROPERTIES[flag]
	if property in resource:
		return bool(resource.get(property))
	return bool(resource.get_meta("lt_" + property, false))


static func set_flag(resource: Object, flag: String, on: bool) -> void:
	var property: String = _PROPERTIES[flag]
	if property in resource:
		resource.set(property, on)
	elif on:
		resource.set_meta("lt_" + property, true)
	elif resource.has_meta("lt_" + property):
		resource.remove_meta("lt_" + property)


static func is_deprecated(resource: Object) -> bool:
	return has(resource, DEPRECATED)


static func is_excluded(resource: Object) -> bool:
	return has(resource, EXCLUDED)


## « DPRC EXCL », « DPRC »... ou "" : pour la ligne de détail d'une carte.
static func text(resource: Object) -> String:
	var flags: PackedStringArray = []
	for flag: String in [DEPRECATED, EXCLUDED]:
		if has(resource, flag):
			flags.append(flag)
	return " ".join(flags)


## Vrai si [param resource] passe le choix [param choice] de FILTERS ; un
## fichier illisible (null) n'est montré que par « Hide flagged » et « All ».
static func passes(resource: Object, choice: int) -> bool:
	match choice:
		0:
			return not is_deprecated(resource) and not is_excluded(resource)
		2:
			return resource != null and is_deprecated(resource)
		3:
			return resource != null and is_excluded(resource)
	return true


## Ajoute le filtre Flags à [param library] (sa donnée est la ressource).
static func add_filter(library: LtLibrary) -> OptionButton:
	var items: Array[String] = []
	for item: String in FILTERS:
		items.append(LtText.t(item))
	# Une donnée qui n'est pas un objet (un élément de catalogue) n'a pas de marque.
	var option: OptionButton = library.add_filter(LtText.t("Flags"), items, func(_path: String, data: Variant, choice: int) -> bool: return passes(data if data is Object else null, choice))
	option.tooltip_text = LtText.t("DPRC (deprecated) and EXCL (excluded from game) are hidden by default. Set them in the document settings.")
	return option


## Cases DPRC et EXCL dans [param parent] ; [param on_toggled] :
## (flag, on) -> void. Rend {flag: CheckBox} pour show_checks().
static func build_checks(parent: Container, on_toggled: Callable) -> Dictionary:
	var checks: Dictionary = {}
	for flag: String in [DEPRECATED, EXCLUDED]:
		var check: CheckBox = CheckBox.new()
		check.text = flag
		check.tooltip_text = LtText.t(_TIPS[flag])
		check.focus_mode = Control.FOCUS_NONE
		check.toggled.connect(func(on: bool) -> void: on_toggled.call(flag, on))
		parent.add_child(check)
		checks[flag] = check
	return checks


## Coche les cases d'après [param resource], sans émettre.
static func show_checks(checks: Dictionary, resource: Object) -> void:
	for flag: String in checks:
		(checks[flag] as CheckBox).set_pressed_no_signal(has(resource, flag))

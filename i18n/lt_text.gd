@tool
class_name LtText
extends RefCounted

## Traduction des textes des éditeurs, indépendante de celle du jeu (le
## TranslationServer de Godot est global : changer sa langue changerait
## aussi celle du jeu).
## Les textes sont écrits en anglais dans le code : LtText.t("Save").
## Avec une autre langue, la traduction est cherchée dans les textes
## ajoutés par le jeu (register), puis dans ceux de l'addon (i18n/fr.gd) ;
## un texte absent reste en anglais. Un texte avec des valeurs garde ses
## %d / %s : LtText.t("%d level(s)") % n.
## Langue : réglage du projet level_tools/language (« en » par défaut,
## « fr »), ou set_language() (un menu de réglages du jeu).

const FR = preload("res://addons/level_tools/i18n/fr.gd")
const SETTING: String = "level_tools/language"
const LANGUAGES: Array[String] = ["en", "fr"]
const LANGUAGE_NAMES: Array[String] = ["English", "Français"]

## Langue choisie par set_language() ; vide : celle du réglage du projet.
static var _language: String = ""
## Textes ajoutés par le jeu : langue -> {anglais: traduction}.
static var _registered: Dictionary[String, Dictionary] = {}


static func t(text: String) -> String:
	var language: String = get_language()
	if language == "en":
		return text
	var registered: Dictionary = _registered.get(language, {})
	if registered.has(text):
		return registered[text]
	if language == "fr":
		return FR.TEXTS.get(text, text)
	return text


## Ajoute les textes d'un éditeur du jeu ({anglais: traduction}) ; un texte
## déjà présent est remplacé.
static func register(language: String, texts: Dictionary) -> void:
	var current: Dictionary = _registered.get(language, {})
	current.merge(texts, true)
	_registered[language] = current


static func get_language() -> String:
	var language: String = _language
	if language == "":
		language = str(ProjectSettings.get_setting(SETTING, "en"))
	return language if LANGUAGES.has(language) else "en"


## Change la langue pour toute la session ; « » : revient au réglage du
## projet.
static func set_language(language: String) -> void:
	_language = language if LANGUAGES.has(language) or language == "" else "en"

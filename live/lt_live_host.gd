@tool
class_name LtLiveHost
extends RefCounted

## Ce que le jeu donne au live edit (LtLiveEdit) : on hérite de cette classe
## et on redéfinit ce qui sert. Une « case » est ce que le jeu veut (Vector2i
## d'une grille, Vector2 en mètres, voie et moment...) ; null : hors du niveau.

## Titre de la fenêtre flottante.
var title: String = "ELEMENTS"
## Aide des gestes du jeu, dans la barre du bas (en anglais, traduite).
var help: String = "left click: place · right click: erase"
## Vrai : un glissé pose sur chaque case survolée ; faux : un clic, une pose.
var drag_paint: bool = true
## Taille de la fenêtre flottante à l'ouverture.
var palette_size: Vector2 = Vector2(160.0, 380.0)


## Contenu de la fenêtre flottante (la palette, et ce qui l'accompagne).
func palette() -> Control:
	return Control.new()


## Case sous [param screen_position] (écran du jeu), ou null.
func cell_at(_screen_position: Vector2) -> Variant:
	return null


## Pose l'élément choisi (ou retire, [param erase]) ; vrai si les données ont
## changé.
func paint(_cell: Variant, _erase: bool) -> bool:
	return false


## Refait le niveau joué depuis les données (une fois par image au plus).
func rebuild() -> void:
	pass


## Faux : pas de bouton Enregistrer (les changements ne durent que la partie).
func can_save() -> bool:
	return true


## Enregistre les données dans leur fichier.
func save() -> Error:
	return ERR_UNAVAILABLE


## Fichier enregistré (message de la barre).
func save_path() -> String:
	return ""


## Instantané des données (annuler) et sa remise en place.
func snapshot() -> Variant:
	return null


func restore(_state: Variant) -> void:
	pass


## Gestes en plus (molette, touches de la palette...) ; vrai s'il a servi.
func handle_input(_event: InputEvent) -> bool:
	return false


## Repères à l'écran (case survolée, départ...) sur [param canvas], qui couvre
## l'écran ; [param hover] : la case survolée, ou null.
func draw_overlay(_canvas: Control, _hover: Variant) -> void:
	pass


## Ouverture et fermeture du live edit.
func opened(_live_edit: Node) -> void:
	pass


func closed() -> void:
	pass

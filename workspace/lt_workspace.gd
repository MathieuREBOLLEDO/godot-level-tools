@tool
class_name LtWorkspace
extends TabContainer

## Cadre ensemble ↔ pièce, le même dans tous les éditeurs : deux onglets,
## l'ensemble (une carte, une table, un donjon, un niveau de BatEmUp) et la
## pièce (un niveau, un module, une salle, un pattern), titré
## « Pièce · nom » quand une pièce est ouverte.
## L'éditeur ouvre une pièce depuis l'ensemble (double-clic) avec
## show_piece() ; au retour sur l'ensemble, [signal whole_shown] lui dit de se
## relire. Avec [member config_path], l'onglet et la pièce ouverte sont
## retenus d'une session à l'autre (last_piece()).
## Repris des onglets Map | Level de Gringo et Table | Modules de RoguePinball.

## L'onglet de l'ensemble vient d'être affiché (relire les pièces).
signal whole_shown
## L'onglet de la pièce vient d'être affiché.
signal piece_shown

const WHOLE: int = 0
const PIECE: int = 1

## Fichier de user:// où retenir l'onglet et la pièce ("" : rien de retenu).
var config_path: String = ""

var _piece_title: String = ""
var _restored: bool = false


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tab_changed.connect(_on_tab_changed)


## Les deux onglets : [param whole] et [param piece] (des contrôles), leurs
## titres, et la bulle de l'onglet de la pièce (comment en ouvrir une).
func setup(whole: Control, whole_title: String, piece: Control, piece_title: String, piece_tooltip: String = "") -> void:
	add_child(whole)
	add_child(piece)
	_piece_title = piece_title
	set_tab_title(WHOLE, whole_title)
	set_tab_title(PIECE, piece_title)
	set_tab_tooltip(PIECE, piece_tooltip)


## Titre de l'onglet de la pièce : « Level · cave_02 » ("" : « Level »).
## Sans effet tant que l'onglet n'existe pas (pièce ouverte pendant la
## construction : le rappeler après setup()).
func set_piece_name(piece_name: String) -> void:
	if get_tab_count() <= PIECE:
		return
	set_tab_title(PIECE, _piece_title if piece_name == "" else "%s · %s" % [_piece_title, piece_name])


## Passe sur la pièce [param piece_name] ("" : celle déjà ouverte, titre
## gardé) ; [param key] (son chemin) est retenu pour la rouvrir à la session
## suivante.
func show_piece(piece_name: String = "", key: String = "") -> void:
	if piece_name != "":
		set_piece_name(piece_name)
	if key != "" and config_path != "":
		LtFiles.remember(config_path, "workspace", "piece", key)
	current_tab = PIECE


func show_whole() -> void:
	current_tab = WHOLE


func is_piece_shown() -> bool:
	return current_tab == PIECE


## Pièce ouverte à la session précédente ("" : aucune).
func last_piece() -> String:
	return str(LtFiles.recall(config_path, "workspace", "piece", "")) if config_path != "" else ""


## Onglet de la session précédente (à appeler une fois l'éditeur rempli) ;
## l'onglet n'est retenu qu'ensuite (la construction ne l'écrase pas).
func restore_tab() -> void:
	if config_path != "":
		current_tab = clampi(int(LtFiles.recall(config_path, "workspace", "tab", WHOLE)), WHOLE, PIECE)
	_restored = true


func _on_tab_changed(tab: int) -> void:
	if config_path != "" and _restored:
		LtFiles.remember(config_path, "workspace", "tab", tab)
	if tab == WHOLE:
		whole_shown.emit()
	else:
		piece_shown.emit()

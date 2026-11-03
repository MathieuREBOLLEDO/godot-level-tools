@tool
extends RefCounted

## Textes des briques en français ({anglais: français}). Les textes propres
## à un jeu passent par LtText.register().

const TEXTS: Dictionary[String, String] = {
	# Coque
	"unsaved": "non enregistré",
	# Palette
	"Favorites": "Favoris",
	"Favorites (right click to add)": "Favoris (clic droit pour ajouter)",
	"Right click an element of another page to add it here.": "Clic droit sur un élément d'une autre page pour l'ajouter ici.",
	"Right click on the grid: pick an element": "Clic droit sur la grille : prendre un élément",
	"Right click: favorite · drag: reorder": "Clic droit : favori · glisser : ordre",
	"Previous page": "Page précédente",
	"Next page": "Page suivante",
	"Eraser": "Gomme",
	# Problèmes (validateur)
	"%d error(s)": "%d erreur(s)",
	"%d warning(s)": "%d avertissement(s)",
	"No problem": "Aucun problème",
	"Click: show the next one": "Clic : montrer le suivant",
	# Document
	"Opened %s.": "%s ouvert.",
	"Saved %s.": "%s enregistré.",
	"The name is empty.": "Le nom est vide.",
	"%s already exists: choose another name.": "%s existe déjà : choisis un autre nom.",
	"Cannot rename (%s).": "Impossible de renommer (%s).",
	"Cannot save %s (%s).": "Impossible d'enregistrer %s (%s).",
	"Cannot write %s (%s).": "Impossible d'écrire %s (%s).",
	"Cannot open %s.": "Impossible d'ouvrir %s.",
	"Cannot delete %s (%s).": "Impossible de supprimer %s (%s).",
	"%s moved to the trash.": "%s mis à la corbeille.",
	"Renamed %s.": "Renommé en %s.",
	"Rename…": "Renommer…",
	# Bibliothèque
	"search": "rechercher",
	"Sort by": "Trier par",
	"%d shown": "%d affiché(s)",
	"No item yet.": "Aucun élément pour l'instant.",
	"Nothing matches the filters.": "Rien ne correspond aux filtres.",
}

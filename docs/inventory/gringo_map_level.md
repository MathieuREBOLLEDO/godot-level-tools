# Inventaire : ProjetGringo, éditeur de carte (Map) et de niveaux (Level)

Code : `ProjetGringo/game/level/` (map_editor, map_canvas, map_level_card,
level_editor, level_canvas, level_palette, element_settings, element_slot,
ground/, palette_store, level_browser, live_edit, floating_panel,
level_tools_theme), `addons/map_editor/plugin.gd`. Référence de qualité des
briques : rien de ce qui suit ne doit disparaître.

## Ce qui passe sur les briques (phase 2)
| Partie | Brique | Changement pour toi |
|---|---|---|
| Thème (LevelToolsTheme) | LtTheme | aucun (mêmes jetons ; les pastilles du pied deviennent la variante LEGEND, même rendu) ; miniatures et couleurs des cases restent dans le jeu |
| En-têtes Map et Level, pied | LtShell | aucun : mêmes boutons, mêmes places ; pied : messages 4 s puis aide, comme aujourd'hui |
| Bibliothèque de la carte | LtLibrary (liste) | aucun : mêmes filtres (Biome, Usage, Flags), tris (Name, Biome, Newest, Largest), cartes (miniature, badge, estompé, glisser), compte, Import ; pas de Rename (les cartes retiennent les niveaux par chemin) |
| Navigateur (Browse) | LtLibrary (grille) dans la même fenêtre | aucun : filtres, tris (avec Difficulty), double-clic ou Open, Duplicate |
| Annuler du Level | LtHistory (instantané maison, même contenu) | **à décider (Q2)** |
| Essayer (Play) | LtPlaytest (copie du niveau, même non enregistré) | aucun ; en jeu, le chemin GameManager reste |
| Dernière carte rouverte | LtFiles.remember, même fichier user://map_editor.cfg | aucun |
| Textes | LtText.t() | **à décider (Q1)** |

Reste tel quel (propre au jeu, phase 4 pour les canvas) : MapCanvas et ses
gestes, LevelCanvas et ses gestes, LevelPalette (pages, favoris, ordre,
touches), panneau du sol, réglages d'élément, mode chemin, trous noirs,
voisins et flèches, live edit (seulement le thème change).
Fichiers des niveaux et des cartes : logique de LevelData et WorldMap
gardée (un nom changé fait un nouveau fichier, comme aujourd'hui).

## Décisions (validées le 2026-11-03)
Q1 oui (LtText + table française). Q2 partout dans l'onglet sauf champ
texte. Q3 oui. Q4 enregistrer d'abord (un nouveau niveau jamais enregistré :
confirmation avant de le perdre).

## Questions
- **Q1. Textes en français ?** Aujourd'hui tout est en anglais en dur.
  Avec les briques, chaque texte passe par LtText.t() et une table française
  (réglage level_tools/language) ; l'anglais reste par défaut.
- **Q2. Ctrl+Z / Ctrl+Y dans l'onglet Level.** Aujourd'hui dans Godot, ils ne
  marchent que si la souris est sur le niveau. Avec la coque : partout dans
  l'onglet (sauf dans un champ texte), comme BatEmUp. Garder la restriction ?
- **Q3. « ● unsaved » dans l'onglet Level.** Il n'existe que sur la carte
  aujourd'hui. L'ajouter au Level ?
- **Q4. Carte modifiée puis New ou Open.** Aujourd'hui les modifications
  sont perdues sans rien demander. Garder, demander (Save / Discard), ou
  enregistrer d'abord comme BatEmUp ?

---

Le détail ci-dessous est la liste de contrôle (une ligne = une fonction à
retrouver après la migration).

## 1) Onglet Map

### 1.1 En-tête
| Fonction | Geste ou contrôle | Fichier:ligne |
|---|---|---|
| Nom de carte | LineEdit « map name » ; chaque frappe marque « ● unsaved » | map_editor.gd:614-625, 290 |
| Taille d'écran | SpinBox « Screen (m) » 8-80 × 6-45 ; enregistre tout de suite level_settings.tres, message | map_editor.gd:628-634, 324-336 |
| Set start | Actif si le niveau choisi est posé et n'est pas déjà le départ ; écrit start_level tout de suite | map_editor.gd:637, 297-318 |
| Reload | Relit les niveaux, « Levels reloaded. » | map_editor.gd:640-643 |
| Frame | Cadre tous les niveaux (animé) | map_editor.gd:644 |
| New (icône) | Nouvelle carte vide, sans confirmation | map_editor.gd:646, 490-496 |
| Open a map ▾ | Cartes de res://game/level/maps/ ; « No saved map » si vide | map_editor.gd:647, 512-541 |
| Save (principal) | maps/<nom>.tres, mémorise la carte, scan | map_editor.gd:648, 499-510 |

### 1.2 Bibliothèque
| Fonction | Geste ou contrôle | Fichier:ligne |
|---|---|---|
| Import | FileDialog .tres multiples, copie avec _2, _3 ; choisit le premier ; messages | map_editor.gd:680, 463-486 |
| Compteur | « N levels · N shown · N on this map » | map_editor.gd:394 |
| Recherche | « search a level », effacer ; nom de fichier sans casse | map_editor.gd:684-688 |
| Biome / Usage / Flags / Sort by | listes ; Usage : Any, Not on this map, On this map, On another map, On no map ; Flags : Hide flagged (défaut), All, Only DPRC, Only excluded ; Sort : Name, Biome, Newest, Largest | map_editor.gd:692-699, 402-449 |
| États vides | « No level matches the filters. » / « No saved level: click an empty cell… » | map_editor.gd:395-398 |
| Carte : clic | Choisir (un re-clic ne déchoisit pas) | map_level_card.gd:58-61 |
| Carte : glisser | Aperçu miniature 3× ; {map_level_path} | map_level_card.gd:64-72 |
| Carte : survol, sélection | Fondu 6/s, filet sable ; filet accent | map_level_card.gd:51-81 |
| Carte : contenu | Miniature, nom, « W×H · biome · flags », estompée si posée | map_level_card.gd:83-99 |
| Carte : badge, bulle | « on this map » vert, « on <carte> +N » bleu ; chemin et usages | map_level_card.gd:101-121 |

### 1.3 Canvas
| Fonction | Geste | Fichier:ligne |
|---|---|---|
| Zoom | Molette ×1,15 autour du pointeur, 1 à 24 px/m | map_canvas.gd:231-233, 390-397 |
| Choisir / déchoisir | Clic gauche ; re-clic sans glisser ; clic sur case vide | map_canvas.gd:254-266, 376-383 |
| Déplacer | Clic gauche glissé, par case, fantôme | map_canvas.gd:261-263, 582-605 |
| Verrouillé | Ni choisi ni déplacé ; double-clic possible | map_canvas.gd:255-260 |
| Ouvrir | Double-clic → onglet Level | map_canvas.gd:255-257 |
| Nouveau niveau (+) | Clic sur case vide sans niveau choisi | map_canvas.gd:267-268 |
| Poser | Clic sur case vide avec un niveau choisi ; ou glisser depuis la bibliothèque | map_editor.gd:202-214 ; map_canvas.gd:355-372 |
| Retirer | Clic droit ; clic droit glissé sur plusieurs | map_canvas.gd:224-225, 269-278 |
| Verrouiller | Clic molette sans glisser ; cadenas au survol | map_canvas.gd:234-242 |
| Déplacer la vue | Clic molette glissé ; Espace + clic gauche | map_canvas.gd:218-247 |
| Point de retour (trou noir) | Clic sur un niveau ; clic droit annule | map_canvas.gd:251-288 |
| Dessin | Étiquette de survol, ombres, règles, rose des vents, cadrage auto, apparition animée, carte vide guidée, niveau manquant, chevauchement hachuré, « off grid », START, drapeau, pointillés du trou noir, détail à fort zoom | map_canvas.gd:102-724 |

### 1.4 Pied
| Fonction | Geste | Fichier:ligne |
|---|---|---|
| ● N open / dead end(s) / to nowhere | Pastilles vert, rouge, bleu ; clic = suivant (recentre, cercle pulsé) | map_editor.gd:740-755, 264-277 |
| Messages | 4 s, rouge si erreur, puis aide | map_editor.gd:549-553 |
| Aide | « click: select · drag: move · double click: open · right click: remove · middle click: lock · wheel: zoom · middle drag: pan » | map_editor.gd:32 |

### 1.5 Fichiers et liens avec Level
- Dernière carte rouverte (user://map_editor.cfg [map] last, sinon la
  première) ; mémorisée à l'ouverture et à l'enregistrement.
- Relit à l'affichage de l'onglet et au retour sur Map ; la carte montre le
  niveau ouvert avec ses modifications non enregistrées.
- Double-clic → « Level · nom » ; case vide → « Level · new level », posé à
  la case à l'enregistrement (« save the map to keep it ») ; flèche de
  voisin met le titre à jour ; Set destination passe sur Map (clic droit :
  « Destination not changed. ») ; Essayer, enregistrement et import → scan.

## 2) Onglet Level

### 2.1 En-tête
| Fonction | Geste ou contrôle | Fichier:ligne |
|---|---|---|
| Back to level select | Icône, en jeu seulement | level_editor.gd:608-610 |
| Nom | LineEdit « level name » (non annulable) | level_editor.gd:614-621 |
| Biome | BIOMES + biome libre d'un ancien niveau | level_editor.gd:630-634 |
| Difficulty | « Auto ★… » ou 1 à 5 étoiles | level_editor.gd:635-641 |
| Width / Height (m) | 8-80 / 6-45, annulables | level_editor.gd:642-643, 429-433 |
| Sun (°) | -80 à 80 | level_editor.gd:644 |
| Map | « not on a map » / « map <nom> · cell x, y » / « · save to place » | level_editor.gd:645, 541-550 |
| DPRC, EXCL | Cases à cocher | level_editor.gd:649-652 |
| Play | Godot : niveau en mémoire dans user://level_editor_play.tres + main.tscn ; en jeu : GameManager | level_editor.gd:656, 392-398 |
| New, Browse, Duplicate (copie en mémoire), Save (principal) | Icônes et bouton | level_editor.gd:658-661 |

### 2.2 Palette
Couches Back / Game / Front (sur le décor : gomme et décor seulement) ;
gomme en haut ; pages ‹ › en boucle (Favorites, Scenery, Gameplay,
Platforms) ; clic = outil ; clic droit = favori ; glisser = réordonner
(user://level_palette.cfg) ; touches 1 à 9 puis 0 (sans Ctrl, sans
répétition) ; numéro sur la case ; bulles (aide, « Wheel on the level:
rotate », « Right click: favorite · drag: reorder ») ; libellé d'outil
(« Nom, up/right… », « set · tuile ») ; grille 3 × 7 minimum.
(level_palette.gd, element_slot.gd, palette_store.gd)

### 2.3 Canvas
Clic gauche pose (un pas d'annulation), glisser peint ; clic droit =
pipette (élément, rotation, sol, réglages ; trou noir : ses réglages) ;
molette = quart de tour si tournable ; survol « x · y » et contour ;
fantôme 55 % ; flèches de voisins (clic : ouvrir, bulle « Open <nom> ») ;
voisins ombrés 3 m ; passages vert / rouge / bleu ; pointillés des trous
noirs ; chemins ; couches estompées ; grille 1 m, 5 m numérotée ; Gringo au
départ ; niveau mis à l'échelle de son cadre. (level_canvas.gd)

### 2.4 Réglages d'élément, mode chemin, sol
- Trou noir : état et Set destination ; Delay (crumble), Period et Phase
  (rythmée), Speed et Loop (mobile), Edit path, Clear ; appliqués aux
  éléments posés ensuite ; repris par la pipette. (element_settings.gd)
- Edit path : clic sur une plateforme mobile, puis ses points ; messages ;
  « Path mode off. » (level_editor.gd:242-285)
- Sol : tiroir à l'outil Ground, Auto, sets Red / Yellow / Blue / Green,
  27 tuiles forcées, molette, résumé, pipette. (ground/)

### 2.5 Annuler
Ctrl+Z, Ctrl+Y ou Ctrl+Maj+Z ; « Undo. » / « Nothing to undo. » ; dans
Godot seulement souris sur le niveau ; 100 pas ; couvre tuiles, décors,
tuiles forcées, rotations, réglages, départ, taille ; pas le nom, biome,
difficulté, soleil, drapeaux ; pile vidée à l'ouverture, au nouveau, à la
copie. (level_editor.gd:115-235)

### 2.6 Carte, voisins, pied
Carte ouverte d'abord (même non enregistrée) ; aperçu de pose d'un nouveau
niveau ; voisins recalculés à chaque pose ; ouvrir un voisin refusé tant
qu'un nouveau niveau n'est pas enregistré, enregistre d'abord sinon ;
pied « CELL x · y », messages 4 s, aide « left click: place · drag: paint ·
right click: pick · ctrl+z: undo · wheel: rotate · 1-9, 0: elements ».

## 3) Navigateur (Browse)
Fenêtre « Levels » 760 × 540 ; recherche ; Biome ; Flags ; Sort (Name,
Biome, Difficulty, Newest) ; miniatures en grille de 230 px, « nom / biome ·
étoiles · W×H · flags », bulle = chemin ; double-clic ou Open ; Duplicate
(copie enregistrée) ; « N level(s) ». (level_browser.gd)

## 4) Live edit (en jeu)
Pause ; palette flottante « ELEMENTS » (déplacer par le titre,
redimensionner par le coin, 140 × 180 minimum) ; clic gauche pose, clic
droit efface, molette tourne, 1 à 9 / 0 ; niveau refait à chaque image en
peinture, Gringo garde son état ; Resume ou Échap ; Save ; pas de pipette
ni d'annulation. (live_edit.gd, floating_panel.gd)

## 5) Fichiers
user://map_editor.cfg, user://level_palette.cfg,
user://level_editor_play.tres, user://levels/, res://game/level/levels/,
res://game/level/maps/, res://game/level/level_settings.tres,
res://design_tokens.cfg.

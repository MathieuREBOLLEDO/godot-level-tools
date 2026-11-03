# Phase 4b : gestes des canvas, avant / après

Décisions (2026-11-03) : molette = zoom, Maj + molette et R tournent ;
clic droit = pipette, la gomme en tête de palette vide ; DungeonTactics
d'abord. Chaque ligne a été vérifiée par un script qui envoie les clics et
les touches au canvas (Pinball : dans l'éditeur Godot).

## Gringo, onglet Level
| Fonction | Avant | Après |
|---|---|---|
| Poser, peindre | clic gauche (glisser) | inchangé |
| Pipette | clic droit | inchangé |
| Tourner pics et cactus | molette | **Maj + molette, R, Maj + R** |
| Zoom | aucun (niveau dans le cadre) | **molette** au curseur |
| Déplacer la vue | aucun | **bouton du milieu, Espace + clic** |
| Tout le niveau | toujours | à l'ouverture, puis **F** |
| Éléments 1 à 9, 0 | souris sur le niveau | inchangé |
| Flèches des voisins, trou noir, chemins | clic | inchangé (suivent le zoom) |
| Live edit (en jeu) | molette = tourner | inchangé |

## Pinball, onglet Modules
| Fonction | Avant | Après |
|---|---|---|
| Poser, peindre, pipette | clic gauche, clic droit | inchangé |
| Zoom, vue | molette, bouton du milieu | inchangé, plus **Espace + clic** |
| Tourner | R / Maj + R | inchangé, plus **Maj + molette** |
| Miroir, cadrer | M, F | inchangé |
| Outils | liste, touches 1 à 9 | **palette commune** : cases, 1 à 9 puis **0**, **favoris**, **ordre** retenu |
| Orientation de l'outil | sous la liste | sous la palette |

## DungeonTactics, Rooms
| Fonction | Avant | Après |
|---|---|---|
| Peindre | clic gauche | inchangé |
| Vider une case (case libre) | clic droit | **gomme** en tête de palette (ou pinceau « Libre ») |
| Pipette | aucune | **clic droit** (case libre : la gomme ; hauteur reprise en mode hauteur) |
| Pinceaux | grille de 13 boutons à lettre | **palette commune** : 3 pages (Terrain, Objets, Ennemis), touches 1 à 9, favoris, ordre |
| Zoom, vue, cadrer | aucun (pièce dans le cadre) | **molette, bouton du milieu, Espace + clic, F** |
| Hauteurs | case « Peindre » + valeur | inchangé (la gomme remet 1) |

## DungeonTactics, Map painter
| Fonction | Avant | Après |
|---|---|---|
| Zoom, vue | molette, bouton du milieu, Espace + clic | inchangé |
| Pipette | Alt + clic | inchangé, plus **clic droit** |
| Toute la carte | bouton du pied | inchangé, plus **F** |

## Pas touché
Pinball Table (on y déplace des éléments : clic droit glissé = vue), carte de
Gringo (verrou au clic du milieu, retrait au clic droit), palette de Gringo
(déjà le modèle de LtPalette ; elle garde son code, avec ses calques et le
tiroir du sol).

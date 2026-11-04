# Design des éditeurs

Même direction que les autres outils (debug menu, feel, QA) : comme
l'éditeur Godot, pour que les éditeurs des jeux s'y fondent.

## Jetons
- Lus dans `res://design_tokens.cfg` du jeu (sections profile, colors,
  fonts, sizes) ; une valeur absente garde le défaut de theme/lt_theme.gd.
- `[profile] follow_editor=true` : dans l'éditeur Godot, fond, panneaux,
  boutons, texte et accent viennent du thème de l'éditeur ouvert ; en jeu,
  les valeurs du fichier.
- Couleurs : INK (fond) < INK_PANEL (bandeaux) < INK_RAISED (boutons,
  cartes), INK_LINE (filets) ; SAND (texte), SAND_DIM (secondaire) ;
  ACCENT, seul accent, réservé à ce qu'on manipule (sélection, focus, bouton
  principal) ; GOOD, BAD, INFO : sens seulement (valide, problème,
  information), jamais en décoration.
- Polices : interface « @engine » (celle de l'éditeur) ou SystemFont, version
  étroite pour titres et surtitres ; chasse fixe (MONO) pour valeurs,
  tailles, coordonnées.
- Un jeu sans design_tokens.cfg prend les défauts : pour garder son
  apparence actuelle, il écrit les siennes dans ce fichier.

## Écran type (LtShell)
- En-tête : surtitre (KICKER), nom du document (TITLE), « non enregistré »,
  groupes de boutons séparés par un filet, un seul bouton principal
  (PRIMARY), à droite.
- Corps : bibliothèque | canvas ou aperçu | réglages ; colonnes
  redimensionnables, une colonne vide est cachée.
- Pied : légende (LEGEND, couleur du sens) à gauche ; message à droite
  (4 s), puis l'aide des gestes.
- État vide : une phrase qui dit quoi faire, et le bouton qui le fait.
- Explications en bulle (tooltip) plutôt qu'en texte dans l'écran.

## Disposition commune (référence : éditeur de niveaux de Gringo)
Tous les écrans rangent leur en-tête et leur pied dans le même ordre :
- En-tête, à gauche : Retour (icône, s'il y a un écran parent), surtitre et
  nom, « non enregistré », puis les réglages du document s'il y en a.
- En-tête, à droite, de gauche à droite, un groupe par filet :
  1. outils de vue et navigation (Frame, Reload, Rooms…) : texte ;
  2. Annuler, Refaire : icône seule (LtIcons.UNDO, REDO) ;
  3. Essayer (et ce qui l'accompagne, Assign) : icône + texte, LtIcons.PLAY ;
  4. fichiers : Nouveau, Ouvrir, Dupliquer, Enregistrer sous, Supprimer en
     icône seule avec une bulle (LtIcons), puis Enregistrer, le seul bouton
     principal, icône + texte, tout à droite.
- Pied : à gauche les mesures et la légende du canvas, à droite le message
  puis l'aide des gestes (set_help(), jamais dans une colonne ou sous le
  canvas), et le compteur des problèmes.
- Bouton en icône seule : `LtTheme.button(groupe, "", bulle, action, icône)`,
  la bulle dit l'action et son raccourci.

## Calques (LtLayers)
- Réglage du projet level_tools/layers : {id, name, collides, front}, dans
  l'ordre du dessin ; « game » toujours là. Barre des calques : un bouton par
  calque, sur plusieurs lignes s'il le faut ; le calque édité net, les autres
  estompés (derrière sans collision : teinté), bulle : derrière ou devant,
  collision ou non.

## Live edit (LtLiveEdit)
Même cadre dans tous les jeux : jeu en pause, fenêtre flottante de la
palette en haut à gauche (déplacer par le titre, coin pour la taille),
barre en bas au centre (aide qui passe à la ligne sur un écran étroit,
Annuler / Refaire, Reprendre, Enregistrer en bouton principal ; sans
Enregistrer, Reprendre l'est). Clic gauche pose, clic droit retire, Échap
reprend ; repères du jeu (case survolée) en couleur ACCENT.

## Animations
Rares : survol des cartes de la bibliothèque (fondu), retour d'une action
dans le pied. Rien qui bouge sans raison.

## Gestes communs des canvas (LtView, LtPalette)
| Geste | Effet |
|---|---|
| Clic gauche (glisser) | poser, peindre |
| Clic droit | pipette : l'élément de la case devient l'outil |
| Molette | zoom centré sur le curseur |
| Maj + molette, R, Maj + R | tourner l'élément choisi |
| Bouton du milieu glissé, Espace + clic | déplacer la vue |
| F | tout le contenu dans la vue (elle suit ensuite la taille du canvas) |
| 1 à 9 puis 0 | cases de la page affichée de la palette |
| Clic droit sur une case de la palette | favori ; glisser une case : ordre |

| M | miroir de l'élément choisi (côté gauche / droit) |
| Ctrl+D, Suppr | dupliquer, retirer ce qui est choisi (vague, couche, niveau sur la carte, objet de la table) |
| Maj + clic gauche glissé | zone (LtCellSelection) ; Ctrl+D la copie à sa droite, Suppr la vide, Échap l'enlève |
| Mode chemin : clic gauche, clic droit | un point de plus, retirer le dernier (LtPathEditor ; points numérotés) |
| Clic du milieu sans glisser | verrou (niveau sur la carte, objet de la table, vague sur la frise) : ni déplacé, ni retiré |

Pour effacer : la gomme, en tête de palette. À l'ouverture, le contenu
tient dans la vue. Les touches passent au canvas quand la souris est dessus
(dans l'éditeur Godot, elles servent ailleurs). Exceptions : l'onglet Table
de Pinball (on y déplace des éléments, clic droit glissé = vue) et le live
edit de Gringo (molette = tourner, clic droit = effacer).

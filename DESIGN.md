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

## Animations
Rares : survol des cartes de la bibliothèque (fondu), retour d'une action
dans le pied. Rien qui bouge sans raison.

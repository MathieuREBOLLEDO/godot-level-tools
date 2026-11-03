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

## Animations
Rares : survol des cartes de la bibliothèque (fondu), retour d'une action
dans le pied. Rien qui bouge sans raison.

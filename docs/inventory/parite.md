# Phase 5 : parité des fonctions entre les éditeurs

Décisions (2026-11-03) : chaque fonction d'un éditeur existe dans tous les
autres, sans exception ; Pinball règle ses modules et éléments dans une
colonne de l'éditeur, plus dans l'Inspecteur de Godot ; DungeonTactics passe
en onglets « Dungeons | Rooms · nom » ; les briques communes d'abord (dans
level_tools, Gringo passe dessus sans rien perdre), puis tous les jeux.

État relevé dans le code le 2026-11-03 (après les phases 1 à 4).

## Éditeurs (colonnes)
| Code | Éditeur | Rôle |
|---|---|---|
| GM | Gringo, Map | ensemble |
| GL | Gringo, Level | pièce |
| BL | BatEmUp, Levels | ensemble |
| BP | BatEmUp, Bullet Patterns | pièce (un niveau utilise des patterns) |
| PT | Pinball, Table | ensemble |
| PM | Pinball, Modules | pièce |
| DD | DungeonTactics, Dungeons | ensemble |
| DR | DungeonTactics, Rooms | pièce |
| DM | DungeonTactics, Map painter | seul (une image) |

Légende : ✔ l'a déjà par la brique commune · ~ l'a avec son propre code
(passera sur la brique) · ➜ le reçoit · ? à trancher (question en bas).

## A. Cadre ensemble ↔ pièce (brique nouvelle : LtWorkspace)
| Fonction | GM | GL | BL | BP | PT | PM | DD | DR | DM |
|---|---|---|---|---|---|---|---|---|---|
| Onglets « Ensemble \| Pièce · nom » dans un même écran | ~ | ~ | ➜ | ➜ | ~ | ~ | ➜ | ➜ | ? Q1 |
| Ouvrir une pièce depuis l'ensemble (double-clic) | ~ | | ➜ vague → son pattern | | ~ module peint | | ➜ salle de l'aperçu | | |
| Pièce neuve depuis l'ensemble, posée à l'enregistrement | ~ « + » case vide | | ➜ « New pattern » d'une vague | | ~ « New module » | | ➜ | | |
| L'ensemble montre la pièce ouverte, même non enregistrée | ~ | | ➜ | | ~ | | ➜ régénère | | |
| Pièce modifiée : enregistrée avant de revenir | ~ | | ➜ | | ~ | | ~ (Back) | | |
| Onglet et pièce ouverts retenus | ~ | | ➜ | | ~ | | ➜ | | |

## B. Bibliothèque (LtLibrary, complétée)
| Fonction | GM | GL | BL | BP | PT | PM | DD | DR | DM |
|---|---|---|---|---|---|---|---|---|---|
| Bibliothèque en cartes (au lieu d'une liste ou d'un dialogue) | ✔ | ✔ Browse | ✔ | ✔ | ➜ (palette maison) | ➜ (dialogue Ouvrir) | ✔ | ✔ | ? Q1 |
| Recherche, compteur, états vides | ✔ | ✔ | ✔ | ✔ | ➜ | ➜ | ✔ | ✔ | ? |
| Miniature de chaque pièce | ✔ | ✔ | ➜ trajets des vagues | ➜ image figée des balles | ➜ dessin du module | ➜ | ➜ aperçu du donjon | ➜ grille de la salle | ? |
| Filtres propres au jeu | ✔ biome, usage | ✔ biome | ➜ orientation | ➜ nb de couches | ➜ taille, peint/scène | ➜ | ➜ genre | ➜ rôle, genre | ? |
| Tri (Name, Newest, Largest + propres au jeu) | ✔ | ✔ | ➜ | ➜ | ➜ | ➜ | ➜ | ➜ | ? |
| Badge « on this map / on X +N » et filtre d'usage | ✔ | | ➜ « in N levels » sur BP | ➜ | ➜ « on this table » | ➜ | ➜ « in N dungeons » sur DR | ➜ | |
| Avertir avant de supprimer une pièce utilisée | ➜ | ➜ | ➜ | ~ (texte fixe) | ➜ | ➜ | ➜ | ➜ | |
| Glisser une carte sur l'ensemble, avec fantôme | ✔ | | ➜ pattern sur une vague | | ~ (aperçu = nom) | | ? Q2 | | |
| Renommer depuis la carte (clic droit) | ➜ Q3 | ➜ Q3 | ✔ | ✔ | ➜ | ➜ | ✔ | ✔ | |
| Importer depuis un autre dossier | ✔ | ➜ | ➜ | ➜ | ➜ | ➜ | ➜ | ➜ | ? |
| Grille de grandes cartes (fenêtre Browse) | ➜ | ✔ | ➜ | ➜ | ➜ | ➜ | ➜ | ➜ | ? |

## C. Fichiers (LtDocument)
| Fonction | GM | GL | BL | BP | PT | PM | DD | DR | DM |
|---|---|---|---|---|---|---|---|---|---|
| Nouveau | ~ | ~ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ➜ Q1 |
| Ouvrir (menu ou dialogue) | ~ menu | ~ Browse | ✔ bibl. | ✔ bibl. | ✔ dialogue | ✔ dialogue | ✔ bibl. | ✔ bibl. | ➜ Q1 |
| Dupliquer | ➜ | ~ | ✔ | ✔ | ➜ | ➜ | ➜ | ➜ | ➜ |
| Enregistrer sous | ➜ | ➜ | ➜ | ➜ | ✔ | ✔ | ➜ | ➜ | ➜ |
| Supprimer (corbeille, confirmation) | ➜ | ➜ | ✔ | ✔ | ➜ | ➜ | ✔ | ✔ | ➜ |
| Dernier document rouvert | ~ | ➜ | ✔ | ✔ | ~ | ➜ | ➜ | ➜ | ✔ (fixe) |
| Ctrl+S de l'éditeur Godot | ➜ | ➜ | ✔ | ✔ | ➜ | ➜ | ✔ | ✔ | ✔ |

## D. Document : réglages, marques, contrôle (briques nouvelles : LtSettings, LtFlags)
| Fonction | GM | GL | BL | BP | PT | PM | DD | DR | DM |
|---|---|---|---|---|---|---|---|---|---|
| Colonne de réglages du document (nom, taille, propres au jeu) | ~ en-tête | ~ en-tête | ✔ | ✔ | ➜ (Inspecteur) | ➜ (Inspecteur) | ✔ | ✔ | ~ colonne maison |
| Taille éditable dans l'éditeur | ~ écran | ~ largeur, hauteur | ~ scroll | — Q4 | ➜ | ➜ | ✔ | ✔ | ➜ |
| Réglages de l'élément choisi dans l'éditeur | | ~ element_settings | ~ panneau de vague | ~ cartes de couche | ➜ (Inspecteur) | ➜ | | | |
| Flags DPRC / EXCL réglés sur le document | ➜ | ~ | ➜ | ➜ | ➜ | ➜ | ➜ | ➜ | ➜ |
| Filtre « Hide flagged » de la bibliothèque, respecté par le jeu | ~ | ~ | ➜ | ➜ | ➜ | ➜ | ➜ | ➜ | ? |
| Validateur (compteur, clic = problème suivant) | ✔ | ✔ | ✔ | ➜ | ✔ | ➜ | ➜ (problème de génération) | ✔ | ➜ |
| Annuler / refaire (boutons, Ctrl+Z) | ➜ | ✔ | ✔ | ✔ | ~ éditeur Godot | ~ éditeur Godot | ✔ | ✔ | ✔ |
| Essayer en jeu | ➜ depuis le niveau choisi | ✔ | ✔ | ✔ + Assign | ✔ | ➜ dans une table d'essai | ➜ | ➜ la salle seule | ➜ au point choisi |

## E. Canvas
| Fonction | GM | GL | BL | BP | PT | PM | DD | DR | DM |
|---|---|---|---|---|---|---|---|---|---|
| Vue commune (molette zoom, milieu / Espace glissé, F) | ~ | ✔ | ➜ aperçu | ➜ aperçu | ✔ | ✔ | ➜ aperçu | ✔ | ~ |
| Palette commune (pages, favoris, ordre, 1 à 9, gomme) | | ~ (le modèle) | ? Q5 | ? Q5 | ➜ éléments | ✔ | | ✔ | ~ couleurs |
| Pipette au clic droit | | ✔ | | | ➜ | ✔ | | ✔ | ✔ |
| Tourner R / Maj+R / Maj+molette | | ✔ | | | ✔ | ✔ | | — Q6 | |
| Miroir M | | ➜ Q6 | | | ✔ | ✔ | | — Q6 | |
| Sélection : Ctrl+D dupliquer, Suppr effacer | ➜ | ➜ zone | ➜ vague | ➜ couche | ✔ | ➜ zone | | ➜ zone | |
| Verrou (clic du milieu, cadenas) | ✔ | | ➜ vague | ➜ couche | ➜ | | | | |
| Calques (Back / Game / Front ; Terrain / Lieux) | | ~ | | | ➜ Q7 | ➜ Q7 | | ➜ Q7 | ~ |
| Voisins ombrés et flèches pour les ouvrir | | ~ | | | | ➜ modules voisins sur la table | | ➜ salles voisines dans le donjon | |
| Liens dessinés (trou noir ; séries de cibles) | ~ | ~ | | | ~ | | | | |
| Mode chemin (points d'un trajet) | | ~ plateformes | ~ Edit path | | ➜ Q8 | | | | |
| Repère du joueur (START, groupe) | ~ | ~ | | | ➜ lancement | | ~ P | ~ P | ~ groupe |
| Édition en jeu (live edit, pause et palette flottante) | | ~ | ➜ Q9 | ➜ Q9 | ➜ Q9 | | ➜ Q9 | | ➜ Q9 |

## Propre au contenu : reste dans le jeu (à confirmer, Q10)
Simulation et frise des vagues (BatEmUp), génération par graine et
régénération (DungeonTactics Dungeons), hauteurs des salles, peinture sur
PNG avec force et bord doux (Map painter), sol automatique et tuiles forcées
(Gringo), murs à deux bouts (Pinball). Leur cadre (vue, palette, réglages,
annuler) vient des briques ; leur logique reste dans le jeu.

## Questions
- **Q1. Map painter de DungeonTactics.** C'est une seule image fixe
  (world.png). Pour lui donner bibliothèque, Nouveau, Ouvrir et onglets, il
  faut accepter plusieurs cartes. Le fait-on, ou il reçoit tout le reste
  (Flags, validateur, Essayer, Dupliquer) sans bibliothèque ?
- **Q2. Glisser une salle dans un donjon.** Le donjon est généré par graine.
  Proposition : glisser une salle sur l'aperçu l'impose dans ce donjon (une
  pièce forcée que la génération garde). Nouveau pour le générateur : oui
  ou non ?
- **Q3. Renommer chez Gringo.** Les cartes retiennent les niveaux par
  chemin, c'est pour ça qu'il manque. Proposition : renommer met aussi à jour
  toutes les cartes et le niveau de départ.
- **Q4. Taille d'un pattern.** Un pattern n'a pas de taille. Son équivalent
  serait la durée du cycle (déjà dans la colonne). D'accord pour le compter
  comme « taille » ?
- **Q5. Palette dans BatEmUp.** Rien ne s'y peint. Proposition : la palette
  sert de catalogue des préréglages (vagues pour Levels, couches Ring / Fan /
  Single pour Patterns) : clic = ajouter, favoris, ordre.
- **Q6. Tourner et miroir.** Les cases de DR n'ont pas d'orientation : rien à
  tourner. Gringo : un miroir M sur les éléments à côté (pics, cactus) ?
- **Q7. Calques ailleurs.** Pinball et Rooms n'ont qu'une couche. Ajouter des
  calques veut dire changer le format des fichiers. On le fait ?
- **Q8. Chemins dans Pinball.** Pas d'objet mobile aujourd'hui : le mode
  chemin ne servirait à rien tant qu'il n'y en a pas. Le garder pour plus tard ?
- **Q9. Édition en jeu partout.** C'est le plus gros morceau (pause, palette
  flottante, sauvegarde depuis le jeu, dans chaque jeu). En dernier, après le
  reste ?
- **Q10.** D'accord pour laisser dans les jeux la liste « propre au
  contenu » ci-dessus ?

## Réponses (2026-11-04)
Q1 à Q6, Q9, Q10 : oui (propositions retenues).
Q7 : oui, calques partout, nombre libre (jusqu'à 10 ou plus), réglé par
projet dans les settings ; usages : détails, parallaxe. Étape 5.
Q8 : A, le mode chemin devient une brique commune (Gringo et BatEmUp
dessus) ; Pinball le prendra avec son premier objet mobile.

## Fait à l'étape 1 (2026-11-04)
Gringo : A (onglets LtWorkspace, onglet et niveau rouverts), B (usages,
import et Flags par la brique, grille dans la carte, Renommer dans la carte
et Browse), C (Dupliquer et Supprimer la carte, Supprimer le niveau,
Ctrl+S de Godot ; Enregistrer sous = changer le nom puis Enregistrer, le
nom fait le fichier), D (Annuler / Refaire sur la carte, Essayer depuis la
carte, marques par LtFlags). Les autres colonnes : étapes 2 à 4.

## Fait à l'étape 2, Pinball (2026-11-04)
PT : A (LtWorkspace), B (bibliothèque complète, Rename des modules peints ;
une scène de module se renomme dans le système de fichiers de Godot), C
(Dupliquer, Supprimer, Ctrl+S ; Dernier ouvert déjà là), D (colonne de
réglages, marques sur la zone). PM : A, B ~ (menu Open des modules peints ;
la bibliothèque est dans Table), C (Dupliquer, Supprimer, Ctrl+S, dernier
module rouvert), D (colonne de réglages, taille, marques, Test dans une zone
d'essai). Annuler reste celui de l'éditeur Godot (Ctrl+Z). Les marques ne
vont pas sur les scènes de module (.tscn) : seulement zones et modules
peints. Reste pour l'étape 5 : palette commune des éléments de la table,
pipette au clic droit sur la table (le clic droit glissé y déplace la vue).

## Fait à l'étape 3a, DungeonTactics Dungeons | Rooms (2026-11-04)
DD et DR : A (onglets, double-clic sur une pièce de l'aperçu, salle
retenue ; le donjon se régénère au retour), B (miniatures, grille, usages,
Flags ; Rename des salles en gardant le numéro), C (Dupliquer, dernier
ouvert), D (marques respectées par le jeu, Play, validateur des donjons).
Les donjons enregistrés avant cette étape ne notent pas leurs salles : à
régénérer (un réglage, Reroll) puis enregistrer pour les badges et le
double-clic. Reste : le Map painter (3b), la colonne LtSettings (DT garde
ses colonnes, déjà à droite).

## Fait à l'étape 3b, Map painter (2026-11-04)
DM : B (bibliothèque des cartes, miniature, usage « in game », Flags, tri,
grille, Rename ; pas d'Import : ce sont des PNG, ils se copient dans le
dossier), C (Nouvelle, Dupliquer, Supprimer, dernière ouverte, nom renommé
à l'enregistrement), D (marques, validateur de taille, Play, carte du jeu
choisie ici). A : pas d'onglets, le Map painter n'a pas de pièce.

## Fait à l'étape 4, BatEmUp (2026-11-04)
BL et BP : A (onglets Levels | Patterns dans un même écran, vague → son
pattern, pattern neuf depuis une vague, onglet retenu ; les deux éditeurs
rouvraient déjà leur dernier document), B (miniatures, grille, import,
filtres, usages, Flags, tri ; avertir avant de supprimer un pattern
utilisé), D (marques, validateur des patterns ; taille d'un pattern = durée
du cycle, Q4). C : Enregistrer sous = changer le nom puis Enregistrer (le
nom fait le fichier) ou Dupliquer. Glisser un pattern sur une vague : pas
fait (le choix se fait dans le panneau de la vague) ; reste pour l'étape 5
avec la palette des préréglages (Q5), le verrou et Ctrl+D.

## Ordre proposé
1. Briques, avec leurs tests, et Gringo dessus sans perte : LtWorkspace
   (A), LtFlags et la bibliothèque complétée (B), LtSettings (D), Dupliquer,
   Supprimer, Enregistrer sous, Ctrl+S communs (C), annuler sur la carte de
   Gringo.
2. Pinball : bibliothèque des modules, colonne de réglages, Flags,
   Essayer un module, palette des éléments.
3. DungeonTactics : onglets Dungeons | Rooms, miniatures, Flags, Essayer,
   validateur des donjons.
4. BatEmUp : onglets Levels | Patterns, miniatures, usages, Flags.
5. Canvas (E) selon les réponses, puis l'édition en jeu (Q9).
Chaque jeu : liste avant / après pour toi, vérifiée sur capture.

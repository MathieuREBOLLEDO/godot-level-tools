# Features

Registre des fonctionnalités de l'addon : une fiche par fonction, avec son
but, ses gestes, ses interactions et les documents qui la décrivent. Lu par
Project Hub (onglet Features), au même format que le mecaniques.md d'un jeu.
Tenu à jour par Claude quand il crée, change ou coupe une fonction.

Format d'une fiche (garder les noms de champs, une ligne chacun) :
- `type` : famille de la fonction (cadre, fichiers, document, canvas, jeu,
  propre au jeu).
- `parent` : titre de la fiche qui la regroupe (facultatif).
- `statut` : à définir, à faire, en cours, à retravailler, fait ou coupé.
- `but` : à quoi elle sert, en une phrase.
- `commandes` : gestes ou raccourcis, « ; » entre deux, « : » avant ce
  qu'ils font.
- `relations` : une sous-ligne par interaction, « ce qu'on touche → effet ».
- `liens` : autres fiches liées, par leur titre.
- `docs` : fichier.md › section ; « ; » entre deux.
- `tests` : noms des fichiers de test, « ; » entre deux (facultatif).
- `projets` : projets pour lesquels la fonction est propre, « ; » entre
  deux. Sans ce champ, la brique est commune à tous les éditeurs.

## Coque d'éditeur
- type : cadre
- statut : fait
- but : le même écran pour tous les éditeurs : en-tête, trois colonnes redimensionnables, pied, état vide.
- relations :
  - Groupes de boutons → serrés, un seul bouton principal par écran
  - Pied → messages, aide des gestes, légende
  - Document lié → « non enregistré » et Ctrl+S
- docs : docs/guide.md › Squelette ; docs/guide.md › En-tête ; DESIGN.md
- tests : test_ui

## Ensemble et pièce
- type : cadre
- statut : fait
- but : deux onglets dans un même écran, l'ensemble (carte, table, donjon) et la pièce ouverte (niveau, module, salle).
- relations :
  - Double-clic sur une pièce de l'ensemble → elle s'ouvre dans l'onglet pièce
  - Retour sur l'ensemble → la pièce modifiée est relue
  - Relance → onglet et dernière pièce retrouvés
- docs : docs/guide.md › Ensemble ↔ pièce (onglets)
- tests : test_workspace_flags

## Thème et textes
- type : cadre
- statut : fait
- but : jetons de design_tokens.cfg et textes traduits, les mêmes dans tous les éditeurs.
- relations :
  - LtText.register → textes du jeu ajoutés à la traduction
  - Réglage level_tools/language → langue de l'interface
- docs : docs/guide.md › Textes ; DESIGN.md
- tests : test_text_theme

## Fichiers du document
- type : fichiers
- statut : fait
- but : Nouveau, Ouvrir, Dupliquer, Supprimer, Enregistrer et Renommer, partout pareils.
- commandes : Ctrl+S : enregistrer
- relations :
  - Supprimer → corbeille, confirmation qui dit où le document sert
  - Lancement → dernier document rouvert
- docs : docs/guide.md › En-tête
- tests : test_documents

## Bibliothèque
- type : fichiers
- statut : fait
- but : retrouver un document en cartes, avec recherche, filtres, tris et miniatures.
- relations :
  - Bouton liste / grille → petites cartes ou grandes miniatures
  - Badge d'usage → « on this map », « on X +N », filtre d'usage
  - Document utilisé ailleurs → averti avant de le supprimer
  - Clic droit sur une carte → Rename
  - Import → copie depuis un autre dossier
- liens : Ensemble et pièce
- docs : docs/guide.md › Bibliothèque ; docs/guide.md › Renommer depuis la bibliothèque
- tests : test_documents

## Annuler et refaire
- type : document
- statut : fait
- but : revenir en arrière dans tout éditeur, 100 pas, petites modifications regroupées.
- commandes : Ctrl+Z : annuler ; Ctrl+Y : refaire
- relations :
  - Curseur glissé → un seul pas pour toute la série
- docs : docs/guide.md › Annuler
- tests : test_history

## Colonne de réglages
- type : document
- statut : fait
- but : régler le document et l'élément choisi dans l'éditeur, à la place de l'Inspecteur de Godot.
- relations :
  - Champ de valeur → curseur et nombre bornés par @export_range
- docs : docs/guide.md › Réglages
- tests : test_ui

## Marques DPRC et EXCL
- type : document
- parent : Colonne de réglages
- statut : fait
- but : marquer un document obsolète ou exclu du jeu, sans le supprimer.
- relations :
  - Filtre « Hide flagged » → cache les documents marqués dans la bibliothèque
  - LtFlags.is_excluded → le jeu ignore ce qui est exclu
- docs : docs/guide.md › Marques (DPRC, EXCL)
- tests : test_workspace_flags

## Validateur
- type : document
- statut : fait
- but : compter les erreurs et avertissements du document et montrer chacun.
- relations :
  - Pied → « 1 error(s) · 2 warning(s) », ou « No problem » en vert
  - Clic sur le compteur → problème suivant cadré dans le canvas
  - Règles → écrites dans le jeu (level_rules.gd), aussi lancées par ses tests
- docs : docs/guide.md › Vérifier (problèmes)
- tests : test_validator

## Vue du canvas
- type : canvas
- statut : fait
- but : les mêmes gestes de vue dans tous les canvas sur grille.
- commandes : molette : zoom vers le curseur ; clic du milieu glissé ou Espace + clic glissé : déplacer ; F : tout cadrer ; R / Maj+R ou Maj + molette : tourner l'élément choisi
- docs : docs/guide.md › Canvas sur grille (vue et palette)
- tests : test_view_palette

## Palette
- type : canvas
- statut : fait
- but : choisir l'élément à peindre parmi des pages, avec favoris et ordre retenus.
- commandes : 1 à 9 puis 0 : cases de la page ; ‹ › : page suivante ; clic droit sur une case : favori ; glisser une case : ordre ; crayon : fenêtre Edit palette
- relations :
  - Première page → les favoris
  - store_path → ordre et favoris gardés d'une session à l'autre
  - Edit palette (LtPaletteEditor) → pages créées, renommées, retirées ; page de chaque élément ; image qui remplace son dessin
  - Disposition (LtPaletteLayout) → enregistrée dans le projet (res://), commitée, la même pour l'éditeur et le jeu
  - Gringo → palette de Level et live edit ; image en jeu : roche, sable, métal, cassable, porte, plateformes (les autres éléments : éditeur seulement)
  - Gringo, sets du sol → une image de 9 × 3 tuiles par set remplace son bloc de ground_tiles.png (éditeur et jeu)
- liens : Gomme, Pipette
- docs : docs/guide.md › Canvas sur grille (vue et palette)
- tests : test_view_palette

## Gomme
- type : canvas
- parent : Palette
- statut : fait
- but : effacer des cases du canvas, avec la même gomme en haut de chaque palette.
- relations :
  - Gomme choisie → item_selected("") : le canvas efface au lieu de peindre
  - Édition en jeu → clic droit retire l'élément sous la souris
- docs : docs/guide.md › Canvas sur grille (vue et palette)
- tests : test_view_palette

## Pipette
- type : canvas
- parent : Palette
- statut : fait
- but : reprendre dans la palette l'élément déjà posé sous la souris.
- commandes : clic droit sur le canvas : choisir l'élément de la case
- docs : docs/guide.md › Canvas sur grille (vue et palette)

## Sélection de zone
- type : canvas
- statut : fait
- but : choisir un rectangle de cases pour le dupliquer ou le vider.
- commandes : Maj + clic glissé : tracer la zone ; Ctrl+D : dupliquer à droite ; Suppr : vider ; Échap : plus de sélection
- relations :
  - Action sur la zone → un pas d'annulation
- liens : Annuler et refaire

## Calques
- type : canvas
- statut : fait
- but : des calques réglés par projet (fond, jeu, devant, caches), les mêmes pour l'éditeur et le jeu.
- relations :
  - collides → ses cases bloquent le joueur
  - front → dessiné devant le joueur
  - reveal → s'efface quand le joueur entre (secrets)
- docs : docs/guide.md › Canvas sur grille (vue et palette)
- tests : test_layers

## Mode chemin
- type : canvas
- statut : fait
- but : tracer le trajet d'un objet mobile, points numérotés.
- commandes : clic gauche : point de plus ; clic droit : retirer le dernier point

## Essayer en jeu
- type : jeu
- statut : fait
- but : lancer le jeu sur le document ouvert, puis revenir à l'éditeur.
- relations :
  - LtPlaytest.play → le jeu démarre sur ce niveau (lecture unique)
  - LtPlaytest.back_to_editor → retour à l'éditeur
- docs : docs/guide.md › Essayer en jeu

## Édition en jeu
- type : jeu
- statut : fait
- but : modifier le niveau pendant la partie, jeu en pause, avec une palette flottante.
- commandes : clic gauche glissé : poser ; clic droit : retirer ; Échap : reprendre
- relations :
  - Barre du bas → aide, Resume, Save en bouton principal
  - Hôte donné par le jeu → palette, case sous la souris, poser / retirer, reconstruire, enregistrer
  - Ouverture → depuis le debug menu du jeu
- liens : Palette, Gomme
- tests : test_live_edit

## Éditeurs de Gringo : Map et Level
- type : propre au jeu
- statut : fait
- but : la carte des écrans de Gringo et l'éditeur de chaque niveau sur grille.
- relations :
  - Map → niveaux posés en cases, glisser une carte de la bibliothèque, liens des trous noirs dessinés
  - Level → sol automatique et tuiles forcées, plateformes mobiles en mode chemin
  - Renommer un niveau → cartes, niveau de départ et trous noirs mis à jour
  - Édition en jeu → molette pour tourner, 1 à 9 pour la palette
- projets : ProjetGringo

## Éditeurs de BatEmUp : Levels et Bullet Patterns
- type : propre au jeu
- statut : fait
- but : les vagues d'un niveau et les patterns de balles qu'elles tirent.
- relations :
  - Levels → simulation et frise des vagues
  - Vague → son pattern ouvert d'un double-clic, ou un pattern neuf
  - Palette → catalogue des préréglages de vagues et de couches (Ring, Fan, Single)
  - Édition en jeu → clic = une vague à la voie du clic, au moment réglé ; clic droit = retirer la plus proche
- projets : BatEmUp

## Éditeurs de RoguePinball : Table et Modules
- type : propre au jeu
- statut : fait
- but : la table de flipper et les modules qui la composent.
- relations :
  - Murs à deux bouts → propres à Pinball
  - Module → essayé dans une zone d'essai
  - Édition en jeu → modules et éléments posés sur la table, sur la copie de la partie seulement (pas de Save)
- projets : RoguePinball

## Éditeurs de DungeonTactics : Dungeons, Rooms et Map painter
- type : propre au jeu
- statut : fait
- but : donjons générés par graine, salles qui les composent, et carte du monde peinte.
- relations :
  - Dungeons → génération par graine, régénérée au retour d'une salle
  - Map painter → peinture sur le PNG de la carte, force et bord doux
  - Édition en jeu → carte du monde et donjon, hors ligne seulement
- projets : DungeonTactics

# Inventaire : RoguePinball (Table, Modules) et DungeonTactics (Map painter, Dungeons, Rooms)

Liste de contrôle complète, une ligne par fonction :
[pinball_dungeontactics_detail.md](pinball_dungeontactics_detail.md).
Ici : ce qui passe sur les briques, et les décisions à prendre.

## RoguePinball
| Partie | Brique | Changement pour toi |
|---|---|---|
| Thème (table_editor_theme.gd) | LtTheme | aucun : mêmes jetons (design_tokens.cfg copié de Gringo), suit le thème de l'éditeur |
| Coque Table et Modules (en-tête, palette / canvas / Inspecteur Godot, pied) | LtShell | aucun : mêmes boutons ; pied : problèmes en rouge et messages, comme aujourd'hui |
| Problèmes (chevauchement, couloir, sortie) | restent dans le jeu ; passeront sur le validateur en phase 3 | aucun |
| Fichiers (Open, New, Save, Save as, dernière zone rouverte) | LtFiles (remember) | aucun |
| Test ▶ | LtPlaytest + run_layout.gd | aucun (voir P4) |
| Canvas, palettes, Inspecteur, rotation, miroir, Ctrl+D... | restent (phase 4 pour le canvas) | aucun |
| Textes (texts.gd, clés « tab_table ») | LtText (textes anglais en clé) | **P2** |
| Annuler (historique de l'éditeur Godot) | **P1** | |

## DungeonTactics
| Partie | Brique | Changement pour toi |
|---|---|---|
| Thème commun aux trois onglets (map_theme.gd) | LtTheme | aucun : mêmes jetons |
| Coques Map painter, Dungeons, Rooms | LtShell | aucun : mêmes contrôles, mêmes places |
| Listes des donjons et des pièces | LtLibrary (liste) | **cartes avec une ligne de détail** (comme BatEmUp) |
| Supprimer (confirmation, corbeille) ; changer de donjon ou de pièce enregistre la précédente ; Ctrl+S de l'éditeur | LtDocument, LtShell.confirm | aucun |
| Réglages (champs) | LtValueField là où il y a curseur + nombre | aucun |
| Peinture du Map painter (PNG, force, pot, calques), aperçu et génération des donjons, grille des pièces | restent dans le jeu | aucun |
| Annuler du Map painter (pile du document, 50 pas) | reste (image entière par coup, pas une ressource) | aucun |
| Textes du Map painter (i18n/, langue de l'éditeur) | LtText | **D1** |
| Textes de Dungeons et Rooms (tr() sur la table de traduction du jeu) | restent sur la table du jeu | aucun |
| Annuler dans Dungeons et Rooms | **D2** (n'existe pas aujourd'hui) | |

## Décisions (validées le 2026-11-03 : les recommandations)
P1 : garder l'historique de l'éditeur Godot. P2, D1 : level_tools/language.
P3 : enregistrer d'abord avant Ouvrir / Nouveau. P4 : les deux corrections.
D2 : ajouter Annuler (LtHistory). D4 : corriger.

- **P1. Annuler dans Pinball.** Aujourd'hui : l'historique de l'éditeur
  Godot (Ctrl+Z de l'éditeur ; couvre aussi les changements faits dans
  l'Inspecteur). Ma recommandation : **le garder** (LtHistory perdrait
  l'Inspecteur). L'autre choix : LtHistory, comme partout ailleurs, avec un
  instantané à chaque changement de l'Inspecteur.
- **P2. Langue de Pinball.** Aujourd'hui : réglage de l'éditeur
  table_editor/language (propre à toi, sur ce PC). Avec les briques : réglage
  du projet level_tools/language (commun à tous les outils du projet).
- **P3 = D3. Ouvrir ou Nouveau avec des modifications non enregistrées.**
  Pinball les perd sans rien demander ; Gringo aussi (Q4). BatEmUp et
  DungeonTactics enregistrent d'abord. Faire pareil partout ?
- **P4. Corrections au passage** (signalées par la lecture, à confirmer) :
  Test ▶ sur une zone neuve ouvre « Enregistrer sous » mais ne lance pas le
  jeu ; changer la langue ou le thème de l'éditeur reconstruit l'onglet et
  perd les modifications en cours.
- **D1. Langue du Map painter.** Aujourd'hui : suit la langue de l'éditeur
  Godot. Avec les briques : réglage level_tools/language.
- **D2. Annuler dans Dungeons et Rooms** (Ctrl+Z / Ctrl+Y, LtHistory) : à
  ajouter ? C'est une fonction nouvelle.
- **D4. Bug possible** du Map painter : Alt+clic (pipette) sur le calque
  Lieux, sur une couleur de Terrain, lit le mauvais tableau
  (map_shelf.gd:77-85). À corriger au passage ?

# Inventaire : BatEmUp, éditeur de niveaux (onglet « Levels »)

Code : `BatEmUp/game/level/editor/` (level_editor.gd, level_preview.gd,
level_preview_world.gd, wave_timeline.gd, wave_panel.gd),
`addons/batemup_levels/plugin.gd`, côté jeu `game/level/level_runner.gd`.

Ce qui passe sur les briques : thème, textes, coque (en-tête, colonnes,
pied), bibliothèque, fichiers, annuler, champs, Essayer. Ce qui reste propre
au jeu, sans changement : aperçu et simulation, frise des vagues, panneau de
vague, chemins, préréglages de vagues.

Colonne « Après » : **en gras**, ce qui change pour toi. « = » : identique.

## Onglet et fichiers
| Fonction | Aujourd'hui | Après | Brique |
|---|---|---|---|
| Onglet « Levels » de l'éditeur Godot | plugin batemup_levels | = | — |
| Relire les fichiers en revenant sur l'onglet | refresh() à l'affichage | = | LtLibrary.set_paths |
| Ouvrir au lancement | le premier niveau de la liste | **le dernier niveau ouvert (sinon le premier)** | LtDocument.open_last |
| Nouveau | bouton New : `new_level`, une vague de drones | = | LtDocument.create |
| Dupliquer | bouton Duplicate : `<nom>_copy`, ouvert | = | LtDocument.duplicate_current |
| Supprimer | bouton Delete, confirmation « Move to trash », corbeille | = | LtDocument.trash_current + confirmation (à ajouter à LtShell) |
| Après suppression | ouvre le premier qui reste | = | LtDocument |
| Renommer | nom dans l'en-tête, snake_case, fichier renommé à l'enregistrement ; nom pris ou vide refusé | = | LtDocument.save(nom) |
| Enregistrer | bouton Save (principal), Ctrl+S, **Entrée dans le nom** | = (Entrée : à ajouter à LtShell) | LtShell.save_requested |
| Enregistrer avant d'ouvrir un autre niveau modifié | oui | = | LtDocument.save_before_switch |
| « ● unsaved » | modifié, ou nom changé non enregistré | = | LtShell.set_dirty |
| Save grisé sans niveau | oui | = (dans le jeu) | — |
| Scanner le système de fichiers après écriture | files_changed → scan() | = | LtDocument.files_changed |

## Bibliothèque (colonne de gauche)
| Fonction | Aujourd'hui | Après | Brique |
|---|---|---|---|
| Liste des niveaux de game/level/levels/ | ItemList, un nom par ligne, chasse fixe | **cartes : nom + ligne de détail « vertical · 3 wave(s) »** (au lieu de la seule bulle) | LtLibrary |
| Filtre par nom | champ « Filter levels… » avec icône loupe | = (texte « search ») | LtLibrary.search |
| Ouvrir | clic sur un niveau | = | LtLibrary.picked |
| État vide | « No level yet. Click New… » / « No level matches. » | = | LtLibrary.empty_text / no_match_text |
| Réglages du niveau sous la liste | Vertical / Horizontal (pastilles), Scroll, End delay | = | LtValueField, CHIP |

## En-tête
| Fonction | Aujourd'hui | Après | Brique |
|---|---|---|---|
| Surtitre « LEVEL EDITOR », nom (bulle : fichier en snake_case) | oui | = | LtShell.set_title |
| Groupes New / Duplicate / Delete puis Undo / Redo, à gauche | oui | = (à gauche : add_group à gauche, à ajouter) | LtShell.add_group |
| Try in game / Save, à droite | oui | = | LtShell |
| Icônes de l'éditeur Godot sur les boutons | oui | = | LtTheme.editor_icon |

## Annuler / refaire
| Fonction | Aujourd'hui | Après | Brique |
|---|---|---|---|
| Ctrl+Z, Ctrl+Y, Ctrl+Maj+Z, boutons ↶ ↷ | oui, 100 pas | = | LtHistory |
| Modifications rapprochées (< 0,5 s) groupées, structure = un pas | oui | = | LtHistory.changed(grouped) |
| Ignoré quand on tape dans un champ | LineEdit | = (et TextEdit) | LtHistory.handle_key |
| Le niveau reste la même ressource (main.tscn la référence) | recopie des champs | = | LtHistory.for_resource |

## Corps (propre au jeu, inchangé)
- Aperçu : simulation, Espace lecture / pause, R début, vitesses 0,5 / 1 / 2 /
  4, compteur « s · ennemis à l'écran », trajectoires de la vague choisie.
- Frise : clic sur une pastille = choisir, glisser = changer le moment
  (pas de 0,1 s), clic dans la règle ou le vide = tête de lecture.
- Vagues : liste, « Add wave ▾ » (6 préréglages à la tête de lecture),
  dupliquer (2 s plus tard), retirer ; panneau de la vague (type, pattern,
  moment, formation, mouvement et ses réglages, chemin : Edit path, Clear,
  compteur de points en rouge sous 2).
- Edit path : clic dans l'aperçu = point, clic droit = retirer le dernier.

## Pied
| Fonction | Aujourd'hui | Après | Brique |
|---|---|---|---|
| Message (ouvert, enregistré, erreur) | à gauche, reste jusqu'au suivant | **à droite, 4 s, puis l'aide** | LtShell.show_message |
| Aide des touches | à droite, toujours visible | **à droite quand aucun message** | LtShell.set_help |
| Message « Path editing… » pendant l'édition d'un chemin | reste affiché | **4 s** (bulle du bouton Edit path inchangée) | LtShell |

## Essayer en jeu
| Fonction | Aujourd'hui | Après | Brique |
|---|---|---|---|
| Try in game | enregistre, écrit le chemin dans user://level_to_play.txt, lance main.tscn | = (demande dans user://level_tools/) | LtPlaytest.play |
| Côté jeu | level_runner lit la demande une fois, aussi hors éditeur | = (consume(editor_only = false)) | LtPlaytest.consume |

## Textes et thème
- Textes : tools_text.gd (dictionnaire français) passe dans
  `LtText.register("fr", …)` ; réglage `batemup/tools/language` remplacé par
  `level_tools/language` (le premier n'était pas déclaré : seul l'anglais
  s'affichait).
- Thème : ToolsTheme → LtTheme (mêmes jetons, mêmes variantes) ;
  ValueField → LtValueField (même code).

## Changements que tu dois valider
1. Ouverture du dernier niveau au lieu du premier.
2. Bibliothèque en cartes avec une ligne de détail.
3. Messages du pied à droite, 4 s, puis l'aide (comme l'éditeur de carte de
   Gringo).

# Inventaire : BatEmUp, éditeur de patterns (onglet « Bullet Patterns »)

Code : `BatEmUp/game/gameplay/patterns/editor/` (pattern_editor.gd,
pattern_preview.gd, preview_world.gd, pattern_timeline.gd, layer_card.gd),
`addons/batemup_tools/plugin.gd`.

Même coque que l'éditeur de niveaux (voir batemup_levels.md) : tout ce qui
y est dit sur fichiers, bibliothèque, en-tête, annuler, pied, textes et
thème vaut ici, avec ces différences :

| Fonction | Aujourd'hui | Après | Brique |
|---|---|---|---|
| Dossier | game/gameplay/patterns/library/ | = | LtDocument |
| Nouveau | `new_pattern`, une couche en anneau | = | LtDocument.create |
| Supprimer | confirmation « Enemies that use it will have no pattern » | = | confirmation (LtShell) |
| Bibliothèque | 210 px, ItemList ; bulle « 2 layer(s) · cycle 1.50 s » | **cartes avec cette ligne en détail** | LtLibrary |
| Colonne de droite | 380 px : Cycle (Pause), Layers, « Add layer ▾ » | = | LtShell.right, LtValueField |
| Aide du pied | « … Space play · R restart » | = | LtShell.set_help |

## Corps (propre au jeu, inchangé)
- Aperçu : Espace lecture / pause, image suivante (met en pause), R recommence
  le cycle, vitesses 0,25 / 0,5 / 1 / 2, tireur Enemy / Player, clic ou
  glisser = déplacer la cible, clic droit = la remettre.
- Frise des couches : clic sur une ligne = choisir la couche.
- Cartes de couche : œil (couche active), plier / déplier, monter, descendre,
  dupliquer, retirer, choix rapides Ring / Fan / Single et Fixed / At
  target, mouvement replié tant qu'il n'est pas utilisé, clic = choisir.

## Essayer en jeu : à décider
Aujourd'hui, « Try in game » enregistre le pattern, **l'écrit dans
enemy_settings.tres (ou player_settings.tres, selon le tireur de l'aperçu)**,
puis lance main.tscn. Le pattern reste donc celui du boss ou du joueur après
l'essai.

Deux choix :
- **A. Garder tel quel** : l'essai change pour de bon le pattern du boss ou du
  joueur (c'est peut-être voulu : c'est aussi une façon de l'affecter).
- **B. Essai sans effet de bord** : une demande LtPlaytest (« pattern »,
  tireur) que le jeu lit une fois ; enemy_settings.tres et
  player_settings.tres ne changent plus. Affecter un pattern se fait alors
  dans l'Inspecteur (ou un bouton « Assign » à part).

## Changements validés (2026-11-03)
1. Les trois de l'éditeur de niveaux (dernier ouvert, cartes, pied, Rename).
2. Essayer : **B**. Try in game ne touche plus aux réglages (le jeu prend le
   pattern en mémoire pour la partie, level_runner.gd) ; nouveau bouton
   **Assign** : donne le pattern au boss ou au joueur pour de bon.
3. Bibliothèque élargie à 240 px (le détail « cycle endless » tient).

## Vérification après migration (2026-11-03)
- Capture avant / après : même disposition ; Assign ajouté à droite.
- Script : un pattern s'ouvre au lancement ; une demande d'essai donne le
  pattern au boss pour la partie, enemy_settings.tres reste identique sur
  le disque.
- Non vérifié à la main : Assign dans l'éditeur Godot, le lancement réel.

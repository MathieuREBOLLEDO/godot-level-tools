# Plan

Plan D (2026-11-03) : briques communes des éditeurs, puis migration des
jeux un par un. Validation par l'utilisateur à la fin de chaque phase.
Règle : aucune fonctionnalité d'un éditeur ne disparaît (inventaire avant
chaque migration, docs/inventory/).

## Phase 1 : le socle (faite le 2026-11-03, à valider)
- [x] Thème (LtTheme), fusion de LevelToolsTheme (Gringo) et ToolsTheme
      (BatEmUp) ; variante LEGEND pour les pastilles de légende de Gringo.
- [x] Textes (LtText) : réglage du projet level_tools/language, register().
- [x] Coque (LtShell), fichiers (LtFiles), document (LtDocument),
      bibliothèque (LtLibrary, LtLibraryCard), annuler (LtHistory), champ
      (LtValueField), Essayer (LtPlaytest).
- [x] Tests (35) et tests/impact.md ; éditeur d'exemple tests/demo_editor.tscn.
- [x] Dépôt GitHub (github.com/MathieuREBOLLEDO/godot-level-tools), poussé ;
      sous-module addons/level_tools de ProjetGringo (ajouté, pas encore
      commité dans ProjetGringo).
- [x] plugin.cfg (project_init exige un plugin.cfg) : déclare le réglage
      level_tools/language.
- [x] project_init installe et active level tools et écrit design_tokens.cfg
      (copie de celui de Gringo) ; project_updater installe déjà tout
      sous-module, rien à y ajouter.

## Phase 2 : migrations (BatEmUp, Gringo, RoguePinball, DungeonTactics)
- [x] Inventaires BatEmUp validés (Try des patterns : choix B + Assign).
- [x] Briques complétées : Entrée dans le nom = enregistrer, groupes
      d'en-tête à gauche, confirmation, Rename depuis la bibliothèque.
- [x] BatEmUp migré (Levels, Bullet Patterns) le 2026-11-03 : vérifié par
      capture et script ; pas commité dans BatEmUp (branche gameplay).
- [x] Inventaires Gringo, RoguePinball, DungeonTactics validés (les
      recommandations).
- [x] Gringo migré (Map, Level, navigateur, live edit ; textes en LtText
      avec table française game/level/level_tools_text.gd) : captures avant /
      après identiques, script de vérification, 239 tests du jeu.
- [x] RoguePinball migré (Tables : Table, Modules ; annuler de l'éditeur
      Godot gardé) et DungeonTactics migré (Map painter, Dungeons, Rooms ;
      annuler ajouté à Dungeons et Rooms, pipette corrigée) : vérifiés par
      script et captures. Non vérifié : les clics réels dans l'éditeur Godot.
- [ ] Rien n'est commité dans les jeux (BatEmUp, ProjetGringo, RoguePinball,
      DungeonTactics) ni dans project_init : à faire sur demande.
- [ ] Brique à venir si besoin : pied avec statut persistant et bouton
      (Map painter de DungeonTactics passe aujourd'hui par footer_label).
- [x] design_tokens.cfg de Gringo copié dans RoguePinball et DungeonTactics
      (mêmes valeurs que leurs défauts : rien ne change à l'écran).
- [ ] Gringo : le fichier de la dernière carte reste user://map_editor.cfg
      (LtFiles.remember prend le chemin), rien à perdre.

## Phase 3 : validateur (faite le 2026-11-03, à valider)
- [x] Brique LtValidator / LtProblem (validator/), compteur du pied de
      LtShell (validate(), set_problems(), problem_picked), couleur WARN
      (jeton « warn », warning_color de l'éditeur Godot). 3 tests.
- [x] Branché : Pinball Table (3 règles reprises, clic = case cadrée),
      DungeonTactics Rooms (8 règles reprises), Gringo Map (culs-de-sac et
      passages vers le vide en avertissements ; pastilles de légende gardées),
      Gringo Level (trou noir sans retour ou vers un niveau disparu : erreur ;
      départ dans une case pleine : avertissement), BatEmUp Levels (fichier
      disparu, vague vide ou sans ennemi, chemin de moins de 2 points).
- [x] On enregistre même avec une erreur. Test des niveaux finis : Gringo
      (test_finished_levels_pass_the_validator) ; les autres jeux n'ont pas
      de suite de tests (vérifiés à la main : tous sans erreur).
- [ ] Pas de règle pour BatEmUp Patterns, Map painter, Dungeons (aucune
      évidente) ; le puzzle : phase 5.

## Phase 4a : disposition commune (faite le 2026-11-03, à valider)
- [x] Règle écrite (DESIGN.md, « Disposition commune ») : en-tête vue →
      annuler → essayer → fichiers en icône seule avec bulle → Enregistrer
      (icône + texte, seul principal) ; aide des gestes dans le pied.
- [x] Briques : LtIcons (icônes de Gringo + supprimer, annuler, refaire,
      enregistrer sous), LtBackdrop (grille discrète et vignettage derrière
      le canvas de toute coque).
- [x] Appliqué : BatEmUp Levels et Patterns, Pinball Table et Modules,
      DungeonTactics Map painter (annuler, refaire, Enregistrer dans
      l'en-tête ; aide et état dans le pied), Dungeons (légende dans le
      pied), Rooms (aide dans le pied). Gringo inchangé (référence).
- [x] plugin.gd : tests/.gdignore dans un jeu sans test runner (plus
      d'erreur « TestCase » à l'ouverture de l'éditeur).

## Phase 4b : gestes communs des canvas (faite le 2026-11-03, à valider)
- [x] Briques : LtView (zoom au curseur, déplacer, F, Maj + molette et R
      pour tourner, cadrage automatique) et LtPalette / LtPaletteSlot
      (reprise de la palette de Gringo). 3 tests.
- [x] DungeonTactics Rooms : vue, palette (3 pages), clic droit = pipette,
      gomme = case libre. Map painter : F et clic droit = pipette.
- [x] Pinball Modules : vue commune (Espace + clic, Maj + molette), palette
      commune (favoris, ordre, touche 0) ; section_palette.gd retiré.
- [x] Gringo Level : vue commune (molette = zoom, Maj + molette / R =
      tourner, déplacer, F).
- [x] Tableau des gestes : docs/inventory/gestes_4b.md.
- [ ] Palette de Gringo encore à elle (calques, tiroir du sol) : la passer sur
      LtPalette plus tard si utile.

## Phase 5 revue : parité des fonctions (cadrée le 2026-11-03)
But : chaque fonction d'un éditeur existe dans tous les autres (Gringo en
référence), pas seulement des briques techniques communes.
- [x] Inventaire : docs/inventory/parite.md (tableau par éditeur, ordre,
      questions Q1 à Q10).
- [x] Réponses aux questions (2026-11-04, dans parite.md).
- [x] Étape 1 (2026-11-04, à valider) : briques LtWorkspace (onglets,
      onglet et pièce retenus), LtFlags (DPRC, EXCL sur toute ressource),
      bibliothèque complétée (set_usage : badges, estompé, filtre ;
      enable_import ; add_layout_toggle), LtSettings + LtShell.settings(),
      LtShell.add_undo_buttons() ; icônes GRID, LIST. 8 tests.
      Gringo dessus : onglets LtWorkspace (dernier niveau et onglet
      rouverts), carte avec Annuler / Refaire, Essayer le niveau choisi,
      Dupliquer et Supprimer la carte ; Level avec Supprimer (avertit des
      cartes qui l'utilisent) et Annuler / Refaire en icônes ; renommer un
      niveau depuis la bibliothèque ou Browse (cartes, départ, trous noirs
      suivent : game/level/level_files.gd, 2 tests) ; Ctrl+S de Godot.
      Pas encore : la colonne de réglages n'a pas d'utilisateur (Pinball,
      étape 2) ; Gringo garde ses réglages dans l'en-tête.
- [x] Étape 2, Pinball (2026-11-04, à valider) : onglets LtWorkspace (onglet
      et module rouverts) ; Table : bibliothèque LtLibrary (modules, modules
      peints, éléments ; miniatures, Kind, Usage, Flags, tri, grille, import,
      Rename des modules peints) à la place de palette.gd ; colonne de
      réglages (zone, élément, module) à la place de l'Inspecteur ; Duplicate,
      Delete ; Ctrl+S de Godot. Modules : colonne de réglages (nom, taille,
      sol, bas ouvert, marques), menu Open, Duplicate, Delete, Test dans une
      zone d'essai. Brique : LtLibrary.clicked (relâché sans glisser),
      LtShell._settings_column (nom libéré pour les jeux), filtre Flags sur
      des données qui ne sont pas des objets.
- [x] Étape 3a, DungeonTactics Dungeons | Rooms (2026-11-04, à valider) :
      onglets LtWorkspace (fin du bouton Salles / Retour ; onglet, donjon et
      salle rouverts) ; double-clic sur une pièce de l'aperçu = sa salle
      (les pièces posées notent leur fichier, dungeon_grid.gd) ; miniatures,
      liste ou grille, usages (donjon dans le monde ; salle dans ce donjon,
      dans un autre), marques (un donjon ou une salle EXCL n'est plus pris par
      le jeu ni tiré) ; Dupliquer ; Rename des salles qui garde le numéro de
      tête (ordre du tirage) ; Play d'un donjon et d'une salle seule (main.gd
      lit la demande « dungeon ») ; validateur des donjons (pas généré :
      erreur ; pas d'entrée : avertissement). Brique : LtWorkspace ignore un
      titre de pièce donné avant que l'onglet existe.
- [x] 3b, Map painter (2026-11-04, à valider) : plusieurs cartes dans
      game/level/maps/ ; bibliothèque (miniature, « in game », Flags, tri,
      grille, Rename) à gauche, outils à droite ; nom renommé à
      l'enregistrement ; marques (maps.cfg) ; « Use in game » (réglage du
      projet dungeon_tactics/world/painted_map, lu par
      WorldData.painted_map()) ; Play (carte pour une partie) ; Nouvelle,
      Dupliquer, Supprimer ; dernière carte rouverte ; validateur (taille).
      Le jeu garde la carte d'une partie dans la sauvegarde.
- [x] Étape 4, BatEmUp (2026-11-04, à valider) : un onglet « Levels » à
      deux onglets LtWorkspace (Levels | Patterns ; plugin batemup_tools
      retiré) ; double-clic sur une vague ou « Edit pattern » = son pattern
      (un nouveau si elle n'en a pas) ; bibliothèques : miniatures, grille,
      import, filtres (sens ; tireur), usages (scène qui joue un niveau ; ce
      niveau, autres niveaux, boss, player pour un pattern), Flags, tri ;
      marques DPRC / EXCL ; validateur des patterns ; avertissement à la
      suppression d'un pattern utilisé. Brique : LtLibrary.add_filters_toggle
      (filtres repliés quand la colonne est courte).
- [ ] Étape 5 : canvas, en sous-étapes (une validation chacune) ; 5a à 5f
      faites et validées (2026-11-04). Reste : calques de Pinball Modules et
      de DungeonTactics Rooms (5e, Gringo d'abord), palette de Gringo sur
      LtPalette et palette des éléments de la table Pinball (à décider) :
      - [x] 5a (2026-11-04, à valider) gestes sans changement de format :
        Ctrl+D / Suppr (vagues, couches, niveau choisi sur la carte de
        Gringo : copie enregistrée posée à la première case libre à droite),
        miroir M dans Gringo Level, pipette au clic droit sans glisser sur la
        table Pinball (sa carte choisie dans la bibliothèque ; glissé = vue,
        comme avant), vue commune (LtView) dans l'aperçu des donjons ;
      - [x] 5b (2026-11-04, à valider) palettes communes : vagues et couches
        toutes prêtes de BatEmUp (Q5 ; clic = ajouter, favoris, ordre, 1 à 9 ;
        à la place des menus « Add ▾ »), couleurs du Map painter (pages
        Terrain et Places, une couleur de l'autre page change de calque,
        1 à 9 souris sur la carte ; colonne qui défile). Brique :
        LtPalette.show_name. Pas fait, à décider : la palette de Gringo
        reste à elle (modèle de LtPalette, avec calques et tiroir du sol) ;
        les éléments de la table Pinball sont des cartes de la bibliothèque
        (clic, glisser) plutôt qu'une palette ;
      - [x] 5c (2026-11-04, à valider) brique LtCellSelection (Maj +
        glisser, Ctrl+D à droite, Suppr, Échap ; 1 test) dans Gringo Level
        (couche éditée, rotations, tuiles forcées, réglages), Pinball Modules
        (objets dont le coin est dans la zone ; ce qui ne tient pas est
        laissé) et Rooms (la pièce s'élargit, 20 cases au plus) ; verrou des
        vagues (clic du milieu sur la frise, bouton), des couches (cadenas de
        la carte), des objets de la table (clic du milieu, case Locked ;
        cadenas dessiné) : champ locked dans WaveData, PatternLayer,
        ElementPlacement, ModulePlacement. Corrigé au passage : l'annuler du
        pinceau de Gringo Level ne rendait pas les cases (instantané qui
        partageait les tableaux du niveau ; déjà le cas avant level_tools) ;
      - [x] 5d (2026-11-04, à valider) brique LtPathEditor (clic gauche un
        point, clic droit retire le dernier ; tracé aux points numérotés ;
        1 test) : vagues de BatEmUp dessus ; Gringo dessine le chemin choisi
        avec elle et gagne le clic droit (retirer le dernier point) et
        l'annuler des points. Voisins : un module peint ouvert depuis la
        table voit les autres modules de la zone, ombrés, à sa vraie case ;
        une salle ouverte depuis l'aperçu d'un donjon voit le donjon autour
        d'elle (3 cases, ombré ; oublié quand on ouvre une autre salle) ;
      - 5e calques en nombre réglable par projet (format des fichiers).
        Décidé le 2026-11-04 : Gringo d'abord (Pinball, Rooms ensuite) ;
        chaque calque peut jouer (collisions réglables) ; pas de parallaxe ;
        réglage du projet. Plan validé ; fait pour Gringo le 2026-11-04,
        à valider par l'utilisateur (Pinball Modules, Rooms : ensuite) :
        - brique LtLayers : liste des calques dans le réglage du projet
          level_tools/layers ({id, name, collides, front}, dans l'ordre du
          dessin), lue par l'éditeur et le jeu ; barre des calques commune
          (un bouton par calque, les autres estompés) ;
        - Gringo : LevelData garde tiles (le calque « game » : éléments de
          jeu, départ, trous noirs...) et range les autres dans layers
          (id -> cases) ; background et foreground d'un niveau ancien sont lus
          comme les calques « back » et « front » (rien à refaire) ; défaut
          du réglage : back, game, front comme aujourd'hui ;
        - un calque collides : ses cases solides (roche, sol, sable ; le
          métal n'est pas un élément de décor) bloquent Gringo ; les autres éléments (pics, plateformes, clés...)
          restent sur le calque game ; front : dessiné devant Gringo ;
        - fait : layers/lt_layers.gd (réglage déclaré par le plugin),
          level_data (layers, layer_id, layer_bytes, migrate_layers ; le
          Layer d'avant marche encore), ground_tiles, level_palette (barre
          en lignes, bulle : derrière/devant, collision), level_canvas,
          level_editor (zone, annuler), element_builder (Layer_<id>),
          grid_level (_add_layer_bodies) ; aperçus de carte et live edit :
          calque game seulement, comme avant ; tests :
          game/level/tests/test_level_layers.gd ;
      - 5f édition en jeu (BatEmUp, Pinball, DungeonTactics). 5e validé le
        2026-11-04. Réponses du 2026-11-04 : DT, peindre une salle change
        son modèle (comme l'onglet Rooms) ; Pinball, rien n'est enregistré
        (la partie en cours seulement, pas de Save) ; BatEmUp, voie du clic
        et moment choisi dans la fenêtre (le jeu y revient) ; annuler /
        refaire (Ctrl+Z, Ctrl+Y) partout, Gringo compris. Plan validé ; fait et
        validé par l'utilisateur le 2026-11-04. Fait : live/lt_live_edit.gd,
        lt_live_host.gd, lt_floating_panel.gd (celle de Gringo retirée),
        LtHistory.checkpoint(état) ; Gringo : live_edit.gd hôte,
        LevelData.snapshot() ; BatEmUp : wave_presets.gd (préréglages communs
        avec l'éditeur), level_live_edit.gd, LevelRunner.start(niveau, moment),
        bouton Live edit de BatEmUp > Niveau ; Pinball : table_live_edit.gd,
        Table.clear(), main.rebuild_table(), Pinball > Live edit (les
        changements durent jusqu'à la fin de la manche : chaque manche refait
        sa zone) ; DungeonTactics : world_live_edit.gd, PaintedGen.set_pixel,
        WorldData.reread_place, WorldMap.reload_chunk, <jeu> > Live edit ;
        peindre sous un lieu fait main (camp...) ne change rien (le lieu
        passe devant) ; un ennemi peint dans une pièce apparaît au prochain
        donjon tiré. Tests : level_tools/tests/test_live_edit.gd,
        game/level/tests/test_live_edit.gd ; les trois autres jeux vérifiés en
        jeu (scripts de contrôle). Plan :
        - brique LtLiveEdit (live/) : le cadre du live edit de Gringo, pour
          tous : jeu en pause, palette dans une fenêtre flottante (la
          FloatingPanel de Gringo passe dans l'addon : LtFloatingPanel),
          barre du bas (aide, Resume, Save en bouton principal), Échap =
          reprendre, clic gauche glissé = poser, clic droit = retirer, une
          reconstruction par image au plus, case survolée dessinée. Le jeu
          donne un hôte : palette, écran -> case, poser/retirer, rebuild,
          save, dessin du repère ; ouvert depuis son debug menu ;
        - Gringo dessus, mêmes gestes (molette = tourner, 1 à 9) ;
        - BatEmUp : palette des préréglages de vague ; clic = une vague à la
          voie du clic, un peu après le moment joué ; clic droit = retirer la
          vague la plus proche ; rebuild = LevelRunner repart au même moment
          (nouveau : start depuis un temps) ; save = le .tres du niveau ;
          [réponse : moment réglé dans la fenêtre flottante, pas « +1 s »] ;
        - Pinball : bibliothèque modules + éléments en palette ; clic = poser
          sur la table (rayon caméra -> plan y = 0 -> case), clic droit =
          retirer l'objet sous la souris ; rebuild = Table vidée puis
          reconstruite (nouveau), balles gardées ; [réponse : la copie de la
          partie seulement, pas de Save] ;
        - DungeonTactics : carte du monde (couleurs du Map painter, pixel du
          PNG, PaintedGen refait, changements de la partie gardés par
          restore_changes ; save = le PNG) et donjon (légende des salles,
          case -> salle sous la souris) ; hors ligne seulement (en ligne la
          pause n'arrête pas le jeu).
- Ensuite : liens et puzzle (ancienne phase 5).
## Décisions
- 2026-11-03 : une règle du validateur est un Callable, pas une classe (plus
  court ; le plan parlait de classes).
- 2026-11-03 : design_tokens.cfg de ProjetGringo = la règle pour tous les
  projets ; une retouche s'y fait d'abord, puis se recopie (les autres
  projets ont chacun leur copie).
- 2026-11-03 : copie de travail = le sous-module de ProjetGringo (c'est lui
  que les tests lancent) ; le clone G:\Projects\Godot_Addons\godot-level-tools
  se remet à jour par git pull.
- 2026-11-03 : classes globales préfixées Lt plutôt que preload : plus
  simple à utiliser dans les jeux, sans heurter leurs classes.
- 2026-11-03 : pas de plugin.cfg ni de dossier editor/ pour l'instant :
  aucune brique n'en a besoin (EditorInterface passe par Engine).
- 2026-11-03 : colonnes de la coque redimensionnables (HSplitContainer),
  largeur de départ fixée par l'éditeur.

# Level Tools

Briques communes des éditeurs de niveaux des jeux Godot 4.7 (ProjetGringo,
RoguePinball, BatEmUp, DungeonTactics...). Chaque jeu assemble ses éditeurs
avec ces briques ; le contenu (éléments, données, dessin) reste dans le jeu.

| Brique | Classe | Rôle |
|---|---|---|
| Thème | LtTheme | jetons de design_tokens.cfg, thème, constructeurs (bouton, groupe, champ, bandeau) |
| Textes | LtText | anglais dans le code, traduction française, textes du jeu ajoutés |
| Coque | LtShell | en-tête, trois colonnes, pied (messages, aide, légende), état vide |
| Fichiers | LtFiles | liste, nom libre ou nettoyé, renommer, corbeille, import, dernier fichier |
| Document | LtDocument | ouvrir, créer, dupliquer, enregistrer et renommer, état modifié |
| Bibliothèque | LtLibrary, LtLibraryCard | recherche, filtres, tris, cartes en liste ou grille |
| Annuler | LtHistory | instantanés, 100 pas, regroupement des petites modifications |
| Champ | LtValueField | curseur et nombre liés à une propriété (@export_range) |
| Essayer | LtPlaytest | demande au jeu, lancement, lecture unique |

Installation : sous-module `addons/level_tools` du jeu (pas de plugin à
activer). Mode d'emploi : docs/guide.md ; apparence : DESIGN.md.

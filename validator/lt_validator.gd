@tool
class_name LtValidator
extends RefCounted

## Validateur d'un type de document : une liste de règles fournies par le jeu.
## Une règle est un Callable (document) -> Array[LtProblem] ; elle rend une
## liste vide quand tout va bien. L'éditeur appelle check() après chaque
## modification et passe le résultat à LtShell.set_problems() (compteur du
## pied). Les tests du jeu appellent errors_in() sur ses niveaux finis.
## Repris des vérifications de l'onglet Table de RoguePinball, des Rooms de
## DungeonTactics et des culs-de-sac de la carte de Gringo.

var _rules: Array[Callable] = []


## Ajoute une règle ; rend le validateur (pour enchaîner).
func add_rule(rule: Callable) -> LtValidator:
	_rules.append(rule)
	return self


## Problèmes de [param document], erreurs d'abord, dans l'ordre des règles.
func check(document: Variant) -> Array[LtProblem]:
	var errors: Array[LtProblem] = []
	var warnings: Array[LtProblem] = []
	if document == null:
		return errors
	for rule: Callable in _rules:
		for problem: LtProblem in rule.call(document):
			if problem.is_error():
				errors.append(problem)
			else:
				warnings.append(problem)
	errors.append_array(warnings)
	return errors


## Nombre de problèmes de gravité [param severity].
static func count(problems: Array[LtProblem], severity: LtProblem.Severity) -> int:
	return problems.filter(func(problem: LtProblem) -> bool: return problem.severity == severity).size()


## Pour les tests : les erreurs (pas les avertissements) des fichiers
## [param paths], « fichier : message ». [param loader] : (chemin) ->
## document (null : fichier illisible, compté comme une erreur).
func errors_in(paths: PackedStringArray, loader: Callable) -> PackedStringArray:
	var lines: PackedStringArray = []
	for path: String in paths:
		var document: Variant = loader.call(path)
		if document == null:
			lines.append("%s: cannot load" % path.get_file())
			continue
		for problem: LtProblem in check(document):
			if problem.is_error():
				lines.append("%s: %s" % [path.get_file(), problem.message])
	return lines

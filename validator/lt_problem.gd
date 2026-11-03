@tool
class_name LtProblem
extends RefCounted

## Un problème trouvé par une règle du validateur (LtValidator) : gravité,
## message (déjà traduit) et endroit, que l'éditeur sait cadrer : une case
## (Vector2i), une position (Vector2 / Vector3), un index (vague, élément),
## un chemin de nœud... ; null : tout le document.

enum Severity { ERROR, WARNING }

var severity: Severity = Severity.ERROR
var message: String = ""
var where: Variant = null


func _init(problem_severity: Severity = Severity.ERROR, text: String = "", place: Variant = null) -> void:
	severity = problem_severity
	message = text
	where = place


static func error(text: String, place: Variant = null) -> LtProblem:
	return LtProblem.new(Severity.ERROR, text, place)


static func warning(text: String, place: Variant = null) -> LtProblem:
	return LtProblem.new(Severity.WARNING, text, place)


func is_error() -> bool:
	return severity == Severity.ERROR

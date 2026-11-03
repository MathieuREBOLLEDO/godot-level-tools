extends TestCase

## Validateur (LtValidator, LtProblem) et compteur du pied de la coque.

const SampleDocument = preload("res://addons/level_tools/tests/sample_document.gd")
const DIR: String = "user://level_tools_tests_validator/"


func after_each() -> void:
	if DirAccess.dir_exists_absolute(DIR):
		for file: String in DirAccess.get_files_at(DIR):
			DirAccess.remove_absolute(DIR + file)
		DirAccess.remove_absolute(DIR)


func test_check_puts_errors_first() -> void:
	var validator: LtValidator = _validator()
	var document: Resource = SampleDocument.new()
	document.title = ""
	document.count = 9
	var problems: Array[LtProblem] = validator.check(document)
	assert_eq(problems.size(), 2)
	assert_true(problems[0].is_error(), "the error first, though its rule comes second")
	assert_eq(problems[0].message, "No title")
	assert_eq(problems[1].where, 9)
	assert_eq(LtValidator.count(problems, LtProblem.Severity.WARNING), 1)
	document.title = "ok"
	document.count = 2
	assert_eq(validator.check(document).size(), 0)
	assert_eq(validator.check(null).size(), 0)


func test_errors_in_ignores_warnings() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var broken: Resource = SampleDocument.new()
	broken.title = ""
	broken.count = 9
	LtFiles.save(broken, DIR + "broken.tres")
	var only_warned: Resource = SampleDocument.new()
	only_warned.title = "fine"
	only_warned.count = 9
	LtFiles.save(only_warned, DIR + "warned.tres")
	var lines: PackedStringArray = _validator().errors_in(PackedStringArray([DIR + "broken.tres", DIR + "warned.tres", DIR + "missing.tres"]),
		func(path: String) -> Variant: return LtFiles.load_fresh(path) if FileAccess.file_exists(path) else null)
	assert_eq(lines, PackedStringArray(["broken.tres: No title", "missing.tres: cannot load"]))


func test_shell_counter_cycles_through_problems() -> void:
	var shell: LtShell = add_test_node(LtShell.new())
	assert_false(shell.problems_button.visible, "no counter without a validator")
	shell.validator = _validator()
	var document: Resource = SampleDocument.new()
	document.title = ""
	document.count = 9
	shell.validate(document)
	assert_true(shell.problems_button.visible)
	assert_eq(shell.problems_button.text, "1 error(s) · 1 warning(s)")
	var picked: Array = []
	shell.problem_picked.connect(func(problem: LtProblem) -> void: picked.append(problem.message))
	shell.problems_button.pressed.emit()
	shell.problems_button.pressed.emit()
	shell.problems_button.pressed.emit()
	assert_eq(picked, ["No title", "Too many", "No title"], "click: the next one, then around")
	assert_eq(shell.footer_label.text, "No title", "message in the footer")
	document.title = "ok"
	document.count = 2
	shell.validate(document)
	assert_eq(shell.problems_button.text, "No problem")
	shell.problems_button.pressed.emit()
	assert_eq(picked.size(), 3, "nothing to show")


func _validator() -> LtValidator:
	var validator: LtValidator = LtValidator.new()
	validator.add_rule(func(document: Resource) -> Array[LtProblem]:
		var problems: Array[LtProblem] = []
		if document.count > 5:
			problems.append(LtProblem.warning("Too many", document.count))
		return problems)
	validator.add_rule(func(document: Resource) -> Array[LtProblem]:
		var problems: Array[LtProblem] = []
		if document.title == "":
			problems.append(LtProblem.error("No title"))
		return problems)
	return validator

extends Resource

## Document de test des briques : un nom, des valeurs bornées, une liste.

@export var title: String = ""
@export_range(0, 10, 0.5) var speed: float = 1.0
@export_range(1, 9) var count: int = 3
@export var items: Array[int] = []

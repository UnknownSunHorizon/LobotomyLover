extends Button

@onready var enemy = $Zondbe

func _on_pressed() -> void:
	enemy.hp -= 100

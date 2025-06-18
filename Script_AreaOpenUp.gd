extends Node3D

@export var Dialogue: Node
@export var Requirement: String = "Area Cleared"
@export var SpawningArea: Node = get_parent()

func _ready() -> void:
	SpawningArea.ready.connect(Callable(self, "area_is_ready"))
	if Requirement == "Area Cleared":
		print("Area Cleared Connect")
		SpawningArea.area_cleared.connect(Callable(self, "area_cleared"))
	
func area_cleared():
	print("OPENING UP")
	$AnimationPlayer.play("OpenUp")
	Dialogue.play_dialogue()

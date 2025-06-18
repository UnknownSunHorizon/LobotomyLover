extends Area3D

@export var PlayerBody: Node
@export var Dialogue: Node

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player_body"):
		Dialogue.play_dialogue()

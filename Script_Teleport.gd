extends Area3D

@export var PlayerNode: Node
@export var other_side: Node

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player_body"):
		if PlayerNode.teleported == false:
			PlayerNode.global_position = other_side.global_position
			PlayerNode.global_rotation += other_side.global_rotation
			PlayerNode.teleported = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player_body"):
		if PlayerNode.teleported == true:
			PlayerNode.teleported = false

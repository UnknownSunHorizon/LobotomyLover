extends Node3D

@export var FollowSpeed: int
@export var PlayerNode: Node
@export var RelativePosition: Vector3
@export var RelativeRotation: Vector3

var PlayerPos

func _physics_process(delta):
	global_position = global_position.lerp(PlayerNode.global_transform * RelativePosition, delta*FollowSpeed)
	var local_rotation_basis = Basis.from_euler(RelativeRotation)
	global_transform.basis = PlayerNode.global_transform.basis * local_rotation_basis

extends XROrigin3D

@export var DeathSound: AudioStreamPlayer3D
@export var HitSound: AudioStreamPlayer3D
@export var TaskCompleteSound: AudioStreamPlayer3D

@export var max_hp: int
var hp: int

@export var SpawningArea: Node

var isdead_called: bool = false
var teleported: bool = false

signal is_hit(where,much)
signal imdead(who)

func _ready() -> void:
	hp = max_hp
	self.imdead.connect(Callable(SpawningArea, "someone_died"))
	$AnimationPlayer.play_backwards("FullVisionLose")
	
func hit(damage):
	hp -= damage
	print(hp)
	if _is_dead():
		DeathSound.play()
	else:
		HitSound.play()
	
func _is_dead() -> bool:
	if hp <= 0:
		$AnimationPlayer.play("FullVisionLose")
		isdead_called = true
		return true
	else:
		return false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FullVisionLose" and isdead_called:
		imdead.emit(self)

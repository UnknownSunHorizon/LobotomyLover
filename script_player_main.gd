extends XROrigin3D

@export var DeathSound: AudioStreamPlayer3D
@export var HitSound: AudioStreamPlayer3D
@export var TaskCompleteSound: AudioStreamPlayer3D

@export var max_hp: int
var hp: int

signal is_hit(where,much)
signal imdead(who)

func _ready() -> void:
	hp = max_hp

func hit(damage):
	hp -= damage
	print(hp)
	if _is_dead():
		DeathSound.play()
	else:
		HitSound.play()
	
func _is_dead() -> bool:
	if hp <= 0:
		imdead.emit(self)
		return true
	else:
		return false

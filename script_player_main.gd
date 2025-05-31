extends XROrigin3D

@export var max_hp: int
var hp: int

signal is_hit(where,much)
signal imdead(who)

func _ready() -> void:
	hp = max_hp

func hit(damage):
	hp -= damage
	print(hp)
	_is_dead()
	
func _is_dead() -> void:
	if hp <= 0:
		imdead.emit(self)

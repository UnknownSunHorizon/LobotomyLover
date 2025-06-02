extends CollisionShape3D

signal is_hit(damage)

func hit(damage):
	is_hit.emit(damage)

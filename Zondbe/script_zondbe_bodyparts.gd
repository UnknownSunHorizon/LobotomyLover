extends CollisionShape3D

<<<<<<< Updated upstream
signal is_hit(where)

func _hit():
	is_hit.emit(name)
=======
signal is_hit(damage)

func hit(damage):
	is_hit.emit(damage)
>>>>>>> Stashed changes

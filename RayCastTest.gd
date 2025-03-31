extends RayCast3D

func _process(float) -> void:
	var result = get_collider()
	if result:
		print(self)
		if result.get("name") == "Zondbe":
			var bodypart = get_collider().shape_owner_get_owner(get_collider_shape())
			bodypart._hit()
		queue_free()

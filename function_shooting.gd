extends RayCast3D

@export var time_between_shots: float
@export var recharge_time: float
@export var damage: float

@export var light_flash_time: float
var fired_already: bool

func _ready():
	fired_already = false
	get_child(1).visible = false

func _on_pickable_object_action_pressed(pickable: Variant) -> void:
	shoot()

func shoot():
	if !fired_already:
		var result = get_collider()
		if result:
			_test_raycast(result.get("position"))
			if result.get("name") == "Zondbe":
				var bodypart = get_collider().shape_owner_get_owner(get_collider_shape())
<<<<<<< Updated upstream
				bodypart._hit()
=======
				bodypart.hit(damage)
>>>>>>> Stashed changes
				
		get_child(1).visible = true
		get_child(1).get_child(0).start(light_flash_time)
		fired_already = true
		get_child(0).start(time_between_shots)

func _on_timer_timeout() -> void:
	fired_already = false

func _on_light_timer_timeout() -> void:
	get_child(1).visible = false

func _test_raycast(result):
	var instance = load("res://object_raycast_test.tscn").instantiate()
	get_parent().get_parent().add_child(instance)
	instance.global_position = position
	await get_tree().create_timer(2).timeout
	instance.queue_free()

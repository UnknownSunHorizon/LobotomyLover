extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var raycast = $HitRaycast
@onready var timer = $Timer
@export var hp: int
@export var head_damage: float
@export var body_damage: float
@export var attack_distance: int
@export var speed: float

var attacking: bool = false

###ACTIONS
func do_attack():
	attacking = true
	#включить анимацию удара
	if raycast.is_colliding():
		raycast.get_collider().hit()
		timer.start(1)

func _on_timer_timeout() -> void:
	attacking = false
	
func do_nyashify():
	print("я няшка")

###LOGIC
func _on_body_collision_is_hit(where) -> void:
	hp -= body_damage
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to " + str(where))
	_is_dead()

func _on_head_collision_is_hit(where) -> void:
	hp -= head_damage
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to " + str(where))
	_is_dead()

func _is_dead() -> void:
	if hp <= 0:
		do_nyashify()

###MOVEMENT
func _physics_process(delta: float) -> void:
	if !attacking:
		var nodes = get_tree().get_nodes_in_group("Nyashka")
		var closest_node = nodes[0]
		for entity in nodes:
			if position.distance_to(entity.global_transform.origin) < position.distance_to(closest_node.global_transform.origin):
				closest_node = entity
		update_target_location(closest_node.global_transform.origin)
		look_at(closest_node.global_transform.origin)
		rotation.x = 0
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * speed
		
		nav_agent.set_velocity(new_velocity)

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _on_navigation_agent_3d_target_reached() -> void:
	if !attacking:
		do_attack()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

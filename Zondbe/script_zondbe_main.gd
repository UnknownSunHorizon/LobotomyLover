extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var raycast = $HitRaycast
@onready var timer = $Timer
@export var hp: int
<<<<<<< Updated upstream
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
=======
@export var head_multiplier: float
@export var attack_strength: int
@export var attack_distance: int
@export var speed: float

var searching_for: String

var attacking: bool = false

signal imdead(who)

###ACTIONS
func _ready():
	if is_in_group("Nyashka"):
		searching_for = "Zondbe"
	else:
		if is_in_group("Zondbe"):
			searching_for = "Nyashka"

func do_attack():
	#включить анимацию удара
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group(searching_for):
			attacking = true
			raycast.get_collider().hit(attack_strength)
			timer.start(1)
			$Particles.set_emitting(true)
>>>>>>> Stashed changes

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
=======
	var new_nyashka = load("res://Zondbe/entity_Nyashka.tscn").instantiate()
	new_nyashka.global_transform = self.global_transform
	print("я няшка")
	queue_free()
	
###LOGIC
func hit(damage):
	hp -= damage
	_is_dead()

func _on_body_collision_is_hit(damage) -> void:
	hit(damage)
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to body")

func _on_head_collision_is_hit(damage) -> void:
	hit(damage*head_multiplier)
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to head")

func _is_dead() -> void:
	if hp <= 0:
		imdead.emit(self)

###MOVEMENT
func _physics_process(delta: float) -> void:
	if !attacking: #то ищет врагов
		var nodes = get_tree().get_nodes_in_group(searching_for)
		if nodes.size() > 0:
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
		else:
			pass
			#сменить режим
>>>>>>> Stashed changes

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _on_navigation_agent_3d_target_reached() -> void:
	if !attacking:
		do_attack()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

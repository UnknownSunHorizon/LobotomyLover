extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var raycast = $HitRaycast
@onready var timer = $Timer
@export var maxhp: int
@export var head_multiplier: float
@export var attack_strength: int
@export var attack_distance: int
@export var speed: float
var hp: int
var shield_broken: bool = false

var searching_for: String

var attacking: bool = false

signal imdead(who)

###ACTIONS
func _ready():
	hp = maxhp
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
			$AttackSound.play()
			$Particles.set_emitting(true)

func _on_timer_timeout() -> void:
	attacking = false
	
func do_nyashify():
	var new_nyashka = load("res://Zondbe/entity_Nyashka.tscn").instantiate()
	new_nyashka.global_transform = self.global_transform
	$DeathSound.play()
	queue_free()
	
###LOGIC
func hit(damage):
	hp -= damage
	if self.is_in_group("Faker"):
		_is_shield_broken()
	if _is_dead():
		$DeathSound.play()
	else:
		$HitSound.play()
		
func _is_shield_broken() -> bool:
	if !shield_broken and hp/maxhp <= 0.75:
		shield_broken = true
		$FakeShieldImage.queue_free()
	return shield_broken

func _on_body_collision_is_hit(damage) -> void:
	hit(damage)
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to body")

func _on_head_collision_is_hit(damage) -> void:
	hit(damage*head_multiplier)
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to head")

func _is_dead() -> bool:
	if hp <= 0:
		imdead.emit(self)
		return true
	else:
		return false

###MOVEMENT
func _physics_process(delta: float) -> void:
	if !attacking: #то ищет врагов
		var nodes = get_tree().get_nodes_in_group(searching_for)
		print(nodes)
		if self.is_in_group("Nyashka"):
			for entity in nodes:
				if entity.is_in_group("Faker"):
					if entity.shield_broken == false:
						nodes.erase(entity)
		print(nodes)
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

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _on_navigation_agent_3d_target_reached() -> void:
	if !attacking:
		do_attack()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

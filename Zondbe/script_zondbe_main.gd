extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var raycast = $HitRaycast
@onready var timer = $Timer
@onready var state = $AnimationTree.get("parameters/playback")

@export var maxhp: int
@export var head_multiplier: float
@export var attack_strength: int
@export var attack_distance: int
@export var speed: float
@export var lookout_distance: int

@export_group("Animations")
@export var animation: AnimationPlayer
@export var idle_state: String
@export var walking_state: String
@export var attack_state: String
@export var hit_state: String
@export var death_state: String

@export var attack_anim: String = "2H_Melee_Attack_Slice"

var hp: int
var shield_broken: bool = false

var searching_for: String

var hitted: bool = false
var cur_closest_node
var kill_counted: bool = false
signal imdead(who)

###ACTIONS
func _ready():
	$NavigationAgent3D.path_max_distance = lookout_distance
	$NavigationAgent3D.target_desired_distance = attack_distance
	state.travel(idle_state)
	hp = maxhp
	if is_in_group("Nyashka"):
		searching_for = "Zondbe"
		get_parent().all_zombies_killed.connect(Callable(self, "no_targets"))
	else:
		if is_in_group("Zondbe"):
			searching_for = "Nyashka"

func no_targets():
	searching_for = "Player"
	print("AREA CLEAR")
	#process_mode = Node.PROCESS_MODE_DISABLED

func do_attack():
	state.travel(attack_state)

	#print("DO ATTACK")
	if !current_state(attack_state):
		if raycast.is_colliding():
			#print("ITS COLLIDING")
			if raycast.get_collider() != null:
				if raycast.get_collider().is_in_group(searching_for):
					#print("ITS IN GROUP ", searching_for)
					#print("ATTACKING = ", attacking)
					raycast.get_collider().hit(attack_strength)
					state.travel(attack_state)
					$AttackSound.play()
					$Particles.set_emitting(true)

func do_nyashify():
	var new_nyashka = load("res://Zondbe/entity_Nyashka.tscn").instantiate()
	new_nyashka.global_transform = self.global_transform
	$DeathSound.play()
	queue_free()
	
###LOGIC
func hit(damage):
	hitted = true
	hp -= damage
	#print(self,hp, get_groups())
	if current_state(idle_state):
		state.travel("Hit")
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
		if kill_counted == false:
			imdead.emit(self)
			kill_counted = true
		return true
	else:
		return false

###MOVEMENT
func _physics_process(delta: float) -> void:
	if !current_state(attack_state): #то ищет врагов
		var nodes = get_tree().get_nodes_in_group(searching_for)
		if self.is_in_group("Nyashka"):
			for entity in nodes:
				if entity.is_in_group("Faker"):
					if entity.shield_broken == false:
						nodes.erase(entity)

		if nodes.size() != 0:
			var closest_node = nodes[0]
			
			for entity in nodes:
				if position.distance_to(entity.global_transform.origin) < position.distance_to(closest_node.global_transform.origin):
					closest_node = entity
			#print(self,closest_node)
			#print(self,position.distance_to(closest_node.global_transform.origin))
			#print(self,closest_node)
			if position.distance_to(closest_node.global_transform.origin) <= lookout_distance:
				state.travel(walking_state)
				#print(self, state.get_current_node())
				update_target_location(closest_node.global_transform.origin)
				#print($NavigationAgent3D.distance_to_target())
				look_at(closest_node.global_transform.origin)
				rotation.x = 0
				var current_location = global_transform.origin
				var next_location = nav_agent.get_next_path_position()
				var new_velocity = (next_location - current_location).normalized() * speed
			
				nav_agent.set_velocity(new_velocity)
			else:
				state.travel(idle_state)
			cur_closest_node = closest_node
		else:
			state.travel(idle_state)
			#if !hitted:
			#	state.travel(hit_state)

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _on_navigation_agent_3d_target_reached() -> void:
	if !current_state(attack_state):
		if searching_for != "Player":
			do_attack()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	var prev_velocity = velocity
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if !current_state(hit_state):
		hitted = false
		
func _on_animation_player_current_animation_changed(name: String) -> void:
	if !current_state(hit_state):
		hitted = false

func current_state(to_check) -> bool:
	if state.get_current_node() == to_check:
		return true
	else:
		return false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	
	#print(self, state.get_current_node())
	if current_state(attack_state):
		#print(self, "   1")
		if anim_name == attack_anim:
			#print(self, "   2")
			state.travel(walking_state)
			#print(self, "   3")
			if self.is_in_group("Nyashka"):
				#print(self, "   4")
				var nodes = get_tree().get_nodes_in_group(searching_for)
				for entity in nodes:
					if entity.is_in_group("Faker"):
						if entity.shield_broken == false:
							nodes.erase(entity)
				if nodes.size() == 0:
					state.travel(idle_state)

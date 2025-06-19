extends Node3D

@onready var player = $XROrigin3D
var nyashka_node = preload("res://Zondbe/entity_Nyashka.tscn")

var xr_interface: XRInterface

@export var Area: int
@export var ZondbeTargetCount: int
@export var ClearPercentage: float = 0.75

var zombie_kill_counter: int = 0

signal area_cleared
signal all_zombies_killed

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	var nyashkas = get_tree().get_nodes_in_group("Nyashka")
	for nyashka in nyashkas:
		if !nyashka.is_in_group("Player"):
			nyashka.imdead.connect(Callable(self, "someone_died"))
	var zondbes = get_tree().get_nodes_in_group("Zondbe")
	for zondbe in zondbes:
		zondbe.imdead.connect(Callable(self, "someone_died"))
	var player = get_tree().get_nodes_in_group("Player")

func someone_died(who):
	if who.is_in_group("Zondbe"):
		print("zondbe died, nya")
		var new_nyashka = nyashka_node.instantiate()
		new_nyashka.global_position = who.global_position
		new_nyashka.global_transform = who.global_transform
		add_child(new_nyashka)
		new_nyashka.imdead.connect(Callable(self, "someone_died"))
		zombie_kill_counter += 1
		is_cleared()
	else:
		if who.is_in_group("Player"):
			print("GAME_OVER")
	if !who.is_in_group("Player"):
		who.queue_free()
	else:
		#print(get_tree().get_current_scene())
		if get_tree():
			get_tree().call_deferred("reload_current_scene")
			print(who.hp)

func is_cleared():
	#print("STARTING CHECKUP")
	var spawners = get_tree().get_nodes_in_group("Spawner")
	#print(spawners)
	var finished_spawning: bool = true
	var max_zondbes: int = 0
	for spawner in spawners:
		max_zondbes += spawner.MaxCount
		if spawner.finished == false:
			finished_spawning = false

	#print("NOW CHECKING ZOMBIES")
	var area_zondbes = get_tree().get_node_count_in_group("Zondbe")
	#print(get_tree().get_nodes_in_group("Zondbe"))
	#print(zombie_kill_counter)
	#print(max_zondbes*(1-ClearPercentage))
	if zombie_kill_counter >= max_zondbes*ClearPercentage and zombie_kill_counter < max_zondbes:
		area_cleared.emit()
		print("AREA COMPLETE")
	if zombie_kill_counter >= max_zondbes:
		all_zombies_killed.emit()
		print("PERFECT AREA COMPLETE")

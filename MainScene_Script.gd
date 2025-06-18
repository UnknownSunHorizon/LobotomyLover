extends Node3D

@onready var player = $XROrigin3D
var nyashka_node = preload("res://Zondbe/entity_Nyashka.tscn")

var xr_interface: XRInterface

@export var Area: int
@export var ZondbeTargetCount: int

signal area_cleared

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
		is_cleared()
	else:
		if who.is_in_group("Player"):
			print("GAME_OVER")
	who.queue_free()

func is_cleared():
	print("STARTING CHECKUP")
	var spawners = get_tree().get_nodes_in_group("Spawner")
	print(spawners)
	var finished_spawning: bool = true
	for spawner in spawners:
		if spawner.finished == false:
			finished_spawning = false
	print(finished_spawning)
	if finished_spawning:
		print("NOW CHECKING ZOMBIES")
		var area_zondbes = get_tree().get_node_count_in_group("Zondbe")
		print(get_tree().get_nodes_in_group("Zondbe"))
		if area_zondbes <= 1:
			area_cleared.emit()
			print("PERFECT AREA COMPLETE")

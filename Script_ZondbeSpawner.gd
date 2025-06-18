extends Node3D

@export var SpawnTime: float
@export var MaxCount: int = 1
@export var EverythingEverywhereAllAtOnce: bool
@export var WaitingForTrigger: bool = false
@export var TriggerNode: Node

@export var SpawningArea: Node

var Area: int
var spawned: int = 0
var finished: bool = false

var zondbe_node = preload("res://Zondbe/entity_Zondbe.tscn")

func _ready() -> void:
	SpawningArea.ready.connect(Callable(self, "area_is_ready"))

func area_is_ready():
	self.Area = SpawningArea.Area
	if !WaitingForTrigger:
		print("NOT WAITING FOR TRIGGET")
		start_spawning()

func start_spawning():
	#print(spawned)
	print("STARTING SPAWNING")
	if EverythingEverywhereAllAtOnce and MaxCount > 0:
		print("EEAAO")
		for i in range(0,MaxCount):
			spawn()
	else:
		print("CONTINUOUSLY")
		spawn()
		$Timer.start(SpawnTime)
		#print(spawned)

func spawn():
	if !finished:
		print("SPAWNING")
		var new_zondbe = zondbe_node.instantiate()
		new_zondbe.add_to_group("Area"+str(self.Area))
		SpawningArea.add_child(new_zondbe)
		print(get_tree().get_nodes_in_group("Zondbe"))
		new_zondbe.global_position = self.global_position
		new_zondbe.global_transform = self.global_transform
		new_zondbe.imdead.connect(Callable(SpawningArea, "someone_died"))
		print(new_zondbe)
		spawned += 1
		print("ZONDBE SPAWNED: " + str(spawned))
		print(get_tree().get_node_count_in_group("Zondbe"))
		if spawned == MaxCount:
			end_spawning()
			print(get_tree().get_nodes_in_group("Zondbe"))

				
func end_spawning():
	$Timer.stop()
	finished = true
	print("ENDED SPAWNING")

func timer_info():
	print(str(self) + "   TIMER WENT OFF    " + str(spawned))

extends Node3D

@onready var player = $XROrigin3D

var xr_interface: XRInterface

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	#get_tree().call_group("Zondbe","update_target_location",player.global_transform.origin)

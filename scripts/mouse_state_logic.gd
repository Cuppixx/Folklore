extends Node #TODO See if the savehandling outside the savesytem can be improved
#Node Overview:
#The mouse logic handles mouse-related signals, including mouse mode, cursor shape, etc."

#region Constants list.
const STATE_CHANGED:String = "\n--> Mouse state changed: "
const FILE_NAME:String = "MouseData"
const PATH_NAME:String = "projectSettings/"
const PARTICLE_TRAIL:Resource = preload("res://scenes/2d/particle_trail_2d.tscn")
#endregion
#region Vars list.
var mouse_data:MouseData
#endregion

func _ready() -> void:
	if SaveSystem.verify_file(FILE_NAME, PATH_NAME) == false:
		mouse_data = MouseData.new()
		update_mouse_mode()
	else: mouse_data = SaveSystem.load_savefile(FILE_NAME, PATH_NAME)

	SignalEventBus.set_mouse_mode.connect(set_mouse_mode)
	SignalEventBus.confined.connect(confined)
	SignalEventBus.reset_controls.connect(reset_controls)

#MouseMode function.
func set_mouse_mode(captured:bool) -> void:
	if captured == true: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		if mouse_data.confined == true: Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if mouse_data.particle_trail == true: add_child(PARTICLE_TRAIL.instantiate())
		else: pass
	printerr(STATE_CHANGED,Input.get_mouse_mode(),"\n")

#region Modify savedata.
func confined(on:bool) -> void:
	mouse_data.confined = on
	update_mouse_mode()

func reset_controls() -> void:
	mouse_data = MouseData.new()
	update_mouse_mode()

func update_mouse_mode() -> void:
	SaveSystem.write_savefile(mouse_data, FILE_NAME, PATH_NAME)
	var is_captured:bool
	match Input.get_mouse_mode():
		2: is_captured = true
		_: is_captured = false
	#After the mouse_data.confined setting got updated,
	#call the set_mouse_mode function with the current 'captured' value.
	set_mouse_mode(is_captured)
#endregion

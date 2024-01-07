extends Node
#Node Overview:
#The mouse logic handles mouse-related signals, including mouse mode, cursor shape, etc."

#region Constants list.
const ERR01:String = "\n--> Couldn't verify mousedata savefile and/or savepath. Loaded and saved default config!\n"
const ERR02:String = "\n--> set_mouse_mode: %s\n"
const FILE_NAME:String = "MouseData"
const PATH_NAME:String = "projectSettings/"
const PARTICLE_TRAIL:Resource = preload("res://scenes/2d/mouse_trail/particle_points_2d.tscn")
#endregion
#region Vars list.
@onready var trail_container:Node = $TrailNodeHolder

var mouse_data:MouseData
var is_mouse_trail_allowed:bool = true
#endregion

func _ready() -> void:
	if SaveSystem.verify_file(FILE_NAME, PATH_NAME) == false:
		mouse_data = MouseData.new()
		_update_mouse_mode()
		printerr(ERR01)
	else: mouse_data = SaveSystem.load_savefile(FILE_NAME, PATH_NAME)
#region Connect functions to signals from the SignalEventBus.
	SignalEventBus.default_mouse_mode.connect(_default_mouse_mode)
	SignalEventBus.set_mouse_mode.connect(_set_mouse_mode)
	SignalEventBus.confined.connect(_confined)
	SignalEventBus.mouse_trail.connect(_trail)
	SignalEventBus.allow_mouse_trail.connect(_allow_mouse_trail)
#endregion

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			#region Disconnect functions to signals from the SignalEventBus.
			SignalEventBus.default_mouse_mode.disconnect(_default_mouse_mode)
			SignalEventBus.set_mouse_mode.disconnect(_set_mouse_mode)
			SignalEventBus.confined.disconnect(_confined)
			SignalEventBus.mouse_trail.disconnect(_trail)
			SignalEventBus.allow_mouse_trail.disconnect(_allow_mouse_trail)
			#endregion
		_:pass

#MouseMode function.
func _set_mouse_mode(captured:bool) -> void:
	if captured == true:
		_safe_free_mouse_trail()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		#Set confined based on user-settings
		if mouse_data.confined == true: Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		#Add mouse trail system if enabled and allowed.
		if mouse_data.particle_trail == true and is_mouse_trail_allowed == true:
			if  trail_container.get_child_count(false) == 0:
				trail_container.add_child(PARTICLE_TRAIL.instantiate(),false,Node.INTERNAL_MODE_DISABLED)
		else: _safe_free_mouse_trail()

	printerr(ERR02 %str(Input.get_mouse_mode()))

#region Internal functions.
func _safe_free_mouse_trail() -> void:
	if trail_container.get_child_count(false) != 0: trail_container.get_child(0,false).queue_free()
func _allow_mouse_trail(allowed:bool) -> void: is_mouse_trail_allowed = allowed
#endregion
#region Modify savedata.
func _default_mouse_mode() -> void: mouse_data = MouseData.new(); _update_mouse_mode()
func _confined(on:bool) -> void: mouse_data.confined = on; _update_mouse_mode()
func _trail(on:bool) -> void: mouse_data.particle_trail = on; _update_mouse_mode()

func _update_mouse_mode() -> void:
	SaveSystem.write_savefile(mouse_data, FILE_NAME, PATH_NAME)
	var is_captured:bool
	match Input.get_mouse_mode():
		2: is_captured = true
		_: is_captured = false
	_set_mouse_mode(is_captured)
#endregion

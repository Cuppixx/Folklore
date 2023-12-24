extends Node2D

var last_mouse_position:Vector2 = Vector2.ZERO
@export var load_offset_time:float = 0.5
@export var offset:Vector2i = Vector2i(35,35)
@export var angle_reach:int = 20
var allow_emitting:bool = false

func _ready() -> void:
	offset = -abs(offset)
	stop_emiting()

	var timer:Timer = Timer.new()
	add_child(timer, false, INTERNAL_MODE_FRONT)
	timer.timeout.connect(set_allow_emitting)
	timer.one_shot = true
	timer.start(load_offset_time)

func set_allow_emitting() -> void:
	allow_emitting = true

#region _process function
func _process(delta: float) -> void:
	var current_mouse_position:Vector2 = get_global_mouse_position()
	var mouse_movement:Vector2 = current_mouse_position - last_mouse_position
	mouse_movement = mouse_movement.normalized()
	print(mouse_movement)
	#region Match after mainmenu loaded
	if allow_emitting == true:
		#match mouse_movement:
		match sign(mouse_movement):
			Vector2(0,-1):
				set_particle(0, 0, 0, -1)
				#print("Moving --> TOP")
			Vector2(1,-1):
				set_particle(1, -45, 1, -1)
				#print("Moving --> TOP-RIGHT")
			Vector2(1,0):
				set_particle(2, -90, 1, 0)
				#print("Moving --> RIGHT")
			Vector2(1,1):
				set_particle(3, -135, 1, 1)
				#print("Moving --> BOTTOM-RIGHT")
			Vector2(0,1):
				set_particle(4, -180, 0, 1)
				#print("Moving --> Bottom")
			Vector2(-1,1):
				set_particle(5, 135, -1, 1)
				#print("Moving --> BOTTOM-LEFT")
			Vector2(-1,0):
				set_particle(6, 90, -1, 0)
				#print("Moving --> LEFT")
			Vector2(-1,-1):
				set_particle(7, 45, -1, -1)
				#print("Moving --> TOP-LEFT")
			Vector2(0,0):
				stop_emiting()
				#print("standing still")
			_: pass
			#endregion
	last_mouse_position = current_mouse_position
#endregion

func set_particle(index:int, angle:int, sign1:int, sign2:int) -> void:
	get_child(index).global_position.x = get_global_mouse_position().x+sign1*offset.x
	get_child(index).global_position.y = get_global_mouse_position().y+sign2*offset.y

	get_child(index).process_material.set("angle_min", angle-angle_reach/2)
	get_child(index).process_material.set("angle_max", angle+angle_reach/2)
	start_emitting_single(index)

func stop_emiting() -> void: for child in get_children(): child.emitting = false
func start_emitting_single(index:int) -> void:
	stop_emiting()
	get_child(index).emitting = true



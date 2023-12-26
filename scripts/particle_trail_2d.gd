extends Node2D

var last_mouse_position:Vector2 = Vector2.ZERO
@export var load_offset_time:float = 0.5
@export var offset:Vector2i = Vector2i(35,35)
@export var angle_reach:int = 10
var allow_emitting:bool = false
var mouse_speed:float

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
	var mouse_movement:Vector2 = round((current_mouse_position - last_mouse_position).normalized() * 10)/10
	mouse_speed = abs((current_mouse_position - last_mouse_position).length())

	mouse_speed = map_value(mouse_speed, 1.0, 100.0, 0.05, 1.0)
	#print(mouse_speed)

	mouse_movement.x = customRound(mouse_movement.x)
	mouse_movement.y = customRound(mouse_movement.y)
	#print(mouse_movement)
	#region Match after mainmenu loaded
	if allow_emitting == true:
		match mouse_movement:
			Vector2(0,-1):
				set_particle(0, 0, 0, -1)
				#print("Moving --> TOP")
			Vector2(0.5,-1):
				set_particle(1, -22.5, 0.5, -1)
				#print("Moving --> TOP-RIGHT1")
			Vector2(1,-1):
				set_particle(2, -45, 1, -1)
				#print("Moving --> TOP-RIGHT2")
			Vector2(1,-0.5):
				set_particle(3, -67.5, 1, -0.5)
				#print("Moving --> TOP-RIGHT3")
			Vector2(1,0):
				set_particle(4, -90, 1, 0)
				#print("Moving --> RIGHT")
			Vector2(1,0.5):
				set_particle(5, -112.5, 1, 0.5)
				#print("Moving --> BOTTOM-RIGHT1")
			Vector2(1,1):
				set_particle(6, -135, 1, 1)
				#print("Moving --> BOTTOM-RIGHT2")
			Vector2(0.5,1):
				set_particle(7, -157.5, 0.5, 1)
				#print("Moving --> BOTTOM-RIGHT3")
			Vector2(0,1):
				set_particle(8, -180, 0, 1)
				#print("Moving --> Bottom")
			Vector2(-0.5,1):
				set_particle(9, 157.5, -0.5, 1)
				#print("Moving --> BOTTOM-LEFT3")
			Vector2(-1,1):
				set_particle(10, 135, -1, 1)
				#print("Moving --> BOTTOM-LEFT2")
			Vector2(-1,0.5):
				set_particle(11, 112.5, -1, 0.5)
				#print("Moving --> BOTTOM-LEFT1")
			Vector2(-1,0):
				set_particle(12, 90, -1, 0)
				#print("Moving --> LEFT")
			Vector2(-1,-0.5):
				set_particle(13, 67.5, -1, -0.5)
				#print("Moving --> TOP-LEFT3")
			Vector2(-1,-1):
				set_particle(14, 45, -1, -1)
				#print("Moving --> TOP-LEFT2")
			Vector2(-0.5,-1):
				set_particle(15, 22.5, -0.5, -1)
				#print("Moving --> TOP-LEFT1")
			#Standing still
			Vector2(0,0):
				stop_emiting()
				#print("standing still")
			_: pass
			#endregion
	last_mouse_position = current_mouse_position
#endregion

func set_particle(index:int, angle:float, sign1:float, sign2:float) -> void:
	get_child(index).global_position.x = get_global_mouse_position().x+sign1*offset.x
	get_child(index).global_position.y = get_global_mouse_position().y+sign2*offset.y

	get_child(index).process_material.set("angle_min", angle-angle_reach/2)
	get_child(index).process_material.set("angle_max", angle+angle_reach/2)
	start_emitting_single(index)

func stop_emiting() -> void: for child:GPUParticles2D in get_children(false): child.emitting = false
func start_emitting_single(index:int, amount_ratio = mouse_speed) -> void:
	stop_emiting()
	get_child(index).emitting = true
	get_child(index).amount_ratio = amount_ratio

func customRound(value):
	var rounding_values:Array = [-1.0, -0.5, 0.5, 1.0]
	if value == 0.0: return 0.0
	else:
		var closest_value:float = rounding_values[0]
		var min_difference:float = abs(value - closest_value)
		for round_value in rounding_values:
			var difference:float = abs(value - round_value)
			if difference < min_difference:
				min_difference = difference
				closest_value = round_value
		return closest_value

func map_value(value_to_map: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	var normalized_value = (value_to_map - from_min) / (from_max - from_min)
	return lerp(to_min, to_max, normalized_value)

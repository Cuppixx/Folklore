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
	timer.timeout.connect(set_allow_amount_ratio)
	timer.one_shot = true
	timer.start(load_offset_time)

func set_allow_amount_ratio() -> void:
	allow_emitting = true

func _process(delta: float) -> void:
	var current_mouse_position:Vector2 = get_global_mouse_position()
	var mouse_movement:Vector2 = current_mouse_position - last_mouse_position
	print(offset)

	#if allow_emitting == true: start_emitting()
	#match sign(mouse_movement):
		#Vector2(1,1):
			##set_particle(0, 0, 0, 0)
			##global_position.x = get_global_mouse_position().x+1*offset.x
			##global_position.y = get_global_mouse_position().y+1*offset.y
			#print("Moving --> BOTTOM-RIGHT")
		#Vector2(1,-1):
			##global_position.x = get_global_mouse_position().x+1*offset.x
			##global_position.y = get_global_mouse_position().y-1*offset.y
			#print("Moving --> TOP-RIGHT")
		#Vector2(-1,1):
			##global_position.x = get_global_mouse_position().x-1*offset.x
			##global_position.y = get_global_mouse_position().y+1*offset.y
			#print("Moving --> BOTTOM-LEFT")
		#Vector2(-1,-1):
			##global_position.x = get_global_mouse_position().x-1*offset.x
			##global_position.y = get_global_mouse_position().y-1*offset.y
			#print("Moving --> TOP-LEFT")
		#Vector2(1,0):
			##global_position.x = get_global_mouse_position().x+1*offset.x
			##global_position.y = get_global_mouse_position().y+0*offset.y
			#print("Moving --> RIGHT")
		#Vector2(-1,0):
			##global_position.x = get_global_mouse_position().x-1*offset.x
			##global_position.y = get_global_mouse_position().y+0*offset.y
			#print("Moving --> LEFT")
		#Vector2(0,1):
			#set_particle(5, 180, 0, 1)
			#print("Moving --> Bottom")
		#Vector2(0,-1):
			#set_particle(1, 0, 0, -1)
			#print("Moving --> TOP")
		#Vector2(0,0):
			#stop_emiting()
			#print("standing still")
		#_:
			#print("Invalid or unknown sign. ",mouse_movement)
#
	#last_mouse_position = current_mouse_position
#
#func set_particle(index:int, angle:int, sign1:int, sign2:int) -> void:
	#global_position.x = get_global_mouse_position().x+sign1*offset.x
	#global_position.y = get_global_mouse_position().y+sign2*offset.y
	#get_child(index).process_material.set("angle_min", angle-angle_reach/2)
	#get_child(index).process_material.set("angle_max", angle+angle_reach/2)
#
#
func stop_emiting() -> void: for child in get_children(): child.emitting = false
func start_emitting() -> void: for child in get_children(): child.emitting = true

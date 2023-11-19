extends CharacterBody3D

#vars speed
var speed:float = 2.7
const SPEED_WALK:float = 1.35
const SPEED_RUN:float = 2.7 #Default State
const SPEED_SPRINT:float = 7.0
const SPEED_CROUCH:float = 0.75
var lerp_speed:float = 4.0
var speed_multiplier:float = 0 #Default 0 -> No change [0.5=50% faster / 0.8=80% faster / 1=100% faster or double the speed]
var speed_multiplier_forwards:float = 2.5

#vars jumping and aerial stuff
var jump_velocity:float = 4.5
var gravity:float = 9.8
var air_movement_value:float = 2.5

#vars camera
var fov_base:float = 75.0
const FOV_MULTIPLY:float = 1.5
var sensitivity:float = 0.004
var cam_ego_clampUp:int = 90 	#Value is set in Degree [90Int=90Degree Clamp]
var cam_ego_clampDown:int = 50	#Value is set in Degree [90Int=90Degree Clamp]
var cam_tilt_value:float = 2.5
var cam_state:bool = false #false -> 1st Person / true -> 3rd Person
var cam_position:Vector3 = Vector3.ZERO

#vars head bobbing
var bob_frequency:float = 2.0
var bob_amplifier:float = 0.08
var bob_time:float = 0.0

#vars other
var direction:Vector3 = Vector3.ZERO
var auto_walk:bool = false

#onready vars
@onready var neck:Node3D = $Neck
@onready var camera:Camera3D = $Neck/Camera3D

func _ready() -> void:
	SignalEventBus.emit_signal("set_mouse_mode", true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(cam_ego_clampDown) * -1, deg_to_rad(cam_ego_clampUp))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SignalEventBus.emit_signal("set_mainmenu", true)
		SignalEventBus.emit_signal("clear_main")

	if Input.is_action_just_pressed("change_fov"):
		if cam_state == false:
			cam_position = Vector3(0.0, 0.0, 0.0)
			cam_state = true
		else:
			cam_position = Vector3(0.0, 0.5, 2.5)
			cam_state = false
		camera.transform.origin = cam_position

	#AutoWalk Code
	if Input.is_action_just_pressed("auto_walk"):
		if auto_walk == false:
			Input.action_press("move_up")
		elif auto_walk == true:
			Input.action_release("move_up")
		auto_walk = !auto_walk

	#Jumping Code
	if not is_on_floor():
		velocity.y -= gravity * delta
	#if Input.is_action_just_pressed("jump") and not is_on_floor():
	#	velocity.y = jump_velocity
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	#Movement Code FirstPerson
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

#	if Input.is_action_pressed("move_up") and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
#		speed_multiplier = speed_multiplier_forwards / 1.3
#	elif Input.is_action_pressed("move_up"):
#		speed_multiplier = speed_multiplier_forwards
#	else:
#		speed_multiplier = 0
	speed_multiplier = speed_multiplier_forwards

	direction = lerp(direction, (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if is_on_floor() == true:
		if direction:
			velocity.x = direction.x * speed * (1+speed_multiplier)
			velocity.z = direction.z * speed * (1+speed_multiplier)
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed * (1+speed_multiplier), delta * air_movement_value)
		velocity.z = lerp(velocity.z, direction.z * speed * (1+speed_multiplier), delta * air_movement_value)

	#Camera Code
	if Input.is_action_pressed("move_left"):
		neck.rotation.z = lerp(neck.rotation.z, deg_to_rad(cam_tilt_value), 0.05)
	elif Input.is_action_pressed("move_right"):
		neck.rotation.z = lerp(neck.rotation.z, deg_to_rad(cam_tilt_value) * -1, 0.05)
	else:
		neck.rotation.z = lerp(neck.rotation.z, 0.0, 0.05)

	bob_time += delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = cam_position + headbob(bob_time)

	#FOV Code
	var velocity_clamped:float = clamp(velocity.length(), 0.5, SPEED_SPRINT * 2)
	var target_fov = fov_base + FOV_MULTIPLY * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func headbob(bob_t:float) -> Vector3:
	var pos:Vector3 = Vector3.ZERO
	pos.y = sin(bob_t * bob_frequency) * bob_amplifier
	pos.x = cos(bob_t * bob_frequency / 2) * bob_amplifier
	return pos

#////////////////////////////////////////////////////////////////////////////////////////////////////

func state_controll() -> void:
	pass
	#await state_enter()
	#await state()
	#await state_leave()

func state_enter() -> void:
	pass

func state() -> void:
	pass

func state_leave() -> void:
	pass

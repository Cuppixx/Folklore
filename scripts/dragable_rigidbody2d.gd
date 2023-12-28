extends RigidBody2D

signal clicked
@export var starting_position:Vector2i = Vector2i(500,500)
@export var rounding_factor:int = 1
var last_mouse_position:Vector2 = Vector2.ZERO
var held = false
var mouse_movement_direction:Vector2
@export var impulse_force:float = 500
@export var impulse_force_additional:float = 100
var screen_limit:Vector2i = Vector2.ZERO
@export var random_start_impulse:bool = true

func _ready() -> void:
	global_position = starting_position
	screen_limit = get_window().size
	if random_start_impulse == true:
		apply_central_impulse(Vector2(randi_range(-1, 1),randi_range(-1, 1)) * impulse_force)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT  and event.pressed:
			if !held:
				print("Picked up")
				pickup()
			else:
				print("Dropped")
				drop(mouse_movement_direction)

func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()

	var current_mouse_position:Vector2 = get_global_mouse_position()
	var diff = current_mouse_position - last_mouse_position
	mouse_movement_direction = round((diff).normalized())
	last_mouse_position = current_mouse_position

	if global_position.x < 0: global_position.x = screen_limit.x-1
	elif global_position.x > screen_limit.x: global_position.x = 1

	if global_position.y > screen_limit.y: global_position.y = 1

func pickup():
	impulse_force += impulse_force_additional
	freeze = true
	held = true

func drop(impulse):
	freeze = false
	apply_central_impulse(impulse * impulse_force)
	held = false

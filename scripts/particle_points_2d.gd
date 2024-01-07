extends Node2D

@onready var sprite_paw:Resource = preload("res://scenes/2d/mouse_trail/sprite_paw.tscn")

#region Export settings.
@export_category("ParticlePoints2d")
@export_group("Sprite Settings")
@export var position_offset:Vector2i = Vector2i(35,35)
@export_range(45,320,5) var sprite_distance:int = 80
@export_range(10,210,5) var max_sprites:int = 70
#endregion
#region Other var and const.
const rounding_factor:float = 100.0
var last_mouse_position:Vector2 = Vector2.ZERO
var can_add_sprite:bool = true
#endregion

func _ready() -> void:
	position_offset = -abs(position_offset)

func _process(_delta:float) -> void:
	var sprite_count:int = get_child_count(false)
	if sprite_count > max_sprites:
		var count_overhead:int = sprite_count - max_sprites
		if count_overhead >= 0: for i:int in count_overhead: get_child(0,false).queue_free()

	var current_mouse_position:Vector2 = get_global_mouse_position()
	var diff:Vector2 = current_mouse_position - last_mouse_position

	var mouse_movement_direction:Vector2 = round((diff).normalized()*rounding_factor)/rounding_factor
	mouse_movement_direction = _custom_round_vec2(mouse_movement_direction)
	match mouse_movement_direction:
		Vector2(0, -1):
			#Mouse moving 'UP'
			_add_sprite(0, 0, -1)
		Vector2(1, -1):
			#Mouse moving 'UP-RIGHT'
			_add_sprite(45, 1, -1)
		Vector2(1, 0):
			#Mouse moving 'RIGHT'
			_add_sprite(90, 1, 0)
		Vector2(1, 1):
			#Mouse moving 'DOWN-RIGHT'
			_add_sprite(135, 1, 1)
		Vector2(0, 1):
			#Mouse moving 'DOWN'
			_add_sprite(180, 0, 1)
		Vector2(-1, 1):
			#Mouse moving 'DOWN-LEFT'
			_add_sprite(-135, -1, 1)
		Vector2(-1, 0):
			#Mouse moving 'LEFT'
			_add_sprite(-90, -1, 0)
		Vector2(-1, -1):
			#Mouse moving 'UP-LEFT'
			_add_sprite(-45, -1, -1)
		#Mouse moving 'NULL' / e.g. standing still.
		Vector2(0,0), _: pass
	last_mouse_position = current_mouse_position

func _add_sprite(angle:int, sign1:int, sign2:int) -> void:
	var x:float = get_global_mouse_position().x+sign1*position_offset.x
	var y:float = get_global_mouse_position().y+sign2*position_offset.y
	var current_position:Vector2 = Vector2(x, y)

	can_add_sprite = true
	for sprite:Sprite2D in get_children(false):
		if (sprite.global_position.distance_to(current_position)) < sprite_distance: can_add_sprite = false

	if can_add_sprite == true:
		var paw:Sprite2D = sprite_paw.instantiate()
		paw.global_position = current_position
		paw.global_rotation_degrees = angle
		add_child(paw,false,Node.INTERNAL_MODE_DISABLED)

func _custom_round_vec2(direction:Vector2) -> Vector2:
	if direction == Vector2.ZERO: return Vector2.ZERO
	var x:float = _custom_round_float(direction.x)
	var y:float = _custom_round_float(direction.y)
	return Vector2(x, y)

func _custom_round_float(value:float) -> float:
	var rounding_values:Array = [-1.0, 0.0, 1.0]
	var closest_value:float = rounding_values[0]
	var min_difference:float = abs(value - closest_value)

	for rounded_value:int in rounding_values:
		var difference:float = abs(value - rounded_value)
		if difference < min_difference: min_difference = difference; closest_value = rounded_value

	return closest_value

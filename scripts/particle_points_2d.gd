extends Node2D

@onready var sprite_paw:Resource = preload("res://scenes/2d/sprite_paw.tscn")

var last_mouse_position:Vector2 = Vector2.ZERO
var mouse_speed:float = 1.0
var rounding_factor:float = 100.0
@export var position_offset:Vector2i = Vector2i(35,35)
@export var sprite_distance:float = 80
@export var max_sprites:float = 70
var can_add_sprite:bool = true

func _ready() -> void: position_offset = -abs(position_offset)

func _process(_delta:float) -> void:
	if get_child_count(false) > max_sprites:
		var diff_count = get_child_count(false) - max_sprites
		if diff_count >= 0:
			for i in diff_count:
				get_child(0,false).queue_free()

	var current_mouse_position:Vector2 = get_global_mouse_position()
	var diff = current_mouse_position - last_mouse_position

	var mouse_movement_distance:Vector2 = round(diff)
	mouse_speed = clamp(abs((mouse_movement_distance).length()),0,1000)

	#print("Mouse Speed: ",mouse_speed)
	mouse_speed = map_value(mouse_speed, 0, 1000, 0.8, 32)
	#print("Mouse Speed after map: ",mouse_speed)

	var mouse_movement_direction:Vector2 = round((diff).normalized()*rounding_factor)/rounding_factor
	mouse_movement_direction = custom_round_vec2(mouse_movement_direction)
	#region Match direction.
	match mouse_movement_direction:
		Vector2(0, -1):
			add_sprite(0, 0, -1)
		Vector2(1, -1):
			add_sprite(45, 1, -1)
		Vector2(1, 0):
			add_sprite(90, 1, 0)
		Vector2(1, 1):
			add_sprite(135, 1, 1)
		Vector2(0, 1):
			add_sprite(180, 0, 1)
		Vector2(-1, 1):
			add_sprite(-135, -1, 1)
		Vector2(-1, 0):
			add_sprite(-90, -1, 0)
		Vector2(-1, -1):
			add_sprite(-45, -1, -1)
		Vector2(0,0): pass # <--- Standing still
		_: pass
		#endregion

	last_mouse_position = current_mouse_position

func add_sprite(angle:float, sign1:float, sign2:float) -> void:
	var current_position:Vector2 = Vector2(get_global_mouse_position().x+sign1*position_offset.x, get_global_mouse_position().y+sign2*position_offset.y)

	can_add_sprite = true
	for sprite in get_children(false):
		if (sprite.global_position.distance_to(current_position)) < sprite_distance: can_add_sprite = false

	if can_add_sprite == true:
		var paw:Sprite2D = sprite_paw.instantiate()
		paw.global_position = current_position
		paw.global_rotation_degrees = angle
		add_child(paw,false,Node.INTERNAL_MODE_DISABLED)

func custom_round_vec2(direction:Vector2) -> Vector2:
	if direction == Vector2.ZERO: return Vector2.ZERO
	var x:float = custom_round_float(direction.x)
	var y:float = custom_round_float(direction.y)
	if x == 0 and y == 0:
		if abs(0-direction.x) >= abs(0-direction.y): x = custom_round_float(direction.x)
		else: y = custom_round_float(direction.y)
	return Vector2(x, y)

func custom_round_float(value:float) -> float:
	var rounding_values:Array = [-1.0, 0.0, 1.0]
	var closest_value:float = rounding_values[0]
	var min_difference:float = abs(value - closest_value)
	for round_value:float in rounding_values:
		var difference:float = abs(value - round_value)
		if difference < min_difference:
			min_difference = difference
			closest_value = round_value
	return closest_value

func map_value(value_to_map: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	var normalized_value = (value_to_map - from_min) / (from_max - from_min)
	return lerp(to_min, to_max, normalized_value)

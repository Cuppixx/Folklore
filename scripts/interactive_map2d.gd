extends Node2D

@onready var area2d:Area2D = $Area2D
@onready var overlay:Node2D = $OverlayLayer

@onready var polygon_overlay:Resource = preload("res://scenes/2d/interavtive_map_polygon_element_overlay.tscn")

var shape_count_array:Array = []

func _ready() -> void:
	var previous_count:int = 0
	var child_count = area2d.get_child_count(false)
	for polygon in child_count:
		apply_overlay(area2d.get_child(polygon).polygon,area2d.get_child(polygon).global_position,polygon)
		var count:int = previous_count + area2d.get_child(polygon).shape_count
		if polygon == 0: count = count-1
		previous_count = count
		shape_count_array.append(count)

func apply_overlay(vec2_array:PackedVector2Array, pos:Vector2, index:int) -> void:
	var instanced_polygon_overlay = polygon_overlay.instantiate()
	instanced_polygon_overlay.polygon_index = index
	instanced_polygon_overlay.polygon = vec2_array
	instanced_polygon_overlay.global_position = pos
	overlay.add_child(instanced_polygon_overlay)

func _on_area_2d_mouse_shape_entered(shape_idx: int) -> void:
	print(shape_idx)
	var first_element = 0
	var last_element = shape_count_array.size()-1
	for i in shape_count_array.size():
		match i:
			first_element:
				if shape_idx >= 0 and shape_idx <= shape_count_array[i]:
					SignalEventBus.emit_signal("in_polygon_area",i,area2d.get_child(i).display_text)
					SignalEventBus.emit_signal("in_polygon_area_get_index",i)
			_:
				if shape_idx > shape_count_array[i-1] and shape_idx <= shape_count_array[i]:
					SignalEventBus.emit_signal("in_polygon_area",i,area2d.get_child(i).display_text)
					SignalEventBus.emit_signal("in_polygon_area_get_index",i)

func _on_area_2d_mouse_entered() -> void: SignalEventBus.emit_signal("is_in_polygon_area", true)
func _on_area_2d_mouse_exited() -> void: SignalEventBus.emit_signal("is_in_polygon_area", false)

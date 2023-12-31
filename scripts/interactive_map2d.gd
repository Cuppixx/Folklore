extends Node2D

@onready var area2d:Area2D = $Area2D
@onready var overlay:Node2D = $OverlayLayer

@onready var polygon_overlay:Resource = preload("res://scenes/2d/interavtive_map_polygon_element_overlay.tscn")

@export var debug_shape_index_enabled:bool = false

var shape_count_array:Array = []
var shape_count_array_all:Array = []

func _ready() -> void:
	var previous_count:int = 0
	var child_count = area2d.get_child_count(false)
	var current_index:int = -1
	for polygon in child_count:
		if area2d.get_child(polygon).is_subregion: pass
		else: current_index += 1

		#apply_overlay(area2d.get_child(polygon).polygon,area2d.get_child(polygon).global_position,area2d.get_child(polygon).index)
		apply_overlay(area2d.get_child(polygon).polygon,area2d.get_child(polygon).global_position,current_index)
		var count:int = previous_count + area2d.get_child(polygon).shape_count
		if polygon == 0: count = count-1
		previous_count = count
		if area2d.get_child(polygon).is_subregion == true:
			#print("Shape Count: ",shape_count_array[polygon-1])
			shape_count_array[shape_count_array.size()-1] += area2d.get_child(polygon).shape_count
		else:
			shape_count_array.append(count)
		shape_count_array_all.append(count)

func apply_overlay(vec2_array:PackedVector2Array, pos:Vector2, index:int) -> void:
	var instanced_polygon_overlay = polygon_overlay.instantiate()
	instanced_polygon_overlay.polygon_index = index
	instanced_polygon_overlay.polygon = vec2_array
	instanced_polygon_overlay.global_position = pos
	overlay.add_child(instanced_polygon_overlay)

func _on_area_2d_mouse_shape_entered(shape_idx: int) -> void:
	if debug_shape_index_enabled == true: print(shape_idx)
	for i in shape_count_array_all.size():
		match i:
			0:
				if shape_idx >= 0 and shape_idx <= shape_count_array_all[i]:
					SignalEventBus.emit_signal("in_polygon_area",i,area2d.get_child(i).display_text)
					#SignalEventBus.emit_signal("in_polygon_area_get_index",i)
			_:
				if shape_idx > shape_count_array_all[i-1] and shape_idx <= shape_count_array_all[i]:
					SignalEventBus.emit_signal("in_polygon_area",i,area2d.get_child(i).display_text)
					#SignalEventBus.emit_signal("in_polygon_area_get_index",i)

	for i in shape_count_array.size():
		match i:
			0:
				if shape_idx >= 0 and shape_idx <= shape_count_array[i]:
					#SignalEventBus.emit_signal("in_polygon_area",i,area2d.get_child(i).display_text)
					SignalEventBus.emit_signal("in_polygon_area_get_index",i)
			_:
				if shape_idx > shape_count_array[i-1] and shape_idx <= shape_count_array[i]:
					#SignalEventBus.emit_signal("in_polygon_area",i,area2d.get_child(i).display_text)
					SignalEventBus.emit_signal("in_polygon_area_get_index",i)

func _on_area_2d_mouse_entered() -> void: SignalEventBus.emit_signal("is_in_polygon_area", true)
func _on_area_2d_mouse_exited() -> void: SignalEventBus.emit_signal("is_in_polygon_area", false)

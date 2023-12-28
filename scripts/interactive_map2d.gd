extends Node2D

var shape_count_array:Array = []

func _ready() -> void:
	var previous_count:int = 0
	var child_count = get_child(0).get_child_count(false)
	for polygon in child_count:
		var count:int = previous_count + get_child(0).get_child(polygon).shape_count
		if polygon == 0: count = count-1
		previous_count = count
		shape_count_array.append(count)

func _on_area_2d_mouse_shape_entered(shape_idx: int) -> void:
	var first_element = 0
	var last_element = shape_count_array.size()-1
	for i in shape_count_array.size():
		match i:
			first_element:
				if shape_idx >= 0 and shape_idx <= shape_count_array[i]:
					SignalEventBus.emit_signal("in_polygon_area",i,get_child(0).get_child(i).display_text)
			_:
				if shape_idx > shape_count_array[i-1] and shape_idx <= shape_count_array[i]:
					SignalEventBus.emit_signal("in_polygon_area",i,get_child(0).get_child(i).display_text)

func _on_area_2d_mouse_entered() -> void: SignalEventBus.emit_signal("is_in_polygon_area", true)
func _on_area_2d_mouse_exited() -> void: SignalEventBus.emit_signal("is_in_polygon_area", false)

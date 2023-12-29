extends Polygon2D

var pm:bool = false
var polygon_index:int
var collision_index:int = -1
var uv_addition:float = 0.0
const uv_speed:float = 0.8
const switch_speed:float = 1.6

func _ready() -> void:
	SignalEventBus.in_polygon_area_get_index.connect(_in_polygon_area_get_index)
	SignalEventBus.is_in_polygon_area.connect(_is_in_polygon_area)
	material = material.duplicate(true)

func _in_polygon_area_get_index(index:int) -> void: collision_index = index

func _is_in_polygon_area(is_in_polygon_area: bool) -> void:
	pm = is_in_polygon_area
	print("On enter and exit: ",pm)
	if is_in_polygon_area == false: collision_index = -1

func _process(delta: float) -> void:
	if pm == true:
		if collision_index == polygon_index:
			uv_addition = min(uv_addition + uv_speed * delta, 2.0)
			material.set_shader_parameter("uv_addition", uv_addition)
		else:
			uv_addition = max(uv_addition - (uv_speed+switch_speed) * delta, 0.0)
			material.set_shader_parameter("uv_addition", uv_addition)
	else:
		if collision_index != polygon_index:
			uv_addition = max(uv_addition - uv_speed * delta, 0.0)
			material.set_shader_parameter("uv_addition", uv_addition)

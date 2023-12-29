extends Polygon2D

var pm:bool = false
var uv_addition:float = 0.0
const uv_speed:float = 0.8

func _ready() -> void: SignalEventBus.is_in_polygon_area.connect(_is_in_polygon_area)

func _is_in_polygon_area(is_in_polygon_area: bool) -> void: pm = is_in_polygon_area

func _process(delta: float) -> void:
	if pm:uv_addition = min(uv_addition + uv_speed * delta, 2.0)
	else: uv_addition = max(uv_addition - uv_speed * delta, 0.0)

	material.set_shader_parameter("uv_addition", uv_addition)

extends TextureRect

@export var crosshair:int = 5
const icon:Resource = preload("res://icon.svg")
@onready var tex2d:Texture2D = icon
var array = PackedVector2Array([Vector2(10, 0), Vector2(0, 10), Vector2(-10, 0), Vector2(0, -10)])
var arrayII = PackedVector2Array([Vector2.ZERO, Vector2(10, 0), Vector2.ZERO, Vector2(0, 10), Vector2.ZERO, Vector2(-10, 0), Vector2.ZERO, Vector2(0, -10)])



func _draw() -> void:
	match crosshair:
		0:
			draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
		1:
			#draw_polygon($"../../../../Worldspace2d/Polygon2D".polygon, PackedColorArray([Color.RED]))
			draw_polygon(array, PackedColorArray([Color.WHITE]))
		2:
			draw_arc(Vector2.ZERO, 5.0, deg_to_rad(0.0), deg_to_rad(360.0),100, Color.RED, 3.0)
		3:
			draw_texture(tex2d, Vector2(-tex2d.get_height()/2, -tex2d.get_height()/2), Color.RED)
		4:
			draw_line(Vector2(-5, 0), Vector2(5, 0), Color.RED, 3.0)
		5:
			print(position)
			draw_polyline(arrayII, Color.RED, -3.0)
		6:
			draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
			var default_font = ThemeDB.fallback_font
			var default_font_size = ThemeDB.fallback_font_size
			draw_string(default_font, Vector2(50,-50), "Mountain Flower", HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

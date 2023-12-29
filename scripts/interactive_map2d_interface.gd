extends Control

@onready var textbox = $Label
var connection_rid
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	SignalEventBus.in_polygon_area.connect(_in_polygon_area)
	SignalEventBus.is_in_polygon_area.connect(_is_in_polygon_area)

func _in_polygon_area(polygon_index:int, display_text:String) -> void:
	textbox.text = display_text
	textbox.set_anchors_preset(Control.PRESET_CENTER, true)
func _is_in_polygon_area(is_in_polygon_area:bool) -> void: visible = is_in_polygon_area


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			print("\n--> Freeing the InteractiveMap2d Interface\n")
			SignalEventBus.in_polygon_area.disconnect(_in_polygon_area)
			SignalEventBus.is_in_polygon_area.disconnect(_is_in_polygon_area)
			get_child(0).queue_free()
			queue_free()

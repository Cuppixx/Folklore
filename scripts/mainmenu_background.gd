extends Node

const BACKGROUND_3D:Resource = preload("res://scenes/3d/maps/mainmenu_background_3d.tscn")
const BACKGROUND_2D:Resource = preload("res://scenes/2d/mainmenu_background_2d.tscn")

const BACKGROUND_CHANGED:String = "\n--> Mainmenu background changed\n"

func _ready() -> void:
	SignalEventBus.set_background_dimension.connect(set_background_dimension)

func set_background_dimension(three_dimensional:bool) -> void:
	if get_child_count(false) != 0:
		var child := get_child(0,false)
		child.queue_free()

	match three_dimensional:
		true:  self.add_child(BACKGROUND_3D.instantiate(),false,Node.INTERNAL_MODE_DISABLED)
		false: self.add_child(BACKGROUND_2D.instantiate(),false,Node.INTERNAL_MODE_DISABLED)
	printerr(BACKGROUND_CHANGED)


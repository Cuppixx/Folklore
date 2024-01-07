extends Node

#region Constants list.
const ERR01:String = "\n--> Interface nodes changed"
const ERR02:String = "\nCouldn't find %s by name! Couldn't free %s!\nEnsure the node exists and/or the trial-name is set correctly!\n"
#endregion
#region Define internal modes.
const INTERNAL_B:Node.InternalMode = Node.INTERNAL_MODE_BACK
const INTERNAL_D:Node.InternalMode = Node.INTERNAL_MODE_DISABLED
const INTERNAL_F:Node.InternalMode = Node.INTERNAL_MODE_FRONT
#endregion
#region Resources.
const MAINMENU:Resource = preload("res://scenes/control/mainmenu.tscn")
const HUD:Resource = preload("res://scenes/control/hud.tscn")
#endregion

#Ready function.
func _ready() -> void:
	SignalEventBus.enable_ui.connect(_match_ui_element)

#Notification handling.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED: printerr(ERR01); print_tree_pretty()
		NOTIFICATION_PREDELETE:
			SignalEventBus.enable_ui.disconnect(_match_ui_element)
		_:pass

func _enable_ui_element(free_internal:bool,resource:Resource,readable:bool=false,internal:Node.InternalMode=Node.INTERNAL_MODE_DISABLED) -> void:
	for node in get_children(free_internal): node.queue_free()
	add_child(resource.instantiate(),readable,internal)

#Functions for connected signals.
func _match_ui_element(element:String) -> void:
	match element:
		"MainMenu":
			_enable_ui_element(true,MAINMENU,false,INTERNAL_F)
		"Hud":
			_enable_ui_element(true,HUD,false,INTERNAL_F)
		"PauseMenu":
			pass
		"OptionsMenu":
			pass

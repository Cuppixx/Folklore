extends Node

#Constants list. #Output messages.
const ERR01:String = "\n--> Interface nodes changed\n"
const ERR02:String = "The path name differs from the actual path\nEnsure that all variables have the correct path assigned"

#Define internal modes.
const INTERNAL_B:Node.InternalMode = Node.INTERNAL_MODE_BACK
const INTERNAL_D:Node.InternalMode = Node.INTERNAL_MODE_DISABLED
const INTERNAL_F:Node.InternalMode = Node.INTERNAL_MODE_FRONT

#Resources and path names for nodes.
const MAINMENU:Resource = preload("res://scenes/control/mainmenu.tscn"); const MAINMENU_PATH_NAME:String = "MainMenu"

#Ready function.
func _ready() -> void:
	#Connect functions to signals from the SignalEventBus.
	SignalEventBus.set_mainmenu.connect(set_mainmenu)

#Notification handling.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED: printerr(ERR01); print_tree_pretty()

#Normal functions.
func custom_add_child(resource:Resource,readable:bool = false,internal:Node.InternalMode = INTERNAL_D) -> void:
	#custom_add_child only works when adding resources to self. If you want to add resources to other nodes from this node (within this script),
	#please refer to the actual add_child method.
	add_child(resource.instantiate(),readable,internal)

func verify_node_path(path:String) -> Node:
	#Retrieve the node or null. If the path returns null, push an error. If the path is valid return the node.
	var current_path := get_node_or_null(path)
	if current_path == null: push_error(ERR02)
	return current_path

#Functions for connected signals.
func set_mainmenu(enabled:bool) -> void:
	match enabled:
		true:
			#If enabled is true, remove all children of the main scene that are NOT marked as internal first, and then add the mainmenu scene.
			#This exclusion is important because it avoids removing key nodes (added with the INTERNAL_MODE_FRONT flag),
			#which are not intended to be removed upon going to the mainmenu.
			for node in get_children(false):
				node.queue_free()
			custom_add_child(MAINMENU,false,INTERNAL_D)
		false:
			#Before freeing, verify the mainmenu path is valid (Node exists).
			var mainmenu:Control = verify_node_path(MAINMENU_PATH_NAME)
			mainmenu.queue_free()

#func set_inventory_selection() -> void:
#	pass
#
#func set_inventory_items() -> void:
#	pass
#
#func set_inventory_magic() -> void:
#	pass
#
#func set_inventory_stats() -> void:
#	pass

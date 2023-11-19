extends Node
#Node overview:
#The main node is responsible for initializing the game's core nodes and scenes.
#On startup, it automatically adds any essential nodes.
#It also manages the worldspace and adds or removes it at runtime, depending on whether the player is ingame or on the mainmenu.

#Constants list.

#Output messages.
const ERR01:String = "\n--> Received a close request\n"
const ERR02:String = "\n--> Received a crash notification\n"
const ERR03:String = "No handling defined for the received notification: "
const ERR04:String = "The path name differs from the actual path\nEnsure that all variables have the correct path assigned"

#Define internal modes.
const INTERNAL_B:Node.InternalMode = Node.INTERNAL_MODE_BACK
const INTERNAL_D:Node.InternalMode = Node.INTERNAL_MODE_DISABLED
const INTERNAL_F:Node.InternalMode = Node.INTERNAL_MODE_FRONT

#Resources for essential nodes.
const SAVE_SYSTEM:Resource = preload("res://scenes/save_system.tscn")
const MOUSE_STATE_LOGIC:Resource = preload("res://scenes/mouse_state_logic.tscn")
const INPUT_HANDLER:Resource = preload("res://scenes/input_handler.tscn")
const AUDIO_MANAGER:Resource = preload("res://scenes/audio_manager.tscn")
const INTERFACE_REGISTRY:Resource = preload("res://scenes/interface_registry.tscn")

#Resources for non-essential nodes.
const WORLDSPACE3D:Resource = preload("res://scenes/3d/worldspace3d.tscn")

#Ready function.
func _ready() -> void:
	#Add the essential nodes that are always required.
	#The save system should always come first so that other nodes can load their data accordingly.
	custom_add_child(SAVE_SYSTEM,false,INTERNAL_F)
	custom_add_child(MOUSE_STATE_LOGIC,false,INTERNAL_F)
	custom_add_child(INPUT_HANDLER,false,INTERNAL_F)
	custom_add_child(AUDIO_MANAGER,false,INTERNAL_F)
	custom_add_child(INTERFACE_REGISTRY,false,INTERNAL_B)

	#Perform the initial setup for the game.
	get_tree().set_auto_accept_quit(false)
	SignalEventBus.emit_signal("set_mainmenu",true)

	#Connect functions to signals from the SignalEventBus.
	SignalEventBus.quit_game.connect(quit_game)
	#After connecting the signal, manually call the connected function clear_main.
	#This operation clears all non-essential nodes.
	SignalEventBus.clear_main.connect(clear_main); clear_main()

	SignalEventBus.new_game.connect(new_game)

#Notification handling.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: printerr(ERR01); get_tree().quit(0)
		NOTIFICATION_CRASH: push_error(ERR02)
		NOTIFICATION_CHILD_ORDER_CHANGED: print_tree_pretty()
		NOTIFICATION_PREDELETE: pass
		_: push_warning(ERR03, what)

#Normal functions.
func custom_add_child(resource:Resource,readable:bool,internal:Node.InternalMode) -> void:
	#custom_add_child only works when adding resources to self!!!
	#If you want to add resources to other nodes from this node (within this script), please refer to the actual add_child method.
	add_child(resource.instantiate(),readable,internal)

#Functions for connected signals.
func quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func clear_main() -> void: for node in get_children(false): node.queue_free()

func new_game(tutorial:bool) -> void:
	add_child(WORLDSPACE3D.instantiate(),false,INTERNAL_D)
	#custom_add_child(WORLDSPACE3D,false,INTERNAL_D)

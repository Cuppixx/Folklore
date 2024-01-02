extends Node
#Node overview:
#The main node is responsible for initializing the game's core nodes and scenes.
#On startup, it automatically adds any essential nodes.
#It also manages the worldspace and adds or removes it at runtime, depending on whether the player is ingame or in the mainmenu.

#region Constants list.
#region Output messages.
const ERR01:String = "\n--> Received a close request\n"
const ERR02:String = "\n--> Received a crash notification\n"
const ERR03:String = "No handling defined for the received notification: "
const ERR04:String = "\n--> Received a destructor notification. Destroying instance of \"Main\"\n"
const ERR05:String = "\n--> All nodes have been successfully removed from the tree! Quitting now!\n"
#endregion
#region Define internal modes.
const INTERNAL_B:Node.InternalMode = Node.INTERNAL_MODE_BACK
const INTERNAL_D:Node.InternalMode = Node.INTERNAL_MODE_DISABLED
const INTERNAL_F:Node.InternalMode = Node.INTERNAL_MODE_FRONT
#endregion
#region Resources for essential nodes.
const MOUSE_STATE_LOGIC:Resource = preload("res://scenes/mouse_state_logic.tscn")
const AUDIO_MANAGER:Resource = preload("res://scenes/audio_manager.tscn")
const INTERFACE_REGISTRY:Resource = preload("res://scenes/interface_registry.tscn")
const LOADING_SCREEN_MANAGER:Resource = preload("res://scenes/loading_screen_manager.tscn")
#endregion
#region Resources for non-essential nodes.
const WORLDSPACE3D:Resource = preload("res://scenes/3d/worldspace3d.tscn")
#endregion
#endregion

#Ready function.
func _ready() -> void:
	#region Add the essential nodes that are always required.
	_custom_add_child(LOADING_SCREEN_MANAGER,false,INTERNAL_B)
	#TODO: Once the LOADING_SCREEN_MANAGER is implemented, ensure that the _ready() function initiates the startup screen,
	#displaying essential information such as "Made by...", "Developed in...", and a flashing light warning.

	_custom_add_child(MOUSE_STATE_LOGIC,false,INTERNAL_F)
	_custom_add_child(AUDIO_MANAGER,false,INTERNAL_F)
	_custom_add_child(INTERFACE_REGISTRY,false,INTERNAL_B)
	#endregion

	#region Perform the initial setup for the game.
	get_tree().set_auto_accept_quit(false)
	#TODO: Develop a save file mechanism to store fundamental startup settings, including resolution,
	#video settings, game preferences, and any other settings not covered by existing nodes.
	SignalEventBus.emit_signal("enable_mainmenu",true)
	#endregion

	#region Connect functions to signals from the SignalEventBus.
	SignalEventBus.quit_game.connect(_quit_game,1)
		#After connecting to the signal 'clear_main', manually call the connected function _clear_main.
		#This operation clears all non-essential nodes.
	SignalEventBus.clear_main.connect(_clear_main,1); _clear_main()
	SignalEventBus.new_game.connect(_new_game,1)
	#endregion

#region Notification handling.
func _notification(what:int) -> void:
	match what:
		#NOTIFICATION_PREDELETE is triggered just before a node is removed from memory
		#using queue_free() or free(), allowing for custom cleanup operations.
			#NOTIFICATION_PREDELETE also triggers when a parent node is freed in Godot's node lifecycle.
			#It ensures cleanup operations before the node's removal during depth-first traversal.
		NOTIFICATION_PREDELETE:
			printerr(ERR04)
			#region Disconnect functions to signals from the SignalEventBus.
			SignalEventBus.quit_game.disconnect(_quit_game)
			SignalEventBus.clear_main.disconnect(_clear_main)
			SignalEventBus.new_game.disconnect(_new_game)
			#endregion

		NOTIFICATION_WM_CLOSE_REQUEST:
			printerr(ERR01)
			queue_free()

		NOTIFICATION_CRASH:
			#printerr(ERR02)
			push_error(ERR02)
			#TODO: Implement a fallback system to signal high-value nodes for saving settings,
			#such as player stats, quest progression, etc.
			#MAKE SURE ... NOTIFICATION_CRASH actually works before implementation.
			get_tree().quit(1)

		NOTIFICATION_CHILD_ORDER_CHANGED: print_tree_pretty()
		_: push_warning(ERR03, what)
#endregion
#region Internal functions.
func _custom_add_child(resource:Resource,readable:bool,internal:Node.InternalMode) -> void:
		#The _custom_add_child() func only works when adding resources to self.
		#If you want to add resources to other nodes from this node (within this script), please refer to the actual add_child method.
	add_child(resource.instantiate(),readable,internal)
#endregion
#region Functions for connected signals.
func _quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _clear_main() -> void:
	for node in get_children(false): node.queue_free()

#TODO: Relocate the "new game" logic away from the main node to the worldspace (mapmanager?).
#Keep only the base worldspace logic (add worldspace only) in this node.
#Currently "new game" logic is located here for easier debugging
func _new_game(tutorial:bool) -> void:
	_custom_add_child(WORLDSPACE3D,false,INTERNAL_D)
func _enable_worldspace3d() -> void: pass
func _remove_worldspace3d() -> void: pass

func _on_tree_exited() -> void:
	printerr(ERR05)
	get_tree().quit(0)
#endregion

extends Control

#References.
@onready var menu_box:MarginContainer = $MenuBox
@onready var menumusicsettings_box:MarginContainer = $MenuMusicSettingsBox
@onready var feedbacklink_box:MarginContainer = $FeedbackLinkBox
@onready var changelog_box:MarginContainer = $ChangelogBox

@onready var switchmenu_button:CheckButton = $MenuBox/MenuBox/SwitchMenu

#IntroBox references.
@onready var intro_box:MarginContainer = $IntroBox
@onready var intro_label:Label = $IntroBox/VBoxContainer/Label
@onready var intro_button_yes:Button = $IntroBox/VBoxContainer/HBoxContainer/Yes
@onready var intro_button_no:Button = $IntroBox/VBoxContainer/HBoxContainer/No
@onready var intro_button_back:Button = $IntroBox/VBoxContainer/HBoxContainer/Back

#Current phase variable and its corresponding displaytext for nodes.
var current_phase:int = 0
const PHASE0TEXT_LABEL:String = "Would you like to play the game introduction?"
const PHASE1TEXT_LABEL:String = "Warning: The introduction is a crucial part of the experience! Do you want to continue without the introduction?"
const PHASE0TEXT_YES:String = "Yes"
const PHASE1TEXT_YES:String = "Continue"
const PHASE0TEXT_NO:String = "No"
const PHASE1TEXT_NO:String = "Go Back"
const PHASE0TEXT_BACK:String = "Back"

@export var menu_bg_3d:bool = false

func _ready() -> void:
	SignalEventBus.emit_signal("mouse_trail", true)
	SignalEventBus.emit_signal("set_mouse_mode", false)
	introbox_visibility(false)
	SignalEventBus.emit_signal("set_background_dimension", menu_bg_3d)

#IntroBox functions.
func introbox_visibility(visibility:bool) -> void:
	match visibility:
		true:
			intro_box.process_mode = Node.PROCESS_MODE_INHERIT
			intro_box.visible = true
		false:
			intro_box.process_mode = Node.PROCESS_MODE_DISABLED
			intro_box.visible = false

func introbox_text(phase_num:int) -> void:
	match phase_num:
		0: intro_label.text = PHASE0TEXT_LABEL; intro_button_yes.text = PHASE0TEXT_YES; intro_button_no.text = PHASE0TEXT_NO; intro_button_back.text = PHASE0TEXT_BACK
		1: intro_label.text = PHASE1TEXT_LABEL; intro_button_yes.text = PHASE1TEXT_YES; intro_button_no.text = PHASE1TEXT_NO

func toggle_base_elements(on:bool) -> void:
	match on:
		false:
			menu_box.process_mode = Node.PROCESS_MODE_DISABLED
			menumusicsettings_box.process_mode = Node.PROCESS_MODE_DISABLED
			feedbacklink_box.process_mode = Node.PROCESS_MODE_DISABLED
			changelog_box.process_mode = Node.PROCESS_MODE_DISABLED
		true:
			menu_box.process_mode = Node.PROCESS_MODE_INHERIT
			menumusicsettings_box.process_mode = Node.PROCESS_MODE_INHERIT
			feedbacklink_box.process_mode = Node.PROCESS_MODE_INHERIT
			changelog_box.process_mode = Node.PROCESS_MODE_INHERIT

#Mainmenu signals.
func _on_new_pressed() -> void:
	current_phase = 0
	introbox_text(current_phase)
	introbox_visibility(true)
	toggle_base_elements(false)

func _on_yes_pressed() -> void:
	var bool_temp:bool
	match current_phase:
		0: bool_temp = true
		1: bool_temp = false
	SignalEventBus.emit_signal("new_game", bool_temp)
	SignalEventBus.emit_signal("set_mainmenu", false)

func _on_no_pressed() -> void:
	match current_phase:
		0: current_phase = 1; intro_button_back.visible = false
		1: current_phase = 0; intro_button_back.visible = true
	introbox_text(current_phase)

func _on_back_pressed() -> void: introbox_visibility(false); toggle_base_elements(true)

func _on_quit_pressed() -> void: SignalEventBus.emit_signal("quit_game")

func _on_switch_menu_pressed() -> void:
	match switchmenu_button.button_pressed:
		true:
			menu_box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			menu_box.set_position(Vector2(get_viewport().size.x - menu_box.size.x ,get_viewport().size.y - menu_box.size.y),false)
		false:
			menu_box.set_anchors_preset(Control.PRESET_CENTER)
			menu_box.set_position(Vector2(get_viewport().size.x/2 - menu_box.size.x/2 ,get_viewport().size.y/2 - menu_box.size.y/2),false)











func _on_check_button_toggled(button_pressed: bool) -> void:
	match button_pressed:
		true: SignalEventBus.emit_signal("confined", true)
		false: SignalEventBus.emit_signal("confined", false)

func _on_check_button_2_pressed() -> void:
	SignalEventBus.emit_signal("reset_controls")

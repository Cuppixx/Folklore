extends Control

@onready var info_label:Label = $CanvasLayer/CenterContainer/VBoxContainer/Info
@onready var pause_button:Button = $CanvasLayer/CenterContainer/VBoxContainer/Pause
@onready var pause_timer:Timer = $PauseTimer
var info_text:String = "Pause allowed in %s"
var pause:String = "Pause"
var unpause:String = "Unpause"

func _ready() -> void:
	SignalEventBus.emit_signal("allow_mouse_trail", false)
	SignalEventBus.emit_signal("set_mouse_mode", false)
	pause_button.text = pause
	pause_button.disabled = true

func _on_pause_timer_timeout() -> void:
	pause_button.disabled = false

func _process(_delta: float) -> void:
	info_label.text = info_text%str(int(pause_timer.time_left))

func _on_pause_pressed() -> void:
	if get_tree().paused == false:
		pause_button.text = unpause
		get_tree().paused = true
	else:
		pause_button.text = pause
		get_tree().paused = false

func _on_resume_pressed() -> void:
	_unpause_tree()
	SignalEventBus.emit_signal("allow_mouse_trail", false)
	SignalEventBus.emit_signal("set_mouse_mode", true)
	self.queue_free()

func _on_options_pressed() -> void:
	pass

func _on_feedback_pressed() -> void:
	pass

func _on_menu_pressed() -> void:
	_unpause_tree()
	SignalEventBus.emit_signal("enable_ui","MainMenu")
	SignalEventBus.emit_signal("clear_main")

func _on_quit_pressed() -> void:
	_unpause_tree()
	SignalEventBus.emit_signal("quit_game")

func _unpause_tree() -> void:
	if get_tree().paused == true: get_tree().paused = false

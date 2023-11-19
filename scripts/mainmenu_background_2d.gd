extends Node2D

#Node references. #Timer.
@onready var timer_main:Timer = $TimerContainer/TimerLightningOne
@onready var timer_secd:Timer = $TimerContainer/TimerLightningTwo

#Lightning.
@onready var lightning_main1:GPUParticles2D = $BackgroundCanvas/CenterContainer/LightningMain
@onready var lightning_main2:GPUParticles2D = $BackgroundCanvas/CenterContainer/LightningMainII
@onready var lightning_secd1:GPUParticles2D = $BackgroundCanvas/ControlTop/LightningSub
@onready var lightning_secd2:GPUParticles2D = $BackgroundCanvas/ControlTop/LightningSubII

#Others.
@export var timer_duration:int = 3
@export var lightning_main_amount_min:int = 1
@export var lightning_main_amount_max:int = 2

#When the timer times out, trigger the emit function with the appropriate parameters.
func _on_timer_lightning_main_timeout() -> void: emit_lightning(lightning_main1, lightning_main2, timer_main)
func _on_timer_lightning_secd_timeout() -> void: emit_lightning(lightning_secd1, lightning_secd2, timer_secd)

func emit_lightning(lightning1:GPUParticles2D, lightning2:GPUParticles2D, timer:Timer) -> void:
	#Calculate random timer duration, based on the set timer duration and duration+1.
	var timer_duration_plus_1:int = timer_duration + 1
	var random_duration:int = randi_range(timer_duration, timer_duration_plus_1)
	match random_duration:
		#Based on the duration match emit lightning 1 or 2.
		timer_duration: lightning1.emitting = true
		timer_duration_plus_1: lightning2.emitting = true
	timer.start(random_duration) #Start timer with random duration.

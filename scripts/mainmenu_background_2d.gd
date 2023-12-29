extends Node2D

#get_child(index).process_material.set("angle_min", angle-angle_reach/2) #<-- used to acess the gpu settings

#Node references. #Timer.
@onready var timer_main:Timer = $TimerContainer/TimerLightningOne
@onready var timer_secd:Timer = $TimerContainer/TimerLightningTwo

#Weather.
@onready var lightning_main1:GPUParticles2D = $BackgroundCanvas/CenterContainer/LightningMain
@onready var lightning_main2:GPUParticles2D = $BackgroundCanvas/CenterContainer/LightningMainII
@onready var lightning_secd1:GPUParticles2D = $BackgroundCanvas/ControlTop/LightningSub
@onready var lightning_secd2:GPUParticles2D = $BackgroundCanvas/ControlTop/LightningSubII

@onready var clouds_base:GPUParticles2D = $BackgroundCanvas/ControlTop/CloudsBase
@onready var clouds_overlay:GPUParticles2D = $BackgroundCanvas/ControlTop/CloudsOverlay

@onready var precipitation:GPUParticles2D = $BackgroundCanvas/ControlTop/Precipitation

#Others.
@export var timer_duration:int = 3

const clouds_color_default:Color = Color("ddb8913a")

const clouds_color_light:Color = Color("eeeef5d2")
const clouds_color_light_hue_min:float = 0.0
const clouds_color_light_hue_max:float = 0.0

const clouds_color_light_thin:Color = Color("fcf1ff54")

const clouds_color_dark:Color = Color("0e0e2de6")
const clouds_color_dark_hue_min:float = -0.5
const clouds_color_dark_hue_max:float = 1.0

const clouds_color_dark_thin:Color = Color("62007553")

const clouds_color_ash:Color = Color("733a3576")

var lightning_enabled:bool = false

func _ready() -> void:
	precipitation.emitting = false

	var random_int_clouds:int
	random_int_clouds = randi_range(0, 5)
	random_int_clouds = 2

	match random_int_clouds:
		0:
			set_cloud_material(clouds_color_default)
		1:
			set_cloud_material(clouds_color_light, clouds_color_light_hue_min, clouds_color_light_hue_max)
			set_precipitation_material(800,1000)
		2:
			set_cloud_material(clouds_color_light_thin)
			set_precipitation_material(200,400)
		3:
			set_cloud_material(clouds_color_dark, clouds_color_dark_hue_min, clouds_color_dark_hue_max)
			set_precipitation_material()
			lightning_enabled = true
		4:
			set_cloud_material(clouds_color_dark_thin)
		5:
			set_cloud_material(clouds_color_ash)
		_:
			set_cloud_material(clouds_color_default)

func set_cloud_material(color: Color, hue_min: float = -0.01, hue_max: float = 0.01) -> void:
	clouds_base.process_material.set("color", color)
	clouds_base.process_material.set("hue_variation_min", hue_min)
	clouds_base.process_material.set("hue_variation_max", hue_max)
	clouds_overlay.process_material.set("color", color)
	clouds_overlay.process_material.set("hue_variation_min", hue_min)
	clouds_overlay.process_material.set("hue_variation_max", hue_max)

func set_precipitation_material(amount_min:int = 1000, amount_max:int = 1000) -> void:
	precipitation.emitting = true
	var random_int_precipitation:int = randi_range(amount_min,amount_max)
	precipitation.amount = random_int_precipitation

#When the timer times out, trigger the emit function with the appropriate parameters.
func _on_timer_lightning_main_timeout() -> void: if lightning_enabled == true: emit_lightning(lightning_main1, lightning_main2, timer_main)
func _on_timer_lightning_secd_timeout() -> void: if lightning_enabled == true: emit_lightning(lightning_secd1, lightning_secd2, timer_secd)

func emit_lightning(lightning1:GPUParticles2D, lightning2:GPUParticles2D, timer:Timer) -> void:
	#Calculate random timer duration, based on the set timer duration and duration+1.
	var timer_duration_plus_1:int = timer_duration + 1
	var random_duration:int = randi_range(timer_duration, timer_duration_plus_1)
	match random_duration:
		#Based on the duration match emit lightning 1 or 2.
		timer_duration: lightning1.emitting = true
		timer_duration_plus_1: lightning2.emitting = true
	timer.start(random_duration) #Start timer with random duration.

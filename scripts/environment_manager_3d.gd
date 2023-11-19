extends Node

class_name environment_manager

@export var camera:Camera3D
@onready var sun = $"SunMoonRotationFix/Sun"
var visible:bool
var sun_direction:Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	sun_direction = sun.global_transform.basis.z * maxf(camera.near, 1.0)
	sun_direction += camera.global_transform.origin

	visible = not camera.is_position_behind(sun_direction)
	if visible == true:
		var unprojected_sun_position:Vector2 = camera.unproject_position(sun_direction)
		$"SunFlare/SunFlare".material.set_shader_parameter("sun_position", unprojected_sun_position)


func _on_world_time_timeout() -> void:
	$SunMoonRotationFix/Sun.rotate_x(deg_to_rad(1))
	if $SunMoonRotationFix/Sun.rotation.x >= 180:
		$SunMoonRotationFix/Sun.rotation.x = -180

extends Node

class_name environment_manager

@export var camera:Camera3D
@onready var rot_axis = $SunMoonRotationFix
@onready var sun = $SunMoonRotationFix/Sun
@onready var moon = $SunMoonRotationFix/Moon
var visible:bool
var sun_direction:Vector3

const sun_energy:float = 0.7
const moon_energy:float = 0.385

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	sun_direction = sun.global_transform.basis.z * maxf(camera.near, 1.0)
	sun_direction += camera.global_transform.origin

	visible = not camera.is_position_behind(sun_direction)
	var unprojected_sun_position:Vector2 = camera.unproject_position(sun_direction)
	$"SunFlare/SunFlare".material.set_shader_parameter("sun_position", unprojected_sun_position)

func _on_world_time_timeout() -> void:
	rot_axis.rotate_x(deg_to_rad(1))
	#print("ROTATION	"+str(rad_to_deg(rot_axis.global_rotation.x)))
	#print("SUN		"+str(rad_to_deg(sun.global_rotation.x)))
	#print("MOON		"+str(rad_to_deg(moon.global_rotation.x)))

	if is_equal_approx(rad_to_deg(rot_axis.global_rotation.x), 90.0):
		sun.light_energy = 0
		moon.light_energy = moon_energy
		#print("------------------------------------------------------SUNDOWN")
	if is_equal_approx(rad_to_deg(rot_axis.global_rotation.x), -90.0):
		sun.light_energy = sun_energy
		moon.light_energy = 0
		#print("------------------------------------------------------SUNDUP")

	if rot_axis.rotation.x >= 360:
		rot_axis.rotation.x = 0

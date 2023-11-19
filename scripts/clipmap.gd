extends StaticBody3D

const TERRAIN:Resource = preload("res://scenes/3d/clipmap_mesh.tscn")
@onready var terrain:MeshInstance3D = $ClipmapMesh
@onready var mesh_size:Vector2 = Vector2.ONE * terrain.mesh_square_size

var player:CharacterBody3D
var player_position:Vector3 = Vector3.ZERO

@export var endless_terrain:bool = false
@export var generate_lod:bool = true
@export var lod_cap:int
@export var grid_size:int = 0
var timer:Timer
@export var update_interval_sec:float = 1.0

const MESH_SQUARE_SIZE_DEFAULT:int = 512
@export var mesh_square_size:int = MESH_SQUARE_SIZE_DEFAULT
##Any additional entries in mesh_square_size_list must follow the same patter. [br]Pattern: [...,128,256,512,1024,2048,...]
@export var mesh_square_size_list:Array = [128,256,512,1024,2048]

func _ready() -> void:
	for x in range(-grid_size,grid_size+1):
		for z in range(-grid_size,grid_size+1):
			if x==0 and z==0: pass
			else:
				var terrain_partition:MeshInstance3D = TERRAIN.instantiate()
				terrain_partition.x = x
				terrain_partition.z = z
				add_child(terrain_partition)

	if endless_terrain == true:
		player = $"../PlayerRegistry/Character"
		timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(update_position)
		timer.set_wait_time(update_interval_sec)
		update_position()
	else:pass

func update_position() -> void:
	player_position = player.global_position.round() * Vector3(1,0,1)
	self.global_position = player_position
	terrain.material_override.set_shader_parameter("uv_x",player_position.x/mesh_size.x)
	terrain.material_override.set_shader_parameter("uv_z",player_position.z/mesh_size.y)
	timer.start()

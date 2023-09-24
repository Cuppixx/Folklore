extends MeshInstance3D

var x:float
var z:float
var lod:int
var subdivide_length:int

@onready var parent_node:StaticBody3D = $".."
var mesh_square_size:int
var mesh_square_size_list:Array

var texture_size:float = 48.0

func _ready() -> void:
	mesh_square_size = parent_node.mesh_square_size
	mesh_square_size_list = parent_node.mesh_square_size_list

	var image_height:int = self.material_override.get_shader_parameter("heightmap").get_image().get_height()
	#var image_height:int = self.material_override.get_shader_parameter("heightmap").get_height()
	if mesh_square_size in mesh_square_size_list:
		var image_index:int = mesh_square_size_list.find(image_height,0)
		var mesh_index:int = mesh_square_size_list.find(mesh_square_size,0)
		#print(image_index - mesh_index)
		self.material_override.set_shader_parameter("heightmap_mipmap_lvl", (image_index - mesh_index))
		#print("Mipmap", self.material_override.get_shader_parameter("heightmap_mipmap_lvl"))
	else: mesh_square_size = image_height

	self.mesh = QuadMesh.new()
	self.mesh.orientation = mesh.FACE_Y
	self.mesh.size = Vector2(mesh_square_size,mesh_square_size)

	self.position = Vector3(x, 0, z) * mesh_square_size

	lod = max(abs(x),abs(z))
	subdivide_length = max((mesh_square_size / (pow(2.0, float(lod)))) -1, 0)
	if lod == 0:
		subdivide_length += mesh_square_size
		#print(subdivide_length)
	else: pass
		#self.material_override.set_shader_parameter("Texture_UV_Scale", (texture_size/float(lod)))
		#print("UV", self.material_override.get_shader_parameter("Texture_UV_Scale"))

	self.mesh.subdivide_width = subdivide_length
	self.mesh.subdivide_depth = subdivide_length

	#print("LOD:", lod)
	#print(subdivide_length)

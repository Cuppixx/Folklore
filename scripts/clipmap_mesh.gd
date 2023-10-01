extends MeshInstance3D

var x:float
var z:float
var lod:int
var subdivisions:int

@onready var parent_node:StaticBody3D = $".."
@onready var generate_lod:bool = parent_node.generate_lod
@onready var lod_cap:int = parent_node.lod_cap
var mesh_square_size:int
var mesh_square_size_list:Array
var image_height:int

var texture_size:float = 48.0

func _ready() -> void:
	image_height = self.material_override.get_shader_parameter("heightmap").get_image().get_height()
	mesh_square_size = parent_node.mesh_square_size
	mesh_square_size_list = parent_node.mesh_square_size_list

	if (mesh_square_size in mesh_square_size_list) and (image_height in mesh_square_size_list):
		#Find the index of the ImageSize and the index of the MeshSize. Subtracting the MeshIndex from the
		#ImageIndex gives the Value used by MipmapLevels.
		var image_index:int = mesh_square_size_list.find(image_height,0)
		var mesh_index:int = mesh_square_size_list.find(mesh_square_size,0)
		self.material_override.set_shader_parameter("heightmap_mipmap_lvl", (image_index - mesh_index))
	else: mesh_square_size = image_height

	#Create a new QuadMesh
	self.mesh = QuadMesh.new()
	self.mesh.orientation = mesh.FACE_Y
	self.mesh.size = Vector2(mesh_square_size,mesh_square_size)

	#Set own position in Grid
	self.position = Vector3(x, 0, z) * mesh_square_size

	#Calculate LOD
	if generate_lod == true:
		lod = max(abs(x),abs(z))
		if lod > lod_cap: lod = lod_cap
		subdivisions = max((mesh_square_size / (pow(2.0, float(lod)))) -1, 0)
		if lod == 0: subdivisions += mesh_square_size
		else: pass
	else: subdivisions = mesh_square_size*2-1

	#Set subdivisions based on LOD calculations
	self.mesh.subdivide_width = subdivisions
	self.mesh.subdivide_depth = subdivisions

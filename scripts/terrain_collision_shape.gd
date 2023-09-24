extends CollisionShape3D

@onready var parent_node:StaticBody3D = $".."
@onready var character:CharacterBody3D = $"../.." #Equivalent to: get_parent().get_parent() -> gets the character to which the collision is attached.
@onready var terrain:MeshInstance3D = $"../../../../Clipmap/ClipmapMesh" #Gets the terrain Node. The terrain Node contains the HeightmapImage which is used to generate the collision.
@onready var heightmap_image:Image = terrain.material_override.get_shader_parameter("heightmap").get_image()
var heightmap_image_height:int			#Because the mesh used in the terrain Node, aswell as the collisionmesh used by self, are calculated as squares the HeightmapImage should
var heightmap_image_height_halfed:int	#also be quadratic. Therefor the heightmap_image_height can be used for calculations that would otherwise require the width property.
@onready var terrain_height:float = terrain.material_override.get_shader_parameter("heightmap_height_value")

var heightShape:HeightMapShape3D = HeightMapShape3D.new()
var collision_square_size:int #The actual size of the collision area that follows the character.
#If the collision_square_size is 0 the collision still generates a single tile. I.e the actual size cant be NULL!
var collision_size_halfed:int

var character_globalpos:Vector3 = Vector3.INF
var character_globalpos_snapped:bool
#character_globalpos_snapped:false -> rounded. character_globalpos_snapped:true -> snapped.
var snap:Vector3

func _ready():
	heightmap_image.resize(terrain.mesh_square_size,terrain.mesh_square_size)
	heightmap_image_height = heightmap_image.get_height()
	heightmap_image_height_halfed = int(heightmap_image_height / 2.0)
	collision_square_size = parent_node.collision_square_size
	heightShape.map_width = collision_square_size
	heightShape.map_depth = collision_square_size
	collision_size_halfed = int(collision_square_size / 2.0)

	character_globalpos_snapped = parent_node.character_globalpos_snapped
	snap = Vector3.ONE * collision_size_halfed

#The _process func calls the start of the Node loop
func _process(_delta: float) -> void:
	update_collision_position()

func update_collision_position() -> void:
	if character_moved() == true:
		character_globalpos = set_character_globalpos() * Vector3(1,0,1)
		self.global_position = character_globalpos
		create_local_heightmap()
	else: pass

func character_moved() -> bool:
	if self.global_position != character_globalpos: return true
	else: return false

func set_character_globalpos() -> Vector3:
	if character_globalpos_snapped == true: return character.global_position.snapped(snap)
	else: return character.global_position.round()

func create_local_heightmap() -> void:
	var floatArray:Array = []
	for z in heightShape.map_depth:
		for x in heightShape.map_width:
			var pos_x:int = x + heightmap_image_height_halfed + int(character_globalpos.x) - collision_size_halfed
			var pos_z:int = z + heightmap_image_height_halfed + int(character_globalpos.z) - collision_size_halfed
			floatArray.push_back(get_height(pos_x, pos_z))
	heightShape.map_data = floatArray
	self.shape = heightShape

func get_height(x:int, z:int) -> float:
	return heightmap_image.get_pixel(int(fposmod(x, heightmap_image_height)), int(fposmod(z, heightmap_image_height))).g * terrain_height

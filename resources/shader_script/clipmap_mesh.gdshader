shader_type spatial;

render_mode specular_toon;

uniform sampler2D heightmap : filter_linear, repeat_enable;
uniform sampler2D normalmap : filter_linear_mipmap_anisotropic, repeat_enable, hint_normal;

uniform int heightmap_mipmap_lvl;
uniform float heightmap_height_value : hint_range(0.0, 500.0, 0.1);
uniform float normalmap_depth_value : hint_range(0.0, 1.0, 0.001);

uniform float uv_x : hint_range(-100.0, 100.0, 0.001);
uniform float uv_z : hint_range(-100.0, 100.0, 0.001);

uniform float slope_coverage : hint_range(0.0, 1.0, 0.001);
uniform float texture_blend_range : hint_range(0.0, 1.0, 0.001);

uniform sampler2D base_texture : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D slope_texture : filter_linear_mipmap_anisotropic, repeat_enable;
uniform float texture_UV_scale;

uniform mat3 u_terrain_normal_basis;
vec3 unpack_normalmap_texture(vec4 input_texture)
{
	vec3 normal = ((input_texture.xzy) * 2.0) - vec3(1.0);
	normal.z = -normal.z;
	return normal;
}

void vertex() {
	//Calculate VERTEX displacement
	vec3 world_vertex = VERTEX + MODEL_MATRIX[3].xyz + (float(textureSize(heightmap,heightmap_mipmap_lvl).x)/2.0);
	vec2 texture_position = world_vertex.xz/float(textureSize(heightmap,heightmap_mipmap_lvl).x);
	VERTEX = vec3(VERTEX.x, texture(heightmap, texture_position).g * heightmap_height_value, VERTEX.z);

	//Calculate NORMAL in VERTEX
	vec2 UVoffset = vec2(UV.x + uv_x, UV.y + uv_z);
	NORMAL = unpack_normalmap_texture(texture(normalmap, UVoffset)) * u_terrain_normal_basis;
}

void fragment() {
	//Calculate NORMAL in FRAGMENT
	vec2 UVoffset = vec2(UV.x + uv_x, UV.y + uv_z);
	vec3 terrain_normal = unpack_normalmap_texture(texture(normalmap, UVoffset)) * u_terrain_normal_basis;
	terrain_normal = normalize(terrain_normal);
	NORMAL = (VIEW_MATRIX * (vec4(terrain_normal, 0.0))).xyz;
	NORMAL_MAP = texture(normalmap, UVoffset).xyz;
	NORMAL_MAP_DEPTH = normalmap_depth_value;

	//Calculate Texture Positions
	vec3 normal_albedo = unpack_normalmap_texture(texture(normalmap, UVoffset));

	float coverage_plus_range = slope_coverage + texture_blend_range;
	float weight = clamp((normal_albedo.y - slope_coverage) / (coverage_plus_range - slope_coverage), 0.0, 1.0);

	vec2 UVoffset_scaled = UVoffset * texture_UV_scale;
	vec4 blended_color = mix(texture(slope_texture, UVoffset_scaled), texture(base_texture, UVoffset_scaled), weight);
	ALBEDO = mix((texture(base_texture, UVoffset_scaled)).rgb, blended_color.rgb, step(normal_albedo.y, coverage_plus_range));
}
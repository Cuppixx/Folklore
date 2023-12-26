shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D normal_map : hint_normal;
uniform float footprint_strength : hint_range(-1.0, 100.0) = 0.5;
uniform float footprint_size : hint_range(0.0, 1.0) = 0.1;

void vertex() {
    // Transform the normal from the normal map to world space
    vec2 normal = texture(normal_map, vec2(0.0)).rg * 2.0 - vec2(1.0);

    // Calculate the displacement based on the normal map
    vec2 displacement = normal * footprint_strength;

    // Perturb the vertex position
    VERTEX += vec2(displacement);
}

void fragment() {
    // Calculate the distance from the current pixel to the center of the image
    vec2 footprint_coord = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
    vec2 footprint_center = vec2(0.5, 0.5);
    float footprint_distance = distance(footprint_coord, footprint_center);

    // Apply the footprint effect
    float footprint_effect = 1.0 - smoothstep(footprint_size, footprint_size + 0.01, footprint_distance);

    // Sample the color from the screen at the perturbed position
    vec2 perturbed_uv = (FRAGCOORD.xy + VERTEX.xy) / SCREEN_PIXEL_SIZE;
	NORMAL = vec3(texture(normal_map, vec2(0.0)).rg * 2.0 - vec2(1.0),0.0);
    COLOR = texture(SCREEN_TEXTURE, perturbed_uv) * (1.0 - footprint_effect) * 100.0;
}


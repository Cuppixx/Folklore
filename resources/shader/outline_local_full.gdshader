shader_type spatial;
render_mode cull_back, depth_draw_opaque, depth_prepass_alpha;

uniform vec3 outline_color : source_color = vec3(0.0);
uniform float outline_step_value : hint_range(0.01, 1.0, 0.001) = 0.01;
uniform float outline_thickness : hint_range(0.0, 30.0, 1.0) = 3.0;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

void fragment() {
    float depth = -FRAGCOORD.z;
    float depth_difference = 0.0;

    for (float x = -outline_thickness; x <= outline_thickness; x += 1.0) {
        for (float y = -outline_thickness; y <= outline_thickness; y += 1.0) {
            if (x == 0.0 && y == 0.0) {
                continue;
            }

            vec2 offsetUV = SCREEN_UV + vec2(x, y) / VIEWPORT_SIZE.xy;
            float depth_neighbor = -texture(DEPTH_TEXTURE, offsetUV).r;

			float pixel_distance = x * x + y * y;

			float condition = step(depth_neighbor, depth);
			depth_difference += condition * clamp(depth - depth_neighbor, 0.0, 1.0) / pixel_distance;
        }
    }
    depth_difference = step(outline_step_value, depth_difference);
    vec3 mesh_color = mix(ALBEDO, outline_color, depth_difference);
    ALBEDO = mesh_color;
}
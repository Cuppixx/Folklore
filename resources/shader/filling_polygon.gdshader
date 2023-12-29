shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float uv_addition : hint_range(0.0, 2.0, 0.01) = 0.0;
uniform float smoothness : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float steps : hint_range(0.0, 2.0, 0.01) = 0.1;

const vec4 color_a = vec4(0.0, 0.0, 0.0, 0.0);

void vertex() {
	float neg = smoothness * -1.0;
	float pos = smoothness;

    float gradient_u = smoothstep(neg, pos, normalize(UV.y) + uv_addition);
    float gradient_d = smoothstep(pos, neg, normalize(UV.y) + uv_addition * -1.0);
    vec4 final_color_u = mix(color_a, color, gradient_u);
    vec4 final_color_d = mix(color_a, color, gradient_d);
	float updown= smoothstep(neg, pos, UV.y / steps);
    vec4 updown_mix = mix(final_color_u, final_color_d, updown);

	float gradient_l = smoothstep(neg, pos, normalize(UV.x) + uv_addition);
    float gradient_r = smoothstep(pos, neg, normalize(UV.x) + uv_addition * -1.0);
	vec4 final_color_l = mix(color_a, color, gradient_l);
    vec4 final_color_r = mix(color_a, color, gradient_r);
	float leftright = smoothstep(neg, pos, UV.x / steps);
	vec4 leftright_mix = mix(final_color_l, final_color_r, leftright);

	float final = smoothstep(neg, pos, (updown_mix.a + leftright_mix.a) * 0.5);
	vec4 final_color = mix(updown_mix,leftright_mix,final);

    COLOR = final_color;
}

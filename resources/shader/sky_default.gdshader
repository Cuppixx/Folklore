shader_type sky;

group_uniforms color_day;
uniform vec3 day_bottom_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 day_top_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 horizon_color_day : source_color = vec3(1.0, 1.0, 1.0);

group_uniforms color_sunset;
uniform vec3 sunset_bottom_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 sunset_top_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 horizon_color_sunset : source_color = vec3(1.0, 1.0, 1.0);

group_uniforms color_night;
uniform vec3 night_bottom_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 night_top_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 horizon_color_night : source_color = vec3(0.0, 0.8, 1.0);

group_uniforms horizon;
uniform float horizon_falloff: hint_range(0.0, 1.0, 0.001);

group_uniforms sun;
uniform vec3 sun_color: source_color = vec3(1.0);
uniform float sun_size: hint_range(0.01, 1.0) = 1.0;
uniform float sun_blur: hint_range(0.01, 1.0) = 0.001;

group_uniforms moon;
uniform vec3 moon_color: source_color = vec3(1.0);
uniform float moon_size: hint_range(0.01, 1.0) = 1.0;
uniform float moon_blur: hint_range(0.01, 1.0) = 0.001;
uniform float moon_crescent_offset: hint_range(-1.0, 1.0) = 0.5;

group_uniforms clouds;
uniform sampler2D clouds_texture: filter_linear_mipmap;
uniform sampler2D clouds_distort_texture: filter_linear_mipmap;
uniform sampler2D clouds_noise_texture: filter_linear_mipmap;
uniform vec3 clouds_main_color: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 clouds_edge_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float clouds_speed: hint_range(0.0, 1.0, 0.001);
uniform float clouds_scale: hint_range(0.0, 1.0, 0.001);
uniform float clouds_cutoff: hint_range(0.0, 1.0, 0.001);
uniform float clouds_fuzziness: hint_range(0.0, 1.0, 0.001);

group_uniforms stars;
uniform sampler2D stars_texture: filter_linear_mipmap;
uniform float stars_cutoff: hint_range(0.0, 1.0, 0.001);
uniform float stars_speed: hint_range(0.0, 0.1);

vec3 calculateSkyGradients(vec3 eyedir_input) {
    float day_amount = clamp(LIGHT0_DIRECTION.y, 0.0, 1.0);
    vec3 gradient_day = mix(day_bottom_color, day_top_color, clamp(eyedir_input.y, 0.0, 1.0)) * day_amount;

    float sunset_amount = clamp(1.0 - abs(LIGHT0_DIRECTION.y), 0.0, 1.0);
    vec3 gradient_sunset = mix(sunset_bottom_color, sunset_top_color, clamp(eyedir_input.y, 0.0, 1.0)) * sunset_amount;

    float night_amount = clamp(-LIGHT0_DIRECTION.y, 0.0, 1.0);
    vec3 gradient_night = mix(night_bottom_color, night_top_color, clamp(eyedir_input.y, 0.0, 1.0)) * night_amount;

    return gradient_day + gradient_sunset + gradient_night;
}

vec3 calculateHorizonGlow(vec3 eyedir_input) {
    float horizon = 1.0 - abs(eyedir_input.y + horizon_falloff);

    vec3 horizon_glow_amount_day = clamp(horizon * clamp(LIGHT0_DIRECTION.y, 0.0, 1.0), 0.0, 1.0) * horizon_color_day;
    vec3 horizon_glow_amount_sunset = clamp(horizon * clamp(1.0 - abs(LIGHT0_DIRECTION.y), 0.0, 1.0), 0.0, 1.0) * horizon_color_sunset;
    vec3 horizon_glow_night = clamp(horizon * clamp(-LIGHT0_DIRECTION.y, 0.0, 1.0), 0.0, 1.0) * horizon_color_night;

    return horizon_glow_amount_day + horizon_glow_amount_sunset + horizon_glow_night;
}

vec4 calculateSun(vec3 eyedir_input) {
    float sun_distance = distance(eyedir_input.xyz, LIGHT0_DIRECTION);
    float sun_power = 1.0 - clamp(sun_distance / sun_size, 0.0, 1.0);
    float sun_disc = clamp(sun_power / sun_blur, sun_power, 1.0);

    return vec4(sun_color, sun_disc);
}

vec4 calculateMoon(vec3 eyedir_input) {
    float moon_distance = distance(eyedir_input.xyz, -LIGHT0_DIRECTION);
    float moon_power = 1.0 - clamp(moon_distance / moon_size, 0.0, 1.0);
    float moon_disc = clamp(moon_power / moon_blur, moon_power, 1.0);

    float moon_crescent_distance = distance(vec3(eyedir_input.x + moon_crescent_offset, eyedir_input.yz), -LIGHT0_DIRECTION);
    float moon_crescent_power = 1.0 - clamp(moon_crescent_distance / moon_size, 0.0, 1.0);
    float moon_crescent_disc = clamp(moon_crescent_power / 0.01, moon_crescent_power, 1.0);

    return vec4(moon_color, clamp(moon_disc - moon_crescent_disc, 0.0, 1.0));
}

vec3 calculateClouds(vec2 sky_uv, vec3 eyedir_input) {
    float clouds_movement = TIME * clouds_speed * 0.5;
    float clouds_base_noise = texture(clouds_texture, (sky_uv + clouds_movement) * clouds_scale).r;
    float noise1 = texture(clouds_distort_texture, (sky_uv + clouds_base_noise + (clouds_movement * 0.75)) * clouds_scale).r;
    float noise2 = texture(clouds_noise_texture, (sky_uv + noise1 + (clouds_movement * 0.25)) * clouds_scale).r;

    float clouds_noise_value = clamp(noise1 * noise2, 0.0, 1.0) * clamp(eyedir_input.y, 0.0, 1.0);

    float clouds_value = clamp(smoothstep(clouds_cutoff, clouds_cutoff + clouds_fuzziness, clouds_noise_value), 0.0, 1.0) * clamp(LIGHT0_DIRECTION.y, 0.1, 1.0);

    vec3 clouds = mix(clouds_edge_color, clouds_main_color, clouds_value) * clouds_value;

    //float clouds_negative = 1.0 - clouds_value;

    return clouds;
}

vec3 calculateStars(vec2 sky_uv) {
    return step(stars_cutoff,texture(stars_texture, sky_uv + (stars_speed * TIME)).rgb * clamp(-LIGHT0_DIRECTION.y, 0.0, 1.0));
}

void sky() {
    // Calculate UV coordinates
    vec2 sky_uv = EYEDIR.xz / EYEDIR.y;

    // Calculate Sky Gradients
    vec3 sky_gradients = calculateSkyGradients(EYEDIR);

    // Calculate Horizon Glow
    vec3 horizon_glow = calculateHorizonGlow(EYEDIR);

    // Calculate Sun and Moon
    vec4 sun = calculateSun(EYEDIR);
    vec4 moon = calculateMoon(EYEDIR);

    // Calculate Clouds
    vec3 clouds = calculateClouds(sky_uv, EYEDIR);

    // Calculate Stars
    vec3 stars = calculateStars(sky_uv);

    // Combine all components
    //vec3 final_sky = mix(horizon_glow + sky_gradients + stars + clouds, sun.rgb * sun.a + moon.rgb * moon.a, sun.a + moon.a);
	vec3 final_sky = mix(horizon_glow + sky_gradients + stars + clouds, sun.rgb * sun.a + moon.rgb * moon.a, sun.a + moon.a);

    // Set the final color
    COLOR = vec3(final_sky);
}
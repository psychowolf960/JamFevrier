shader_type spatial;
// blend_mix enables alpha transparency; depth_draw_opaque writes depth only at opaque pass
// (required for beer-lambert depth sampling to work correctly)
render_mode blend_mix, depth_draw_opaque, cull_back;

/// Water tint color (multiplied with texture)
uniform vec4 out_color : source_color = vec4(0.0, 0.2, 1.0, 1.0);
/// Peak height offset per triangle
uniform float amount : hint_range(0.2, 5.0, 0.1) = 0.8;
/// Animation speed
uniform float speed : hint_range(0.1, 5.0, 0.1) = 1.0;
/// Beer-Lambert extinction coefficient — 0.0 uses out_color.a directly
uniform float beer_factor : hint_range(0.0, 2.0, 0.01) = 0.2;
uniform float metallic : hint_range(0.0, 1.0) = 0.6;
uniform float specular : hint_range(0.0, 1.0) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;

/// Surface texture (e.g. foam, ripple pattern). Assign in Inspector; defaults to white.
uniform sampler2D water_texture : hint_default_white, repeat_enable, filter_linear_mipmap;
/// How much the texture tints the surface color (0 = flat color, 1 = full texture)
uniform float texture_influence : hint_range(0.0, 1.0, 0.01) = 0.4;
/// UV tiling — increase to tile the texture more densely
uniform vec2 uv_scale = vec2(1.0, 1.0);
/// Two independent scroll directions for a cross-flow look
uniform vec2 scroll_direction_a = vec2(1.0, 0.0);
uniform vec2 scroll_direction_b = vec2(0.0, 1.0);
/// Speed multiplier for UV scrolling (independent of vertex wave speed)
uniform float scroll_speed : hint_range(0.0, 2.0, 0.01) = 0.05;

// Godot 4: depth texture must be declared as a uniform with hint_depth_texture
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

float generate_offset(float x, float z, float val1, float val2, float time) {
	// PI is a built-in constant in Godot 4 GLSL (replaces the magic 3.14)
	float radians_x = ((mod(x + z * x * val1, amount) / amount)
		+ (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * PI;
	float radians_z = ((mod(val2 * (z * x + x * z), amount) / amount)
		+ (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * PI;
	return amount * 0.5 * (sin(radians_z) * cos(radians_x));
}

vec3 apply_distortion(vec3 vertex, float time) {
	float xd = generate_offset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generate_offset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generate_offset(vertex.x, vertex.z, 0.15, 0.2, time);
	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	// VERTEX here is in object/local space — distort before projection
	VERTEX = apply_distortion(VERTEX, TIME * 0.1);
}

void fragment() {
	// Flat lowpoly normals: screen-space derivatives of view-space VERTEX give
	// per-triangle facing. If water looks black, swap the cross() arguments.
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;

	// Two scrolling UV layers blended together break up tiling repetition
	vec2 uv_a = UV * uv_scale + scroll_direction_a * TIME * scroll_speed;
	vec2 uv_b = UV * uv_scale + scroll_direction_b * TIME * scroll_speed;
	vec3 tex_a = texture(water_texture, uv_a).rgb;
	vec3 tex_b = texture(water_texture, uv_b).rgb;
	vec3 tex_color = (tex_a + tex_b) * 0.5;

	ALBEDO = mix(out_color.rgb, out_color.rgb * tex_color, texture_influence);

	if (beer_factor > 0.0) {
		// --- Godot 4 depth reconstruction ---
		// Sample the raw (non-linear) depth behind the water surface
		float raw_depth = texture(depth_texture, SCREEN_UV).r;

		// Reconstruct view-space position of the background fragment
		// INV_PROJECTION_MATRIX is a Godot 4 built-in (replaces manual PROJECTION_MATRIX math)
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, raw_depth);
		vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		view_pos /= view_pos.w;

		// In Godot 4 view space, camera looks down -Z, so negate for positive depth
		float scene_depth = -view_pos.z;
		float surface_depth = -VERTEX.z; // VERTEX in fragment is view-space

		float depth_diff = scene_depth - surface_depth;
		ALPHA = clamp(1.0 - exp(-depth_diff * beer_factor), 0.0, 1.0);
	} else {
		ALPHA = out_color.a;
	}
}

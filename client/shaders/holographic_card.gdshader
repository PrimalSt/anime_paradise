shader_type canvas_item;

// Holographic foil effect for rare anime cards
uniform float speed : hint_range(0.1, 5.0) = 1.2;
uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 tint_color : source_color = vec4(1.0, 0.85, 0.4, 0.6); // Gold tint for SSR, rainbow for UR
uniform bool is_rainbow = false;

vec3 rainbow(float t) {
    vec3 c = vec3(
        0.5 + 0.5 * cos(6.28318 * (t + 0.00)),
        0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
        0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
    return c;
}

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    
    // Diagonal light sweep
    float sweep = sin((UV.x + UV.y) * 4.0 - TIME * speed);
    sweep = smoothstep(0.4, 0.95, sweep);
    
    // Holographic shimmer color
    vec3 foil;
    if (is_rainbow) {
        foil = rainbow(UV.x * 2.0 + UV.y * 1.5 + TIME * 0.4);
    } else {
        foil = tint_color.rgb;
    }
    
    // Combine base with shimmering light
    vec3 mixed = mix(base_color.rgb, base_color.rgb + foil * 0.7, sweep * intensity);
    COLOR = vec4(mixed, base_color.a);
}

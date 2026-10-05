shader_type canvas_item;

uniform vec4 portal_color : source_color = vec4(0.4, 0.7, 1.0, 1.0); // Changes based on rarity: Blue (R), Purple (SR), Gold (SSR), Rainbow (UR)
uniform float speed : hint_range(0.1, 10.0) = 2.0;
uniform float charge : hint_range(0.0, 2.0) = 1.0;
uniform bool rainbow_mode = false;

vec3 rainbow(float t) {
    return vec3(
        0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
        0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
        0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
}

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    float angle = atan(uv.y, uv.x);
    
    // Rotating spiral rays
    float rays = sin(angle * 8.0 + TIME * speed + dist * 10.0);
    rays = smoothstep(-0.2, 0.8, rays);
    
    // Concentric glowing rings
    float rings = sin(dist * 25.0 - TIME * speed * 2.0);
    rings = smoothstep(0.3, 0.9, rings);
    
    // Radial falloff from center
    float core = smoothstep(0.48, 0.05, dist);
    float glow = smoothstep(0.5, 0.1, dist);
    
    vec3 color;
    if (rainbow_mode) {
        color = rainbow(dist * 2.0 - TIME * 0.8);
    } else {
        color = portal_color.rgb;
    }
    
    float alpha = (rays * 0.4 + rings * 0.3 + core * 0.8) * glow * charge;
    COLOR = vec4(color * (1.2 + charge * 0.8), clamp(alpha, 0.0, 1.0));
}

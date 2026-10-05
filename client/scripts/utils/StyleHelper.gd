class_name StyleHelper
extends Object

# Theme Color Palette
const COLOR_BG_DARK = Color(0.06, 0.05, 0.09, 1.0)
const COLOR_PANEL_BG = Color(0.10, 0.09, 0.15, 0.95)
const COLOR_PANEL_BORDER = Color(0.25, 0.20, 0.35, 0.8)

const COLOR_ACCENT_PINK = Color(0.98, 0.35, 0.65, 1.0) # #fa5aa6
const COLOR_ACCENT_GOLD = Color(1.00, 0.84, 0.25, 1.0) # #ffd640
const COLOR_ACCENT_PURPLE = Color(0.68, 0.35, 0.95, 1.0) # #ad5af2
const COLOR_ACCENT_CYAN = Color(0.25, 0.80, 1.00, 1.0) # #40ccff

# Rarity Color Mapping
const RARITY_COLORS = {
	"UR": Color(1.0, 0.25, 0.75, 1.0),   # Prismatic / Radiant Pink
	"SSR": Color(1.0, 0.82, 0.18, 1.0),  # Luminous Gold
	"SR": Color(0.68, 0.38, 0.95, 1.0),  # Amethyst Purple
	"R": Color(0.25, 0.68, 0.95, 1.0),   # Sky Blue
	"N": Color(0.65, 0.68, 0.75, 1.0)    # Silver Slate
}

# Rarity Border / Glow Colors
const RARITY_GLOW_COLORS = {
	"UR": Color(1.0, 0.4, 0.9, 0.9),
	"SSR": Color(1.0, 0.9, 0.3, 0.9),
	"SR": Color(0.8, 0.5, 1.0, 0.8),
	"R": Color(0.4, 0.8, 1.0, 0.7),
	"N": Color(0.7, 0.7, 0.8, 0.5)
}

static func get_rarity_color(rarity: String) -> Color:
	return RARITY_COLORS.get(rarity, RARITY_COLORS["R"])

static func get_rarity_glow_color(rarity: String) -> Color:
	return RARITY_GLOW_COLORS.get(rarity, RARITY_GLOW_COLORS["R"])

# Stylized Button with Glow & Rounded Corners
static func apply_button_style(btn: Button, primary_color: Color = COLOR_ACCENT_PINK, corner_radius: int = 12) -> void:
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(primary_color.r * 0.25, primary_color.g * 0.25, primary_color.b * 0.25, 0.85)
	normal.set_corner_radius_all(corner_radius)
	normal.set_border_width_all(2)
	normal.border_color = Color(primary_color.r, primary_color.g, primary_color.b, 0.6)
	normal.shadow_size = 4
	normal.shadow_color = Color(0, 0, 0, 0.4)
	
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(primary_color.r * 0.4, primary_color.g * 0.4, primary_color.b * 0.4, 0.95)
	hover.set_corner_radius_all(corner_radius)
	hover.set_border_width_all(2)
	hover.border_color = primary_color
	hover.shadow_size = 8
	hover.shadow_color = Color(primary_color.r, primary_color.g, primary_color.b, 0.35)

	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(primary_color.r * 0.55, primary_color.g * 0.55, primary_color.b * 0.55, 1.0)
	pressed.set_corner_radius_all(corner_radius)
	pressed.set_border_width_all(2)
	pressed.border_color = primary_color

	var disabled = StyleBoxFlat.new()
	disabled.bg_color = Color(0.15, 0.15, 0.2, 0.5)
	disabled.set_corner_radius_all(corner_radius)
	disabled.set_border_width_all(1)
	disabled.border_color = Color(0.3, 0.3, 0.35, 0.4)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.6))

# Stylized Frosted Glass Panel
static func apply_panel_style(panel: Control, border_color: Color = COLOR_PANEL_BORDER, corner_radius: int = 16, bg_alpha: float = 0.92) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(COLOR_PANEL_BG.r, COLOR_PANEL_BG.g, COLOR_PANEL_BG.b, bg_alpha)
	style.set_corner_radius_all(corner_radius)
	style.set_border_width_all(2)
	style.border_color = border_color
	style.shadow_size = 12
	style.shadow_color = Color(0, 0, 0, 0.45)
	panel.add_theme_stylebox_override("panel", style)

# Stylized Card Frame for Rarity
static func create_card_frame(rarity: String, corner_radius: int = 14) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	var color = get_rarity_color(rarity)
	var glow = get_rarity_glow_color(rarity)
	
	style.bg_color = Color(0.08, 0.07, 0.12, 0.95)
	style.set_corner_radius_all(corner_radius)
	style.set_border_width_all(3 if rarity in ["SSR", "UR"] else 2)
	style.border_color = glow
	style.shadow_size = 14 if rarity in ["SSR", "UR"] else 6
	style.shadow_color = Color(color.r, color.g, color.b, 0.45 if rarity in ["SSR", "UR"] else 0.2)
	return style

# Holographic Shimmer Material Shader
static var _holo_shader: Shader = null

static func get_holographic_material(rarity: String) -> ShaderMaterial:
	if not (rarity in ["SSR", "UR"]):
		return null
	
	if _holo_shader == null:
		var path = "res://shaders/holographic_card.gdshader"
		if ResourceLoader.exists(path):
			_holo_shader = load(path)
	
	if _holo_shader:
		var mat = ShaderMaterial.new()
		mat.shader = _holo_shader
		mat.set_shader_parameter("is_rainbow", rarity == "UR")
		mat.set_shader_parameter("intensity", 0.6 if rarity == "UR" else 0.45)
		mat.set_shader_parameter("speed", 1.5 if rarity == "UR" else 1.0)
		mat.set_shader_parameter("tint_color", Color(1.0, 0.85, 0.3, 0.8) if rarity == "SSR" else Color(1.0, 0.4, 0.9, 0.8))
		return mat
	return null

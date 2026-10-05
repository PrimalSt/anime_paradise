extends Control

@onready var background_texture: TextureRect = $RoomArea/BackgroundTexture
@onready var fallback_background: ColorRect = $RoomArea/FallbackBackground
@onready var room_tint_overlay: ColorRect = $RoomArea/RoomTintOverlay
@onready var entities_layer: Control = $RoomArea/EntitiesLayer
@onready var particles_layer: Control = $RoomArea/ParticlesLayer
@onready var effects_layer: Control = $RoomArea/EffectsLayer

@onready var top_hud: PanelContainer = $TopHUD
@onready var tier_label: Label = $TopHUD/Margin/HBox/TitleBox/ComfortTierPanel/TierLabel
@onready var comfort_label: Label = $TopHUD/Margin/HBox/StatsBox/ComfortLabel
@onready var residents_label: Label = $TopHUD/Margin/HBox/StatsBox/ResidentsLabel
@onready var income_rate_label: Label = $TopHUD/Margin/HBox/StatsBox/IncomeRateLabel
@onready var pending_label: Label = $TopHUD/Margin/HBox/PiggyBox/PendingLabel
@onready var btn_collect: Button = $TopHUD/Margin/HBox/PiggyBox/BtnCollect
@onready var btn_clean: Button = $TopHUD/Margin/HBox/ActionsBox/BtnClean
@onready var btn_furniture: Button = $TopHUD/Margin/HBox/ActionsBox/BtnFurniture
@onready var btn_residents: Button = $TopHUD/Margin/HBox/ActionsBox/BtnResidents
@onready var btn_theme: Button = $TopHUD/Margin/HBox/ActionsBox/BtnTheme

@onready var speech_bubble: PanelContainer = $SpeechBubble
@onready var speech_label: Label = $SpeechBubble/SpeechLabel
@onready var modals_layer: Control = $ModalsLayer
@onready var dimmer: ColorRect = $ModalsLayer/Dimmer

var dorm_data: Dictionary = {}
var chibis: Array = []
var placed_furniture: Array = []
var ambient_particles: Array = []
var active_modal: Control = null
var current_theme: String = "bg_dorm_room"
var current_lighting: String = "day"
var _editing_residents: Array = []
var _user_inventory_map: Dictionary = {}
var _dragged_furniture: Dictionary = {}
var _bubble_tween: Tween = null
var _coin_pulse_tween: Tween = null

const WALK_MIN_X: float = 220.0
const WALK_MAX_X: float = 1700.0
const WALK_MIN_Y: float = 560.0
const WALK_MAX_Y: float = 900.0

const FURNITURE_CATALOG: Dictionary = {
	"cozy_bed": {
		"id": "cozy_bed", "name": "Королевская кровать", "icon": "🛏️",
		"comfort": 40, "desc": "Мягкая просторная кровать с шелковыми простынями.",
		"type": "bed",
		"default_pos": Vector2(300, 680), "size": Vector2(170, 110),
		"color": Color(0.75, 0.35, 0.48, 0.95), "border": Color(1.0, 0.6, 0.75, 0.9)
	},
	"plush_sofa": {
		"id": "plush_sofa", "name": "Велюровый диван", "icon": "🛋️",
		"comfort": 30, "desc": "Уютный диван для приятных дружеских бесед.",
		"type": "sofa",
		"default_pos": Vector2(740, 700), "size": Vector2(160, 95),
		"color": Color(0.42, 0.32, 0.65, 0.95), "border": Color(0.75, 0.6, 1.0, 0.9)
	},
	"tea_table": {
		"id": "tea_table", "name": "Чайный столик", "icon": "🪑",
		"comfort": 20, "desc": "Круглый столик для чаепитий и угощений.",
		"type": "table",
		"default_pos": Vector2(1100, 720), "size": Vector2(130, 90),
		"color": Color(0.55, 0.38, 0.25, 0.95), "border": Color(0.9, 0.7, 0.45, 0.9)
	},
	"sakura_carpet": {
		"id": "sakura_carpet", "name": "Ковёр с лепестками", "icon": "🌸",
		"comfort": 15, "desc": "Теплый коврик с узором падающих лепестков сакуры.",
		"type": "carpet",
		"default_pos": Vector2(920, 760), "size": Vector2(240, 115),
		"color": Color(0.85, 0.45, 0.65, 0.65), "border": Color(1.0, 0.7, 0.85, 0.8)
	},
	"bonsai_plant": {
		"id": "bonsai_plant", "name": "Мини-бонсай", "icon": "🪴",
		"comfort": 10, "desc": "Карликовая сосна, приносящая душевный покой и дзен.",
		"type": "plant",
		"default_pos": Vector2(540, 640), "size": Vector2(90, 90),
		"color": Color(0.25, 0.55, 0.35, 0.95), "border": Color(0.5, 0.9, 0.6, 0.9)
	},
	"anime_poster": {
		"id": "anime_poster", "name": "Постер шедевра", "icon": "🖼️",
		"comfort": 10, "desc": "Красочный настенный арт с любимыми героями.",
		"type": "wall",
		"default_pos": Vector2(1380, 520), "size": Vector2(95, 120),
		"color": Color(0.3, 0.45, 0.75, 0.95), "border": Color(0.6, 0.8, 1.0, 0.9)
	},
	"crystal_chandelier": {
		"id": "crystal_chandelier", "name": "Хрустальная люстра", "icon": "💡",
		"comfort": 50, "desc": "Сияющая люстра, озаряющая комнату волшебным светом.",
		"type": "ceiling",
		"default_pos": Vector2(960, 200), "size": Vector2(120, 95),
		"color": Color(0.95, 0.85, 0.3, 0.95), "border": Color(1.0, 0.95, 0.6, 0.9)
	}
}

const FOOD_ITEMS: Array = [
	{"id": "strawberry_cake", "name": "Клубничный торт", "icon": "🍰", "hunger": 45, "affection": 20, "price": 80, "currency": "coins", "desc": "Воздушный бисквит со свежей клубникой"},
	{"id": "dango_milk", "name": "Данго-молоко", "icon": "🍡", "hunger": 35, "affection": 15, "price": 50, "currency": "coins", "desc": "Сладкий десерт с шариками данго"},
	{"id": "matcha_tea", "name": "Маття Латте", "icon": "🍵", "hunger": 20, "affection": 10, "price": 30, "currency": "coins", "desc": "Традиционный японский чай с нежной пенкой"},
	{"id": "curry_ramen", "name": "Карри-рамен", "icon": "🍜", "hunger": 60, "affection": 20, "price": 90, "currency": "coins", "desc": "Сытный острый рамен с соусом карри"},
	{"id": "spicy_tofu", "name": "Острый тофу", "icon": "🍲", "hunger": 40, "affection": 20, "price": 60, "currency": "coins", "desc": "Огненный тофу — лакомство Ху Тао!"},
	{"id": "tea_buns", "name": "Чайные булочки", "icon": "🥟", "hunger": 30, "affection": 15, "price": 40, "currency": "coins", "desc": "Свежие теплые булочки с кремом для Рем"},
	{"id": "beef_steak", "name": "Стейк короля", "icon": "🥩", "hunger": 75, "affection": 30, "price": 140, "currency": "coins", "desc": "Сочный кусок мраморной говядины для Сейбер"},
	{"id": "cinnamon_roll", "name": "Синнабон", "icon": "🥮", "hunger": 30, "affection": 15, "price": 40, "currency": "coins", "desc": "Ароматная булочка с корицей для Хинаты"},
	{"id": "miso_soup", "name": "Мисо-суп", "icon": "🥣", "hunger": 25, "affection": 10, "price": 35, "currency": "coins", "desc": "Традиционный суп с тофу и вакаме"},
	{"id": "golden_ribbon", "name": "Шёлковая лента", "icon": "🎀", "hunger": 0, "affection": 60, "price": 200, "currency": "coins", "desc": "Изящный алый подарок, дающий много симпатии"},
	{"id": "music_box", "name": "Шкатулка", "icon": "🎵", "hunger": 0, "affection": 120, "price": 10, "currency": "love_gems", "desc": "Хрустальная заводная шкатулка с нежной мелодией"}
]

const THEME_OPTIONS: Array = [
	{"id": "bg_dorm_room", "name": "Классическое общежитие", "icon": "🏠", "desc": "Теплая и ламповая комната отдыха", "color": Color(0.2, 0.16, 0.28)},
	{"id": "bg_cozy_cafe", "name": "Уютное Кафе", "icon": "☕", "desc": "Аромат кофе, выпечки и спокойная музыка", "color": Color(0.3, 0.2, 0.15)},
	{"id": "bg_sakura_park", "name": "Сад Сакуры", "icon": "🌸", "desc": "Цветущие вишни и свежий весенний бриз", "color": Color(0.35, 0.18, 0.28)},
	{"id": "bg_night_festival", "name": "Ночной фестиваль", "icon": "🌙", "desc": "Огни фонариков под звездным куполом", "color": Color(0.12, 0.14, 0.3)},
	{"id": "bg_library", "name": "Королевская Библиотека", "icon": "📚", "desc": "Величие фолиантов и старинных рукописей", "color": Color(0.25, 0.18, 0.14)},
	{"id": "bg_banner", "name": "Звёздная сцена", "icon": "🌌", "desc": "Яркие софиты для настоящих айдолов", "color": Color(0.15, 0.12, 0.35)}
]

func _ready() -> void:
	speech_bubble.visible = false
	modals_layer.visible = false
	
	# Apply visual styling to TopHUD and control buttons
	StyleHelper.apply_panel_style(top_hud, StyleHelper.COLOR_PANEL_BORDER, 0, 0.94)
	StyleHelper.apply_button_style(btn_collect, StyleHelper.COLOR_ACCENT_GOLD, 12)
	StyleHelper.apply_button_style(btn_clean, Color(0.3, 0.75, 0.8), 10)
	StyleHelper.apply_button_style(btn_furniture, StyleHelper.COLOR_ACCENT_PURPLE, 10)
	StyleHelper.apply_button_style(btn_residents, StyleHelper.COLOR_ACCENT_PINK, 10)
	StyleHelper.apply_button_style(btn_theme, Color(0.85, 0.5, 0.3), 10)
	StyleHelper.apply_panel_style(speech_bubble, StyleHelper.COLOR_ACCENT_PINK, 14, 0.95)
	
	var tier_style = StyleBoxFlat.new()
	tier_style.bg_color = Color(0.2, 0.15, 0.3, 0.8)
	tier_style.set_corner_radius_all(10)
	tier_style.set_border_width_all(1)
	tier_style.border_color = StyleHelper.COLOR_ACCENT_GOLD
	$TopHUD/Margin/HBox/TitleBox/ComfortTierPanel.add_theme_stylebox_override("panel", tier_style)

	# Connect buttons
	btn_collect.pressed.connect(_on_collect_income)
	btn_clean.pressed.connect(_on_clean_dorm)
	btn_furniture.pressed.connect(_open_furniture_modal)
	btn_residents.pressed.connect(_open_residents_modal)
	btn_theme.pressed.connect(_open_theme_modal)
	dimmer.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			close_active_modal()
	)

	# GameSession signals
	GameSession.dorm_updated.connect(_on_dorm_updated)
	GameSession.waifus_updated.connect(func(_w):
		if chibis.is_empty() and dorm_data.size() > 0:
			spawn_chibis(dorm_data.get("assigned_waifus", []))
	)

	_init_ambient_particles()
	GameSession.refresh_dorm()
	GameSession.refresh_waifus()

func _process(delta: float) -> void:
	_update_chibis_ai(delta)
	_update_ambient_particles(delta)
	_update_y_sorting()

func _input(event: InputEvent) -> void:
	if _dragged_furniture.is_empty():
		return

	var rec: Dictionary = _dragged_furniture.get("record", {})
	var fnode: Control = rec.get("node", null)

	if event is InputEventMouseMotion:
		if is_instance_valid(fnode):
			var offset: Vector2 = _dragged_furniture.get("offset", Vector2.ZERO)
			var target_pos = entities_layer.get_local_mouse_position() - offset
			target_pos.x = clampf(target_pos.x, 150.0, 1750.0)
			target_pos.y = clampf(target_pos.y, 180.0, 920.0)
			fnode.position = target_pos
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_instance_valid(fnode):
			fnode.scale = Vector2.ONE
		_dragged_furniture.clear()
		_save_current_furniture_layout()

func _on_dorm_updated(data: Dictionary) -> void:
	dorm_data = data
	var comfort = int(data.get("comfort_level", 20))
	var pending = int(data.get("pending_coins", 0))
	var coins_per_min = float(data.get("coins_per_minute", 4.0))
	var tier = str(data.get("comfort_tier", "Уютная комната 🛋️"))
	var theme_id = str(data.get("theme", "bg_dorm_room"))
	var assigned = data.get("assigned_waifus", [])

	tier_label.text = " " + tier + " "
	comfort_label.text = "🛋️ Уют: " + str(comfort)
	residents_label.text = "👥 Жильцы: " + str(assigned.size()) + "/4"
	income_rate_label.text = "🪙 " + str(coins_per_min) + "/мин"
	pending_label.text = "🪙 " + str(pending)

	btn_collect.disabled = (pending == 0)
	if pending > 0:
		_start_coin_pulse()
	else:
		_stop_coin_pulse()

	apply_theme(theme_id, false)
	_load_furniture_layout(data.get("furniture_layout", []))
	spawn_chibis(assigned)

# =========================================================================
# THEME & LIGHTING SYSTEM
# =========================================================================
func apply_theme(theme_id: String, save_to_server: bool = true) -> void:
	current_theme = theme_id
	var tex = GameSession.get_background_texture(theme_id)
	if tex:
		background_texture.texture = tex
		background_texture.visible = true
		fallback_background.visible = false
	else:
		background_texture.visible = false
		fallback_background.visible = true
		for opt in THEME_OPTIONS:
			if opt.get("id", "") == theme_id:
				fallback_background.color = opt.get("color", Color(0.12, 0.1, 0.18))
				break

	if save_to_server:
		NetworkManager.set_dorm_theme(theme_id, func(success: bool, _data: Variant):
			if success:
				GameSession.show_toast("Тема комнаты изменена! ✨", true)
		)

func set_lighting_mood(mood: String) -> void:
	current_lighting = mood
	var target_tint = Color(1.0, 1.0, 1.0, 0.0)
	match mood:
		"day":
			target_tint = Color(1.0, 1.0, 1.0, 0.0)
		"sunset":
			target_tint = Color(0.9, 0.45, 0.12, 0.22)
		"night":
			target_tint = Color(0.12, 0.16, 0.45, 0.38)
	
	var tween = create_tween()
	tween.tween_property(room_tint_overlay, "color", target_tint, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# =========================================================================
# FURNITURE SYSTEM & DRAG-AND-DROP
# =========================================================================
func _load_furniture_layout(layout: Array) -> void:
	for p in placed_furniture:
		var n = p.get("node", null)
		if is_instance_valid(n):
			n.queue_free()
	placed_furniture.clear()

	var to_place = layout
	if to_place.is_empty():
		to_place = [
			{"id": "cozy_bed", "x": 320, "y": 680},
			{"id": "plush_sofa", "x": 750, "y": 700},
			{"id": "tea_table", "x": 1120, "y": 720},
			{"id": "sakura_carpet", "x": 930, "y": 760},
			{"id": "bonsai_plant", "x": 560, "y": 640},
			{"id": "anime_poster", "x": 1400, "y": 520}
		]

	for item in to_place:
		var fid = str(item.get("id", ""))
		if not FURNITURE_CATALOG.has(fid):
			continue
		var cat_data: Dictionary = FURNITURE_CATALOG[fid]
		var def_p: Vector2 = cat_data.get("default_pos", Vector2(500, 600))
		var pos = Vector2(float(item.get("x", def_p.x)), float(item.get("y", def_p.y)))
		_create_furniture_node(cat_data, pos)

func _create_furniture_node(cat_data: Dictionary, pos: Vector2) -> Control:
	var fnode = Control.new()
	fnode.position = pos
	var fsize: Vector2 = cat_data.get("size", Vector2(120, 90))
	fnode.custom_minimum_size = fsize
	fnode.pivot_offset = fsize * 0.5

	# Contact Shadow
	var shadow = Panel.new()
	shadow.custom_minimum_size = Vector2(fsize.x * 0.95, 20)
	shadow.position = Vector2(fsize.x * 0.025, fsize.y - 12)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s_style = StyleBoxFlat.new()
	s_style.bg_color = Color(0, 0, 0, 0.35)
	s_style.set_corner_radius_all(14)
	shadow.add_theme_stylebox_override("panel", s_style)
	fnode.add_child(shadow)

	# Main card container
	var panel = PanelContainer.new()
	panel.custom_minimum_size = fsize
	var style = StyleBoxFlat.new()
	style.bg_color = cat_data.get("color", Color(0.3, 0.3, 0.4))
	style.border_color = cat_data.get("border", Color(0.6, 0.6, 0.8))
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.4)
	panel.add_theme_stylebox_override("panel", style)
	fnode.add_child(panel)

	# Inner content
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	var icon_lbl = Label.new()
	icon_lbl.text = cat_data.get("icon", "🪑")
	icon_lbl.add_theme_font_size_override("font_size", 34)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon_lbl)

	var name_lbl = Label.new()
	name_lbl.text = cat_data.get("name", "Мебель")
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	var comfort_badge = Label.new()
	comfort_badge.text = "+" + str(cat_data.get("comfort", 10)) + " 🛋️"
	comfort_badge.add_theme_font_size_override("font_size", 11)
	comfort_badge.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	comfort_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(comfort_badge)

	# Drag and drop capture button
	var btn = Button.new()
	btn.custom_minimum_size = fsize
	btn.flat = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	fnode.add_child(btn)

	var item_record = {"id": cat_data.get("id", ""), "node": fnode, "data": cat_data}
	placed_furniture.append(item_record)

	btn.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_dragged_furniture = {"record": item_record, "offset": fnode.get_local_mouse_position()}
			fnode.scale = Vector2(1.06, 1.06)
	)

	entities_layer.add_child(fnode)
	return fnode

func _save_current_furniture_layout() -> void:
	var layout: Array = []
	for p in placed_furniture:
		var n: Control = p.get("node", null)
		if is_instance_valid(n):
			layout.append({
				"id": p.get("id", ""),
				"x": round(n.position.x),
				"y": round(n.position.y)
			})
	NetworkManager.save_dorm_layout(layout, func(success: bool, data: Variant):
		if success and data is Dictionary:
			dorm_data["comfort_level"] = data.get("comfort_level", dorm_data.get("comfort_level", 20))
			comfort_label.text = "🛋️ Уют: " + str(dorm_data["comfort_level"])
	)

# =========================================================================
# CHIBI WAIFUS SYSTEM & AI
# =========================================================================
func spawn_chibis(assigned: Array) -> void:
	for c in chibis:
		var n = c.get("node", null)
		if is_instance_valid(n):
			n.queue_free()
	chibis.clear()

	var waifu_ids_to_spawn = assigned.duplicate()
	if waifu_ids_to_spawn.is_empty() and GameSession.user_waifus.size() > 0:
		for w in GameSession.user_waifus.slice(0, 4):
			waifu_ids_to_spawn.append(w.get("character_id", ""))

	var spawn_points = [
		Vector2(450, 720),
		Vector2(780, 760),
		Vector2(1120, 700),
		Vector2(1420, 740)
	]

	for i in range(min(waifu_ids_to_spawn.size(), spawn_points.size())):
		var cid = str(waifu_ids_to_spawn[i])
		var char_info = GameSession.all_characters_catalog.get(cid, {})
		
		var user_waifu = {}
		for uw in GameSession.user_waifus:
			if uw.get("character_id", "") == cid:
				user_waifu = uw
				break

		var pos = spawn_points[i] + Vector2(randf_range(-30, 30), randf_range(-20, 20))
		_create_chibi_entity(char_info, user_waifu, pos)

func _create_chibi_entity(char_info: Dictionary, user_waifu: Dictionary, initial_pos: Vector2) -> void:
	var root = Control.new()
	root.position = initial_pos
	root.custom_minimum_size = Vector2(100, 130)
	root.pivot_offset = Vector2(50, 65)

	# Soft ground contact shadow
	var shadow = Panel.new()
	shadow.custom_minimum_size = Vector2(64, 16)
	shadow.position = Vector2(18, 116)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh_style = StyleBoxFlat.new()
	sh_style.bg_color = Color(0, 0, 0, 0.35)
	sh_style.set_corner_radius_all(12)
	shadow.add_theme_stylebox_override("panel", sh_style)
	root.add_child(shadow)

	# Sprite wrapper (for bobbing & directional flip)
	var sprite_wrapper = Control.new()
	sprite_wrapper.custom_minimum_size = Vector2(100, 120)
	sprite_wrapper.pivot_offset = Vector2(50, 60)
	root.add_child(sprite_wrapper)

	var cid = str(char_info.get("id", ""))
	var rarity = str(char_info.get("rarity", "SSR"))
	var tex = GameSession.get_character_texture(cid)

	# Avatar Card
	var avatar_panel = PanelContainer.new()
	avatar_panel.custom_minimum_size = Vector2(88, 112)
	avatar_panel.position = Vector2(6, 0)
	avatar_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar_panel.add_theme_stylebox_override("panel", StyleHelper.create_card_frame(rarity, 14))
	sprite_wrapper.add_child(avatar_panel)

	if tex:
		var img_rect = TextureRect.new()
		img_rect.texture = tex
		img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		img_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		avatar_panel.add_child(img_rect)
	else:
		var icon = Label.new()
		icon.text = "💃"
		icon.add_theme_font_size_override("font_size", 54)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		avatar_panel.add_child(icon)

	# Name tag
	var name_tag = Label.new()
	name_tag.text = char_info.get("name", "Вайфу")
	name_tag.add_theme_font_size_override("font_size", 12)
	name_tag.add_theme_color_override("font_color", Color(1, 0.92, 0.5))
	name_tag.position = Vector2(-20, 114)
	name_tag.custom_minimum_size = Vector2(140, 20)
	name_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(name_tag)

	# Mini Mood badge
	var mood_badge = Label.new()
	mood_badge.text = "💖"
	mood_badge.add_theme_font_size_override("font_size", 16)
	mood_badge.position = Vector2(74, -4)
	root.add_child(mood_badge)

	# Thought / Emote bubble
	var emote_bubble = PanelContainer.new()
	emote_bubble.custom_minimum_size = Vector2(44, 34)
	emote_bubble.position = Vector2(28, -34)
	emote_bubble.pivot_offset = Vector2(22, 17)
	emote_bubble.visible = false
	var eb_style = StyleBoxFlat.new()
	eb_style.bg_color = Color(1.0, 0.95, 0.98, 0.95)
	eb_style.set_corner_radius_all(12)
	eb_style.set_border_width_all(2)
	eb_style.border_color = StyleHelper.COLOR_ACCENT_PINK
	eb_style.shadow_size = 6
	eb_style.shadow_color = Color(0, 0, 0, 0.3)
	emote_bubble.add_theme_stylebox_override("panel", eb_style)
	root.add_child(emote_bubble)

	var emote_lbl = Label.new()
	emote_lbl.text = "❤️"
	emote_lbl.add_theme_font_size_override("font_size", 18)
	emote_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emote_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	emote_bubble.add_child(emote_lbl)

	# Click Button for interactions
	var click_btn = Button.new()
	click_btn.custom_minimum_size = Vector2(100, 130)
	click_btn.flat = true
	click_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	root.add_child(click_btn)

	var chibi_record = {
		"node": root,
		"sprite": sprite_wrapper,
		"shadow": shadow,
		"bubble": emote_bubble,
		"bubble_label": emote_lbl,
		"mood_badge": mood_badge,
		"char_info": char_info,
		"user_waifu": user_waifu,
		"state": "idle",
		"timer": randf_range(2.0, 5.0),
		"target_pos": initial_pos,
		"facing_right": true,
		"bob_time": randf() * 10.0,
		"walk_speed": randf_range(65.0, 85.0),
		"furniture_target": null,
		"bubble_active": false
	}
	chibis.append(chibi_record)

	# Tap reaction
	click_btn.pressed.connect(func():
		_on_chibi_tapped(chibi_record)
	)

	entities_layer.add_child(root)

func _update_chibis_ai(delta: float) -> void:
	for c in chibis:
		var root: Control = c.get("node", null)
		if not is_instance_valid(root):
			continue

		c["timer"] = c.get("timer", 3.0) - delta
		var sprite: Control = c.get("sprite", null)
		var state: String = str(c.get("state", "idle"))

		match state:
			"idle":
				var breath = sin(Time.get_ticks_msec() * 0.003 + c.get("bob_time", 0.0)) * 0.025
				var facing: bool = c.get("facing_right", true)
				if is_instance_valid(sprite):
					sprite.scale = Vector2((1.0 if facing else -1.0) * (1.0 - breath * 0.5), 1.0 + breath)
				
				if not c.get("bubble_active", false) and randf() < 0.004:
					_trigger_chibi_emote(c)

				if c.get("timer", 0.0) <= 0.0:
					_pick_next_chibi_action(c)

			"walk":
				var current_pos: Vector2 = root.position
				var target: Vector2 = c.get("target_pos", current_pos)
				var dist = current_pos.distance_to(target)

				if dist < 8.0:
					root.position = target
					if is_instance_valid(sprite):
						sprite.position.y = 0
						sprite.rotation_degrees = 0
					if c.get("furniture_target", null) != null:
						c["state"] = "furniture"
						c["timer"] = randf_range(8.0, 14.0)
						_show_furniture_emote(c)
					else:
						c["state"] = "idle"
						c["timer"] = randf_range(3.0, 6.0)
				else:
					var dir = (target - current_pos).normalized()
					var spd: float = c.get("walk_speed", 75.0)
					root.position += dir * spd * delta

					if dir.x > 0.1:
						c["facing_right"] = true
					elif dir.x < -0.1:
						c["facing_right"] = false
					
					if is_instance_valid(sprite):
						sprite.scale.x = 1.0 if c.get("facing_right", true) else -1.0
						c["bob_time"] = c.get("bob_time", 0.0) + delta * 11.0
						var bob: float = c.get("bob_time", 0.0)
						sprite.position.y = -abs(sin(bob)) * 7.0
						sprite.rotation_degrees = sin(bob) * 3.5

			"furniture":
				if is_instance_valid(sprite):
					sprite.position.y = 3.0
					var breath = sin(Time.get_ticks_msec() * 0.002 + c.get("bob_time", 0.0)) * 0.02
					var facing: bool = c.get("facing_right", true)
					sprite.scale = Vector2(1.0 if facing else -1.0, 1.0 + breath)

				if c.get("timer", 0.0) <= 0.0:
					c["state"] = "idle"
					c["furniture_target"] = null
					c["timer"] = randf_range(2.0, 4.0)

func _pick_next_chibi_action(c: Dictionary) -> void:
	var roll = randf()

	# Filter floor-only furniture so waifus don't walk onto ceiling chandeliers
	var floor_furniture: Array = []
	for f in placed_furniture:
		var ftype = str(f.get("data", {}).get("type", ""))
		if ftype in ["bed", "sofa", "table", "carpet", "plant"]:
			floor_furniture.append(f)

	if roll < 0.45 and floor_furniture.size() > 0:
		var f_choice = floor_furniture[randi() % floor_furniture.size()]
		var fn: Control = f_choice.get("node", null)
		if is_instance_valid(fn):
			c["state"] = "walk"
			c["furniture_target"] = f_choice
			var fsize: Vector2 = f_choice.get("data", {}).get("size", Vector2(100, 100))
			var dest_x = clampf(fn.position.x + randf_range(15, maxf(20, fsize.x - 30)), WALK_MIN_X, WALK_MAX_X)
			var dest_y = clampf(fn.position.y + maxf(10, fsize.y - 25), WALK_MIN_Y, WALK_MAX_Y)
			c["target_pos"] = Vector2(dest_x, dest_y)
			return

	if roll < 0.80:
		# Walk to a cozy floor spot
		c["state"] = "walk"
		c["furniture_target"] = null
		c["target_pos"] = Vector2(
			randf_range(WALK_MIN_X, WALK_MAX_X),
			randf_range(WALK_MIN_Y, WALK_MAX_Y)
		)
	else:
		# Stay idle, turn around
		c["state"] = "idle"
		c["facing_right"] = not c.get("facing_right", true)
		c["timer"] = randf_range(2.5, 5.0)

func _trigger_chibi_emote(c: Dictionary) -> void:
	var emotes = ["❤️", "🍰", "🍵", "🎵", "✨", "💤", "🌸", "⭐"]
	var chosen = emotes[randi() % emotes.size()]
	var bubble: PanelContainer = c.get("bubble", null)
	var lbl: Label = c.get("bubble_label", null)
	if not is_instance_valid(bubble) or not is_instance_valid(lbl):
		return

	lbl.text = chosen
	bubble.visible = true
	c["bubble_active"] = true
	bubble.scale = Vector2.ZERO

	var tween = create_tween()
	tween.tween_property(bubble, "scale", Vector2(1.1, 1.1), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_interval(2.5)
	tween.tween_property(bubble, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		bubble.visible = false
		c["bubble_active"] = false
	)

func _show_furniture_emote(c: Dictionary) -> void:
	var ftarget = c.get("furniture_target", {})
	var fid = str(ftarget.get("id", "")) if ftarget != null else ""
	var emote = "✨"
	if fid == "cozy_bed":
		emote = "💤"
	elif fid == "plush_sofa":
		emote = "🛋️"
	elif fid == "tea_table":
		emote = "🍵"
	elif fid == "sakura_carpet":
		emote = "🌸"
	elif fid == "bonsai_plant":
		emote = "🪴"

	var bubble: PanelContainer = c.get("bubble", null)
	var lbl: Label = c.get("bubble_label", null)
	if not is_instance_valid(bubble) or not is_instance_valid(lbl):
		return

	lbl.text = emote
	bubble.visible = true
	c["bubble_active"] = true
	bubble.scale = Vector2.ZERO

	var tween = create_tween()
	tween.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(4.0)
	tween.tween_property(bubble, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(func():
		bubble.visible = false
		c["bubble_active"] = false
	)

func _on_chibi_tapped(c: Dictionary) -> void:
	AudioManager.play_sfx_heart()
	var root: Control = c.get("node", null)
	if is_instance_valid(root):
		_spawn_floating_hearts(root.position + Vector2(40, 20), 4)

	var char_info: Dictionary = c.get("char_info", {})
	var dialogues = char_info.get("dialogues", {})
	var reply = dialogues.get("greeting", "Я так рада тебя видеть в нашей уютной комнате!")
	if is_instance_valid(root):
		show_speech_bubble(root.position + Vector2(-60, -70), reply)

	_open_waifu_modal(char_info, c.get("user_waifu", {}))

func _update_y_sorting() -> void:
	for c in chibis:
		var root: Control = c.get("node", null)
		if is_instance_valid(root):
			root.z_index = int(root.position.y + 115)
	for f in placed_furniture:
		var fn: Control = f.get("node", null)
		if is_instance_valid(fn):
			var data: Dictionary = f.get("data", {})
			var ftype = str(data.get("type", ""))
			if ftype == "carpet":
				fn.z_index = int(fn.position.y) - 60
			elif ftype in ["wall", "ceiling"]:
				fn.z_index = 5
			else:
				var fsize: Vector2 = data.get("size", Vector2(100, 100))
				fn.z_index = int(fn.position.y + fsize.y * 0.75)

# =========================================================================
# AMBIENT PARTICLES
# =========================================================================
func _init_ambient_particles() -> void:
	for p in particles_layer.get_children():
		p.queue_free()
	ambient_particles.clear()

	for i in range(20):
		var lbl = Label.new()
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_font_size_override("font_size", randi_range(10, 18))
		particles_layer.add_child(lbl)

		var p_data = {
			"node": lbl,
			"pos": Vector2(randf_range(100, 1820), randf_range(100, 1000)),
			"speed_y": randf_range(-15.0, 15.0),
			"speed_x": randf_range(-10.0, 15.0),
			"sin_offset": randf() * 10.0,
			"alpha": randf_range(0.2, 0.8)
		}
		ambient_particles.append(p_data)

func _update_ambient_particles(delta: float) -> void:
	var particle_chars = ["✦", "✨", "•", "🌸"]
	var char_idx = 0
	if current_lighting == "sunset":
		char_idx = 3
	elif current_lighting == "night":
		char_idx = 0

	for p in ambient_particles:
		var node: Label = p.get("node", null)
		if not is_instance_valid(node):
			continue

		p["pos"].y += p.get("speed_y", 0.0) * delta
		p["pos"].x += (p.get("speed_x", 0.0) + sin(Time.get_ticks_msec() * 0.002 + p.get("sin_offset", 0.0)) * 12.0) * delta

		if p["pos"].x < 50: p["pos"].x = 1870
		elif p["pos"].x > 1870: p["pos"].x = 50
		if p["pos"].y < 50: p["pos"].y = 1030
		elif p["pos"].y > 1030: p["pos"].y = 50

		node.position = p["pos"]
		node.text = particle_chars[char_idx]
		node.modulate.a = p.get("alpha", 0.5) * (0.6 + sin(Time.get_ticks_msec() * 0.003 + p.get("sin_offset", 0.0)) * 0.4)

# =========================================================================
# SPEECH & EFFECT POPUPS
# =========================================================================
func show_speech_bubble(pos: Vector2, text: String) -> void:
	speech_label.text = "«" + text + "»"
	speech_bubble.position = Vector2(clampf(pos.x, 80.0, 1600.0), clampf(pos.y, 80.0, 960.0))
	speech_bubble.visible = true
	speech_bubble.modulate.a = 0.0

	if _bubble_tween and _bubble_tween.is_valid():
		_bubble_tween.kill()

	_bubble_tween = create_tween()
	_bubble_tween.tween_property(speech_bubble, "modulate:a", 1.0, 0.2)
	_bubble_tween.tween_interval(3.2)
	_bubble_tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.3)
	_bubble_tween.tween_callback(func(): speech_bubble.visible = false)

func _spawn_floating_hearts(pos: Vector2, count: int = 5) -> void:
	for i in range(count):
		var heart = Label.new()
		heart.text = "❤️"
		heart.add_theme_font_size_override("font_size", randi_range(24, 38))
		heart.position = pos + Vector2(randf_range(-30, 30), randf_range(-20, 20))
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		effects_layer.add_child(heart)

		var tween = create_tween()
		var target_y = heart.position.y - randf_range(60, 110)
		var target_x = heart.position.x + randf_range(-40, 40)
		tween.parallel().tween_property(heart, "position", Vector2(target_x, target_y), 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(heart, "modulate:a", 0.0, 0.9)
		tween.tween_callback(heart.queue_free)

func _spawn_coin_shower() -> void:
	var start_pos = Vector2(960, 540)
	var end_pos = pending_label.global_position + Vector2(20, 10)

	for i in range(16):
		var coin = Label.new()
		coin.text = "🪙"
		coin.add_theme_font_size_override("font_size", randi_range(24, 32))
		coin.position = start_pos + Vector2(randf_range(-80, 80), randf_range(-40, 40))
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		effects_layer.add_child(coin)

		var arc_pos = Vector2(
			lerp(coin.position.x, end_pos.x, 0.5) + randf_range(-150, 150),
			min(coin.position.y, end_pos.y) - randf_range(100, 250)
		)

		var tween = create_tween()
		tween.tween_interval(i * 0.04)
		tween.tween_property(coin, "position", arc_pos, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(coin, "position", end_pos, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(coin, "scale", Vector2(0.5, 0.5), 0.35)
		tween.tween_callback(coin.queue_free)

func _start_coin_pulse() -> void:
	if _coin_pulse_tween and _coin_pulse_tween.is_valid():
		return
	_coin_pulse_tween = create_tween().set_loops()
	_coin_pulse_tween.tween_property(btn_collect, "scale", Vector2(1.05, 1.05), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_coin_pulse_tween.tween_property(btn_collect, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_coin_pulse() -> void:
	if _coin_pulse_tween and _coin_pulse_tween.is_valid():
		_coin_pulse_tween.kill()
		_coin_pulse_tween = null
	btn_collect.scale = Vector2.ONE

# =========================================================================
# HUD ACTIONS & INCOME
# =========================================================================
func _on_collect_income() -> void:
	btn_collect.disabled = true
	NetworkManager.collect_dorm_income(func(success: bool, data: Variant):
		if success and data is Dictionary:
			AudioManager.play_sfx_coins()
			_spawn_coin_shower()
			var coins_gain = data.get("coins_collected", 0)
			GameSession.show_toast("Собрано +" + str(coins_gain) + " монет! 🪙", true)
			var new_bal = int(data.get("new_balance", GameSession.coins))
			GameSession.set_balances(new_bal, GameSession.love_gems, GameSession.soul_shards)
			GameSession.refresh_dorm()
		else:
			btn_collect.disabled = false
	)

func _on_clean_dorm() -> void:
	btn_clean.disabled = true
	NetworkManager.clean_dorm(func(success: bool, data: Variant):
		btn_clean.disabled = false
		if success and data is Dictionary:
			AudioManager.play_sfx_ssr()
			for i in range(24):
				var star = Label.new()
				star.text = "✨"
				star.add_theme_font_size_override("font_size", randi_range(28, 44))
				star.position = Vector2(randf_range(200, 1720), randf_range(200, 900))
				star.mouse_filter = Control.MOUSE_FILTER_IGNORE
				effects_layer.add_child(star)

				var tw = create_tween()
				tw.tween_property(star, "scale", Vector2(1.4, 1.4), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw.parallel().tween_property(star, "modulate:a", 0.0, 0.8)
				tw.tween_callback(star.queue_free)

			var msg = str(data.get("message", "Комната сияет чистотой! ✨"))
			GameSession.show_toast(msg, true)
			var new_bal = int(data.get("new_balance", GameSession.coins))
			GameSession.set_balances(new_bal, GameSession.love_gems, GameSession.soul_shards)
			GameSession.refresh_dorm()
			GameSession.refresh_waifus()
	)

# =========================================================================
# MODALS MANAGEMENT
# =========================================================================
func close_active_modal() -> void:
	if active_modal and is_instance_valid(active_modal):
		active_modal.queue_free()
		active_modal = null
	modals_layer.visible = false

# --- 1. WAIFU DORM PROFILE & FEEDING MODAL ---
func _open_waifu_modal(char_info: Dictionary, user_waifu: Dictionary) -> void:
	close_active_modal()
	modals_layer.visible = true

	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(840, 580)
	modal.anchors_preset = Control.PRESET_CENTER
	modal.position = Vector2(540, 250)
	StyleHelper.apply_panel_style(modal, StyleHelper.COLOR_ACCENT_PINK, 18, 0.96)
	modals_layer.add_child(modal)
	active_modal = modal

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	modal.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	margin.add_child(hbox)

	# Left Column: Big Portrait & Rarity Frame
	var left_vbox = VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(260, 0)
	hbox.add_child(left_vbox)

	var cid = str(char_info.get("id", ""))
	var rarity = str(char_info.get("rarity", "SSR"))
	var art_frame = PanelContainer.new()
	art_frame.custom_minimum_size = Vector2(250, 340)
	art_frame.add_theme_stylebox_override("panel", StyleHelper.create_card_frame(rarity, 16))
	left_vbox.add_child(art_frame)

	var tex = GameSession.get_character_texture(cid)
	if tex:
		var art_rect = TextureRect.new()
		art_rect.texture = tex
		art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art_frame.add_child(art_rect)
	else:
		var big_icon = Label.new()
		big_icon.text = "💃"
		big_icon.add_theme_font_size_override("font_size", 96)
		big_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		big_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		art_frame.add_child(big_icon)

	var star_lbl = Label.new()
	star_lbl.text = "⭐⭐⭐⭐⭐"
	star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_vbox.add_child(star_lbl)

	# Right Column: Stats & Actions
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 12)
	hbox.add_child(right_vbox)

	var title_lbl = Label.new()
	title_lbl.text = char_info.get("name", "Вайфу") + " [" + rarity + "]"
	title_lbl.add_theme_font_size_override("font_size", 24)
	title_lbl.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
	right_vbox.add_child(title_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = char_info.get("title", "Верная спутница")
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	right_vbox.add_child(desc_lbl)

	var aff_level = int(user_waifu.get("affection_level", 1))
	var aff_pts = int(user_waifu.get("affection_points", 0))
	var mood_val = int(user_waifu.get("mood", 100))
	var hunger_val = int(user_waifu.get("hunger", 100))

	var stats_box = VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 6)
	right_vbox.add_child(stats_box)

	var aff_lbl = Label.new()
	aff_lbl.text = "❤️ Симпатия: Уровень " + str(aff_level) + " (" + str(aff_pts) + " очков)"
	aff_lbl.add_theme_font_size_override("font_size", 14)
	stats_box.add_child(aff_lbl)

	var mood_bar_lbl = Label.new()
	mood_bar_lbl.text = "💖 Настроение: " + str(mood_val) + "/100 (Отличное ✨)"
	mood_bar_lbl.add_theme_font_size_override("font_size", 14)
	stats_box.add_child(mood_bar_lbl)

	var hunger_bar_lbl = Label.new()
	hunger_bar_lbl.text = "🍖 Сытость: " + str(hunger_val) + "/100"
	hunger_bar_lbl.add_theme_font_size_override("font_size", 14)
	stats_box.add_child(hunger_bar_lbl)

	# Action Buttons (Headpat & Talk)
	var actions_hbox = HBoxContainer.new()
	actions_hbox.add_theme_constant_override("separation", 10)
	right_vbox.add_child(actions_hbox)

	var btn_pat = Button.new()
	btn_pat.text = "👋 Погладить"
	btn_pat.custom_minimum_size = Vector2(140, 40)
	StyleHelper.apply_button_style(btn_pat, StyleHelper.COLOR_ACCENT_PINK, 10)
	actions_hbox.add_child(btn_pat)

	var btn_talk = Button.new()
	btn_talk.text = "💬 Беседа"
	btn_talk.custom_minimum_size = Vector2(130, 40)
	StyleHelper.apply_button_style(btn_talk, StyleHelper.COLOR_ACCENT_PURPLE, 10)
	actions_hbox.add_child(btn_talk)

	var food_tray_label = Label.new()
	food_tray_label.text = "🍰 Угощения и подарки из инвентаря / магазина:"
	food_tray_label.add_theme_font_size_override("font_size", 13)
	right_vbox.add_child(food_tray_label)

	var food_scroll = ScrollContainer.new()
	food_scroll.custom_minimum_size = Vector2(0, 160)
	food_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(food_scroll)

	var food_grid = GridContainer.new()
	food_grid.columns = 3
	food_grid.add_theme_constant_override("h_separation", 8)
	food_grid.add_theme_constant_override("v_separation", 8)
	food_scroll.add_child(food_grid)

	var fav_food = char_info.get("favorite_food", [])
	var wid = int(user_waifu.get("id", -1))

	# Function to populate food cards with inventory check
	var populate_food_tray = func(inv_map: Dictionary):
		for ch in food_grid.get_children():
			ch.queue_free()

		for f_data in FOOD_ITEMS:
			var fid = str(f_data.get("id", ""))
			var is_favorite = (fid in fav_food)
			var owned_qty = int(inv_map.get(fid, 0))
			var price = int(f_data.get("price", 50))
			var cur_type = str(f_data.get("currency", "coins"))

			var f_card = Button.new()
			f_card.custom_minimum_size = Vector2(160, 68)

			var f_title = str(f_data.get("icon", "🍰")) + " " + str(f_data.get("name", "Угощение"))
			if is_favorite:
				f_title += "\n⭐ Любимое (x2)"
			else:
				f_title += "\n+" + str(f_data.get("affection", 15)) + " ❤️"

			if owned_qty > 0:
				f_title += " (x" + str(owned_qty) + ")"
				StyleHelper.apply_button_style(f_card, StyleHelper.COLOR_ACCENT_GOLD if is_favorite else Color(0.2, 0.45, 0.35), 8)
			else:
				var cur_icon = "🪙" if cur_type == "coins" else "💎"
				f_title += " [" + str(price) + cur_icon + "]"
				StyleHelper.apply_button_style(f_card, Color(0.25, 0.25, 0.38), 8)

			f_card.text = f_title
			food_grid.add_child(f_card)

			f_card.pressed.connect(func():
				if wid <= 0:
					GameSession.show_toast("Эта вайфу еще не в коллекции!", false)
					return

				if owned_qty > 0:
					# Feed directly from inventory
					NetworkManager.feed_waifu(wid, fid, func(feed_ok: bool, feed_data: Variant):
						if feed_ok and feed_data is Dictionary:
							AudioManager.play_sfx_heart()
							_spawn_floating_hearts(modal.global_position + Vector2(200, 200), 8)
							var rep = str(feed_data.get("reply", "Очень вкусно!"))
							var gain = feed_data.get("affection_gain", 15)
							var fav_note = "⭐ Любимое блюдо! " if feed_data.get("is_favorite", false) else ""
							GameSession.show_toast(fav_note + "+" + str(gain) + " симпатии! «" + rep + "»", true)
							GameSession.refresh_waifus()
							close_active_modal()
						else:
							var err = "Не удалось покормить вайфу"
							if feed_data is Dictionary:
								err = feed_data.get("error", err)
							GameSession.show_toast(err, false)
					)
				else:
					# Quick Buy and Feed
					var has_currency = false
					if cur_type == "coins":
						has_currency = (GameSession.coins >= price)
					else:
						has_currency = (GameSession.love_gems >= price)

					if not has_currency:
						var c_name = "монет" if cur_type == "coins" else "кристаллов любви"
						GameSession.show_toast("Недостаточно " + c_name + " для покупки!", false)
						return

					NetworkManager.buy_shop_item(fid, 1, func(buy_ok: bool, buy_data: Variant):
						if buy_ok:
							if buy_data is Dictionary and buy_data.has("new_balance"):
								var nb = buy_data["new_balance"]
								GameSession.set_balances(
									int(nb.get("coins", GameSession.coins)),
									int(nb.get("love_gems", GameSession.love_gems)),
									GameSession.soul_shards
								)
							# Feed immediately
							NetworkManager.feed_waifu(wid, fid, func(feed_ok: bool, feed_data: Variant):
								if feed_ok and feed_data is Dictionary:
									AudioManager.play_sfx_heart()
									_spawn_floating_hearts(modal.global_position + Vector2(200, 200), 8)
									var rep = str(feed_data.get("reply", "Очень вкусно!"))
									var gain = feed_data.get("affection_gain", 15)
									GameSession.show_toast("Куплено и съедено! +" + str(gain) + " симпатии! «" + rep + "»", true)
									GameSession.refresh_waifus()
									close_active_modal()
							)
						else:
							GameSession.show_toast("Ошибка покупки предмета", false)
					)
			)

	# Fetch inventory to show quantities
	NetworkManager.get_inventory(func(inv_ok: bool, inv_res: Variant):
		_user_inventory_map.clear()
		if inv_ok and inv_res is Array:
			for item_entry in inv_res:
				if item_entry is Dictionary:
					var iid = str(item_entry.get("item_id", ""))
					var qty = int(item_entry.get("quantity", 0))
					_user_inventory_map[iid] = qty
		populate_food_tray.call(_user_inventory_map)
	)

	# Headpat handler
	btn_pat.pressed.connect(func():
		if wid <= 0:
			GameSession.show_toast("Сначала добавьте вайфу в коллекцию", false)
			return
		NetworkManager.headpat_waifu(wid, func(success: bool, data: Variant):
			if success and data is Dictionary:
				AudioManager.play_sfx_heart()
				_spawn_floating_hearts(modal.global_position + Vector2(150, 150), 10)
				var rep = str(data.get("reply", "Спасибо за ласку!"))
				GameSession.show_toast("Погладили! «" + rep + "»", true)
				GameSession.refresh_waifus()
				close_active_modal()
		)
	)

	# Talk handler
	btn_talk.pressed.connect(func():
		AudioManager.play_sfx_click()
		var dialogues = char_info.get("dialogues", {})
		var msg = dialogues.get("greeting", "Здесь так спокойно и хорошо вместе с тобой.")
		GameSession.show_toast("«" + msg + "»", true)
	)

	# Close button
	var btn_close = Button.new()
	btn_close.text = "Закрыть ✖️"
	btn_close.custom_minimum_size = Vector2(0, 36)
	StyleHelper.apply_button_style(btn_close, Color(0.4, 0.35, 0.45), 8)
	btn_close.pressed.connect(close_active_modal)
	right_vbox.add_child(btn_close)

# --- 2. RESIDENTS MANAGEMENT MODAL ---
func _open_residents_modal() -> void:
	close_active_modal()
	modals_layer.visible = true

	_editing_residents = dorm_data.get("assigned_waifus", []).duplicate()

	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(920, 600)
	modal.anchors_preset = Control.PRESET_CENTER
	modal.position = Vector2(500, 240)
	StyleHelper.apply_panel_style(modal, StyleHelper.COLOR_ACCENT_PURPLE, 18, 0.96)
	modals_layer.add_child(modal)
	active_modal = modal

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	modal.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)

	var title = Label.new()
	title.text = "👥 Управление жильцами общежития"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
	header_hbox.add_child(title)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	var btn_close = Button.new()
	btn_close.text = "✖️"
	btn_close.custom_minimum_size = Vector2(36, 36)
	StyleHelper.apply_button_style(btn_close, Color(0.5, 0.3, 0.4), 8)
	btn_close.pressed.connect(close_active_modal)
	header_hbox.add_child(btn_close)

	var slots_label = Label.new()
	slots_label.text = "Текущие жители комнаты (до 4 персонажей):"
	slots_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(slots_label)

	var slots_hbox = HBoxContainer.new()
	slots_hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(slots_hbox)

	var roster_label = Label.new()
	roster_label.text = "Все вайфу из вашей коллекции:"
	roster_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(roster_label)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 260)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var roster_grid = GridContainer.new()
	roster_grid.columns = 4
	roster_grid.add_theme_constant_override("h_separation", 12)
	roster_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(roster_grid)

	# Dynamic UI update function that does not reset state
	var refresh_ui = Callable()
	refresh_ui = func():
		# 1. Update Slots
		for ch in slots_hbox.get_children():
			ch.queue_free()

		for i in range(4):
			var slot_card = PanelContainer.new()
			slot_card.custom_minimum_size = Vector2(200, 90)
			var s_style = StyleBoxFlat.new()
			s_style.set_corner_radius_all(12)
			s_style.set_border_width_all(2)

			if i < _editing_residents.size():
				var cid = str(_editing_residents[i])
				var c_info = GameSession.all_characters_catalog.get(cid, {})
				s_style.bg_color = Color(0.18, 0.15, 0.28, 0.95)
				s_style.border_color = StyleHelper.COLOR_ACCENT_PINK
				slot_card.add_theme_stylebox_override("panel", s_style)

				var s_vbox = VBoxContainer.new()
				s_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
				slot_card.add_child(s_vbox)

				var s_name = Label.new()
				s_name.text = c_info.get("name", cid)
				s_name.add_theme_font_size_override("font_size", 13)
				s_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				s_vbox.add_child(s_name)

				var btn_remove = Button.new()
				btn_remove.text = "Выселить ✖️"
				btn_remove.custom_minimum_size = Vector2(100, 28)
				StyleHelper.apply_button_style(btn_remove, Color(0.6, 0.25, 0.35), 6)
				btn_remove.pressed.connect(func():
					_editing_residents.erase(cid)
					refresh_ui.call()
				)
				s_vbox.add_child(btn_remove)
			else:
				s_style.bg_color = Color(0.1, 0.1, 0.15, 0.6)
				s_style.border_color = Color(0.3, 0.3, 0.4, 0.5)
				slot_card.add_theme_stylebox_override("panel", s_style)

				var empty_lbl = Label.new()
				empty_lbl.text = "🛏️ Пустой слот"
				empty_lbl.add_theme_font_size_override("font_size", 12)
				empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				slot_card.add_child(empty_lbl)

			slots_hbox.add_child(slot_card)

		# 2. Update Roster Grid
		for ch in roster_grid.get_children():
			ch.queue_free()

		for uw in GameSession.user_waifus:
			var cid = str(uw.get("character_id", ""))
			var c_info = GameSession.all_characters_catalog.get(cid, {})
			var rarity = str(c_info.get("rarity", "SSR"))
			var is_assigned = (cid in _editing_residents)

			var card = PanelContainer.new()
			card.custom_minimum_size = Vector2(200, 110)
			card.add_theme_stylebox_override("panel", StyleHelper.create_card_frame(rarity, 12))

			var cvbox = VBoxContainer.new()
			cvbox.alignment = BoxContainer.ALIGNMENT_CENTER
			card.add_child(cvbox)

			var cname = Label.new()
			cname.text = c_info.get("name", cid)
			cname.add_theme_font_size_override("font_size", 13)
			cname.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
			cname.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cvbox.add_child(cname)

			var toggle_btn = Button.new()
			toggle_btn.custom_minimum_size = Vector2(120, 32)
			if is_assigned:
				toggle_btn.text = "В комнате ✔️"
				StyleHelper.apply_button_style(toggle_btn, Color(0.2, 0.5, 0.35), 8)
				toggle_btn.pressed.connect(func():
					_editing_residents.erase(cid)
					refresh_ui.call()
				)
			else:
				toggle_btn.text = "Заселить ➕"
				StyleHelper.apply_button_style(toggle_btn, StyleHelper.COLOR_ACCENT_PINK, 8)
				toggle_btn.pressed.connect(func():
					if _editing_residents.size() >= 4:
						GameSession.show_toast("В комнате может жить максимум 4 вайфу!", false)
						return
					_editing_residents.append(cid)
					refresh_ui.call()
				)
			cvbox.add_child(toggle_btn)
			roster_grid.add_child(card)

	refresh_ui.call()

	# Bottom Save Button
	var btn_save = Button.new()
	btn_save.text = "💾 Сохранить и применить"
	btn_save.custom_minimum_size = Vector2(0, 44)
	StyleHelper.apply_button_style(btn_save, StyleHelper.COLOR_ACCENT_GOLD, 10)
	btn_save.pressed.connect(func():
		NetworkManager.assign_dorm_waifus(_editing_residents, func(success: bool, _data: Variant):
			if success:
				dorm_data["assigned_waifus"] = _editing_residents.duplicate()
				residents_label.text = "👥 Жильцы: " + str(_editing_residents.size()) + "/4"
				spawn_chibis(_editing_residents)
				GameSession.show_toast("Жильцы комнаты успешно обновлены! ✨", true)
				close_active_modal()
		)
	)
	vbox.add_child(btn_save)

# --- 3. FURNITURE MANAGEMENT MODAL ---
func _open_furniture_modal() -> void:
	close_active_modal()
	modals_layer.visible = true

	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(900, 580)
	modal.anchors_preset = Control.PRESET_CENTER
	modal.position = Vector2(510, 250)
	StyleHelper.apply_panel_style(modal, StyleHelper.COLOR_ACCENT_PURPLE, 18, 0.96)
	modals_layer.add_child(modal)
	active_modal = modal

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	modal.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)

	var title = Label.new()
	title.text = "🛋️ Расстановка и каталог мебели"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
	header_hbox.add_child(title)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	var btn_close = Button.new()
	btn_close.text = "✖️"
	btn_close.custom_minimum_size = Vector2(36, 36)
	StyleHelper.apply_button_style(btn_close, Color(0.5, 0.3, 0.4), 8)
	btn_close.pressed.connect(close_active_modal)
	header_hbox.add_child(btn_close)

	var hint = Label.new()
	hint.text = "Совет: Вы можете перетаскивать установленную мебель прямо по полу комнаты мышкой!"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	vbox.add_child(hint)

	# Presets
	var presets_hbox = HBoxContainer.new()
	presets_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(presets_hbox)

	var btn_preset_all = Button.new()
	btn_preset_all.text = "✨ Полный комплект (+175 Уюта)"
	btn_preset_all.custom_minimum_size = Vector2(250, 38)
	StyleHelper.apply_button_style(btn_preset_all, StyleHelper.COLOR_ACCENT_GOLD, 8)
	btn_preset_all.pressed.connect(func():
		var full_set = []
		for fid in FURNITURE_CATALOG.keys():
			var cat = FURNITURE_CATALOG[fid]
			var def_p = cat.get("default_pos", Vector2(500, 600))
			full_set.append({"id": fid, "x": def_p.x, "y": def_p.y})
		_load_furniture_layout(full_set)
		_save_current_furniture_layout()
		GameSession.show_toast("Установлен гармоничный комплект мебели! ✨", true)
		close_active_modal()
	)
	presets_hbox.add_child(btn_preset_all)

	var btn_clear_all = Button.new()
	btn_clear_all.text = "🧹 Очистить комнату"
	btn_clear_all.custom_minimum_size = Vector2(170, 38)
	StyleHelper.apply_button_style(btn_clear_all, Color(0.6, 0.25, 0.35), 8)
	btn_clear_all.pressed.connect(func():
		_load_furniture_layout([])
		_save_current_furniture_layout()
		GameSession.show_toast("Мебель убрана на склад.", true)
		close_active_modal()
	)
	presets_hbox.add_child(btn_clear_all)

	# Furniture items scroll
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 340)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)

	var refresh_furniture_grid = Callable()
	refresh_furniture_grid = func():
		for ch in grid.get_children():
			ch.queue_free()

		var placed_ids = []
		for p in placed_furniture:
			placed_ids.append(p.get("id", ""))

		for fid in FURNITURE_CATALOG.keys():
			var cat: Dictionary = FURNITURE_CATALOG[fid]
			var is_placed = (fid in placed_ids)

			var card = PanelContainer.new()
			card.custom_minimum_size = Vector2(260, 95)
			var c_style = StyleBoxFlat.new()
			c_style.bg_color = cat.get("color", Color(0.3, 0.3, 0.4))
			c_style.border_color = cat.get("border", Color(0.6, 0.6, 0.8))
			c_style.set_border_width_all(2)
			c_style.set_corner_radius_all(12)
			card.add_theme_stylebox_override("panel", c_style)

			var chbox = HBoxContainer.new()
			chbox.add_theme_constant_override("separation", 10)
			card.add_child(chbox)

			var icon_lbl = Label.new()
			icon_lbl.text = " " + str(cat.get("icon", "🪑"))
			icon_lbl.add_theme_font_size_override("font_size", 38)
			chbox.add_child(icon_lbl)

			var cvbox = VBoxContainer.new()
			cvbox.alignment = BoxContainer.ALIGNMENT_CENTER
			cvbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			chbox.add_child(cvbox)

			var name_lbl = Label.new()
			name_lbl.text = str(cat.get("name", "Мебель")) + " (+" + str(cat.get("comfort", 10)) + " 🛋️)"
			name_lbl.add_theme_font_size_override("font_size", 13)
			cvbox.add_child(name_lbl)

			var toggle_btn = Button.new()
			toggle_btn.custom_minimum_size = Vector2(100, 30)
			if is_placed:
				toggle_btn.text = "Убрать ✖️"
				StyleHelper.apply_button_style(toggle_btn, Color(0.6, 0.3, 0.35), 6)
				toggle_btn.pressed.connect(func():
					for p in placed_furniture:
						if p.get("id", "") == fid:
							var n = p.get("node", null)
							if is_instance_valid(n):
								n.queue_free()
							placed_furniture.erase(p)
							break
					_save_current_furniture_layout()
					refresh_furniture_grid.call()
				)
			else:
				toggle_btn.text = "Поставить ➕"
				StyleHelper.apply_button_style(toggle_btn, Color(0.2, 0.6, 0.4), 6)
				toggle_btn.pressed.connect(func():
					_create_furniture_node(cat, cat.get("default_pos", Vector2(500, 600)))
					_save_current_furniture_layout()
					refresh_furniture_grid.call()
				)
			cvbox.add_child(toggle_btn)
			grid.add_child(card)

	refresh_furniture_grid.call()

# --- 4. THEME & LIGHTING MODAL ---
func _open_theme_modal() -> void:
	close_active_modal()
	modals_layer.visible = true

	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(800, 520)
	modal.anchors_preset = Control.PRESET_CENTER
	modal.position = Vector2(560, 280)
	StyleHelper.apply_panel_style(modal, Color(0.85, 0.5, 0.3), 18, 0.96)
	modals_layer.add_child(modal)
	active_modal = modal

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	modal.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)

	var title = Label.new()
	title.text = "🎨 Выбор темы и освещения комнаты"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
	header_hbox.add_child(title)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	var btn_close = Button.new()
	btn_close.text = "✖️"
	btn_close.custom_minimum_size = Vector2(36, 36)
	StyleHelper.apply_button_style(btn_close, Color(0.5, 0.3, 0.4), 8)
	btn_close.pressed.connect(close_active_modal)
	header_hbox.add_child(btn_close)

	# Lighting Mood selection
	var light_label = Label.new()
	light_label.text = "Атмосфера и время суток:"
	light_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(light_label)

	var light_hbox = HBoxContainer.new()
	light_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(light_hbox)

	var moods = [
		{"id": "day", "name": "☀️ Солнечный день", "color": Color(0.3, 0.6, 0.8)},
		{"id": "sunset", "name": "🌅 Золотой закат", "color": Color(0.85, 0.45, 0.15)},
		{"id": "night", "name": "🌙 Уютная ночь", "color": Color(0.25, 0.25, 0.55)}
	]

	for m in moods:
		var btn = Button.new()
		btn.text = m.get("name", "")
		btn.custom_minimum_size = Vector2(180, 40)
		StyleHelper.apply_button_style(btn, m.get("color", Color(0.3, 0.4, 0.5)), 8)
		btn.pressed.connect(func():
			set_lighting_mood(m.get("id", "day"))
			GameSession.show_toast("Освещение: " + m.get("name", ""), true)
		)
		light_hbox.add_child(btn)

	# Themes Grid
	var themes_label = Label.new()
	themes_label.text = "Интерьеры комнаты:"
	themes_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(themes_label)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	for opt in THEME_OPTIONS:
		var card = Button.new()
		card.custom_minimum_size = Vector2(230, 80)
		var desc_text = str(opt.get("desc", ""))
		card.text = str(opt.get("icon", "")) + " " + str(opt.get("name", "")) + ("\n" + desc_text if desc_text != "" else "")
		var opt_id = str(opt.get("id", ""))
		var is_current = (opt_id == current_theme)
		StyleHelper.apply_button_style(card, StyleHelper.COLOR_ACCENT_GOLD if is_current else opt.get("color", Color(0.2, 0.2, 0.3)), 10)
		card.pressed.connect(func():
			apply_theme(opt_id, true)
			close_active_modal()
		)
		grid.add_child(card)

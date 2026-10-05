extends Control

# Top Header Nodes
@onready var progress_label: Label = $MainVBox/TopHeaderPanel/Margin/HBox/CollectionProgressBox/ProgressLabel
@onready var progress_bar: ProgressBar = $MainVBox/TopHeaderPanel/Margin/HBox/CollectionProgressBox/ProgressBar
@onready var star_power_label: Label = $MainVBox/TopHeaderPanel/Margin/HBox/StarPowerLabel
@onready var favorites_count_label: Label = $MainVBox/TopHeaderPanel/Margin/HBox/FavoritesCountLabel
@onready var dates_count_label: Label = $MainVBox/TopHeaderPanel/Margin/HBox/DatesCountLabel

# Filter Controls
@onready var filter_control_panel: PanelContainer = $MainVBox/FilterControlPanel
@onready var search_input: LineEdit = $MainVBox/FilterControlPanel/Margin/HBox/SearchInput
@onready var rarity_chips_box: HBoxContainer = $MainVBox/FilterControlPanel/Margin/HBox/RarityChipsBox
@onready var franchise_option: OptionButton = $MainVBox/FilterControlPanel/Margin/HBox/FranchiseOption
@onready var btn_favorites_only: Button = $MainVBox/FilterControlPanel/Margin/HBox/BtnFavoritesOnly
@onready var sort_option: OptionButton = $MainVBox/FilterControlPanel/Margin/HBox/SortOption

# Gallery Grid
@onready var grid_container: HFlowContainer = $MainVBox/ScrollContainer/GridContainer

# Detail Modal Nodes
@onready var detail_modal: Control = $DetailModal
@onready var modal_dimmer: ColorRect = $DetailModal/Dimmer
@onready var modal_panel: PanelContainer = $DetailModal/Panel
@onready var big_portrait: TextureRect = $DetailModal/Panel/Margin/MainHBox/LeftCol/PortraitFrame/BigPortrait
@onready var btn_card_favorite: Button = $DetailModal/Panel/Margin/MainHBox/LeftCol/PortraitFrame/BtnCardFavorite
@onready var dialogue_balloon: Label = $DetailModal/Panel/Margin/MainHBox/LeftCol/VoiceBox/Margin/VBox/DialogueBalloon

@onready var btn_voice_greeting: Button = $DetailModal/Panel/Margin/MainHBox/LeftCol/VoiceBox/Margin/VBox/VoiceButtonsHBox/BtnVoiceGreeting
@onready var btn_voice_headpat: Button = $DetailModal/Panel/Margin/MainHBox/LeftCol/VoiceBox/Margin/VBox/VoiceButtonsHBox/BtnVoiceHeadpat
@onready var btn_voice_feed: Button = $DetailModal/Panel/Margin/MainHBox/LeftCol/VoiceBox/Margin/VBox/VoiceButtonsHBox/BtnVoiceFeed
@onready var btn_voice_level: Button = $DetailModal/Panel/Margin/MainHBox/LeftCol/VoiceBox/Margin/VBox/VoiceButtonsHBox/BtnVoiceLevel
@onready var btn_voice_love: Button = $DetailModal/Panel/Margin/MainHBox/LeftCol/VoiceBox/Margin/VBox/VoiceButtonsHBox/BtnVoiceLove

@onready var char_name: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/TopInfoBar/NameBox/CharName
@onready var char_title_franchise: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/TopInfoBar/NameBox/CharTitleFranchise
@onready var rarity_badge: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/TopInfoBar/BadgesBox/RarityBadge
@onready var stars_label: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/TopInfoBar/BadgesBox/StarsLabel
@onready var bio_label: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/BioLabel

@onready var charm_bar: ProgressBar = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/StatsBox/Margin/VBox/CharmHBox/CharmBar
@onready var charm_value: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/StatsBox/Margin/VBox/CharmHBox/CharmValue
@onready var energy_bar: ProgressBar = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/StatsBox/Margin/VBox/EnergyHBox/EnergyBar
@onready var energy_value: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/StatsBox/Margin/VBox/EnergyHBox/EnergyValue
@onready var intellect_bar: ProgressBar = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/StatsBox/Margin/VBox/IntellectHBox/IntellectBar
@onready var intellect_value: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/StatsBox/Margin/VBox/IntellectHBox/IntellectValue

@onready var ascend_desc: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/AscensionBox/Margin/HBox/AscendInfo/AscendDesc
@onready var btn_ascend: Button = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/AscensionBox/Margin/HBox/BtnAscend

@onready var affection_status_label: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/MilestonesBox/Margin/VBox/AffectionHeaderHBox/AffectionStatusLabel
@onready var affection_points_label: Label = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/MilestonesBox/Margin/VBox/AffectionHeaderHBox/AffectionPointsLabel
@onready var affection_progress_bar: ProgressBar = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/MilestonesBox/Margin/VBox/AffectionProgressBar

@onready var milestones_hbox: HBoxContainer = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/MilestonesBox/Margin/VBox/MilestonesHBox
@onready var outfits_hbox: HBoxContainer = $DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/WardrobeBox/Margin/VBox/OutfitsHBox

@onready var btn_headpat: Button = $DetailModal/Panel/Margin/MainHBox/RightCol/ActionsHBox/BtnHeadpat
@onready var btn_feed: Button = $DetailModal/Panel/Margin/MainHBox/RightCol/ActionsHBox/BtnFeed
@onready var btn_go_date: Button = $DetailModal/Panel/Margin/MainHBox/RightCol/ActionsHBox/BtnGoDate
@onready var btn_close_detail: Button = $DetailModal/Panel/Margin/MainHBox/RightCol/ActionsHBox/BtnCloseDetail

# Filter & Sort state
var current_rarity_filter: String = "ALL"
var current_franchise_filter: String = "ALL"
var current_search_query: String = ""
var only_favorites: bool = false
var current_sort_index: int = 0

var selected_waifu_data: Dictionary = {}
var balloon_tween: Tween = null
var current_active_voice_btn: Button = null
var is_ascending: bool = false
var is_headpatting: bool = false
var is_feeding: bool = false
var is_unlocking_outfit: bool = false

const ASCENSION_COSTS = {1: 30, 2: 60, 3: 120, 4: 250}
const AFFECTION_THRESHOLDS = [0, 50, 120, 220, 350, 500, 700, 950, 1250, 1600]
const RANKS = {
	1: "Знакомая",
	2: "Приятельница",
	3: "Близкая подруга",
	4: "Возлюбленная",
	5: "Невеста",
	6: "Родственная душа",
	7: "Вечная любовь",
	8: "Пламенное сердце",
	9: "Божественная связь",
	10: "Абсолютное единство"
}
const MILESTONE_REWARDS = {
	2: {"gems": 50, "title": "Симпатия"},
	3: {"gems": 100, "title": "Доверие"},
	4: {"gems": 150, "title": "Привязанность"},
	5: {"gems": 250, "title": "Истинная любовь"}
}

func _get_affection_progress(points: int, level: int) -> Dictionary:
	var cur_thresh = AFFECTION_THRESHOLDS[clamp(level - 1, 0, AFFECTION_THRESHOLDS.size() - 1)]
	var next_thresh = AFFECTION_THRESHOLDS[clamp(level, 0, AFFECTION_THRESHOLDS.size() - 1)]
	var diff = max(1, next_thresh - cur_thresh)
	var pts_in_level = max(0, points - cur_thresh)
	var pct = clampf((float(pts_in_level) / float(diff)) * 100.0, 0.0, 100.0)
	return {
		"current_threshold": cur_thresh,
		"next_threshold": next_thresh,
		"points_in_level": pts_in_level,
		"points_required": diff,
		"percentage": pct
	}

func _ready() -> void:
	detail_modal.visible = false

	# Apply Styling
	_apply_visual_styling()

	# Setup Sort Options
	_setup_sort_options()

	# Connect Search and Filter Signals
	search_input.text_changed.connect(func(new_text: String):
		current_search_query = new_text.strip_edges().to_lower()
		render_roster()
	)

	btn_favorites_only.toggled.connect(func(toggled_on: bool):
		AudioManager.play_sfx_click()
		only_favorites = toggled_on
		_update_favorites_button_style()
		render_roster()
	)

	sort_option.item_selected.connect(func(idx: int):
		AudioManager.play_sfx_click()
		current_sort_index = idx
		render_roster()
	)

	franchise_option.item_selected.connect(func(idx: int):
		AudioManager.play_sfx_click()
		current_franchise_filter = franchise_option.get_item_metadata(idx)
		render_roster()
	)

	# Detail Modal Actions
	btn_close_detail.pressed.connect(func():
		AudioManager.play_sfx_click()
		detail_modal.visible = false
	)

	modal_dimmer.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			AudioManager.play_sfx_click()
			detail_modal.visible = false
	)

	btn_card_favorite.pressed.connect(_on_toggle_modal_favorite)
	btn_headpat.pressed.connect(_on_headpat_clicked)
	btn_feed.pressed.connect(_on_feed_clicked)
	btn_go_date.pressed.connect(_on_go_date_clicked)
	btn_ascend.pressed.connect(_on_ascend_clicked)

	# Voice lines
	btn_voice_greeting.pressed.connect(func(): _play_voice_line("greeting", btn_voice_greeting))
	btn_voice_headpat.pressed.connect(func(): _play_voice_line("headpat", btn_voice_headpat))
	btn_voice_feed.pressed.connect(func(): _play_voice_line("feed", btn_voice_feed))
	btn_voice_level.pressed.connect(func(): _play_voice_line("level_up", btn_voice_level))
	btn_voice_love.pressed.connect(func(): _play_voice_line("confession", btn_voice_love))

	# React to data updates
	GameSession.waifus_updated.connect(func(_w):
		_populate_franchises()
		render_roster()
		_update_header_stats()
		if detail_modal.visible and selected_waifu_data.has("id"):
			var updated = GameSession.get_waifu_by_id(int(selected_waifu_data.get("id", -1)))
			if not updated.is_empty():
				open_detail_modal(updated, true)
	)

	_setup_rarity_chips()
	_populate_franchises()
	render_roster()
	_update_header_stats()

func _apply_visual_styling() -> void:
	StyleHelper.apply_panel_style($MainVBox/TopHeaderPanel, StyleHelper.COLOR_PANEL_BORDER, 12, 0.94)
	StyleHelper.apply_panel_style(filter_control_panel, StyleHelper.COLOR_PANEL_BORDER, 12, 0.94)
	_update_favorites_button_style()

	# Detail Modal Panels
	StyleHelper.apply_panel_style(modal_panel, StyleHelper.COLOR_ACCENT_PINK, 18, 0.96)
	StyleHelper.apply_panel_style($DetailModal/Panel/Margin/MainHBox/LeftCol/PortraitFrame, StyleHelper.COLOR_ACCENT_PURPLE, 14, 0.5)
	StyleHelper.apply_panel_style($DetailModal/Panel/Margin/MainHBox/LeftCol/VoiceBox, StyleHelper.COLOR_PANEL_BORDER, 12, 0.6)
	StyleHelper.apply_panel_style($DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/StatsBox, StyleHelper.COLOR_PANEL_BORDER, 12, 0.5)
	StyleHelper.apply_panel_style($DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/AscensionBox, StyleHelper.COLOR_ACCENT_GOLD, 12, 0.5)
	StyleHelper.apply_panel_style($DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/MilestonesBox, StyleHelper.COLOR_ACCENT_PINK, 12, 0.5)
	StyleHelper.apply_panel_style($DetailModal/Panel/Margin/MainHBox/RightCol/DetailTabsScroll/ScrollVBox/WardrobeBox, StyleHelper.COLOR_ACCENT_CYAN, 12, 0.5)

	# Buttons
	StyleHelper.apply_button_style(btn_headpat, StyleHelper.COLOR_ACCENT_PINK, 12)
	StyleHelper.apply_button_style(btn_feed, StyleHelper.COLOR_ACCENT_GOLD, 12)
	StyleHelper.apply_button_style(btn_go_date, StyleHelper.COLOR_ACCENT_PURPLE, 12)
	StyleHelper.apply_button_style(btn_ascend, StyleHelper.COLOR_ACCENT_GOLD, 12)
	StyleHelper.apply_button_style(btn_close_detail, Color(0.3, 0.28, 0.4), 12)

	# Voice buttons
	_reset_voice_buttons_styling()

func _reset_voice_buttons_styling() -> void:
	for b in [btn_voice_greeting, btn_voice_headpat, btn_voice_feed, btn_voice_level, btn_voice_love]:
		StyleHelper.apply_button_style(b, Color(0.25, 0.22, 0.35), 8)

func _update_favorites_button_style() -> void:
	if only_favorites:
		StyleHelper.apply_button_style(btn_favorites_only, StyleHelper.COLOR_ACCENT_GOLD, 8)
	else:
		StyleHelper.apply_button_style(btn_favorites_only, Color(0.25, 0.22, 0.35), 8)

func _setup_sort_options() -> void:
	sort_option.clear()
	sort_option.add_item("💎 Редкость (UR ➔ R)", 0)
	sort_option.add_item("🏆 Уровень (Макс ➔ Мин)", 1)
	sort_option.add_item("❤️ Симпатия (Макс ➔ Мин)", 2)
	sort_option.add_item("⭐ Звёзды (5★ ➔ 1★)", 3)
	sort_option.add_item("🔤 По алфавиту (А ➔ Я)", 4)
	sort_option.add_item("🕒 Недавно полученные", 5)

func _setup_rarity_chips() -> void:
	for child in rarity_chips_box.get_children():
		rarity_chips_box.remove_child(child)
		child.queue_free()

	var rarities = ["ALL", "UR", "SSR", "SR", "R"]
	for r in rarities:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(75, 34)
		btn.text = "Все" if r == "ALL" else r
		if r == current_rarity_filter:
			StyleHelper.apply_button_style(btn, StyleHelper.COLOR_ACCENT_PINK, 8)
		else:
			StyleHelper.apply_button_style(btn, Color(0.25, 0.22, 0.35), 8)

		var r_val = r
		btn.pressed.connect(func():
			AudioManager.play_sfx_click()
			current_rarity_filter = r_val
			_setup_rarity_chips()
			render_roster()
		)
		rarity_chips_box.add_child(btn)

func _populate_franchises() -> void:
	franchise_option.clear()
	franchise_option.add_item("Все вселенные", 0)
	franchise_option.set_item_metadata(0, "ALL")

	var franchise_set = {}
	if GameSession.all_characters_catalog.size() > 0:
		for cid in GameSession.all_characters_catalog:
			var fr = GameSession.all_characters_catalog[cid].get("franchise", "")
			if fr != "":
				franchise_set[fr] = true
	else:
		for w in GameSession.user_waifus:
			var fr = w.get("template", {}).get("franchise", "")
			if fr != "":
				franchise_set[fr] = true

	var sorted_franchises = franchise_set.keys()
	sorted_franchises.sort()

	var idx = 1
	var selected_idx = 0
	for fr in sorted_franchises:
		franchise_option.add_item(fr, idx)
		franchise_option.set_item_metadata(idx, fr)
		if fr == current_franchise_filter:
			selected_idx = idx
		idx += 1

	if selected_idx == 0 and current_franchise_filter != "ALL":
		current_franchise_filter = "ALL"
	franchise_option.select(selected_idx)

func _update_header_stats() -> void:
	var waifus = GameSession.user_waifus
	var distinct_chars = {}
	var total_star_power = 0
	var fav_count = 0
	var total_dates = 0

	for w in waifus:
		var cid = w.get("character_id", "")
		distinct_chars[cid] = true
		total_star_power += int(w.get("stars", 1))
		total_dates += int(w.get("dates_completed", 0))
		if bool(w.get("is_favorite", false)):
			fav_count += 1

	var total_catalog = max(25, GameSession.all_characters_catalog.size())
	var collected = distinct_chars.size()
	var pct = int((float(collected) / float(total_catalog)) * 100.0) if total_catalog > 0 else 0

	progress_label.text = "Коллекция: " + str(collected) + " / " + str(total_catalog) + " (" + str(pct) + "%)"
	progress_bar.max_value = total_catalog
	progress_bar.value = collected
	star_power_label.text = "⭐ Сила звёзд: " + str(total_star_power)
	favorites_count_label.text = "💖 Избранных: " + str(fav_count)
	dates_count_label.text = "💌 Свиданий: " + str(total_dates)

func render_roster() -> void:
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()

	var waifus = GameSession.user_waifus.duplicate(true)

	if waifus.size() == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = "Ваша коллекция пока пуста. Откройте кейсы в разделе «🎰 Кейсы (Gacha)», чтобы получить вайфу!"
		empty_lbl.add_theme_font_size_override("font_size", 18)
		empty_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
		grid_container.add_child(empty_lbl)
		return

	# 1. Filter
	var filtered: Array = []
	for w in waifus:
		var template = w.get("template", {})
		var rarity = template.get("rarity", "R")
		var franchise = template.get("franchise", "")
		var char_name_str = template.get("name", "").to_lower()
		var title_str = template.get("title", "").to_lower()
		var is_fav = bool(w.get("is_favorite", false))

		if current_rarity_filter != "ALL" and rarity != current_rarity_filter:
			continue
		if current_franchise_filter != "ALL" and franchise != current_franchise_filter:
			continue
		if only_favorites and not is_fav:
			continue
		if current_search_query != "":
			if not (current_search_query in char_name_str or current_search_query in title_str or current_search_query in franchise.to_lower()):
				continue
		filtered.append(w)

	# 2. Sort
	var rarity_weights = {"UR": 4, "SSR": 3, "SR": 2, "R": 1, "N": 0}
	filtered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var t_a = a.get("template", {})
		var t_b = b.get("template", {})
		match current_sort_index:
			0: # Rarity (UR -> R)
				var r_a = rarity_weights.get(t_a.get("rarity", "R"), 0)
				var r_b = rarity_weights.get(t_b.get("rarity", "R"), 0)
				if r_a != r_b: return r_a > r_b
				return int(a.get("stars", 1)) > int(b.get("stars", 1))
			1: # Level (Highest to lowest)
				var l_a = int(a.get("affection_level", 1))
				var l_b = int(b.get("affection_level", 1))
				if l_a != l_b: return l_a > l_b
				return int(a.get("affection_points", 0)) > int(b.get("affection_points", 0))
			2: # Affection (Highest to lowest)
				return int(a.get("affection_points", 0)) > int(b.get("affection_points", 0))
			3: # Stars (5 -> 1)
				return int(a.get("stars", 1)) > int(b.get("stars", 1))
			4: # Alphabetical
				return t_a.get("name", "") < t_b.get("name", "")
			5: # Recent
				return int(a.get("id", 0)) > int(b.get("id", 0))
			_:
				return false
	)

	if filtered.size() == 0:
		var no_res_lbl = Label.new()
		no_res_lbl.text = "Героинь по заданным критериям фильтра не найдено."
		no_res_lbl.add_theme_font_size_override("font_size", 16)
		no_res_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
		grid_container.add_child(no_res_lbl)
		return

	# 3. Render Cards
	for w in filtered:
		var card = create_roster_card(w)
		grid_container.add_child(card)

func create_roster_card(waifu: Dictionary) -> Control:
	var template = waifu.get("template", {})
	var rarity = template.get("rarity", "R")
	var waifu_id = int(waifu.get("id", -1))
	var is_fav = bool(waifu.get("is_favorite", false))

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(215, 315)
	panel.add_theme_stylebox_override("panel", StyleHelper.create_card_frame(rarity, 14))
	panel.pivot_offset = Vector2(107, 157)

	# 1. Background click overlay placed behind margin
	var click_btn = Button.new()
	click_btn.flat = true
	click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_btn.mouse_filter = Control.MOUSE_FILTER_PASS
	click_btn.pressed.connect(func():
		AudioManager.play_sfx_click()
		open_detail_modal(waifu)
	)

	# Hover animation
	click_btn.mouse_entered.connect(func():
		var tw = create_tween()
		tw.tween_property(panel, "scale", Vector2(1.025, 1.025), 0.15).set_trans(Tween.TRANS_SINE)
	)
	click_btn.mouse_exited.connect(func():
		var tw = create_tween()
		tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
	)

	panel.add_child(click_btn)

	# 2. Content margin placed in front of click_btn with mouse_filter PASS
	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)

	# Image container
	var img_panel = PanelContainer.new()
	img_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	img_panel.custom_minimum_size = Vector2(0, 180)
	img_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inner_style = StyleBoxFlat.new()
	inner_style.set_corner_radius_all(10)
	inner_style.bg_color = Color(0.06, 0.05, 0.1, 0.85)
	img_panel.add_theme_stylebox_override("panel", inner_style)
	vbox.add_child(img_panel)

	var char_id = template.get("id", "")
	var current_outfit = waifu.get("current_outfit_id", "default")
	var tex = GameSession.get_character_texture(char_id, current_outfit)
	if tex:
		var img_rect = TextureRect.new()
		img_rect.texture = tex
		img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		img_rect.material = StyleHelper.get_holographic_material(rarity)
		img_panel.add_child(img_rect)
	else:
		var fallback_lbl = Label.new()
		fallback_lbl.text = "🌸\n" + template.get("name", "?")
		fallback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		fallback_lbl.add_theme_font_size_override("font_size", 14)
		fallback_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.7))
		img_panel.add_child(fallback_lbl)

	# Favorite Star Button on Card (stops mouse input, handles click directly)
	var fav_btn = Button.new()
	fav_btn.custom_minimum_size = Vector2(34, 34)
	fav_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	fav_btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	fav_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	fav_btn.z_index = 2
	fav_btn.text = "★" if is_fav else "☆"
	fav_btn.add_theme_font_size_override("font_size", 18)
	fav_btn.add_theme_color_override("font_color", Color(1, 0.85, 0.2) if is_fav else Color(0.7, 0.7, 0.8, 0.6))
	var fav_style = StyleBoxFlat.new()
	fav_style.bg_color = Color(0.05, 0.04, 0.08, 0.8)
	fav_style.set_corner_radius_all(6)
	fav_btn.add_theme_stylebox_override("normal", fav_style)
	fav_btn.pressed.connect(func():
		AudioManager.play_sfx_click()
		NetworkManager.toggle_favorite(waifu_id, func(success: bool, data: Variant):
			if success and data is Dictionary:
				var new_fav = bool(data.get("is_favorite", false))
				waifu["is_favorite"] = new_fav
				fav_btn.text = "★" if new_fav else "☆"
				fav_btn.add_theme_color_override("font_color", Color(1, 0.85, 0.2) if new_fav else Color(0.7, 0.7, 0.8, 0.6))
				_update_header_stats()
				GameSession.refresh_waifus()
		)
	)
	img_panel.add_child(fav_btn)

	# Name label
	var name_lbl = Label.new()
	name_lbl.text = template.get("name", "Героиня")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
	vbox.add_child(name_lbl)

	# Star glyphs
	var stars_lbl = Label.new()
	var stars = int(waifu.get("stars", 1))
	var star_str = ""
	for i in range(5):
		star_str += "★" if i < stars else "☆"
	stars_lbl.text = star_str
	stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	stars_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(stars_lbl)

	# Affection bar & text
	var aff_pts = int(waifu.get("affection_points", 0))
	var aff_lvl = int(waifu.get("affection_level", 1))
	var aff_lbl = Label.new()
	aff_lbl.text = "❤️ Ур. " + str(aff_lvl) + " (" + str(aff_pts) + " очков)"
	aff_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aff_lbl.add_theme_font_size_override("font_size", 11)
	aff_lbl.add_theme_color_override("font_color", Color(1, 0.5, 0.8))
	vbox.add_child(aff_lbl)

	# Mini stats chip
	var star_mult = 1.0 + (float(stars - 1) * 0.2)
	var base_stats = template.get("base_stats", {})
	var c_val = int(float(base_stats.get("charm", 80)) * star_mult)
	var e_val = int(float(base_stats.get("energy", 80)) * star_mult)
	var i_val = int(float(base_stats.get("intellect", 80)) * star_mult)

	var stats_lbl = Label.new()
	stats_lbl.text = "💖" + str(c_val) + " ⚡" + str(e_val) + " 🧠" + str(i_val)
	stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_lbl.add_theme_font_size_override("font_size", 11)
	stats_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	vbox.add_child(stats_lbl)

	return panel

func open_detail_modal(waifu: Dictionary, preserve_dialogue: bool = false) -> void:
	selected_waifu_data = waifu
	var template = waifu.get("template", {})
	var rarity = template.get("rarity", "R")
	var char_id = template.get("id", "")
	var current_outfit = waifu.get("current_outfit_id", "default")
	var is_fav = bool(waifu.get("is_favorite", false))

	char_name.text = template.get("name", "")
	char_name.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
	char_title_franchise.text = template.get("title", "") + " • " + template.get("franchise", "")
	rarity_badge.text = "★ " + rarity + " ★"
	rarity_badge.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
	bio_label.text = template.get("bio", "")

	# Big Portrait
	var portrait_tex = GameSession.get_character_texture(char_id, current_outfit)
	big_portrait.texture = portrait_tex
	big_portrait.material = StyleHelper.get_holographic_material(rarity) if portrait_tex else null

	# Favorite Button on Modal
	btn_card_favorite.text = "★" if is_fav else "☆"
	btn_card_favorite.add_theme_color_override("font_color", Color(1, 0.85, 0.2) if is_fav else Color(0.7, 0.7, 0.8, 0.6))

	# Stars
	var stars = int(waifu.get("stars", 1))
	var star_str = ""
	for i in range(5):
		star_str += "★" if i < stars else "☆"
	stars_label.text = star_str

	# Stats with star bonuses
	var base_stats = template.get("base_stats", {})

	var base_charm = int(base_stats.get("charm", 85))
	var charm_bonus = int(float(base_charm) * (float(stars - 1) * 0.2))
	var total_charm = base_charm + charm_bonus
	charm_bar.max_value = 200.0
	charm_bar.value = total_charm
	charm_value.text = str(total_charm) + " (+" + str(charm_bonus) + ")"

	var base_energy = int(base_stats.get("energy", 85))
	var energy_bonus = int(float(base_energy) * (float(stars - 1) * 0.2))
	var total_energy = base_energy + energy_bonus
	energy_bar.max_value = 200.0
	energy_bar.value = total_energy
	energy_value.text = str(total_energy) + " (+" + str(energy_bonus) + ")"

	var base_intellect = int(base_stats.get("intellect", 85))
	var intellect_bonus = int(float(base_intellect) * (float(stars - 1) * 0.2))
	var total_intellect = base_intellect + intellect_bonus
	intellect_bar.max_value = 200.0
	intellect_bar.value = total_intellect
	intellect_value.text = str(total_intellect) + " (+" + str(intellect_bonus) + ")"

	# Star Ascension Panel with LIVE STAT BOOST PREVIEW
	if stars >= 5:
		ascend_desc.text = "Достигнут максимальный ранг звёзд (5★)! Характеристики усилены на +80%."
		btn_ascend.text = "✓ Максимум (5★)"
		btn_ascend.disabled = true
	else:
		var next_star = stars + 1
		var cost = ASCENSION_COSTS.get(stars, 100)
		var next_mult = 1.0 + (float(next_star - 1) * 0.2)
		var n_c = int(float(base_charm) * next_mult)
		var n_e = int(float(base_energy) * next_mult)
		var n_i = int(float(base_intellect) * next_mult)
		var diff_c = n_c - total_charm
		var diff_e = n_e - total_energy
		var diff_i = n_i - total_intellect
		ascend_desc.text = "Предпросмотр ранга " + str(next_star) + "★ (+20% ко всем характеристикам):\n💖 " + str(total_charm) + " ➔ " + str(n_c) + " (+" + str(diff_c) + ")  ⚡ " + str(total_energy) + " ➔ " + str(n_e) + " (+" + str(diff_e) + ")  🧠 " + str(total_intellect) + " ➔ " + str(n_i) + " (+" + str(diff_i) + ")\nОсколков Души у вас: " + str(GameSession.soul_shards) + " 🔮"
		btn_ascend.text = "🌟 Возвысить до " + str(next_star) + "★ (" + str(cost) + " 🔮)"
		btn_ascend.disabled = (GameSession.soul_shards < cost)

	# Affection Progress calculation in modal
	var aff_pts = int(waifu.get("affection_points", 0))
	var aff_lvl = int(waifu.get("affection_level", 1))
	var rank_name = RANKS.get(aff_lvl, "Родственная душа")
	var aff_prog = _get_affection_progress(aff_pts, aff_lvl)
	affection_status_label.text = "❤️ Ранг отношений: " + rank_name + " (Ур. " + str(aff_lvl) + ")"
	if aff_lvl >= 10:
		affection_points_label.text = "Максимальный уровень симпатии! (" + str(aff_pts) + " очков)"
		affection_progress_bar.value = 100.0
	else:
		var n_lvl = aff_lvl + 1
		affection_points_label.text = str(aff_pts) + " / " + str(aff_prog["next_threshold"]) + " очков до Ур. " + str(n_lvl)
		affection_progress_bar.value = aff_prog["percentage"]

	# Greeting dialogue in balloon only if not preserving ongoing dialogue
	if not preserve_dialogue:
		var dialogues = template.get("dialogues", {})
		_show_speech_text(dialogues.get("greeting", "Привет!"))
		_reset_voice_buttons_styling()

	# Render Milestones & Outfits
	render_milestones(waifu)
	render_outfits(waifu, template)

	# Entrance Pop Tween for modal
	if not detail_modal.visible:
		modal_panel.scale = Vector2(0.9, 0.9)
		modal_panel.pivot_offset = (modal_panel.size if modal_panel.size.x > 0 else modal_panel.custom_minimum_size) * 0.5
		detail_modal.visible = true
		var tw = create_tween()
		tw.tween_property(modal_panel, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		detail_modal.visible = true

func render_milestones(waifu: Dictionary) -> void:
	for child in milestones_hbox.get_children():
		milestones_hbox.remove_child(child)
		child.queue_free()

	var cur_lvl = int(waifu.get("affection_level", 1))
	var claimed = waifu.get("claimed_milestones", [])
	var waifu_id = int(waifu.get("id", -1))

	for lvl in [2, 3, 4, 5]:
		var m_data = MILESTONE_REWARDS[lvl]
		var gems = m_data["gems"]
		var title = m_data["title"]
		var is_claimed = (lvl in claimed)
		var can_claim = (cur_lvl >= lvl and not is_claimed)

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(165, 80)
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(8)
		style.set_border_width_all(2)

		if is_claimed:
			style.bg_color = Color(0.1, 0.3, 0.18, 0.8)
			style.border_color = Color(0.3, 0.8, 0.4, 0.7)
		elif can_claim:
			style.bg_color = Color(0.3, 0.25, 0.1, 0.8)
			style.border_color = StyleHelper.COLOR_ACCENT_GOLD
		else:
			style.bg_color = Color(0.12, 0.1, 0.16, 0.6)
			style.border_color = Color(0.3, 0.28, 0.35, 0.5)

		card.add_theme_stylebox_override("panel", style)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_bottom", 6)
		card.add_child(margin)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		margin.add_child(vbox)

		var lvl_lbl = Label.new()
		lvl_lbl.text = "Ур. " + str(lvl) + ": " + title
		lvl_lbl.add_theme_font_size_override("font_size", 12)
		lvl_lbl.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_PINK if can_claim else Color.WHITE)
		vbox.add_child(lvl_lbl)

		var reward_lbl = Label.new()
		reward_lbl.text = "+" + str(gems) + " 💎"
		reward_lbl.add_theme_font_size_override("font_size", 11)
		reward_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1))
		vbox.add_child(reward_lbl)

		var btn_claim = Button.new()
		btn_claim.custom_minimum_size = Vector2(0, 26)
		btn_claim.add_theme_font_size_override("font_size", 11)

		if is_claimed:
			btn_claim.text = "✓ Получено"
			btn_claim.disabled = true
			StyleHelper.apply_button_style(btn_claim, Color(0.2, 0.45, 0.25), 6)
		elif can_claim:
			btn_claim.text = "Забрать 💎"
			StyleHelper.apply_button_style(btn_claim, StyleHelper.COLOR_ACCENT_GOLD, 6)
			var target_lvl = lvl
			btn_claim.pressed.connect(func():
				btn_claim.disabled = true
				_claim_milestone(waifu_id, target_lvl)
			)
		else:
			btn_claim.text = "🔒 Ур. " + str(lvl)
			btn_claim.disabled = true
			StyleHelper.apply_button_style(btn_claim, Color(0.2, 0.18, 0.25), 6)

		vbox.add_child(btn_claim)
		milestones_hbox.add_child(card)

func _claim_milestone(waifu_id: int, milestone_level: int) -> void:
	NetworkManager.claim_milestone(waifu_id, milestone_level, func(success: bool, data: Variant):
		if success and data is Dictionary:
			AudioManager.play_sfx_coins()
			var gems = data.get("gems_awarded", 50)
			GameSession.show_toast("Награда за уровень получена: +" + str(gems) + " Кристаллов! 💎", true)
			var new_gems = int(data.get("love_gems", GameSession.love_gems))
			GameSession.set_balances(GameSession.coins, new_gems, GameSession.soul_shards)
			selected_waifu_data["claimed_milestones"] = data.get("claimed_milestones", [])
			render_milestones(selected_waifu_data)
			GameSession.refresh_waifus()
		else:
			render_milestones(selected_waifu_data)
			var err = "Ошибка получения награды"
			if data is Dictionary and data.has("detail"):
				err = str(data["detail"])
			GameSession.show_toast(err, false)
	)

func render_outfits(waifu: Dictionary, template: Dictionary) -> void:
	for child in outfits_hbox.get_children():
		outfits_hbox.remove_child(child)
		child.queue_free()

	var unlocked = waifu.get("unlocked_outfits", ["default"])
	var current_outfit = waifu.get("current_outfit_id", "default")
	var all_outfits = template.get("outfits", [])
	var char_id = template.get("id", "")

	for out in all_outfits:
		var oid = out.get("id")
		var oname = out.get("name")
		var is_unlocked = oid in unlocked
		var is_equipped = oid == current_outfit

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(140, 42)
		btn.add_theme_font_size_override("font_size", 12)

		if is_equipped:
			btn.text = "✓ " + oname
			btn.disabled = true
			StyleHelper.apply_button_style(btn, Color(0.2, 0.6, 0.35), 8)
		elif is_unlocked:
			btn.text = "Надеть: " + oname
			StyleHelper.apply_button_style(btn, StyleHelper.COLOR_ACCENT_CYAN, 8)
			btn.pressed.connect(func(): _equip_outfit(oid))
		else:
			btn.text = "🔒 " + oname + " (50 🔮)"
			StyleHelper.apply_button_style(btn, StyleHelper.COLOR_ACCENT_PURPLE, 8)
			btn.pressed.connect(func(): _unlock_outfit(oid))

		# Live Portrait Preview on Hover
		var outfit_target_id = oid
		btn.mouse_entered.connect(func():
			var preview_tex = GameSession.get_character_texture(char_id, outfit_target_id)
			if preview_tex:
				big_portrait.texture = preview_tex
		)
		btn.mouse_exited.connect(func():
			var cur_out = selected_waifu_data.get("current_outfit_id", "default")
			var normal_tex = GameSession.get_character_texture(char_id, cur_out)
			if normal_tex:
				big_portrait.texture = normal_tex
		)

		outfits_hbox.add_child(btn)

func _equip_outfit(outfit_id: String) -> void:
	var waifu_id = int(selected_waifu_data.get("id", -1))
	NetworkManager.equip_outfit(waifu_id, outfit_id, func(success: bool, _data: Variant):
		if success:
			AudioManager.play_sfx_click()
			GameSession.show_toast("Наряд успешно надет!", true)
			selected_waifu_data["current_outfit_id"] = outfit_id
			open_detail_modal(selected_waifu_data, true)
			GameSession.refresh_waifus()
	)

func _unlock_outfit(outfit_id: String) -> void:
	if is_unlocking_outfit:
		return
	is_unlocking_outfit = true
	var waifu_id = int(selected_waifu_data.get("id", -1))
	NetworkManager.unlock_outfit(waifu_id, outfit_id, func(success: bool, data: Variant):
		is_unlocking_outfit = false
		if success and data is Dictionary:
			AudioManager.play_sfx_ssr()
			GameSession.show_toast("Новый облик разблокирован! 👗", true)
			var new_shards = int(data.get("soul_shards", GameSession.soul_shards))
			GameSession.set_balances(GameSession.coins, GameSession.love_gems, new_shards)
			selected_waifu_data["unlocked_outfits"] = data.get("unlocked_outfits", [])
			selected_waifu_data["current_outfit_id"] = outfit_id
			open_detail_modal(selected_waifu_data, true)
			GameSession.refresh_waifus()
		else:
			var err = "Недостаточно осколков души (требуется 50 🔮)"
			if data is Dictionary and data.has("detail"):
				err = str(data["detail"])
			GameSession.show_toast(err, false)
	)

func _on_ascend_clicked() -> void:
	if is_ascending:
		return
	is_ascending = true
	var waifu_id = int(selected_waifu_data.get("id", -1))
	btn_ascend.disabled = true
	NetworkManager.ascend_waifu(waifu_id, func(success: bool, data: Variant):
		is_ascending = false
		if success and data is Dictionary:
			AudioManager.play_sfx_ascend()
			var stars = data.get("stars", 2)
			GameSession.show_toast("Героиня возвышена до " + str(stars) + "★! Характеристики усилены! 🌟", true)
			var new_shards = int(data.get("soul_shards", GameSession.soul_shards))
			GameSession.set_balances(GameSession.coins, GameSession.love_gems, new_shards)
			selected_waifu_data["stars"] = stars
			open_detail_modal(selected_waifu_data, true)
			_play_voice_line("level_up", btn_voice_level)
			GameSession.refresh_waifus()
		else:
			btn_ascend.disabled = false
			var err = "Недостаточно осколков души для возвышения!"
			if data is Dictionary and data.has("detail"):
				err = str(data["detail"])
			GameSession.show_toast(err, false)
	)

func _on_toggle_modal_favorite() -> void:
	var waifu_id = int(selected_waifu_data.get("id", -1))
	AudioManager.play_sfx_click()
	NetworkManager.toggle_favorite(waifu_id, func(success: bool, data: Variant):
		if success and data is Dictionary:
			var new_fav = bool(data.get("is_favorite", false))
			selected_waifu_data["is_favorite"] = new_fav
			btn_card_favorite.text = "★" if new_fav else "☆"
			btn_card_favorite.add_theme_color_override("font_color", Color(1, 0.85, 0.2) if new_fav else Color(0.7, 0.7, 0.8, 0.6))
			_update_header_stats()
			GameSession.refresh_waifus()
	)

func _on_headpat_clicked() -> void:
	if is_headpatting:
		return
	is_headpatting = true
	btn_headpat.disabled = true
	var waifu_id = int(selected_waifu_data.get("id", -1))
	NetworkManager.headpat_waifu(waifu_id, func(success: bool, data: Variant):
		is_headpatting = false
		btn_headpat.disabled = false
		if success and data is Dictionary:
			AudioManager.play_sfx_heart()
			var reply = data.get("reply", "Спасибо за ласку!")
			_show_speech_text(reply)
			var gain = data.get("affection_gain", 15)
			GameSession.show_toast("+" + str(gain) + " очков симпатии! ❤️", true)
			GameSession.refresh_waifus()
		else:
			var err = "Слишком часто! Подождите немного перед следующей лаской."
			if data is Dictionary and data.has("detail"):
				err = str(data["detail"])
			GameSession.show_toast(err, false)
	)

func _on_feed_clicked() -> void:
	if is_feeding:
		return
	var waifu_id = int(selected_waifu_data.get("id", -1))
	var template = selected_waifu_data.get("template", {})
	var fav_foods = template.get("favorite_food", [])

	# Find available food in user_inventory, prioritizing favorite food
	var chosen_food = ""
	var is_fav = false

	for item in GameSession.user_inventory:
		var item_id = item.get("item_id", "")
		var item_type = item.get("item_type", "")
		var qty = int(item.get("quantity", 0))
		if (item_type == "food" or item_type == "gift") and qty > 0:
			if chosen_food == "":
				chosen_food = item_id
			if item_id in fav_foods:
				chosen_food = item_id
				is_fav = true
				break

	if chosen_food == "":
		AudioManager.play_sfx_click()
		GameSession.show_toast("У вас нет угощений! Купите еду в Магазине 🛍️", false)
		return

	is_feeding = true
	btn_feed.disabled = true
	NetworkManager.feed_waifu(waifu_id, chosen_food, func(success: bool, data: Variant):
		is_feeding = false
		btn_feed.disabled = false
		if success and data is Dictionary:
			AudioManager.play_sfx_heart()
			var reply = data.get("reply", "Очень вкусно!")
			_show_speech_text(reply)
			var gain = data.get("affection_gain", 20)
			var fav_flag = data.get("is_favorite", is_fav)
			var msg = ("Любимое блюдо x2! " if fav_flag else "") + "+" + str(gain) + " симпатии! 🍰"
			GameSession.show_toast(msg, true)
			GameSession.refresh_inventory()
			GameSession.refresh_waifus()
		else:
			var err = "Ошибка кормления"
			if data is Dictionary and data.has("detail"):
				err = str(data["detail"])
			GameSession.show_toast(err, false)
	)

func _on_go_date_clicked() -> void:
	AudioManager.play_sfx_click()
	var wid = int(selected_waifu_data.get("id", -1))
	GameSession.preselected_dating_waifu_id = wid
	detail_modal.visible = false
	GameSession.switch_to_view("dating")

func _play_voice_line(dialogue_key: String, clicked_btn: Button = null) -> void:
	AudioManager.play_synth_arpeggio([523.25, 659.25, 783.99, 1046.50], 0.07, 0.35, "bell")
	var template = selected_waifu_data.get("template", {})
	var dialogues = template.get("dialogues", {})
	var line = ""

	_reset_voice_buttons_styling()
	if clicked_btn:
		StyleHelper.apply_button_style(clicked_btn, StyleHelper.COLOR_ACCENT_GOLD, 8)

	match dialogue_key:
		"greeting":
			line = dialogues.get("greeting", "Привет! Рада видеть тебя!")
		"headpat":
			line = dialogues.get("headpat", "Ой... Твоя рука такая тёплая...")
		"feed":
			line = dialogues.get("feed", "М-м-м, как вкусно! Спасибо за заботу!")
		"level_up":
			line = dialogues.get("level_up", "Мои силы растут благодаря твоей вере во меня!")
		"confession":
			var cur_lvl = int(selected_waifu_data.get("affection_level", 1))
			if cur_lvl >= 4:
				line = dialogues.get("confession", "Ты — самое драгоценное сокровище в моем сердце. Я навсегда останусь рядом с тобой! 💖")
			else:
				line = "Наши чувства только начинают расцветать... Давай сходим на свидание и узнаем друг друга лучше!"
		_:
			line = "«...»"

	_show_speech_text(line)

func _show_speech_text(text: String) -> void:
	if balloon_tween and balloon_tween.is_valid():
		balloon_tween.kill()
	dialogue_balloon.text = "«" + text + "»"
	dialogue_balloon.visible_ratio = 0.0
	balloon_tween = create_tween()
	var dur = max(0.3, float(text.length()) * 0.02)
	balloon_tween.tween_property(dialogue_balloon, "visible_ratio", 1.0, dur)

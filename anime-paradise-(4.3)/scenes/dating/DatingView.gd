extends Control

# Selection Phase UI
@onready var select_panel: Control = $SelectPanel
@onready var bg_select: TextureRect = $SelectPanel/Background
@onready var dates_count_badge: Label = $SelectPanel/MainMargin/MainVBox/TopHeader/StatsBox/DatesCountBadge
@onready var btn_open_gallery: Button = $SelectPanel/MainMargin/MainVBox/TopHeader/StatsBox/BtnOpenGallery
@onready var loc_scroll: ScrollContainer = $SelectPanel/MainMargin/MainVBox/ContentSplit/LocationsSection/LocScroll
@onready var locations_vbox: VBoxContainer = $SelectPanel/MainMargin/MainVBox/ContentSplit/LocationsSection/LocScroll/LocationsVBox
@onready var waifus_hbox: HBoxContainer = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/WaifuScroll/WaifusHBox
@onready var selected_preview_panel: PanelContainer = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel
@onready var preview_portrait: TextureRect = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/PortraitBox/BigPortrait
@onready var preview_name: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/CompanionName
@onready var preview_title: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/CompanionTitle
@onready var preview_rank_badge: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/RankHBox/RankBadge
@onready var preview_affection_pts: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/RankHBox/AffectionPoints
@onready var preview_affection_bar: ProgressBar = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/AffectionProgressBar
@onready var preview_stat_charm: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/StatsGrid/StatCharm
@onready var preview_stat_energy: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/StatsGrid/StatEnergy
@onready var preview_stat_intellect: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/StatsGrid/StatIntellect
@onready var preview_quote: Label = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/QuoteBubble
@onready var btn_preview_voice: Button = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/ActionsHBox/BtnPreviewVoice
@onready var btn_gift: Button = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/InfoVBox/ActionsHBox/BtnGift
@onready var btn_start_date: Button = $SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/BtnStartDate

# VN Interface UI
@onready var vn_panel: Control = $VNPanel
@onready var vn_background: TextureRect = $VNPanel/Background
@onready var ambient_particles: CPUParticles2D = $VNPanel/AmbientParticles
@onready var vn_top_bar: PanelContainer = $VNPanel/VNTopBar
@onready var loc_title_label: Label = $VNPanel/VNTopBar/Margin/HBox/LocTitleLabel
@onready var waifu_rank_label: Label = $VNPanel/VNTopBar/Margin/HBox/WaifuRankLabel
@onready var btn_backlog: Button = $VNPanel/VNTopBar/Margin/HBox/BtnBacklog
@onready var btn_auto: Button = $VNPanel/VNTopBar/Margin/HBox/BtnAuto
@onready var btn_skip: Button = $VNPanel/VNTopBar/Margin/HBox/BtnSkip
@onready var btn_speed: Button = $VNPanel/VNTopBar/Margin/HBox/BtnSpeed
@onready var btn_exit_vn: Button = $VNPanel/VNTopBar/Margin/HBox/BtnExitVN

@onready var char_portrait: TextureRect = $VNPanel/CharPortrait
@onready var char_icon: Label = $VNPanel/CharPortrait/CharIcon
@onready var emotion_badge: Label = $VNPanel/CharPortrait/EmotionBadge

@onready var dialog_box: PanelContainer = $VNPanel/DialogArea/DialogBox
@onready var speaker_plate: PanelContainer = $VNPanel/DialogArea/DialogBox/SpeakerPlate
@onready var speaker_label: Label = $VNPanel/DialogArea/DialogBox/SpeakerPlate/PlateMargin/SpeakerLabel
@onready var narrative_label: Label = $VNPanel/DialogArea/DialogBox/Margin/VBox/NarrativeLabel
@onready var dialog_text: Label = $VNPanel/DialogArea/DialogBox/Margin/VBox/DialogText
@onready var prompt_indicator: Label = $VNPanel/DialogArea/DialogBox/PromptIndicator
@onready var choices_container: VBoxContainer = $VNPanel/DialogArea/ChoicesContainer

# Backlog Modal
@onready var backlog_modal: Control = $BacklogModal
@onready var backlog_list: VBoxContainer = $BacklogModal/Panel/Margin/VBox/Scroll/BacklogList
@onready var btn_close_backlog: Button = $BacklogModal/Panel/Margin/VBox/BtnCloseBacklog

# CG Gallery Modal
@onready var cg_gallery_modal: Control = $CGGalleryModal
@onready var gallery_grid: HFlowContainer = $CGGalleryModal/Panel/Margin/VBox/Scroll/GalleryGrid
@onready var btn_close_gallery: Button = $CGGalleryModal/Panel/Margin/VBox/BtnCloseGallery

# Date Conclusion Modal
@onready var conclusion_modal: Control = $ConclusionModal
@onready var conclusion_title: Label = $ConclusionModal/Panel/Margin/VBox/Title
@onready var conclusion_cg_container: VBoxContainer = $ConclusionModal/Panel/Margin/VBox/CGContainer
@onready var conclusion_cg_image: TextureRect = $ConclusionModal/Panel/Margin/VBox/CGContainer/CGImage
@onready var conclusion_cg_badge: Label = $ConclusionModal/Panel/Margin/VBox/CGContainer/CGUnlockBadge
@onready var rank_progress_label: Label = $ConclusionModal/Panel/Margin/VBox/RankPanel/Margin/VBox/RankProgressLabel
@onready var level_up_badge: Label = $ConclusionModal/Panel/Margin/VBox/RankPanel/Margin/VBox/LevelUpBadge
@onready var conclusion_affection_bar: ProgressBar = $ConclusionModal/Panel/Margin/VBox/RankPanel/Margin/VBox/ConclusionAffectionBar
@onready var affection_gain_label: Label = $ConclusionModal/Panel/Margin/VBox/RankPanel/Margin/VBox/AffectionGainLabel
@onready var rewards_label: Label = $ConclusionModal/Panel/Margin/VBox/RankPanel/Margin/VBox/RewardsLabel
@onready var btn_close_conclusion: Button = $ConclusionModal/Panel/Margin/VBox/BtnCloseConclusion

# Fullscreen CG Viewer
@onready var fullscreen_cg_modal: Control = $FullscreenCGModal
@onready var full_cg_image: TextureRect = $FullscreenCGModal/FullCGImage
@onready var full_cg_title: Label = $FullscreenCGModal/TitleBadge

var selected_location_id: String = "sakura_park"
var selected_waifu_id: int = -1
var current_node_id: String = ""
var locations_data: Array = []

var typewriter_tween: Tween = null
var breathing_tween: Tween = null
var prompt_tween: Tween = null
var auto_advance_timer: SceneTreeTimer = null
var affection_bar_tween: Tween = null

var is_auto_playing: bool = false
var is_skipping: bool = false
var is_finishing_date: bool = false
var is_starting_date: bool = false
var is_submitting_choice: bool = false
var text_speed_mode: int = 0 # 0: 1x (0.02s/char), 1: 2x (0.007s/char), 2: Instant
var dialogue_backlog: Array = []
var _typewriter_audio_step: int = 0

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
	vn_panel.visible = false
	backlog_modal.visible = false
	cg_gallery_modal.visible = false
	conclusion_modal.visible = false
	fullscreen_cg_modal.visible = false
	select_panel.visible = true

	# Styling
	_apply_visual_styling()

	# Start breathing idle animation on portrait
	_init_portrait_breathing()

	# Start blinking prompt indicator animation
	_init_prompt_animation()

	# Button signals
	btn_start_date.pressed.connect(_on_start_date)
	btn_preview_voice.pressed.connect(_on_preview_voice)
	btn_gift.pressed.connect(_open_gift_modal)
	btn_open_gallery.pressed.connect(_open_cg_gallery)
	btn_close_gallery.pressed.connect(func():
		AudioManager.play_sfx_click()
		cg_gallery_modal.visible = false
	)
	btn_backlog.pressed.connect(_open_backlog)
	btn_close_backlog.pressed.connect(func():
		AudioManager.play_sfx_click()
		backlog_modal.visible = false
	)
	btn_auto.pressed.connect(_toggle_auto_play)
	btn_skip.pressed.connect(_toggle_skip)
	btn_speed.pressed.connect(_toggle_text_speed)
	btn_exit_vn.pressed.connect(_on_exit_vn)

	btn_close_conclusion.pressed.connect(func():
		AudioManager.play_sfx_click()
		is_finishing_date = false
		conclusion_modal.visible = false
		vn_panel.visible = false
		select_panel.visible = true
		GameSession.refresh_all_data()
		_update_header_stats()
	)

	# Click conclusion CG image to view fullscreen
	conclusion_cg_image.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			var cg_tex = conclusion_cg_image.texture
			if cg_tex:
				AudioManager.play_sfx_click()
				_open_fullscreen_cg(cg_tex, "Романтическое воспоминание: " + _get_location_name(selected_location_id))
	)

	# Fullscreen CG click to dismiss
	fullscreen_cg_modal.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			AudioManager.play_sfx_click()
			fullscreen_cg_modal.visible = false
	)
	$FullscreenCGModal/Dimmer.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			AudioManager.play_sfx_click()
			fullscreen_cg_modal.visible = false
	)

	# Click dimmers outside to close modals
	$BacklogModal/Dimmer.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			AudioManager.play_sfx_click()
			backlog_modal.visible = false
	)
	$CGGalleryModal/Dimmer.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			AudioManager.play_sfx_click()
			cg_gallery_modal.visible = false
	)

	# Click on dialog box or VN backdrop finishes typing immediately
	var finish_typing_fn = func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			if typewriter_tween and typewriter_tween.is_running():
				typewriter_tween.kill()
				dialog_text.visible_ratio = 1.0
				prompt_indicator.visible = true
	dialog_box.gui_input.connect(finish_typing_fn)
	$VNPanel/Dimmer.gui_input.connect(finish_typing_fn)

	GameSession.waifus_updated.connect(func(_w):
		load_waifus()
		load_locations()
		_update_header_stats()
	)

	# Check if preselected waifu exists
	if GameSession.preselected_dating_waifu_id != -1:
		selected_waifu_id = GameSession.preselected_dating_waifu_id
		GameSession.preselected_dating_waifu_id = -1

	# Set ambient background for select panel
	var bg_park = GameSession.get_background_texture("bg_sakura_park")
	if bg_park:
		bg_select.texture = bg_park

	load_locations()
	load_waifus()
	_update_header_stats()

func _apply_visual_styling() -> void:
	StyleHelper.apply_panel_style(selected_preview_panel, StyleHelper.COLOR_ACCENT_PINK, 16, 0.94)
	StyleHelper.apply_panel_style($SelectPanel/MainMargin/MainVBox/ContentSplit/CompanionSection/SelectedPreviewPanel/Margin/HBox/PortraitBox, StyleHelper.COLOR_ACCENT_PURPLE, 12, 0.5)
	StyleHelper.apply_button_style(btn_start_date, StyleHelper.COLOR_ACCENT_PINK, 14)
	StyleHelper.apply_button_style(btn_preview_voice, StyleHelper.COLOR_ACCENT_PURPLE, 8)
	StyleHelper.apply_button_style(btn_gift, StyleHelper.COLOR_ACCENT_GOLD, 8)
	StyleHelper.apply_button_style(btn_open_gallery, StyleHelper.COLOR_ACCENT_GOLD, 10)

	# VN Top Bar & Dialog Box
	StyleHelper.apply_panel_style(vn_top_bar, StyleHelper.COLOR_PANEL_BORDER, 0, 0.94)
	StyleHelper.apply_button_style(btn_backlog, Color(0.25, 0.22, 0.35), 8)
	StyleHelper.apply_button_style(btn_auto, Color(0.25, 0.22, 0.35), 8)
	StyleHelper.apply_button_style(btn_skip, Color(0.25, 0.22, 0.35), 8)
	StyleHelper.apply_button_style(btn_speed, Color(0.25, 0.22, 0.35), 8)
	StyleHelper.apply_button_style(btn_exit_vn, Color(0.5, 0.2, 0.25), 8)

	StyleHelper.apply_panel_style(dialog_box, StyleHelper.COLOR_ACCENT_PURPLE, 18, 0.96)
	StyleHelper.apply_panel_style(speaker_plate, StyleHelper.COLOR_ACCENT_PINK, 10, 0.98)

	# Modals
	StyleHelper.apply_panel_style($BacklogModal/Panel, StyleHelper.COLOR_PANEL_BORDER, 16, 0.96)
	StyleHelper.apply_button_style(btn_close_backlog, StyleHelper.COLOR_ACCENT_PURPLE, 10)
	StyleHelper.apply_panel_style($CGGalleryModal/Panel, StyleHelper.COLOR_ACCENT_GOLD, 18, 0.96)
	StyleHelper.apply_button_style(btn_close_gallery, StyleHelper.COLOR_ACCENT_GOLD, 12)
	StyleHelper.apply_panel_style($ConclusionModal/Panel, StyleHelper.COLOR_ACCENT_GOLD, 18, 0.96)
	StyleHelper.apply_panel_style($ConclusionModal/Panel/Margin/VBox/RankPanel, StyleHelper.COLOR_ACCENT_PINK, 14, 0.5)
	StyleHelper.apply_button_style(btn_close_conclusion, StyleHelper.COLOR_ACCENT_PINK, 14)

	# Pulse tween on Start Date Button
	var pulse = create_tween().set_loops()
	pulse.tween_property(btn_start_date, "scale", Vector2(1.02, 1.02), 0.9).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(btn_start_date, "scale", Vector2(1.0, 1.0), 0.9).set_trans(Tween.TRANS_SINE)

func _init_portrait_breathing() -> void:
	if breathing_tween and breathing_tween.is_valid():
		breathing_tween.kill()
	char_portrait.pivot_offset = Vector2(char_portrait.custom_minimum_size.x * 0.5, char_portrait.custom_minimum_size.y)
	breathing_tween = create_tween().set_loops()
	breathing_tween.tween_property(char_portrait, "scale", Vector2(1.0, 1.018), 2.2).set_trans(Tween.TRANS_SINE)
	breathing_tween.tween_property(char_portrait, "scale", Vector2(1.0, 1.0), 2.2).set_trans(Tween.TRANS_SINE)

func _init_prompt_animation() -> void:
	if prompt_tween and prompt_tween.is_valid():
		prompt_tween.kill()
	prompt_tween = create_tween().set_loops()
	prompt_tween.tween_property(prompt_indicator, "modulate:a", 0.2, 0.5)
	prompt_tween.tween_property(prompt_indicator, "modulate:a", 1.0, 0.5)

func _update_header_stats() -> void:
	var waifus = GameSession.user_waifus
	var total_dates = 0
	var unlocked_cgs = {}

	for w in waifus:
		total_dates += int(w.get("dates_completed", 0))
		for cg in w.get("cgs_unlocked", []):
			unlocked_cgs[cg] = true

	dates_count_badge.text = "💖 Проведено свиданий: " + str(total_dates) + " | 🖼️ Открыто CG: " + str(unlocked_cgs.size())

func load_locations(force_fetch: bool = false) -> void:
	if not force_fetch and locations_data.size() > 0:
		_render_location_cards()
		return

	NetworkManager.get_dating_locations(func(success: bool, data: Variant):
		if success and data is Array:
			locations_data = data
			_render_location_cards()
	)

func _render_location_cards() -> void:
	var saved_scroll = loc_scroll.scroll_vertical
	for child in locations_vbox.get_children():
		locations_vbox.remove_child(child)
		child.queue_free()

	for loc in locations_data:
		var card = _create_location_card(loc)
		locations_vbox.add_child(card)

	await get_tree().process_frame
	loc_scroll.scroll_vertical = saved_scroll

func _create_location_card(loc: Dictionary) -> Control:
	var lid = loc.get("id", "sakura_park")
	var is_selected = (lid == selected_location_id)
	var req_lvl = int(loc.get("min_affection_level", 1))

	var current_waifu = GameSession.get_waifu_by_id(selected_waifu_id)
	var waifu_lvl = int(current_waifu.get("affection_level", 1))
	var is_locked = (waifu_lvl < req_lvl)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 120)

	var border_col = StyleHelper.COLOR_ACCENT_PINK if is_selected else (Color(0.35, 0.32, 0.45) if not is_locked else Color(0.2, 0.18, 0.25))
	StyleHelper.apply_panel_style(panel, border_col, 14, 0.92 if not is_locked else 0.55)

	# Click overlay button placed behind margin with PASS filter
	var click_btn = Button.new()
	click_btn.flat = true
	click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_btn.mouse_filter = Control.MOUSE_FILTER_PASS
	click_btn.pressed.connect(func():
		AudioManager.play_sfx_click()
		if is_locked:
			GameSession.show_toast("Локация заблокирована! Требуется Ур. симпатии " + str(req_lvl), false)
			return
		selected_location_id = lid
		_render_location_cards()
		var preview_bg = GameSession.get_background_texture("bg_" + lid)
		if preview_bg:
			var tw = create_tween()
			tw.tween_property(bg_select, "modulate:a", 0.6, 0.15)
			tw.tween_callback(func(): bg_select.texture = preview_bg)
			tw.tween_property(bg_select, "modulate:a", 1.0, 0.2)
		GameSession.show_toast("Выбрана локация: " + loc.get("name", ""), true)
	)
	panel.add_child(click_btn)

	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)

	# Location thumbnail
	var thumb_box = PanelContainer.new()
	thumb_box.mouse_filter = Control.MOUSE_FILTER_PASS
	thumb_box.custom_minimum_size = Vector2(136, 100)
	var thumb_tex = GameSession.get_background_texture("bg_" + lid)
	if thumb_tex:
		var thumb_rect = TextureRect.new()
		thumb_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb_rect.texture = thumb_tex
		thumb_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		thumb_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		thumb_box.add_child(thumb_rect)
	hbox.add_child(thumb_box)

	# Info column
	var info_vbox = VBoxContainer.new()
	info_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var top_row = HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_PASS
	info_vbox.add_child(top_row)

	var title_lbl = Label.new()
	title_lbl.text = loc.get("name", "")
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD if is_selected else Color.WHITE)
	top_row.add_child(title_lbl)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer)

	var duration_lbl = Label.new()
	duration_lbl.text = "⏱️ " + loc.get("duration", "15 мин")
	duration_lbl.add_theme_font_size_override("font_size", 12)
	duration_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	top_row.add_child(duration_lbl)

	var vibe_lbl = Label.new()
	vibe_lbl.text = "✨ " + loc.get("vibe", "")
	vibe_lbl.add_theme_font_size_override("font_size", 13)
	vibe_lbl.add_theme_color_override("font_color", Color(0.95, 0.5, 0.8))
	info_vbox.add_child(vibe_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = loc.get("description", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	info_vbox.add_child(desc_lbl)

	var status_row = HBoxContainer.new()
	status_row.mouse_filter = Control.MOUSE_FILTER_PASS
	info_vbox.add_child(status_row)

	var lock_lbl = Label.new()
	if is_locked:
		lock_lbl.text = "🔒 Требуется уровень симпатии: " + str(req_lvl)
		lock_lbl.add_theme_color_override("font_color", Color(1, 0.35, 0.35))
	else:
		lock_lbl.text = "🔓 Доступно (" + loc.get("bonus_desc", "+25% Любви") + ")"
		lock_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
	lock_lbl.add_theme_font_size_override("font_size", 11)
	status_row.add_child(lock_lbl)

	var status_spacer = Control.new()
	status_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_child(status_spacer)

	# Dedicated CG Gallery preview button on the card
	var btn_cg = Button.new()
	btn_cg.custom_minimum_size = Vector2(110, 26)
	btn_cg.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_cg.text = "🖼️ Превью CG"
	btn_cg.add_theme_font_size_override("font_size", 11)
	StyleHelper.apply_button_style(btn_cg, StyleHelper.COLOR_ACCENT_GOLD, 6)
	btn_cg.pressed.connect(func():
		AudioManager.play_sfx_click()
		var cg_tex = GameSession.get_background_texture("cg_" + lid)
		if cg_tex and not is_locked:
			_open_fullscreen_cg(cg_tex, "Превью воспоминания: " + loc.get("name", ""))
		else:
			_open_cg_gallery()
	)
	status_row.add_child(btn_cg)

	return panel

func load_waifus() -> void:
	for child in waifus_hbox.get_children():
		waifus_hbox.remove_child(child)
		child.queue_free()

	var waifus = GameSession.user_waifus
	if waifus.size() == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = "Сначала откройте хотя бы одну героиню в кейсах!"
		empty_lbl.add_theme_font_size_override("font_size", 16)
		empty_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
		waifus_hbox.add_child(empty_lbl)
		selected_preview_panel.visible = false
		btn_start_date.disabled = true
		return

	if selected_waifu_id == -1 and waifus.size() > 0:
		selected_waifu_id = int(waifus[0].get("id", -1))

	for w in waifus:
		var wid = int(w.get("id", -1))
		var template = w.get("template", {})
		var char_id = template.get("id", "")
		var rarity = template.get("rarity", "R")
		var is_selected = (wid == selected_waifu_id)

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(130, 150)
		card.add_theme_stylebox_override("panel", StyleHelper.create_card_frame(rarity if not is_selected else "UR", 10))

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 6)
		margin.add_theme_constant_override("margin_right", 6)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_bottom", 6)
		card.add_child(margin)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		margin.add_child(vbox)

		var thumb = TextureRect.new()
		thumb.custom_minimum_size = Vector2(0, 95)
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var current_outfit = w.get("current_outfit_id", "default")
		var tex = GameSession.get_character_texture(char_id, current_outfit)
		if tex:
			thumb.texture = tex
		vbox.add_child(thumb)

		var name_lbl = Label.new()
		name_lbl.text = template.get("name", "")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD if is_selected else Color.WHITE)
		vbox.add_child(name_lbl)

		var lvl_lbl = Label.new()
		lvl_lbl.text = "❤️ Ур. " + str(w.get("affection_level", 1))
		lvl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_lbl.add_theme_font_size_override("font_size", 11)
		lvl_lbl.add_theme_color_override("font_color", Color(1, 0.5, 0.8))
		vbox.add_child(lvl_lbl)

		var click_btn = Button.new()
		click_btn.flat = true
		click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		click_btn.pressed.connect(func():
			AudioManager.play_sfx_click()
			selected_waifu_id = wid
			load_waifus()
			_render_location_cards()
			_update_selected_waifu_preview()
		)
		card.add_child(click_btn)

		waifus_hbox.add_child(card)

	_update_selected_waifu_preview()

func _update_selected_waifu_preview() -> void:
	var waifu = GameSession.get_waifu_by_id(selected_waifu_id)
	if waifu.is_empty():
		selected_preview_panel.visible = false
		btn_start_date.disabled = true
		return

	selected_preview_panel.visible = true
	btn_start_date.disabled = false

	var template = waifu.get("template", {})
	var char_id = template.get("id", "")
	var current_outfit = waifu.get("current_outfit_id", "default")
	var rarity = template.get("rarity", "R")

	preview_name.text = template.get("name", "Героиня")
	preview_name.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
	preview_title.text = template.get("title", "") + " • " + template.get("franchise", "")

	var tex = GameSession.get_character_texture(char_id, current_outfit)
	preview_portrait.texture = tex
	preview_portrait.material = StyleHelper.get_holographic_material(rarity) if tex else null

	var aff_pts = int(waifu.get("affection_points", 0))
	var aff_lvl = int(waifu.get("affection_level", 1))
	var rank_name = RANKS.get(aff_lvl, "Абсолютное единство")
	var prog = _get_affection_progress(aff_pts, aff_lvl)

	preview_rank_badge.text = "Ранг отношений: " + rank_name
	if aff_lvl >= 10:
		preview_affection_pts.text = "(Ур. 10 • МАКСИМАЛЬНЫЙ РАНГ • " + str(aff_pts) + " очков)"
		preview_affection_bar.value = 100.0
	else:
		preview_affection_pts.text = "(Ур. " + str(aff_lvl) + " • " + str(prog.points_in_level) + "/" + str(prog.points_required) + " очков)"
		preview_affection_bar.value = prog.percentage

	# Calculate stats with star multiplier
	var stars = int(waifu.get("stars", 1))
	var star_mult = 1.0 + (float(stars - 1) * 0.2)
	var base_stats = template.get("base_stats", {})
	var charm = int(float(base_stats.get("charm", 80)) * star_mult)
	var energy = int(float(base_stats.get("energy", 80)) * star_mult)
	var intellect = int(float(base_stats.get("intellect", 80)) * star_mult)

	preview_stat_charm.text = "💖 Очарование: " + str(charm)
	preview_stat_energy.text = "⚡ Энергия: " + str(energy)
	preview_stat_intellect.text = "🧠 Интеллект: " + str(intellect)

	var dialogues = template.get("dialogues", {})
	preview_quote.text = "«" + dialogues.get("greeting", "Я так рада провести этот день с тобой!") + "»"

func _on_preview_voice() -> void:
	var waifu = GameSession.get_waifu_by_id(selected_waifu_id)
	if waifu.is_empty():
		return
	AudioManager.play_synth_arpeggio([523.25, 659.25, 783.99, 1046.50], 0.07, 0.35, "bell")
	var template = waifu.get("template", {})
	var dialogues = template.get("dialogues", {})
	var quote = dialogues.get("greeting", "Привет!")
	preview_quote.text = "«" + quote + "»"

	# Speech bubble bounce
	var tw = create_tween()
	preview_quote.modulate = Color(1.0, 0.5, 0.8)
	tw.tween_property(preview_quote, "modulate", Color(0.9, 0.9, 0.7), 0.5)

func _on_start_date() -> void:
	if is_starting_date:
		return
	if selected_waifu_id == -1:
		GameSession.show_toast("Выберите спутницу для свидания", false)
		return

	var current_waifu = GameSession.get_waifu_by_id(selected_waifu_id)
	if current_waifu.is_empty():
		GameSession.show_toast("Спутница не найдена", false)
		return
	var waifu_lvl = int(current_waifu.get("affection_level", 1))

	# Check unlock level for location
	for loc in locations_data:
		if loc.get("id") == selected_location_id:
			var req = int(loc.get("min_affection_level", 1))
			if waifu_lvl < req:
				GameSession.show_toast("Уровень симпатии слишком мал для этой локации!", false)
				return

	var bg_tex = GameSession.get_background_texture("bg_" + selected_location_id)
	if not bg_tex:
		bg_tex = GameSession.get_background_texture("bg_sakura_park")
	if bg_tex:
		vn_background.texture = bg_tex

	# Apply dynamic particle ambiance & audio motif
	_apply_location_ambiance(selected_location_id)

	# Reset visual novel state
	dialogue_backlog.clear()
	is_auto_playing = false
	is_skipping = false
	btn_auto.text = "▶️ Авто"
	btn_skip.text = "⏩ Пропуск"

	is_starting_date = true
	btn_start_date.disabled = true
	AudioManager.play_sfx_click()
	NetworkManager.start_date(selected_waifu_id, selected_location_id, func(success: bool, data: Variant):
		is_starting_date = false
		btn_start_date.disabled = false
		if success and data is Dictionary:
			select_panel.visible = false
			vn_panel.visible = true
			render_dialogue_node(data)
		else:
			var err = "Ошибка запуска свидания"
			if data is Dictionary and data.has("detail"):
				err = str(data["detail"])
			GameSession.show_toast(err, false)
	)

func _apply_location_ambiance(location_id: String) -> void:
	match location_id:
		"sakura_park":
			ambient_particles.color = Color(1.0, 0.75, 0.85, 0.55)
			ambient_particles.direction = Vector2(-0.4, 1.0)
			ambient_particles.gravity = Vector2(0, 15)
			ambient_particles.initial_velocity_min = 20.0
			ambient_particles.initial_velocity_max = 50.0
			ambient_particles.angular_velocity_min = -30.0
			ambient_particles.angular_velocity_max = 30.0
			ambient_particles.scale_amount_min = 4.0
			ambient_particles.scale_amount_max = 8.0
			ambient_particles.amount = 26
			AudioManager.play_synth_arpeggio([523.25, 659.25, 783.99, 1046.50], 0.08, 0.3, "soft")
		"cozy_cafe":
			ambient_particles.color = Color(1.0, 0.88, 0.65, 0.5)
			ambient_particles.direction = Vector2(0.1, -1.0)
			ambient_particles.gravity = Vector2(0, -12)
			ambient_particles.initial_velocity_min = 15.0
			ambient_particles.initial_velocity_max = 35.0
			ambient_particles.angular_velocity_min = -15.0
			ambient_particles.angular_velocity_max = 15.0
			ambient_particles.scale_amount_min = 3.0
			ambient_particles.scale_amount_max = 6.0
			ambient_particles.amount = 18
			AudioManager.play_synth_arpeggio([440.0, 554.37, 659.25, 830.61], 0.09, 0.3, "bell")
		"night_festival":
			ambient_particles.color = Color(0.95, 0.55, 0.9, 0.55)
			ambient_particles.direction = Vector2(0.3, -0.7)
			ambient_particles.gravity = Vector2(0, -5)
			ambient_particles.initial_velocity_min = 25.0
			ambient_particles.initial_velocity_max = 60.0
			ambient_particles.angular_velocity_min = -40.0
			ambient_particles.angular_velocity_max = 40.0
			ambient_particles.scale_amount_min = 4.0
			ambient_particles.scale_amount_max = 9.0
			ambient_particles.amount = 30
			AudioManager.play_synth_arpeggio([659.25, 880.0, 1108.73, 1318.51], 0.07, 0.35, "bell")
		"library":
			ambient_particles.color = Color(0.7, 0.88, 1.0, 0.45)
			ambient_particles.direction = Vector2(0.2, 0.2)
			ambient_particles.gravity = Vector2(0, 3)
			ambient_particles.initial_velocity_min = 5.0
			ambient_particles.initial_velocity_max = 18.0
			ambient_particles.angular_velocity_min = -10.0
			ambient_particles.angular_velocity_max = 10.0
			ambient_particles.scale_amount_min = 3.0
			ambient_particles.scale_amount_max = 6.0
			ambient_particles.amount = 16
			AudioManager.play_synth_arpeggio([392.0, 587.33, 783.99], 0.10, 0.25, "soft")
		_:
			ambient_particles.color = Color(1.0, 0.8, 0.85, 0.45)
			ambient_particles.gravity = Vector2(0, 12)
	ambient_particles.restart()

func render_dialogue_node(data: Dictionary) -> void:
	current_node_id = data.get("node_id", "")
	var waifu = GameSession.get_waifu_by_id(selected_waifu_id)
	var template = waifu.get("template", {})
	var char_id = template.get("id", "")
	var current_outfit = waifu.get("current_outfit_id", "default")
	var aff_lvl = int(data.get("affection_level", waifu.get("affection_level", 1)))
	var rank_name = data.get("rank_title", RANKS.get(aff_lvl, "Возлюбленная"))

	var loc_id = data.get("location_id", selected_location_id)
	loc_title_label.text = "📍 " + _get_location_name(loc_id)
	waifu_rank_label.text = "💖 " + template.get("name", "Героиня") + " • " + rank_name + " (Ур. " + str(aff_lvl) + ")"

	var speaker = data.get("speaker", "Вайфу")
	var narrative = data.get("narrative_text", "")
	var spoken = data.get("character_text", "")

	# Speaker plate animation on change
	if speaker_label.text != speaker:
		speaker_label.text = speaker
		speaker_plate.pivot_offset = speaker_plate.size * 0.5
		var plate_tween = create_tween()
		speaker_plate.scale = Vector2(0.85, 0.85)
		plate_tween.tween_property(speaker_plate, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	narrative_label.visible = (narrative != "")
	narrative_label.text = narrative

	var char_text = "«" + spoken + "»" if spoken != "" else ""
	dialog_text.text = char_text

	# Save to backlog
	dialogue_backlog.append({
		"speaker": speaker,
		"narrative": narrative,
		"spoken": char_text
	})

	# Character Portrait & Emotion
	var char_tex = GameSession.get_character_texture(char_id, current_outfit)
	char_portrait.texture = char_tex
	char_icon.visible = (char_tex == null)

	var emotion = data.get("emotion", "smile")
	_apply_emotion(emotion)

	# Typewriter effect
	prompt_indicator.visible = false
	if typewriter_tween:
		typewriter_tween.kill()

	_typewriter_audio_step = 0
	if is_skipping or text_speed_mode == 2:
		dialog_text.visible_ratio = 1.0
		prompt_indicator.visible = true
		if is_auto_playing:
			_schedule_auto_advance(data)
	else:
		dialog_text.visible_ratio = 0.0
		var speed_rate = 0.02 if text_speed_mode == 0 else 0.007
		var duration = max(0.2, float(char_text.length()) * speed_rate)
		typewriter_tween = create_tween()
		typewriter_tween.tween_method(func(val: float):
			dialog_text.visible_ratio = val
			var chars_vis = int(val * float(char_text.length()))
			if chars_vis - _typewriter_audio_step >= 4:
				_typewriter_audio_step = chars_vis
				AudioManager.play_sfx_roulette_tick(false, 1.8)
		, 0.0, 1.0, duration)
		typewriter_tween.tween_callback(func():
			prompt_indicator.visible = true
			if is_auto_playing:
				_schedule_auto_advance(data)
		)

	# Choices setup
	_render_choices(data)

func _apply_emotion(emotion: String) -> void:
	if breathing_tween and breathing_tween.is_valid():
		breathing_tween.kill()

	match emotion:
		"blush":
			emotion_badge.text = "😳 Смущение"
			char_icon.text = "🥰"
			var tw = create_tween()
			tw.tween_property(char_portrait, "modulate", Color(1.08, 0.94, 0.97), 0.3)
			tw.tween_property(char_portrait, "scale", Vector2(1.03, 1.03), 0.2).set_trans(Tween.TRANS_SPRING)
			tw.tween_property(char_portrait, "scale", Vector2(1.0, 1.0), 0.2)
			tw.tween_callback(_init_portrait_breathing)
			AudioManager.play_sfx_heart()
		"happy":
			emotion_badge.text = "✨ Восторг"
			char_icon.text = "😄"
			var tw = create_tween()
			tw.tween_property(char_portrait, "modulate", Color(1.05, 1.05, 0.96), 0.3)
			var base_y = char_portrait.position.y
			tw.tween_property(char_portrait, "position:y", base_y - 12.0, 0.15).set_trans(Tween.TRANS_SINE)
			tw.tween_property(char_portrait, "position:y", base_y, 0.2).set_trans(Tween.TRANS_BOUNCE)
			tw.tween_callback(_init_portrait_breathing)
			AudioManager.play_synth_arpeggio([783.99, 987.77, 1174.66], 0.05, 0.25, "bell")
		_:
			emotion_badge.text = "😊 Улыбка"
			char_icon.text = "🌸"
			var tw = create_tween()
			tw.tween_property(char_portrait, "modulate", Color.WHITE, 0.3)
			tw.tween_property(char_portrait, "scale", Vector2(1.0, 1.0), 0.2)
			tw.tween_callback(_init_portrait_breathing)

func _render_choices(data: Dictionary) -> void:
	for child in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()

	var choices = data.get("choices", [])
	var is_end = data.get("is_end", false)

	if choices.size() == 0 or is_end:
		var btn_finish = Button.new()
		btn_finish.custom_minimum_size = Vector2(360, 56)
		btn_finish.text = "💖 Завершить свидание! 💖"
		btn_finish.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		StyleHelper.apply_button_style(btn_finish, StyleHelper.COLOR_ACCENT_PINK, 14)
		btn_finish.pressed.connect(func():
			btn_finish.disabled = true
			_on_finish_date(data)
		)
		choices_container.add_child(btn_finish)
	else:
		for i in range(choices.size()):
			var ch = choices[i]
			var card = _create_choice_card(ch, i)
			choices_container.add_child(card)

func _create_choice_card(choice: Dictionary, index: int) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 56)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.10, 0.18, 0.92)
	style.set_corner_radius_all(12)
	style.set_border_width_all(2)
	style.border_color = StyleHelper.COLOR_ACCENT_CYAN
	style.shadow_size = 6
	style.shadow_color = Color(0, 0, 0, 0.35)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_theme_constant_override("separation", 14)
	margin.add_child(hbox)

	# Number badge
	var num_badge = Label.new()
	num_badge.text = "[" + str(index + 1) + "]"
	num_badge.add_theme_font_size_override("font_size", 16)
	num_badge.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
	hbox.add_child(num_badge)

	# Choice text
	var text_lbl = Label.new()
	text_lbl.text = choice.get("text", "")
	text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.add_theme_font_size_override("font_size", 14)
	text_lbl.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(text_lbl)

	# Hint pill badge
	var hint = choice.get("hint", "")
	if hint != "":
		var hint_panel = PanelContainer.new()
		hint_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		var h_style = StyleBoxFlat.new()
		h_style.bg_color = Color(0.2, 0.15, 0.3, 0.8)
		h_style.set_corner_radius_all(8)
		h_style.set_border_width_all(1)
		h_style.border_color = StyleHelper.COLOR_ACCENT_PINK if "💖" in hint else StyleHelper.COLOR_ACCENT_GOLD
		hint_panel.add_theme_stylebox_override("panel", h_style)

		var h_margin = MarginContainer.new()
		h_margin.mouse_filter = Control.MOUSE_FILTER_PASS
		h_margin.add_theme_constant_override("margin_left", 10)
		h_margin.add_theme_constant_override("margin_right", 10)
		h_margin.add_theme_constant_override("margin_top", 4)
		h_margin.add_theme_constant_override("margin_bottom", 4)
		hint_panel.add_child(h_margin)

		var hint_lbl = Label.new()
		hint_lbl.text = hint
		hint_lbl.add_theme_font_size_override("font_size", 12)
		hint_lbl.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_PINK if "💖" in hint else StyleHelper.COLOR_ACCENT_GOLD)
		h_margin.add_child(hint_lbl)
		hbox.add_child(hint_panel)

	# Button overlay
	var btn = Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.mouse_filter = Control.MOUSE_FILTER_PASS

	btn.mouse_entered.connect(func():
		var tw = create_tween()
		tw.tween_property(panel, "scale", Vector2(1.015, 1.015), 0.12)
		style.border_color = StyleHelper.COLOR_ACCENT_PINK
	)
	btn.mouse_exited.connect(func():
		var tw = create_tween()
		tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.12)
		style.border_color = StyleHelper.COLOR_ACCENT_CYAN
	)

	var idx = index
	btn.pressed.connect(func():
		for b in choices_container.get_children():
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		AudioManager.play_sfx_click()
		submit_choice(idx)
	)
	panel.add_child(btn)

	return panel

func submit_choice(choice_index: int) -> void:
	if is_submitting_choice:
		return
	is_submitting_choice = true
	NetworkManager.submit_date_choice(selected_waifu_id, selected_location_id, current_node_id, choice_index, func(success: bool, data: Variant):
		is_submitting_choice = false
		if success and data is Dictionary:
			var gain = data.get("affection_gain", 10)
			AudioManager.play_sfx_heart()
			GameSession.show_toast("+" + str(gain) + " очков симпатии! ❤️", true)
			render_dialogue_node(data)
		else:
			for b in choices_container.get_children():
				b.mouse_filter = Control.MOUSE_FILTER_STOP
			GameSession.show_toast("Ошибка выбора ответа", false)
	)

func _schedule_auto_advance(data: Dictionary) -> void:
	if not is_auto_playing:
		return
	var is_end = data.get("is_end", false)
	if is_end:
		auto_advance_timer = get_tree().create_timer(2.0)
		auto_advance_timer.timeout.connect(func():
			if is_auto_playing and vn_panel.visible:
				_on_finish_date(data)
		)

func _toggle_auto_play() -> void:
	is_auto_playing = not is_auto_playing
	if is_auto_playing:
		is_skipping = false
		btn_skip.text = "⏩ Пропуск"
		btn_auto.text = "⏸️ Стоп"
		StyleHelper.apply_button_style(btn_auto, StyleHelper.COLOR_ACCENT_PINK, 8)
		GameSession.show_toast("Авто-режим включен ▶️", true)
		if prompt_indicator.visible:
			auto_advance_timer = get_tree().create_timer(1.2)
			auto_advance_timer.timeout.connect(func():
				if is_auto_playing and choices_container.get_child_count() == 1:
					var child = choices_container.get_child(0)
					if child is Button and not child.disabled:
						child.emit_signal("pressed")
			)
	else:
		btn_auto.text = "▶️ Авто"
		StyleHelper.apply_button_style(btn_auto, Color(0.25, 0.22, 0.35), 8)

func _toggle_skip() -> void:
	is_skipping = not is_skipping
	if is_skipping:
		is_auto_playing = false
		btn_auto.text = "▶️ Авто"
		btn_skip.text = "⏸️ Стоп"
		StyleHelper.apply_button_style(btn_skip, StyleHelper.COLOR_ACCENT_GOLD, 8)
		if typewriter_tween and typewriter_tween.is_running():
			typewriter_tween.kill()
		dialog_text.visible_ratio = 1.0
		prompt_indicator.visible = true
	else:
		btn_skip.text = "⏩ Пропуск"
		StyleHelper.apply_button_style(btn_skip, Color(0.25, 0.22, 0.35), 8)

func _toggle_text_speed() -> void:
	text_speed_mode = (text_speed_mode + 1) % 3
	AudioManager.play_sfx_click()
	match text_speed_mode:
		0:
			btn_speed.text = "⚡ Скорость: 1x"
		1:
			btn_speed.text = "⚡ Скорость: 2x"
		2:
			btn_speed.text = "⚡ Скорость: Мгн."
	GameSession.show_toast("Скорость текста изменена: " + btn_speed.text, true)

func _on_finish_date(data: Dictionary) -> void:
	if is_finishing_date:
		return
	is_finishing_date = true

	# Reset auto-play and skip modes
	is_auto_playing = false
	is_skipping = false
	btn_auto.text = "▶️ Авто"
	btn_skip.text = "⏩ Пропуск"
	StyleHelper.apply_button_style(btn_auto, Color(0.25, 0.22, 0.35), 8)
	StyleHelper.apply_button_style(btn_skip, Color(0.25, 0.22, 0.35), 8)

	var waifu = GameSession.get_waifu_by_id(selected_waifu_id)
	var template = waifu.get("template", {})
	var leveled_up = data.get("leveled_up", false)
	var cg_unlocked = data.get("cg_unlocked", false)

	if cg_unlocked:
		AudioManager.play_sfx_ur()
	elif leveled_up:
		AudioManager.play_sfx_level_up()
	else:
		AudioManager.play_sfx_heart()

	# Configure conclusion modal
	conclusion_title.text = "🎉 НЕЗАБЫВАЕМОЕ СВИДАНИЕ! 🎉"
	var prev_lvl = int(data.get("prev_affection_level", 1))
	var cur_lvl = int(data.get("affection_level", 1))
	var rank_name = data.get("rank_title", RANKS.get(cur_lvl, "Возлюбленная"))
	var cur_pts = int(data.get("current_affection", waifu.get("affection_points", 0)))
	var prog = _get_affection_progress(cur_pts, cur_lvl)

	if leveled_up:
		level_up_badge.visible = true
		level_up_badge.text = "🌟 ПОВЫШЕНИЕ СИМПАТИИ: Ур. " + str(prev_lvl) + " ➔ Ур. " + str(cur_lvl) + "! 🌟"
		rank_progress_label.text = "Ранг отношений: " + RANKS.get(prev_lvl, "Знакомая") + " ➔ " + rank_name + "!"
	else:
		level_up_badge.visible = false
		if cur_lvl >= 10:
			rank_progress_label.text = "Ранг отношений: " + rank_name + " (МАКСИМАЛЬНЫЙ РАНГ • Абсолютное единство!)"
		else:
			var to_next = prog.points_required - prog.points_in_level
			rank_progress_label.text = "Ранг отношений: " + rank_name + " (Ур. " + str(cur_lvl) + " • До след. ранга: " + str(to_next) + " очков)"

	# Animated Affection Progress Bar
	conclusion_affection_bar.max_value = 100.0

	if affection_bar_tween and affection_bar_tween.is_valid():
		affection_bar_tween.kill()
	affection_bar_tween = create_tween()

	if leveled_up:
		conclusion_affection_bar.value = 80.0
		affection_bar_tween.tween_property(conclusion_affection_bar, "value", 100.0, 0.4)
		affection_bar_tween.tween_interval(0.2)
		affection_bar_tween.tween_callback(func(): conclusion_affection_bar.value = 0.0)
		affection_bar_tween.tween_property(conclusion_affection_bar, "value", prog.percentage, 0.6).set_trans(Tween.TRANS_CUBIC)
	else:
		var start_pct = max(0.0, prog.percentage - 15.0)
		conclusion_affection_bar.value = start_pct
		affection_bar_tween.tween_property(conclusion_affection_bar, "value", prog.percentage, 0.6).set_trans(Tween.TRANS_CUBIC)

	affection_gain_label.text = "Спутница: " + template.get("name", "") + " • +" + str(data.get("affection_gain", 25)) + " Любви ❤️"

	var gems = int(data.get("gems_reward", 5))
	rewards_label.text = "Награда: +" + str(gems) + " Кристаллов Любви 💎"

	# Romantic CG Display
	conclusion_cg_container.visible = true
	var cg_tex = GameSession.get_background_texture("cg_" + selected_location_id)
	if not cg_tex:
		var char_id = template.get("id", "")
		cg_tex = GameSession.get_character_texture(char_id)
	conclusion_cg_image.texture = cg_tex

	if cg_unlocked:
		conclusion_cg_badge.text = "✨ НОВОЕ РОМАНТИЧЕСКОЕ ВОСПОМИНАНИЕ РАЗБЛОКИРОВАНО! (+10 💎)"
		conclusion_cg_badge.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
	else:
		conclusion_cg_badge.text = "📸 Романтическое воспоминание: " + _get_location_name(selected_location_id) + " (Нажмите для просмотра)"
		conclusion_cg_badge.add_theme_color_override("font_color", Color(0.9, 0.8, 1.0))

	# Entrance bounce animation for modal panel
	var panel = $ConclusionModal/Panel
	panel.scale = Vector2(0.85, 0.85)
	panel.pivot_offset = panel.custom_minimum_size * 0.5
	conclusion_modal.visible = true
	var entrance_tween = create_tween()
	entrance_tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _open_fullscreen_cg(tex: Texture2D, title: String) -> void:
	if not tex:
		return
	full_cg_image.texture = tex
	full_cg_title.text = "🖼️ " + title
	fullscreen_cg_modal.visible = true

	var tw = create_tween()
	fullscreen_cg_modal.modulate.a = 0.0
	tw.tween_property(fullscreen_cg_modal, "modulate:a", 1.0, 0.25)

func _open_backlog() -> void:
	AudioManager.play_sfx_click()
	for child in backlog_list.get_children():
		backlog_list.remove_child(child)
		child.queue_free()

	if dialogue_backlog.is_empty():
		var empty = Label.new()
		empty.text = "История реплик пока пуста."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		backlog_list.add_child(empty)
	else:
		for item in dialogue_backlog:
			var box = PanelContainer.new()
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.12, 0.1, 0.18, 0.85)
			style.set_corner_radius_all(8)
			style.set_border_width_all(1)
			style.border_color = Color(0.3, 0.25, 0.4)
			box.add_theme_stylebox_override("panel", style)

			var margin = MarginContainer.new()
			margin.add_theme_constant_override("margin_left", 14)
			margin.add_theme_constant_override("margin_top", 10)
			margin.add_theme_constant_override("margin_right", 14)
			margin.add_theme_constant_override("margin_bottom", 10)
			box.add_child(margin)

			var vbox = VBoxContainer.new()
			vbox.add_theme_constant_override("separation", 6)
			margin.add_child(vbox)

			var spk = Label.new()
			spk.text = item.get("speaker", "")
			spk.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_PINK)
			spk.add_theme_font_size_override("font_size", 16)
			vbox.add_child(spk)

			var narr = item.get("narrative", "")
			if narr != "":
				var narr_lbl = Label.new()
				narr_lbl.text = narr
				narr_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				narr_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.85))
				narr_lbl.add_theme_font_size_override("font_size", 13)
				vbox.add_child(narr_lbl)

			var txt = item.get("spoken", "")
			if txt != "":
				var text_lbl = Label.new()
				text_lbl.text = txt
				text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				text_lbl.add_theme_color_override("font_color", Color(1, 1, 0.85))
				text_lbl.add_theme_font_size_override("font_size", 15)
				vbox.add_child(text_lbl)

			backlog_list.add_child(box)

	backlog_modal.visible = true
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll = $BacklogModal/Panel/Margin/VBox/Scroll
	scroll.scroll_vertical = 999999

func _open_cg_gallery() -> void:
	AudioManager.play_sfx_click()
	for child in gallery_grid.get_children():
		gallery_grid.remove_child(child)
		child.queue_free()

	var waifus = GameSession.user_waifus
	var unlocked_set = {}
	for w in waifus:
		for cg in w.get("cgs_unlocked", []):
			unlocked_set[cg] = true

	for loc in locations_data:
		var lid = loc.get("id", "")
		var lname = loc.get("name", "")

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(240, 200)

		# Check if any CG for this location is unlocked
		var is_unlocked = false
		for k in unlocked_set.keys():
			if k.begins_with("cg_" + lid):
				is_unlocked = true
				break

		StyleHelper.apply_panel_style(card, StyleHelper.COLOR_ACCENT_GOLD if is_unlocked else Color(0.25, 0.25, 0.35), 12, 0.9)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		card.add_child(margin)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)
		margin.add_child(vbox)

		var img_rect = TextureRect.new()
		img_rect.custom_minimum_size = Vector2(0, 130)
		img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

		var cg_tex = GameSession.get_background_texture("cg_" + lid)
		if cg_tex and is_unlocked:
			img_rect.texture = cg_tex
		else:
			img_rect.texture = cg_tex
			img_rect.modulate = Color(0.2, 0.2, 0.25, 0.8)
		vbox.add_child(img_rect)

		var title_lbl = Label.new()
		title_lbl.text = lname
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_lbl.add_theme_font_size_override("font_size", 13)
		vbox.add_child(title_lbl)

		var status_lbl = Label.new()
		status_lbl.text = "✓ Разблокировано (Нажмите)" if is_unlocked else "🔒 Заблокировано"
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_lbl.add_theme_font_size_override("font_size", 11)
		status_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5) if is_unlocked else Color(0.7, 0.4, 0.4))
		vbox.add_child(status_lbl)

		var click_btn = Button.new()
		click_btn.flat = true
		click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var target_tex = cg_tex
		var target_title = lname
		if is_unlocked and cg_tex:
			click_btn.pressed.connect(func():
				AudioManager.play_sfx_click()
				_open_fullscreen_cg(target_tex, target_title)
			)
		else:
			click_btn.pressed.connect(func():
				AudioManager.play_sfx_click()
				GameSession.show_toast("Завершите свидание в локации «" + target_title + "», чтобы открыть воспоминание! 🔒", false)
			)
		card.add_child(click_btn)

		gallery_grid.add_child(card)

	cg_gallery_modal.visible = true

func _on_exit_vn() -> void:
	AudioManager.play_sfx_click()
	if typewriter_tween and typewriter_tween.is_running():
		typewriter_tween.kill()
	is_auto_playing = false
	is_skipping = false
	is_submitting_choice = false
	btn_auto.text = "▶️ Авто"
	btn_skip.text = "⏩ Пропуск"
	StyleHelper.apply_button_style(btn_auto, Color(0.25, 0.22, 0.35), 8)
	StyleHelper.apply_button_style(btn_skip, Color(0.25, 0.22, 0.35), 8)
	vn_panel.visible = false
	select_panel.visible = true
	GameSession.show_toast("Свидание приостановлено", false)

func _get_location_name(lid: String) -> String:
	for loc in locations_data:
		if loc.get("id") == lid:
			return loc.get("name", lid.capitalize())
	return lid.capitalize()

var _active_gift_modal: Control = null

func _open_gift_modal() -> void:
	if _active_gift_modal and is_instance_valid(_active_gift_modal):
		_active_gift_modal.queue_free()
		
	var waifu = GameSession.get_waifu_by_id(selected_waifu_id)
	if waifu.is_empty():
		GameSession.show_toast("Сначала выберите вайфу!", false)
		return
		
	var template = waifu.get("template", {})
	var fav_food = template.get("favorite_food", [])
	var wid = selected_waifu_id
		
	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(600, 400)
	modal.anchors_preset = Control.PRESET_CENTER
	modal.position = Vector2(660, 340)
	StyleHelper.apply_panel_style(modal, StyleHelper.COLOR_ACCENT_PINK, 18, 0.96)
	add_child(modal)
	_active_gift_modal = modal
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	modal.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "🎁 Подарить подарок " + template.get("name", "")
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 260)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)
	
	var btn_close = Button.new()
	btn_close.text = "Закрыть ✖️"
	btn_close.custom_minimum_size = Vector2(120, 36)
	btn_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	StyleHelper.apply_button_style(btn_close, Color(0.4, 0.35, 0.45), 8)
	btn_close.pressed.connect(func():
		_active_gift_modal.queue_free()
		_active_gift_modal = null
	)
	vbox.add_child(btn_close)
	
	var populate = func(inv_map: Dictionary):
		for ch in grid.get_children():
			ch.queue_free()
			
		for f_data in FOOD_ITEMS:
			var fid = str(f_data.get("id", ""))
			var is_favorite = (fid in fav_food)
			var owned_qty = int(inv_map.get(fid, 0))
			var price = int(f_data.get("price", 50))
			var cur_type = str(f_data.get("currency", "coins"))
			
			var f_card = Button.new()
			f_card.custom_minimum_size = Vector2(160, 68)
			
			var f_title = str(f_data.get("icon", "🍰")) + " " + str(f_data.get("name", "Подарок"))
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
			grid.add_child(f_card)
			
			f_card.pressed.connect(func():
				if owned_qty > 0:
					NetworkManager.feed_waifu(wid, fid, func(feed_ok: bool, feed_data: Variant):
						if feed_ok and feed_data is Dictionary:
							AudioManager.play_sfx_heart()
							var rep = str(feed_data.get("reply", "Спасибо за подарок!"))
							var gain = feed_data.get("affection_gain", 15)
							GameSession.show_toast("+" + str(gain) + " симпатии! «" + rep + "»", true)
							GameSession.refresh_waifus()
							_active_gift_modal.queue_free()
							_active_gift_modal = null
						else:
							var err = "Не удалось подарить"
							if feed_data is Dictionary:
								err = feed_data.get("error", err)
							GameSession.show_toast(err, false)
					)
				else:
					var has_currency = false
					if cur_type == "coins":
						has_currency = (GameSession.coins >= price)
					else:
						has_currency = (GameSession.love_gems >= price)
						
					if not has_currency:
						GameSession.show_toast("Недостаточно средств!", false)
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
							NetworkManager.feed_waifu(wid, fid, func(feed_ok: bool, feed_data: Variant):
								if feed_ok and feed_data is Dictionary:
									AudioManager.play_sfx_heart()
									var rep = str(feed_data.get("reply", "Спасибо за подарок!"))
									var gain = feed_data.get("affection_gain", 15)
									GameSession.show_toast("Куплено и подарено! +" + str(gain) + " симпатии!", true)
									GameSession.refresh_waifus()
									_active_gift_modal.queue_free()
									_active_gift_modal = null
							)
						else:
							GameSession.show_toast("Ошибка покупки предмета", false)
					)
			)
			
	NetworkManager.get_inventory(func(inv_ok: bool, inv_res: Variant):
		var inv_map = {}
		if inv_ok and inv_res is Array:
			for item_entry in inv_res:
				if item_entry is Dictionary:
					inv_map[str(item_entry.get("item_id", ""))] = int(item_entry.get("quantity", 0))
		populate.call(inv_map)
	)

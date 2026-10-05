extends Control

# Banner UI
@onready var banner_title: Label = $VBoxContainer/BannerHeader/HBox/VBox/BannerTitle
@onready var banner_desc: Label = $VBoxContainer/BannerHeader/HBox/VBox/BannerDesc
@onready var pity_label: Label = $VBoxContainer/BannerHeader/HBox/VBox/PityBox/PityLabel
@onready var pity_bar: ProgressBar = $VBoxContainer/BannerHeader/HBox/VBox/PityBox/PityBar
@onready var btn_rates: Button = $VBoxContainer/BannerHeader/HBox/VBox/BtnRates
@onready var banner_bg: TextureRect = $VBoxContainer/BannerHeader/BannerBg
@onready var featured_portrait: TextureRect = $VBoxContainer/BannerHeader/HBox/PortraitPanel/FeaturedPortrait
@onready var btn_pull_1: Button = $VBoxContainer/Controls/HBox/BtnPull1
@onready var btn_pull_10: Button = $VBoxContainer/Controls/HBox/BtnPull10
@onready var btn_multi_mode_main: Button = $VBoxContainer/Controls/HBox/BtnMultiModeMain
@onready var banner_tabs_container: HBoxContainer = $VBoxContainer/BannerTabs

# CS:GO Casino Roulette Summoning Overlay
@onready var summoning_overlay: Control = $SummoningOverlay
@onready var overlay_title: Label = $SummoningOverlay/HeaderBox/OverlayTitle
@onready var overlay_subtitle: Label = $SummoningOverlay/HeaderBox/OverlaySubtitle
@onready var single_roulette_container: Control = $SummoningOverlay/SingleRoulette
@onready var single_tape_frame: PanelContainer = $SummoningOverlay/SingleRoulette/TapeFrame
@onready var single_tape_viewport: Control = $SummoningOverlay/SingleRoulette/TapeFrame/TapeViewport
@onready var single_tape_strip: Control = $SummoningOverlay/SingleRoulette/TapeFrame/TapeViewport/TapeStrip
@onready var left_fade: TextureRect = $SummoningOverlay/SingleRoulette/TapeFrame/TapeViewport/LeftFade
@onready var right_fade: TextureRect = $SummoningOverlay/SingleRoulette/TapeFrame/TapeViewport/RightFade
@onready var single_center_needle: Control = $SummoningOverlay/SingleRoulette/TapeFrame/CenterNeedle
@onready var single_top_pointer: Label = $SummoningOverlay/SingleRoulette/TapeFrame/CenterNeedle/TopPointer
@onready var single_bottom_pointer: Label = $SummoningOverlay/SingleRoulette/TapeFrame/CenterNeedle/BottomPointer
@onready var single_laser_line: ColorRect = $SummoningOverlay/SingleRoulette/TapeFrame/CenterNeedle/LaserLine
@onready var single_near_miss_banner: Label = $SummoningOverlay/SingleRoulette/NearMissBanner
@onready var single_status_text: Label = $SummoningOverlay/SingleRoulette/StatusText

@onready var multi_roulette_container: Control = $SummoningOverlay/MultiRoulette
@onready var multi_grid: GridContainer = $SummoningOverlay/MultiRoulette/Scroll/Grid

@onready var btn_skip: Button = $SummoningOverlay/TopControls/BtnSkip
@onready var btn_mode_toggle: Button = $SummoningOverlay/TopControls/BtnModeToggle
@onready var btn_next_pull: Button = $SummoningOverlay/TopControls/BtnNextPull
@onready var vortex_particles: CPUParticles2D = $SummoningOverlay/Particles

# Single Reveal Overlay
@onready var single_reveal_overlay: Control = $SingleRevealOverlay
@onready var single_card_holder: PanelContainer = $SingleRevealOverlay/CardCenter/CardHolder
@onready var single_portrait: TextureRect = $SingleRevealOverlay/CardCenter/CardHolder/VBox/PortraitBox/Portrait
@onready var single_rarity_badge: Label = $SingleRevealOverlay/CardCenter/CardHolder/VBox/RarityBadge
@onready var single_name_label: Label = $SingleRevealOverlay/CardCenter/CardHolder/VBox/NameLabel
@onready var single_franchise_label: Label = $SingleRevealOverlay/CardCenter/CardHolder/VBox/FranchiseLabel
@onready var single_quote_label: Label = $SingleRevealOverlay/CardCenter/CardHolder/VBox/QuoteLabel
@onready var single_duplicate_label: Label = $SingleRevealOverlay/CardCenter/CardHolder/VBox/DuplicateLabel
@onready var btn_reveal_next: Button = $SingleRevealOverlay/TopActions/BtnRevealNext
@onready var btn_reveal_skip_all: Button = $SingleRevealOverlay/TopActions/BtnRevealSkipAll
@onready var tap_to_continue_label: Label = $SingleRevealOverlay/TapToContinue

# Pull Results Summary Modal
@onready var result_modal: Control = $ResultModal
@onready var cards_container: HFlowContainer = $ResultModal/Panel/Margin/VBox/Scroll/CardsContainer
@onready var btn_close_result: Button = $ResultModal/Panel/Margin/VBox/ActionsHBox/BtnClose
@onready var btn_pull_again_1: Button = $ResultModal/Panel/Margin/VBox/ActionsHBox/BtnPullAgain1
@onready var btn_pull_again_10: Button = $ResultModal/Panel/Margin/VBox/ActionsHBox/BtnPullAgain10
@onready var result_title: Label = $ResultModal/Panel/Margin/VBox/HeaderHBox/TitleLabel

# Rates & Rules Modal
@onready var rates_modal: Control = $RatesModal
@onready var rates_content: RichTextLabel = $RatesModal/Panel/Margin/VBox/RatesContent
@onready var btn_close_rates: Button = $RatesModal/Panel/Margin/VBox/BtnCloseRates

# Roulette constants
const SINGLE_CARD_WIDTH: float = 210.0
const SINGLE_CARD_HEIGHT: float = 270.0
const SINGLE_CARD_GAP: float = 14.0
const SINGLE_TOTAL_CARDS: int = 46
const SINGLE_WIN_INDEX: int = 36
const SINGLE_DURATION: float = 4.8
const DECEL_EXPONENT: float = 2.4 # Natural friction deceleration: fast spin -> steady slowdown -> crawl

const MINI_CARD_WIDTH: float = 80.0
const MINI_CARD_HEIGHT: float = 92.0
const MINI_CARD_GAP: float = 8.0
const MINI_TOTAL_CARDS: int = 26
const MINI_WIN_INDEX: int = 18

# Roulette dynamic state
var is_single_spinning: bool = false
var single_spin_elapsed: float = 0.0
var single_target_scroll: float = 0.0
var single_last_ticked_idx: int = -1
var single_tape_items: Array = []
var single_winning_char: Dictionary = {}
var single_current_drop: Dictionary = {}

var is_multi_spinning: bool = false
var multi_reels_data: Array = []
var multi_last_global_tick_time: float = 0.0

var is_sequential_mode: bool = false
var sequential_index: int = 0

var current_case_index: int = 0
var cases: Array = []
var pending_drops: Array = []
var is_summoning: bool = false

var _shake_tween: Tween = null
var _banner_tween: Tween = null

func _ready() -> void:
	# Hide all overlays initially
	summoning_overlay.visible = false
	single_reveal_overlay.visible = false
	result_modal.visible = false
	rates_modal.visible = false

	# Apply theme styling
	StyleHelper.apply_panel_style($VBoxContainer/BannerHeader, StyleHelper.COLOR_PANEL_BORDER, 16, 0.7)
	StyleHelper.apply_panel_style($VBoxContainer/Controls, StyleHelper.COLOR_PANEL_BORDER, 14, 0.85)
	StyleHelper.apply_panel_style($VBoxContainer/BannerHeader/HBox/PortraitPanel, StyleHelper.COLOR_ACCENT_PINK, 14, 0.3)
	StyleHelper.apply_panel_style($ResultModal/Panel, StyleHelper.COLOR_ACCENT_PURPLE, 18, 0.95)
	StyleHelper.apply_panel_style($RatesModal/Panel, StyleHelper.COLOR_ACCENT_GOLD, 16, 0.95)
	StyleHelper.apply_panel_style(single_tape_frame, StyleHelper.COLOR_ACCENT_GOLD, 16, 0.95)

	# Buttons styling
	StyleHelper.apply_button_style(btn_pull_1, StyleHelper.COLOR_ACCENT_PINK, 14)
	StyleHelper.apply_button_style(btn_pull_10, StyleHelper.COLOR_ACCENT_GOLD, 14)
	StyleHelper.apply_button_style(btn_multi_mode_main, Color(0.35, 0.35, 0.5), 12)
	StyleHelper.apply_button_style(btn_rates, StyleHelper.COLOR_ACCENT_CYAN, 10)
	StyleHelper.apply_button_style(btn_skip, Color(0.7, 0.7, 0.8), 10)
	StyleHelper.apply_button_style(btn_mode_toggle, StyleHelper.COLOR_ACCENT_GOLD, 10)
	StyleHelper.apply_button_style(btn_next_pull, StyleHelper.COLOR_ACCENT_PINK, 10)
	StyleHelper.apply_button_style(btn_reveal_next, StyleHelper.COLOR_ACCENT_PINK, 12)
	StyleHelper.apply_button_style(btn_reveal_skip_all, Color(0.65, 0.65, 0.75), 12)
	StyleHelper.apply_button_style(btn_close_result, StyleHelper.COLOR_ACCENT_PINK, 12)
	StyleHelper.apply_button_style(btn_pull_again_1, StyleHelper.COLOR_ACCENT_CYAN, 12)
	StyleHelper.apply_button_style(btn_pull_again_10, StyleHelper.COLOR_ACCENT_GOLD, 12)
	StyleHelper.apply_button_style(btn_close_rates, StyleHelper.COLOR_ACCENT_PINK, 10)

	# Setup smooth edge vignettes
	_setup_tape_vignettes()

	# Needle pivot setup for mechanical clapper deflection
	single_top_pointer.pivot_offset = Vector2(20, 0)
	single_bottom_pointer.pivot_offset = Vector2(20, 30)

	# Connect buttons
	btn_pull_1.pressed.connect(func(): _start_pull(1))
	btn_pull_10.pressed.connect(func(): _start_pull(10))
	btn_multi_mode_main.pressed.connect(_on_multi_mode_toggle_pressed)
	btn_pull_again_1.pressed.connect(func():
		result_modal.visible = false
		_start_pull(1)
	)
	btn_pull_again_10.pressed.connect(func():
		result_modal.visible = false
		_start_pull(10)
	)
	btn_close_result.pressed.connect(func():
		AudioManager.play_sfx_click()
		result_modal.visible = false
	)
	btn_skip.pressed.connect(_on_skip_summoning)
	btn_mode_toggle.pressed.connect(_on_multi_mode_toggle_pressed)
	btn_next_pull.pressed.connect(_advance_sequential_pull)
	btn_reveal_next.pressed.connect(_advance_sequential_pull)
	btn_reveal_skip_all.pressed.connect(_on_skip_summoning)
	btn_rates.pressed.connect(_show_rates_modal)
	btn_close_rates.pressed.connect(func():
		AudioManager.play_sfx_click()
		rates_modal.visible = false
	)

	$SingleRevealOverlay.gui_input.connect(_on_single_reveal_input)
	_set_children_mouse_ignore(single_reveal_overlay)

	_update_mode_toggle_buttons()

	var bg_tex = GameSession.get_background_texture("bg_banner")
	if bg_tex:
		banner_bg.texture = bg_tex

	load_cases()

func _setup_tape_vignettes() -> void:
	var grad_left = Gradient.new()
	grad_left.colors = PackedColorArray([Color(0.04, 0.03, 0.07, 0.98), Color(0.04, 0.03, 0.07, 0.0)])
	var tex_left = GradientTexture2D.new()
	tex_left.gradient = grad_left
	tex_left.width = 180
	tex_left.height = 1
	tex_left.fill_from = Vector2(0, 0)
	tex_left.fill_to = Vector2(1, 0)
	left_fade.texture = tex_left

	var grad_right = Gradient.new()
	grad_right.colors = PackedColorArray([Color(0.04, 0.03, 0.07, 0.0), Color(0.04, 0.03, 0.07, 0.98)])
	var tex_right = GradientTexture2D.new()
	tex_right.gradient = grad_right
	tex_right.width = 180
	tex_right.height = 1
	tex_right.fill_from = Vector2(0, 0)
	tex_right.fill_to = Vector2(1, 0)
	right_fade.texture = tex_right

func _process(delta: float) -> void:
	# 1. Handle CS:GO Single Roulette Spin
	if is_single_spinning:
		single_spin_elapsed += delta
		var u: float = clampf(single_spin_elapsed / SINGLE_DURATION, 0.0, 1.0)
		
		# Realistic friction deceleration curve: fast spin -> steady slowdown -> crawl
		var progress: float = 1.0 - pow(1.0 - u, DECEL_EXPONENT)
		var current_scroll: float = single_target_scroll * progress
		single_tape_strip.position.x = -current_scroll

		var step: float = SINGLE_CARD_WIDTH + SINGLE_CARD_GAP
		var v_c: float = 750.0 # Center needle position inside 1500px TapeFrame
		var card_idx: int = int((current_scroll + v_c) / step)

		if card_idx != single_last_ticked_idx and card_idx >= 0 and card_idx < single_tape_items.size():
			single_last_ticked_idx = card_idx
			var card_data = single_tape_items[card_idx]
			var rarity = card_data.get("rarity", "R")
			var is_gold = (rarity in ["SSR", "UR"])

			# Audible mechanical click on each card crossing the center needle
			var pitch = lerp(1.22, 0.86, u) + randf_range(-0.04, 0.04)
			AudioManager.play_sfx_roulette_tick(is_gold, pitch)
			_kick_needle(single_top_pointer, single_bottom_pointer, is_gold)

		# Dynamic status feedback during deceleration
		if u < 0.35:
			single_status_text.text = "⚡ РАЗГОН РУЛЕТКИ..."
		elif u < 0.75:
			single_status_text.text = "🎯 Замедление барабана..."
		else:
			single_status_text.text = "✨ Финальный ход к указателю..."

		if u >= 1.0:
			is_single_spinning = false
			_on_single_roulette_finished(single_current_drop)

	# 2. Handle 10x Simultaneous Multi-Reels
	if is_multi_spinning:
		var all_stopped: bool = true
		var now_sec = Time.get_ticks_msec() / 1000.0

		for d in multi_reels_data:
			if not d["stopped"]:
				d["elapsed"] += delta
				var u_m: float = clampf(d["elapsed"] / d["duration"], 0.0, 1.0)
				var prog_m: float = 1.0 - pow(1.0 - u_m, DECEL_EXPONENT)
				var scroll_m: float = d["target"] * prog_m
				d["tape"].position.x = -scroll_m

				var card_idx_m: int = int((scroll_m + d["v_c"]) / d["step"])
				if card_idx_m != d["last_tick"] and card_idx_m >= 0 and card_idx_m < d["items"].size():
					d["last_tick"] = card_idx_m
					var is_gold_m = (d["items"][card_idx_m].get("rarity") in ["SSR", "UR"])
					
					# Clapper kick on that mini reel
					_kick_needle(d["needle_top"], d["needle_bottom"], is_gold_m)

					# Coordinated audio rate limiter to avoid overwhelming audio clutter
					if is_gold_m or (now_sec - multi_last_global_tick_time) > 0.045:
						multi_last_global_tick_time = now_sec
						AudioManager.play_sfx_roulette_tick(is_gold_m, 1.0 + randf() * 0.15)

				if u_m >= 1.0:
					d["stopped"] = true
					_on_mini_reel_stopped(d)
				else:
					all_stopped = false

		if all_stopped:
			is_multi_spinning = false
			_on_all_multi_reels_stopped()

func load_cases() -> void:
	if GameSession.all_cases.size() > 0:
		cases = GameSession.all_cases
		setup_banner_tabs()
		display_case(0)
	else:
		NetworkManager.get_cases(func(success: bool, data: Variant):
			if success and data is Array:
				cases = data
				GameSession.all_cases = data
				setup_banner_tabs()
				display_case(0)
		)

func setup_banner_tabs() -> void:
	for child in banner_tabs_container.get_children():
		banner_tabs_container.remove_child(child)
		child.queue_free()

	for i in range(cases.size()):
		var c = cases[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(190, 44)
		btn.text = c.get("name", "Баннер")
		var idx = i
		btn.pressed.connect(func():
			AudioManager.play_sfx_click()
			display_case(idx)
		)
		banner_tabs_container.add_child(btn)

func update_tabs_highlight() -> void:
	var children = banner_tabs_container.get_children()
	for i in range(children.size()):
		var btn = children[i] as Button
		if btn:
			if i == current_case_index:
				StyleHelper.apply_button_style(btn, StyleHelper.COLOR_ACCENT_PINK, 12)
			else:
				StyleHelper.apply_button_style(btn, Color(0.3, 0.28, 0.4), 12)

func display_case(index: int) -> void:
	if index < 0 or index >= cases.size():
		return
	current_case_index = index
	update_tabs_highlight()

	var c = cases[index]
	banner_title.text = c.get("name", "")
	banner_desc.text = c.get("description", "")

	var curr_icon = "🪙" if c.get("currency") == "coins" else "💎"
	var cost = int(c.get("cost_per_pull", 100))
	btn_pull_1.text = "1x Призыв (" + curr_icon + " " + str(cost) + ")"
	btn_pull_10.text = "10x Призыв (" + curr_icon + " " + str(cost * 10) + ")"
	btn_pull_again_1.text = "🎰 Еще 1x (" + curr_icon + " " + str(cost) + ")"
	btn_pull_again_10.text = "🎰 Еще 10x (" + curr_icon + " " + str(cost * 10) + ")"

	var pity_limit = int(c.get("pity_limit", 60))
	pity_bar.max_value = pity_limit
	pity_bar.value = 0

	pity_label.text = "Гарант SSR/UR каждые " + str(pity_limit) + " круток | Гарант SR каждые 10 круток"

	var case_id = c.get("id", "")
	var featured_list = c.get("featured", [])
	var featured_char_id = "raiden_genshin"
	if featured_list.size() > 0:
		featured_char_id = str(featured_list[0])
	else:
		match case_id:
			"genshin_banner":
				featured_char_id = "raiden_genshin"
			"rezero_banner":
				featured_char_id = "rem_rezero"
			"premium_banner":
				featured_char_id = "saber_fate"
			_:
				featured_char_id = "miku_vocaloid"

	var portrait_tex = GameSession.get_character_texture(featured_char_id)
	if portrait_tex:
		featured_portrait.texture = portrait_tex
		featured_portrait.visible = true
	else:
		featured_portrait.visible = false

	var banner_tex = null
	match case_id:
		"genshin_banner":
			banner_tex = GameSession.get_background_texture("banner_genshin")
		"rezero_banner":
			banner_tex = GameSession.get_background_texture("banner_rezero")
		"premium_banner":
			banner_tex = GameSession.get_background_texture("banner_premium")
		"fantasy_magic_banner":
			banner_tex = GameSession.get_background_texture("banner_fantasy")
		"modern_romcom_banner":
			banner_tex = GameSession.get_background_texture("banner_modern")
		"sci_fi_destiny_banner":
			banner_tex = GameSession.get_background_texture("banner_scifi")
		_:
			banner_tex = GameSession.get_background_texture("bg_banner")
	if banner_tex == null:
		banner_tex = GameSession.get_background_texture("bg_banner")
	if banner_tex:
		banner_bg.texture = banner_tex

func _show_rates_modal() -> void:
	AudioManager.play_sfx_click()
	if cases.size() == 0:
		return
	var c = cases[current_case_index]
	var rates = c.get("rates", {})

	var text = "[center][b][font_size=20]" + c.get("name", "") + "[/font_size][/b][/center]\n\n"
	text += "[color=#ff55aa][b]★ UR (Сверхредкие):[/b][/color] " + str(float(rates.get("UR", 0.01)) * 100.0) + "%\n"
	text += "[color=#ffcc33][b]★ SSR (Легендарные):[/b][/color] " + str(float(rates.get("SSR", 0.05)) * 100.0) + "%\n"
	text += "[color=#bb66ff][b]★ SR (Эпические):[/b][/color] " + str(float(rates.get("SR", 0.15)) * 100.0) + "%\n"
	text += "[color=#44aaff][b]★ R (Редкие):[/b][/color] " + str(float(rates.get("R", 0.35)) * 100.0) + "%\n"
	var n_rate = float(rates.get("N", 0.0))
	if n_rate > 0.0:
		text += "[color=#aaaaaa][b]★ N (Обычные):[/b][/color] " + str(n_rate * 100.0) + "%\n"
	text += "\n"
	text += "[color=#ffd700][b]Система Гаранта (Pity):[/b][/color]\n"
	text += "• Каждые 10 призывов гарантирован персонаж ранга [color=#bb66ff]SR[/color] или выше.\n"
	text += "• Каждые " + str(c.get("pity_limit", 60)) + " призывов гарантирован персонаж ранга [color=#ffcc33]SSR[/color] / [color=#ff55aa]UR[/color].\n"
	text += "• При выпадении дубликата персонажа начисляются [color=#cc66ff]Осколки Души[/color] для гардероба и возвышения."

	rates_content.text = text
	rates_modal.visible = true

func _start_pull(count: int) -> void:
	if cases.size() == 0 or is_summoning:
		return
	var c = cases[current_case_index]
	var case_id = c.get("id")

	btn_pull_1.disabled = true
	btn_pull_10.disabled = true
	is_summoning = true

	# Start initial rising whoosh SFX
	AudioManager.play_sfx_roulette_spin()

	NetworkManager.roll_case(case_id, count, func(success: bool, data: Variant):
		if success and data is Dictionary:
			var drops = data.get("drops", [])
			var new_bal = data.get("new_balance", {})
			GameSession.set_balances(
				int(new_bal.get("coins", GameSession.coins)),
				int(new_bal.get("love_gems", GameSession.love_gems)),
				int(new_bal.get("soul_shards", GameSession.soul_shards))
			)
			GameSession.refresh_waifus()

			var pity_data = data.get("pity", {})
			if pity_data is Dictionary and pity_data.size() > 0:
				var pull_cnt = int(pity_data.get("pull_count", 0))
				pity_bar.value = pull_cnt
				pity_label.text = "Гарант SSR/UR: " + str(pull_cnt) + " / " + str(int(pity_bar.max_value))

			pending_drops = drops

			if count == 1:
				btn_mode_toggle.visible = false
				btn_next_pull.visible = false
				_start_single_roulette(drops[0])
			else:
				btn_mode_toggle.visible = true
				_update_mode_toggle_buttons()
				if is_sequential_mode:
					sequential_index = 0
					_start_single_roulette(drops[0])
				else:
					btn_next_pull.visible = false
					_start_multi_roulette(drops)
		else:
			is_summoning = false
			btn_pull_1.disabled = false
			btn_pull_10.disabled = false
			var err = "Не удалось открыть кейс"
			if data is Dictionary:
				err = data.get("error", err)
			elif data is String and data != "":
				err = data
			GameSession.show_toast(err, false)
	)

func _start_single_roulette(drop: Dictionary) -> void:
	single_current_drop = drop
	single_winning_char = drop.get("character", {})
	var winning_rarity = single_winning_char.get("rarity", "R")

	var case_name = cases[current_case_index].get("name", "Кейс")
	if pending_drops.size() > 1 and is_sequential_mode:
		overlay_title.text = "🎰 КЕЙС " + str(sequential_index + 1) + " из " + str(pending_drops.size())
	else:
		overlay_title.text = "🎰 ОТКРЫТИЕ: " + case_name.to_upper()
	overlay_subtitle.text = "Испытай удачу... Смотри на указатель!"

	summoning_overlay.visible = true
	summoning_overlay.modulate.a = 1.0
	single_roulette_container.visible = true
	multi_roulette_container.visible = false
	single_near_miss_banner.visible = false
	btn_next_pull.visible = false

	# Setup tape items with near-miss placement
	var pool_chars = _get_pool_characters()
	single_tape_items.clear()
	for i in range(SINGLE_TOTAL_CARDS):
		if i == SINGLE_WIN_INDEX:
			single_tape_items.append(single_winning_char)
		elif i == SINGLE_WIN_INDEX - 1:
			# If winner is not gold, place a tempting UR/SSR right before it for suspense
			if not (winning_rarity in ["SSR", "UR"]):
				single_tape_items.append(_get_high_tier_character(pool_chars))
			else:
				single_tape_items.append(pool_chars.pick_random())
		elif i == SINGLE_WIN_INDEX + 1:
			# Also put high tier after the winner
			if not (winning_rarity in ["SSR", "UR"]) and randf() < 0.6:
				single_tape_items.append(_get_high_tier_character(pool_chars))
			else:
				single_tape_items.append(pool_chars.pick_random())
		else:
			single_tape_items.append(pool_chars.pick_random())

	# Clear and rebuild cards in TapeStrip
	for child in single_tape_strip.get_children():
		single_tape_strip.remove_child(child)
		child.queue_free()

	var step = SINGLE_CARD_WIDTH + SINGLE_CARD_GAP
	for i in range(single_tape_items.size()):
		var card = _create_roulette_card(single_tape_items[i], Vector2(SINGLE_CARD_WIDTH, SINGLE_CARD_HEIGHT), false)
		card.position = Vector2(i * step, 0)
		single_tape_strip.add_child(card)

	# Calculate exact target stop position under center needle (v_c = 750.0 in 1500px TapeFrame)
	var v_c = 750.0
	# Natural jitter inside winning card so it lands organically within bounds
	var jitter = randf_range(-SINGLE_CARD_WIDTH * 0.28, SINGLE_CARD_WIDTH * 0.28)
	single_target_scroll = (SINGLE_WIN_INDEX * step) + (SINGLE_CARD_WIDTH / 2.0) + jitter - v_c

	single_tape_strip.position.x = 0.0
	single_spin_elapsed = 0.0
	single_last_ticked_idx = -1
	is_single_spinning = true

	AudioManager.play_sfx_roulette_spin()

func _on_single_roulette_finished(drop: Dictionary) -> void:
	AudioManager.play_sfx_roulette_stop()

	var char_data = drop.get("character", {})
	var rarity = char_data.get("rarity", "R")
	var is_top_tier = (rarity in ["SSR", "UR"])

	# Direct O(1) winning card punch animation
	if SINGLE_WIN_INDEX < single_tape_strip.get_child_count():
		var winning_card = single_tape_strip.get_child(SINGLE_WIN_INDEX) as Control
		if winning_card:
			winning_card.pivot_offset = winning_card.size / 2.0
			var t = create_tween()
			t.tween_property(winning_card, "scale", Vector2(1.18, 1.18), 0.15).set_trans(Tween.TRANS_BACK)
			t.tween_property(winning_card, "scale", Vector2.ONE, 0.2)

	# Suspenseful Near-Miss check: if player missed a gold card by 1 slot!
	var near_miss_occurred = false
	if not is_top_tier:
		var prev_card = single_tape_items[SINGLE_WIN_INDEX - 1] if SINGLE_WIN_INDEX > 0 else {}
		var next_card = single_tape_items[SINGLE_WIN_INDEX + 1] if SINGLE_WIN_INDEX + 1 < single_tape_items.size() else {}
		var missed_char = {}
		if prev_card.get("rarity") in ["SSR", "UR"]:
			missed_char = prev_card
		elif next_card.get("rarity") in ["SSR", "UR"]:
			missed_char = next_card

		if not missed_char.is_empty():
			near_miss_occurred = true
			AudioManager.play_sfx_near_miss()
			_flash_near_miss(missed_char.get("name", "Редкий персонаж"), missed_char.get("rarity", "SSR"))
			_screen_shake(7.0, 0.35)

	# Rarity explosion feedback
	if is_top_tier:
		_screen_shake(15.0, 0.6)
		vortex_particles.color = StyleHelper.get_rarity_color(rarity)
		vortex_particles.emitting = true
		AudioManager.play_sfx_burst(rarity)
		single_status_text.text = "★ СВЕРХРЕДКИЙ ДЖЕКПОТ! РАНГ " + rarity + "! ★"
	elif not near_miss_occurred:
		AudioManager.play_sfx_burst(rarity)
		single_status_text.text = "★ ВЫИГРЫШ: " + char_data.get("name", "") + " ★"

	# Short suspense delay to absorb the win
	var timer = get_tree().create_timer(0.9)
	timer.timeout.connect(func():
		if not is_summoning:
			return
		_show_single_card_reveal(drop)
	)

func _start_multi_roulette(drops: Array) -> void:
	overlay_title.text = "🎰 МУЛЬТИ-ПРИЗЫВ (10 КЕЙСОВ ОДНОВРЕМЕННО)"
	overlay_subtitle.text = "Все 10 барабанов крутятся синхронно... Лови легендарный дроп!"

	summoning_overlay.visible = true
	summoning_overlay.modulate.a = 1.0
	single_roulette_container.visible = false
	multi_roulette_container.visible = true

	# Clear previous grid slots
	for child in multi_grid.get_children():
		multi_grid.remove_child(child)
		child.queue_free()

	multi_reels_data.clear()
	multi_last_global_tick_time = 0.0
	var pool_chars = _get_pool_characters()

	# Create 10 parallel spinning mini-reels
	for k in range(drops.size()):
		var reel_data = _create_multi_reel_slot(k, drops, pool_chars)
		multi_reels_data.append(reel_data)

	is_multi_spinning = true
	AudioManager.play_sfx_roulette_spin()

func _create_multi_reel_slot(index: int, drops: Array, pool_chars: Array) -> Dictionary:
	var drop = drops[index]
	var winning_char = drop.get("character", {})
	var winning_rarity = winning_char.get("rarity", "R")

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 105)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.08, 0.14, 0.95)
	style.set_corner_radius_all(10)
	style.set_border_width_all(2)
	style.border_color = Color(0.25, 0.22, 0.35, 0.8)
	panel.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	var badge = Label.new()
	badge.text = "#" + str(index + 1)
	badge.custom_minimum_size = Vector2(45, 0)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color(0.7, 0.7, 0.85))
	hbox.add_child(badge)

	# Mini tape viewport
	var mini_vp = Control.new()
	mini_vp.clip_contents = true
	mini_vp.custom_minimum_size = Vector2(580, 95)
	mini_vp.size = Vector2(580, 95)
	hbox.add_child(mini_vp)

	var mini_tape = Control.new()
	mini_tape.anchors_preset = Control.PRESET_FULL_RECT
	mini_vp.add_child(mini_tape)

	# Mini tape vignettes
	var l_fade = TextureRect.new()
	l_fade.custom_minimum_size = Vector2(60, 0)
	l_fade.anchors_preset = Control.PRESET_LEFT_WIDE
	l_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l_fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var g_l = Gradient.new()
	g_l.colors = PackedColorArray([Color(0.09, 0.08, 0.14, 0.95), Color(0.09, 0.08, 0.14, 0.0)])
	var t_l = GradientTexture2D.new()
	t_l.gradient = g_l
	t_l.width = 60
	t_l.height = 1
	l_fade.texture = t_l
	mini_vp.add_child(l_fade)

	var r_fade = TextureRect.new()
	r_fade.custom_minimum_size = Vector2(60, 0)
	r_fade.anchors_preset = Control.PRESET_RIGHT_WIDE
	r_fade.offset_left = -60.0
	r_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r_fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var g_r = Gradient.new()
	g_r.colors = PackedColorArray([Color(0.09, 0.08, 0.14, 0.0), Color(0.09, 0.08, 0.14, 0.95)])
	var t_r = GradientTexture2D.new()
	t_r.gradient = g_r
	t_r.width = 60
	t_r.height = 1
	r_fade.texture = t_r
	mini_vp.add_child(r_fade)

	# Build mini tape items
	var tape_items = []
	for i in range(MINI_TOTAL_CARDS):
		if i == MINI_WIN_INDEX:
			tape_items.append(winning_char)
		elif i == MINI_WIN_INDEX - 1:
			if not (winning_rarity in ["SSR", "UR"]):
				tape_items.append(_get_high_tier_character(pool_chars))
			else:
				tape_items.append(pool_chars.pick_random())
		else:
			tape_items.append(pool_chars.pick_random())

	var mini_step = MINI_CARD_WIDTH + MINI_CARD_GAP
	for i in range(tape_items.size()):
		var card = _create_roulette_card(tape_items[i], Vector2(MINI_CARD_WIDTH, MINI_CARD_HEIGHT), true)
		card.position = Vector2(i * mini_step, 0)
		mini_tape.add_child(card)

	# Mini center needle
	var needle = Control.new()
	needle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	needle.anchors_preset = Control.PRESET_FULL_RECT
	mini_vp.add_child(needle)

	var mini_laser = ColorRect.new()
	mini_laser.color = Color(1, 0.85, 0.2, 0.9)
	mini_laser.custom_minimum_size = Vector2(2, 0)
	mini_laser.anchors_preset = Control.PRESET_CENTER
	mini_laser.anchor_left = 0.5
	mini_laser.anchor_right = 0.5
	mini_laser.anchor_bottom = 1.0
	mini_laser.offset_left = -1
	mini_laser.offset_right = 1
	mini_laser.mouse_filter = Control.MOUSE_FILTER_IGNORE
	needle.add_child(mini_laser)

	var top_p = Label.new()
	top_p.text = "▼"
	top_p.anchors_preset = Control.PRESET_CENTER_TOP
	top_p.anchor_left = 0.5
	top_p.anchor_right = 0.5
	top_p.offset_left = -10
	top_p.offset_right = 10
	top_p.offset_top = -4
	top_p.add_theme_font_size_override("font_size", 14)
	top_p.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	top_p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_p.pivot_offset = Vector2(10, 0)
	needle.add_child(top_p)

	var bot_p = Label.new()
	bot_p.text = "▲"
	bot_p.anchors_preset = Control.PRESET_CENTER_BOTTOM
	bot_p.anchor_left = 0.5
	bot_p.anchor_right = 0.5
	bot_p.anchor_bottom = 1.0
	bot_p.offset_left = -10
	bot_p.offset_right = 10
	bot_p.offset_top = -18
	bot_p.add_theme_font_size_override("font_size", 14)
	bot_p.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	bot_p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bot_p.pivot_offset = Vector2(10, 14)
	needle.add_child(bot_p)

	var status_lbl = Label.new()
	status_lbl.text = "Крутится..."
	status_lbl.custom_minimum_size = Vector2(110, 0)
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_lbl.add_theme_font_size_override("font_size", 12)
	status_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	hbox.add_child(status_lbl)

	multi_grid.add_child(panel)

	var vp_w = 580.0
	var v_c = vp_w / 2.0
	var jitter = randf_range(-MINI_CARD_WIDTH * 0.25, MINI_CARD_WIDTH * 0.25)
	var target_scroll = (MINI_WIN_INDEX * mini_step) + (MINI_CARD_WIDTH / 2.0) + jitter - v_c
	var dur = 2.4 + float(index) * 0.24

	return {
		"panel": panel,
		"tape": mini_tape,
		"needle_top": top_p,
		"needle_bottom": bot_p,
		"status_label": status_lbl,
		"badge": badge,
		"items": tape_items,
		"winner": winning_char,
		"drop": drop,
		"target": target_scroll,
		"duration": dur,
		"elapsed": 0.0,
		"stopped": false,
		"last_tick": -1,
		"step": mini_step,
		"v_c": v_c
	}

func _on_mini_reel_stopped(d: Dictionary) -> void:
	AudioManager.play_sfx_roulette_stop()
	var winner = d["winner"]
	var rarity = winner.get("rarity", "R")
	var is_top = (rarity in ["SSR", "UR"])
	var glow = StyleHelper.get_rarity_glow_color(rarity)
	var col = StyleHelper.get_rarity_color(rarity)

	var style = d["panel"].get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		var new_style = style.duplicate() as StyleBoxFlat
		new_style.border_color = glow
		new_style.set_border_width_all(3 if is_top else 2)
		if is_top:
			new_style.shadow_size = 14
			new_style.shadow_color = Color(col.r, col.g, col.b, 0.6)
		d["panel"].add_theme_stylebox_override("panel", new_style)

	d["status_label"].text = "★ " + rarity + " ★\n" + winner.get("name", "")
	d["status_label"].add_theme_color_override("font_color", col)
	d["badge"].add_theme_color_override("font_color", col)

	if is_top:
		AudioManager.play_sfx_burst(rarity)
		_screen_shake(6.0, 0.3)

func _on_all_multi_reels_stopped() -> void:
	overlay_subtitle.text = "✨ Все кейсы открыты! Загрузка сводки..."
	var timer = get_tree().create_timer(0.9)
	timer.timeout.connect(func():
		if is_summoning:
			show_results_summary(pending_drops)
	)

func _on_skip_summoning() -> void:
	is_single_spinning = false
	is_multi_spinning = false
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		summoning_overlay.position = Vector2.ZERO
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()
		single_near_miss_banner.visible = false
	show_results_summary(pending_drops)

func _on_multi_mode_toggle_pressed() -> void:
	AudioManager.play_sfx_click()
	is_sequential_mode = not is_sequential_mode
	_update_mode_toggle_buttons()

func _update_mode_toggle_buttons() -> void:
	if is_sequential_mode:
		btn_multi_mode_main.text = "⏩ 10x: По очереди (CS:GO)"
		StyleHelper.apply_button_style(btn_multi_mode_main, StyleHelper.COLOR_ACCENT_PINK, 12)
		btn_mode_toggle.text = "⏩ Режим: По одному"
		StyleHelper.apply_button_style(btn_mode_toggle, StyleHelper.COLOR_ACCENT_PINK, 10)
	else:
		btn_multi_mode_main.text = "⚡ 10x: Барабаны сразу"
		StyleHelper.apply_button_style(btn_multi_mode_main, StyleHelper.COLOR_ACCENT_GOLD, 12)
		btn_mode_toggle.text = "⚡ Режим: 10x Сразу"
		StyleHelper.apply_button_style(btn_mode_toggle, StyleHelper.COLOR_ACCENT_GOLD, 10)

func _advance_sequential_pull() -> void:
	AudioManager.play_sfx_click()
	if is_sequential_mode and sequential_index < pending_drops.size() - 1:
		single_reveal_overlay.visible = false
		sequential_index += 1
		_start_single_roulette(pending_drops[sequential_index])
	else:
		single_reveal_overlay.visible = false
		show_results_summary(pending_drops)

func _show_single_card_reveal(drop: Dictionary) -> void:
	var char_data = drop.get("character", {})
	var rarity = char_data.get("rarity", "R")
	var is_dup = drop.get("is_duplicate", false)
	var shards = drop.get("shards_awarded", 0)

	single_reveal_overlay.visible = true
	single_reveal_overlay.modulate.a = 0.0

	# Top action buttons for multi sequential pulls
	if is_sequential_mode and pending_drops.size() > 1:
		btn_reveal_next.visible = true
		btn_reveal_skip_all.visible = true
		if sequential_index < pending_drops.size() - 1:
			btn_reveal_next.text = "Следующий (" + str(sequential_index + 2) + "/" + str(pending_drops.size()) + ") ▶"
			tap_to_continue_label.text = "Нажмите в любом месте или Пробел для следующего кейса ▶"
		else:
			btn_reveal_next.text = "Сводка результатов ▶"
			tap_to_continue_label.text = "Нажмите в любом месте для перехода к результатам ▶"
	else:
		btn_reveal_next.visible = false
		btn_reveal_skip_all.visible = false
		tap_to_continue_label.text = "Нажмите в любом месте, чтобы продолжить ▶"

	var char_id = char_data.get("id", "")
	var tex = GameSession.get_character_texture(char_id)
	single_portrait.texture = tex

	StyleHelper.apply_panel_style(single_card_holder, StyleHelper.get_rarity_glow_color(rarity), 16, 0.95)
	single_portrait.material = StyleHelper.get_holographic_material(rarity)

	single_rarity_badge.text = "★ " + rarity + " ★"
	single_rarity_badge.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
	single_name_label.text = char_data.get("name", "")
	single_franchise_label.text = char_data.get("franchise", "")

	var dialogues = char_data.get("dialogues", {})
	single_quote_label.text = "«" + dialogues.get("greeting", "Рада встрече с тобой!") + "»"

	if is_dup:
		single_duplicate_label.text = "Дубликат: +" + str(shards) + " 🔮 Осколков Души"
		single_duplicate_label.visible = true
	else:
		single_duplicate_label.text = "✨ НОВЫЙ ПЕРСОНАЖ В КОЛЛЕКЦИИ! ✨"
		single_duplicate_label.visible = true

	single_card_holder.pivot_offset = single_card_holder.size / 2.0 if single_card_holder.size.x > 0 else Vector2(190, 280)
	single_card_holder.scale = Vector2(0.0, 1.0)
	var tween = create_tween()
	tween.tween_property(single_reveal_overlay, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(single_card_holder, "scale:x", 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		AudioManager.play_sfx_card_flip()
	)

func _on_single_reveal_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance_sequential_pull()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_advance_sequential_pull()

func show_results_summary(drops: Array) -> void:
	single_reveal_overlay.visible = false
	summoning_overlay.visible = false
	is_summoning = false
	is_single_spinning = false
	is_multi_spinning = false
	btn_pull_1.disabled = false
	btn_pull_10.disabled = false

	for child in cards_container.get_children():
		cards_container.remove_child(child)
		child.queue_free()

	result_title.text = "✨ РЕЗУЛЬТАТ ПРИЗЫВА (" + str(drops.size()) + ") ✨"

	for drop in drops:
		var char_data = drop.get("character", {})
		var rarity = char_data.get("rarity", "R")
		var is_dup = drop.get("is_duplicate", false)
		var shards = drop.get("shards_awarded", 0)

		var card = create_card_widget(char_data, rarity, is_dup, shards)
		cards_container.add_child(card)

	result_modal.visible = true
	result_modal.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(result_modal, "modulate:a", 1.0, 0.25)

func create_card_widget(char_data: Dictionary, rarity: String, is_dup: bool, shards: int) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(230, 320)
	panel.add_theme_stylebox_override("panel", StyleHelper.create_card_frame(rarity, 14))

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var portrait_container = PanelContainer.new()
	portrait_container.custom_minimum_size = Vector2(0, 180)
	portrait_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inner_style = StyleBoxFlat.new()
	inner_style.set_corner_radius_all(10)
	inner_style.bg_color = Color(0.05, 0.05, 0.08, 0.8)
	portrait_container.add_theme_stylebox_override("panel", inner_style)
	vbox.add_child(portrait_container)

	var char_id = char_data.get("id", "")
	var tex = GameSession.get_character_texture(char_id)
	if tex:
		var img_rect = TextureRect.new()
		img_rect.texture = tex
		img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		img_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		img_rect.material = StyleHelper.get_holographic_material(rarity)
		portrait_container.add_child(img_rect)
	else:
		var icon_label = Label.new()
		icon_label.text = "🌸"
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_label.add_theme_font_size_override("font_size", 64)
		icon_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		portrait_container.add_child(icon_label)

	var rarity_badge = Label.new()
	rarity_badge.text = "★ " + rarity + " ★"
	rarity_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_badge.add_theme_font_size_override("font_size", 16)
	rarity_badge.add_theme_color_override("font_color", StyleHelper.get_rarity_color(rarity))
	vbox.add_child(rarity_badge)

	var name_label = Label.new()
	name_label.text = char_data.get("name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(name_label)

	var fran_label = Label.new()
	fran_label.text = char_data.get("franchise", "")
	fran_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fran_label.add_theme_font_size_override("font_size", 12)
	fran_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(fran_label)

	if is_dup:
		var dup_label = Label.new()
		dup_label.text = "Дубликат +" + str(shards) + " 🔮"
		dup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dup_label.add_theme_font_size_override("font_size", 12)
		dup_label.add_theme_color_override("font_color", Color(0.8, 0.45, 1.0))
		vbox.add_child(dup_label)
	else:
		var new_label = Label.new()
		new_label.text = "✨ НОВИНКА! ✨"
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.add_theme_font_size_override("font_size", 12)
		new_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		vbox.add_child(new_label)

	return panel

func _create_roulette_card(char_data: Dictionary, card_size: Vector2, is_mini: bool = false) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = card_size
	panel.size = card_size
	var rarity = char_data.get("rarity", "R")
	var is_top_tier = (rarity in ["SSR", "UR"])
	var glow_color = StyleHelper.get_rarity_glow_color(rarity)
	var rarity_color = StyleHelper.get_rarity_color(rarity)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.06, 0.11, 0.95)
	style.set_corner_radius_all(6 if is_mini else 12)
	style.set_border_width_all(3 if is_top_tier else 2)
	style.border_color = glow_color
	if is_top_tier:
		style.shadow_size = 12 if is_mini else 22
		style.shadow_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.55)
	else:
		style.shadow_size = 3
		style.shadow_color = Color(0, 0, 0, 0.35)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	var pad = 4 if is_mini else 8
	margin.add_theme_constant_override("margin_left", pad)
	margin.add_theme_constant_override("margin_right", pad)
	margin.add_theme_constant_override("margin_top", pad)
	margin.add_theme_constant_override("margin_bottom", pad)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3 if is_mini else 6)
	margin.add_child(vbox)

	var portrait_box = PanelContainer.new()
	portrait_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inner_box = StyleBoxFlat.new()
	inner_box.set_corner_radius_all(4 if is_mini else 8)
	inner_box.bg_color = Color(0.04, 0.04, 0.07, 0.8)
	portrait_box.add_theme_stylebox_override("panel", inner_box)
	vbox.add_child(portrait_box)

	var char_id = char_data.get("id", "")
	var tex = GameSession.get_character_texture(char_id)
	if tex:
		var img = TextureRect.new()
		img.texture = tex
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		img.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if is_top_tier:
			img.material = StyleHelper.get_holographic_material(rarity)
		portrait_box.add_child(img)
	else:
		var lbl = Label.new()
		lbl.text = "🌸"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 28 if is_mini else 48)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		portrait_box.add_child(lbl)

	var bar = ColorRect.new()
	bar.custom_minimum_size = Vector2(0, 3 if is_mini else 5)
	bar.color = rarity_color
	vbox.add_child(bar)

	if not is_mini:
		var rarity_badge = Label.new()
		rarity_badge.text = "★ " + rarity + " ★"
		rarity_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rarity_badge.add_theme_font_size_override("font_size", 13)
		rarity_badge.add_theme_color_override("font_color", rarity_color)
		vbox.add_child(rarity_badge)

		var name_lbl = Label.new()
		name_lbl.text = char_data.get("name", "")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.clip_text = true
		name_lbl.add_theme_font_size_override("font_size", 14)
		vbox.add_child(name_lbl)
	else:
		var mini_lbl = Label.new()
		mini_lbl.text = rarity + " " + char_data.get("name", "")
		mini_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mini_lbl.clip_text = true
		mini_lbl.add_theme_font_size_override("font_size", 10)
		mini_lbl.add_theme_color_override("font_color", rarity_color)
		vbox.add_child(mini_lbl)

	return panel

func _get_pool_characters() -> Array:
	var pool_chars: Array = []
	if current_case_index >= 0 and current_case_index < cases.size():
		var pool_ids = cases[current_case_index].get("pool", [])
		for cid in pool_ids:
			if GameSession.all_characters_catalog.has(cid):
				pool_chars.append(GameSession.all_characters_catalog[cid])

	if pool_chars.is_empty():
		for c in GameSession.all_characters_catalog.values():
			pool_chars.append(c)

	if pool_chars.is_empty():
		pool_chars = [
			{"id": "raiden_genshin", "name": "Райдэн Сёгун", "rarity": "UR", "franchise": "Genshin Impact"},
			{"id": "violet_evergarden", "name": "Вайолет Эвергарден", "rarity": "UR", "franchise": "Violet Evergarden"},
			{"id": "frieren_magic", "name": "Фрирен", "rarity": "UR", "franchise": "Frieren: Beyond Journey's End"},
			{"id": "makima_csm", "name": "Макима", "rarity": "UR", "franchise": "Chainsaw Man"},
			{"id": "kurumi_tokisaki", "name": "Куруми Токисаки", "rarity": "UR", "franchise": "Date A Live"},
			{"id": "rem_rezero", "name": "Рем", "rarity": "SSR", "franchise": "Re:Zero"},
			{"id": "asuka_eva", "name": "Аска Лэнгли", "rarity": "SSR", "franchise": "Evangelion"},
			{"id": "saber_fate", "name": "Сейбер", "rarity": "SSR", "franchise": "Fate/stay night"},
			{"id": "madoka_magica", "name": "Мадока Канамэ", "rarity": "SSR", "franchise": "Madoka Magica"},
			{"id": "marin_kitagawa", "name": "Марин Китагава", "rarity": "SSR", "franchise": "My Dress-Up Darling"},
			{"id": "megumin_konosuba", "name": "Мэгумин", "rarity": "SSR", "franchise": "KonoSuba"},
			{"id": "aqua_konosuba", "name": "Аква", "rarity": "SSR", "franchise": "KonoSuba"},
			{"id": "nezuko_demonslayer", "name": "Недзуко Камадо", "rarity": "SSR", "franchise": "Demon Slayer"},
			{"id": "holo_spice", "name": "Холо Мудрая", "rarity": "SSR", "franchise": "Spice and Wolf"},
			{"id": "hutao_genshin", "name": "Ху Тао", "rarity": "SR", "franchise": "Genshin Impact"},
			{"id": "emilia_rezero", "name": "Эмилия", "rarity": "SR", "franchise": "Re:Zero"},
			{"id": "rei_eva", "name": "Рей Аянами", "rarity": "SR", "franchise": "Evangelion"},
			{"id": "yor_spy", "name": "Йор Форджер", "rarity": "SR", "franchise": "Spy x Family"},
			{"id": "sinon_sao", "name": "Синон", "rarity": "SR", "franchise": "Sword Art Online"},
			{"id": "chisato_lycoris", "name": "Чисато Нишикиги", "rarity": "SR", "franchise": "Lycoris Recoil"},
			{"id": "anya_spy", "name": "Аня Форджер", "rarity": "SR", "franchise": "Spy x Family"},
			{"id": "hinata_naruto", "name": "Хината Хьюга", "rarity": "R", "franchise": "Naruto"},
			{"id": "miku_vocaloid", "name": "Хацунэ Мику", "rarity": "R", "franchise": "Vocaloid"},
			{"id": "bocchi_hitori", "name": "Хитори Гото (Боччи)", "rarity": "R", "franchise": "Bocchi the Rock!"},
			{"id": "chika_fujiwara", "name": "Чика Фудзивара", "rarity": "R", "franchise": "Kaguya-sama: Love is War"}
		]
	return pool_chars

func _get_high_tier_character(pool_chars: Array) -> Dictionary:
	var urs = []
	var ssrs = []
	for c in pool_chars:
		if c.get("rarity") == "UR":
			urs.append(c)
		elif c.get("rarity") == "SSR":
			ssrs.append(c)
	if not urs.is_empty() and randf() < 0.4:
		return urs.pick_random()
	if not ssrs.is_empty():
		return ssrs.pick_random()
	if not urs.is_empty():
		return urs.pick_random()
	return pool_chars.pick_random() if not pool_chars.is_empty() else {}

func _kick_needle(top_ptr: Control, bot_ptr: Control, is_gold: bool) -> void:
	if not top_ptr or not bot_ptr:
		return
	# Physical mechanical clapper deflection & elastic snap-back
	var deflect = -0.32 if is_gold else -0.22
	top_ptr.rotation = deflect
	bot_ptr.rotation = -deflect
	top_ptr.modulate = Color(2.4, 2.0, 0.4) if is_gold else Color(1.35, 1.35, 1.35)
	bot_ptr.modulate = top_ptr.modulate

	var t = create_tween().set_parallel(true)
	t.tween_property(top_ptr, "rotation", 0.0, 0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(bot_ptr, "rotation", 0.0, 0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(top_ptr, "modulate", Color.WHITE, 0.14)
	t.tween_property(bot_ptr, "modulate", Color.WHITE, 0.14)

func _flash_near_miss(char_name: String, rarity: String = "SSR") -> void:
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()

	single_near_miss_banner.text = "⚡ ТАК БЛИЗКО! ЕДВА НЕ ВЫПАЛА " + char_name.to_upper() + " (" + rarity + ")! ⚡"
	single_near_miss_banner.visible = true
	single_near_miss_banner.modulate = Color(2.5, 0.35, 0.65)
	
	_banner_tween = create_tween()
	_banner_tween.tween_property(single_near_miss_banner, "modulate", Color.WHITE, 0.25)
	_banner_tween.tween_interval(2.0)
	_banner_tween.tween_property(single_near_miss_banner, "modulate:a", 0.0, 0.4)
	_banner_tween.tween_callback(func():
		single_near_miss_banner.visible = false
		single_near_miss_banner.modulate = Color.WHITE
	)

func _screen_shake(intensity: float = 8.0, duration: float = 0.4) -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		summoning_overlay.position = Vector2.ZERO

	_shake_tween = create_tween()
	var steps = 8
	for i in range(steps):
		var off = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)) * (1.0 - float(i) / steps)
		_shake_tween.tween_property(summoning_overlay, "position", off, duration / steps)
	_shake_tween.tween_property(summoning_overlay, "position", Vector2.ZERO, 0.05)

func _set_children_mouse_ignore(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			continue
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_ignore(child)

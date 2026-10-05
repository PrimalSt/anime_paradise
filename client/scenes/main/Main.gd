extends Control

@onready var coins_label: Label = $TopBar/MarginContainer/HBoxContainer/CoinsContainer/CoinsLabel
@onready var gems_label: Label = $TopBar/MarginContainer/HBoxContainer/GemsContainer/GemsLabel
@onready var shards_label: Label = $TopBar/MarginContainer/HBoxContainer/ShardsContainer/ShardsLabel
@onready var username_label: Label = $TopBar/MarginContainer/HBoxContainer/UserContainer/UsernameLabel
@onready var view_container: PanelContainer = $ContentArea
@onready var toast_panel: PanelContainer = $ToastOverlay/ToastPanel
@onready var toast_label: Label = $ToastOverlay/ToastPanel/ToastLabel
@onready var auth_dimmer: ColorRect = $AuthDimmer
@onready var auth_modal: PanelContainer = $AuthModal
@onready var modals_layer: CanvasLayer = $ModalsLayer

@onready var btn_gacha: Button = $BottomBar/HBoxContainer/BtnGacha
@onready var btn_roster: Button = $BottomBar/HBoxContainer/BtnRoster
@onready var btn_dorm: Button = $BottomBar/HBoxContainer/BtnDorm
@onready var btn_dating: Button = $BottomBar/HBoxContainer/BtnDating
@onready var btn_shop: Button = $BottomBar/HBoxContainer/BtnShop
@onready var btn_settings: Button = $TopBar/MarginContainer/HBoxContainer/BtnSettings
@onready var btn_logout: Button = $TopBar/MarginContainer/HBoxContainer/BtnLogout
@onready var settings_modal: Control = $SettingsModal
var current_view_node: Control = null
var current_tab: String = "gacha"
var _toast_tween: Tween = null

# Views scenes
var gacha_scene = preload("res://scenes/gacha/GachaView.tscn")
var roster_scene = preload("res://scenes/roster/RosterView.tscn")
var dorm_scene = preload("res://scenes/dorm/DormView.tscn")
var dating_scene = preload("res://scenes/dating/DatingView.tscn")
var shop_scene = preload("res://scenes/shop/ShopView.tscn")

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	toast_panel.visible = false
	auth_dimmer.visible = false
	auth_modal.visible = false
	settings_modal.visible = false

	# Apply theme and styling to TopBar and BottomBar
	StyleHelper.apply_panel_style($TopBar, StyleHelper.COLOR_PANEL_BORDER, 0, 0.95)
	StyleHelper.apply_panel_style($BottomBar, StyleHelper.COLOR_PANEL_BORDER, 0, 0.95)
	StyleHelper.apply_button_style(btn_logout, Color(0.6, 0.3, 0.4), 8)
	_update_nav_buttons()

	# Connect signals
	GameSession.balance_updated.connect(_on_balance_updated)
	GameSession.toast_requested.connect(_on_toast_requested)
	GameSession.view_switch_requested.connect(func(view_name: String): switch_view(view_name))
	NetworkManager.auth_state_changed.connect(_on_auth_state_changed)

	btn_gacha.pressed.connect(func(): switch_view("gacha"))
	btn_roster.pressed.connect(func(): switch_view("roster"))
	btn_dorm.pressed.connect(func(): switch_view("dorm"))
	btn_dating.pressed.connect(func(): switch_view("dating"))
	btn_shop.pressed.connect(func(): switch_view("shop"))
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_logout.pressed.connect(_on_logout_pressed)

	if NetworkManager.auth_token == "":
		show_auth_modal()
	else:
		username_label.text = NetworkManager.current_username
		GameSession.refresh_all_data()
		_check_daily_bonus()
		switch_view("gacha")

	_create_quests_button_and_modal()

func _create_quests_button_and_modal() -> void:
	# Add a quests button to top bar
	var hbox: HBoxContainer = $TopBar/MarginContainer/HBoxContainer
	var btn_quests = Button.new()
	btn_quests.text = "📋 Квесты"
	btn_quests.custom_minimum_size = Vector2(100, 36)
	StyleHelper.apply_button_style(btn_quests, StyleHelper.COLOR_ACCENT_PURPLE, 12)
	hbox.add_child(btn_quests)
	# Move it before settings
	hbox.move_child(btn_quests, hbox.get_child_count() - 3)

	var quest_badge = Label.new()
	quest_badge.name = "QuestBadge"
	quest_badge.text = "!"
	quest_badge.add_theme_font_size_override("font_size", 11)
	quest_badge.add_theme_color_override("font_color", Color.WHITE)
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color(0.9, 0.15, 0.15)
	badge_style.set_corner_radius_all(8)
	quest_badge.add_theme_stylebox_override("normal", badge_style)
	quest_badge.custom_minimum_size = Vector2(16, 16)
	quest_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	quest_badge.visible = false
	btn_quests.add_child(quest_badge)
	
	var q_timer = Timer.new()
	q_timer.wait_time = 60.0
	q_timer.autostart = true
	q_timer.timeout.connect(func():
		NetworkManager.request_api("/quests/", HTTPClient.METHOD_GET, null, func(ok, data):
			if ok and data is Array:
				var has_unclaimed = false
				for q in data:
					if q.get("completed", false) and not q.get("claimed", false):
						has_unclaimed = true
						break
				quest_badge.visible = has_unclaimed
		)
	)
	add_child(q_timer)

	btn_quests.pressed.connect(func():
		AudioManager.play_sfx_click()
		quest_badge.visible = false
		_open_quests_modal()
	)

	var btn_achievements = Button.new()
	btn_achievements.text = "🏆 Достижения"
	btn_achievements.custom_minimum_size = Vector2(120, 36)
	StyleHelper.apply_button_style(btn_achievements, StyleHelper.COLOR_ACCENT_GOLD, 12)
	hbox.add_child(btn_achievements)
	hbox.move_child(btn_achievements, hbox.get_child_count() - 4)

	btn_achievements.pressed.connect(func():
		AudioManager.play_sfx_click()
		_open_achievements_modal()
	)

func _open_quests_modal() -> void:
	if current_view_node != null and current_view_node.has_method("close_active_modal"):
		current_view_node.close_active_modal()
		
	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(500, 400)
	modal.set_anchors_preset(Control.PRESET_CENTER)
	modal.position = Vector2(1920/2.0 - 250, 1080/2.0 - 200)
	StyleHelper.apply_panel_style(modal, StyleHelper.COLOR_ACCENT_PURPLE, 16, 0.96)
	modals_layer.add_child(modal)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	modal.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	var title = Label.new()
	title.text = "📋 Ежедневные Квесты"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
	hbox.add_child(title)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	var close_btn = Button.new()
	close_btn.text = "✖️"
	StyleHelper.apply_button_style(close_btn, Color(0.6, 0.3, 0.35), 8)
	close_btn.pressed.connect(func():
		modal.queue_free()
	)
	hbox.add_child(close_btn)

	var list_vbox = VBoxContainer.new()
	list_vbox.add_theme_constant_override("separation", 10)
	vbox.add_child(list_vbox)
	
	NetworkManager.request_api("/quests/", HTTPClient.METHOD_GET, null, func(ok, data):
		if ok and data is Array:
			for q in data:
				var qbox = PanelContainer.new()
				var qstyle = StyleBoxFlat.new()
				qstyle.bg_color = Color(0.1, 0.1, 0.15, 0.8)
				qstyle.set_corner_radius_all(10)
				qbox.add_theme_stylebox_override("panel", qstyle)
				
				var qm = MarginContainer.new()
				qm.add_theme_constant_override("margin_left", 12)
				qm.add_theme_constant_override("margin_top", 8)
				qm.add_theme_constant_override("margin_right", 12)
				qm.add_theme_constant_override("margin_bottom", 8)
				qbox.add_child(qm)
				
				var qh = HBoxContainer.new()
				qh.add_theme_constant_override("separation", 10)
				qm.add_child(qh)
				
				var text_lbl = Label.new()
				text_lbl.text = q.get("desc", "") + "\n(" + str(q.get("progress", 0)) + "/" + str(q.get("target", 1)) + ")"
				text_lbl.add_theme_font_size_override("font_size", 14)
				text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				qh.add_child(text_lbl)
				
				var rew_lbl = Label.new()
				rew_lbl.text = str(q.get("reward_coins", 0)) + " 🪙 | " + str(q.get("reward_gems", 0)) + " 💎"
				rew_lbl.add_theme_font_size_override("font_size", 13)
				rew_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
				qh.add_child(rew_lbl)
				
				var claim_btn = Button.new()
				claim_btn.custom_minimum_size = Vector2(100, 32)
				
				if q.get("claimed", false):
					claim_btn.text = "Получено"
					claim_btn.disabled = true
					StyleHelper.apply_button_style(claim_btn, Color(0.3, 0.3, 0.3), 6)
				elif q.get("completed", false):
					claim_btn.text = "Забрать"
					StyleHelper.apply_button_style(claim_btn, StyleHelper.COLOR_ACCENT_GOLD, 6)
					claim_btn.pressed.connect(func():
						NetworkManager.request_api("/quests/claim", HTTPClient.METHOD_POST, {"quest_id": q["id"]}, func(ok2, data2):
							if ok2:
								AudioManager.play_sfx_coins()
								GameSession.show_toast(data2.get("message", "Награда получена"), true)
								claim_btn.text = "Получено"
								claim_btn.disabled = true
								StyleHelper.apply_button_style(claim_btn, Color(0.3, 0.3, 0.3), 6)
								var bal = data2.get("new_balance", {})
								GameSession.set_balances(bal.get("coins", GameSession.coins), bal.get("love_gems", GameSession.love_gems), GameSession.soul_shards)
						)
					)
				else:
					claim_btn.text = "В процессе"
					claim_btn.disabled = true
					StyleHelper.apply_button_style(claim_btn, Color(0.3, 0.3, 0.4), 6)
					
				qh.add_child(claim_btn)
				list_vbox.add_child(qbox)
	)

func _open_achievements_modal() -> void:
	if current_view_node != null and current_view_node.has_method("close_active_modal"):
		current_view_node.close_active_modal()
		
	var modal = PanelContainer.new()
	modal.custom_minimum_size = Vector2(540, 500)
	modal.set_anchors_preset(Control.PRESET_CENTER)
	modal.position = Vector2(1920/2.0 - 270, 1080/2.0 - 250)
	StyleHelper.apply_panel_style(modal, StyleHelper.COLOR_ACCENT_GOLD, 16, 0.96)
	modals_layer.add_child(modal)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	modal.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	var title = Label.new()
	title.text = "🏆 Достижения"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
	hbox.add_child(title)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	var close_btn = Button.new()
	close_btn.text = "✖️"
	StyleHelper.apply_button_style(close_btn, Color(0.6, 0.3, 0.35), 8)
	close_btn.pressed.connect(func():
		modal.queue_free()
	)
	hbox.add_child(close_btn)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	var list_vbox = VBoxContainer.new()
	list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(list_vbox)
	
	NetworkManager.request_api("/achievements/", HTTPClient.METHOD_GET, null, func(ok, data):
		if ok and data is Array:
			for a in data:
				var abox = PanelContainer.new()
				var astyle = StyleBoxFlat.new()
				astyle.bg_color = Color(0.15, 0.1, 0.1, 0.8) if a.get("claimed", false) else Color(0.2, 0.15, 0.1, 0.9)
				astyle.set_corner_radius_all(10)
				abox.add_theme_stylebox_override("panel", astyle)
				
				var am = MarginContainer.new()
				am.add_theme_constant_override("margin_left", 12)
				am.add_theme_constant_override("margin_top", 12)
				am.add_theme_constant_override("margin_right", 12)
				am.add_theme_constant_override("margin_bottom", 12)
				abox.add_child(am)
				
				var ah = HBoxContainer.new()
				ah.add_theme_constant_override("separation", 12)
				am.add_child(ah)
				
				var icon_lbl = Label.new()
				icon_lbl.text = a.get("icon", "🏆")
				icon_lbl.add_theme_font_size_override("font_size", 24)
				ah.add_child(icon_lbl)
				
				var text_vbox = VBoxContainer.new()
				text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				ah.add_child(text_vbox)
				
				var title_lbl = Label.new()
				title_lbl.text = a.get("title", "")
				title_lbl.add_theme_font_size_override("font_size", 16)
				title_lbl.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
				text_vbox.add_child(title_lbl)
				
				var desc_lbl = Label.new()
				desc_lbl.text = a.get("description", "")
				desc_lbl.add_theme_font_size_override("font_size", 13)
				desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
				text_vbox.add_child(desc_lbl)
				
				var rtype = a.get("reward_type", "coins")
				var cur_icon = "🪙"
				if rtype == "love_gems": cur_icon = "💎"
				elif rtype == "soul_shards": cur_icon = "🔮"
				
				var rew_lbl = Label.new()
				rew_lbl.text = "+" + str(a.get("reward", 0)) + " " + cur_icon
				rew_lbl.add_theme_font_size_override("font_size", 14)
				rew_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
				rew_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				ah.add_child(rew_lbl)
				
				var claim_btn = Button.new()
				claim_btn.custom_minimum_size = Vector2(110, 32)
				
				if a.get("unlocked", false) and a.get("claimed", false):
					claim_btn.text = "✅ Получено"
					claim_btn.disabled = true
					StyleHelper.apply_button_style(claim_btn, Color(0.3, 0.3, 0.3), 6)
				elif a.get("unlocked", false) and not a.get("claimed", false):
					claim_btn.text = "🎁 Забрать"
					StyleHelper.apply_button_style(claim_btn, StyleHelper.COLOR_ACCENT_GOLD, 6)
					claim_btn.pressed.connect(func():
						NetworkManager.request_api("/achievements/claim", HTTPClient.METHOD_POST, {"achievement_id": a["id"]}, func(ok2, data2):
							if ok2:
								AudioManager.play_sfx_coins()
								GameSession.show_toast("Получено: " + str(a.get("reward", 0)) + " " + cur_icon, true)
								claim_btn.text = "✅ Получено"
								claim_btn.disabled = true
								StyleHelper.apply_button_style(claim_btn, Color(0.3, 0.3, 0.3), 6)
								astyle.bg_color = Color(0.15, 0.1, 0.1, 0.8)
								var bal = data2.get("new_balance", {})
								GameSession.set_balances(bal.get("coins", GameSession.coins), bal.get("love_gems", GameSession.love_gems), GameSession.soul_shards)
						)
					)
				else:
					claim_btn.text = "🔒 Заблокировано"
					claim_btn.disabled = true
					StyleHelper.apply_button_style(claim_btn, Color(0.3, 0.3, 0.3), 6)
					
				ah.add_child(claim_btn)
				list_vbox.add_child(abox)
	)

func _on_auth_state_changed(is_logged_in: bool) -> void:
	if is_logged_in:
		auth_dimmer.visible = false
		auth_modal.visible = false
		username_label.text = NetworkManager.current_username
		_check_daily_bonus()
		switch_view("gacha")
	else:
		if current_view_node != null:
			current_view_node.queue_free()
			current_view_node = null
		username_label.text = ""
		coins_label.text = "0"
		gems_label.text = "0"
		shards_label.text = "0"
		show_auth_modal()

func _check_daily_bonus() -> void:
	NetworkManager.request_api("/auth/me", HTTPClient.METHOD_GET, null, func(ok, data):
		if ok and data.get("can_claim_daily_bonus", false):
			var modal = PanelContainer.new()
			modal.custom_minimum_size = Vector2(400, 300)
			modal.set_anchors_preset(Control.PRESET_CENTER)
			modal.position = Vector2(1920/2.0 - 200, 1080/2.0 - 150)
			StyleHelper.apply_panel_style(modal, StyleHelper.COLOR_ACCENT_PINK, 16, 0.96)
			modals_layer.add_child(modal)

			var margin = MarginContainer.new()
			margin.add_theme_constant_override("margin_left", 20)
			margin.add_theme_constant_override("margin_top", 20)
			margin.add_theme_constant_override("margin_right", 20)
			margin.add_theme_constant_override("margin_bottom", 20)
			modal.add_child(margin)

			var vbox = VBoxContainer.new()
			vbox.add_theme_constant_override("separation", 20)
			vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			margin.add_child(vbox)

			var title = Label.new()
			title.text = "🎁 Ежедневный бонус!"
			title.add_theme_font_size_override("font_size", 24)
			title.add_theme_color_override("font_color", StyleHelper.COLOR_ACCENT_GOLD)
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(title)

			var text = Label.new()
			text.text = "Сегодняшний бонус: +100 💎"
			text.add_theme_font_size_override("font_size", 18)
			text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(text)

			var claim_btn = Button.new()
			claim_btn.text = "Забрать!"
			StyleHelper.apply_button_style(claim_btn, StyleHelper.COLOR_ACCENT_GOLD, 12)
			claim_btn.pressed.connect(func():
				NetworkManager.request_api("/auth/daily-bonus", HTTPClient.METHOD_POST, null, func(ok2, data2):
					if ok2:
						AudioManager.play_sfx_ur()
						var bal = data2.get("new_balance", {})
						GameSession.set_balances(bal.get("coins", GameSession.coins), bal.get("love_gems", GameSession.love_gems), GameSession.soul_shards)
						GameSession.show_toast("Получено 100 💎!", true)
						modal.queue_free()
				)
			)
			vbox.add_child(claim_btn)

			var close_btn = Button.new()
			close_btn.text = "✖️ Закрыть"
			StyleHelper.apply_button_style(close_btn, Color(0.6, 0.3, 0.35), 8)
			close_btn.pressed.connect(func(): modal.queue_free())
			vbox.add_child(close_btn)
	)

func show_auth_modal() -> void:
	auth_dimmer.visible = true
	auth_modal.visible = true

func _on_logout_pressed() -> void:
	AudioManager.play_sfx_click()
	NetworkManager.clear_token()
	show_auth_modal()

func _on_settings_pressed() -> void:
	AudioManager.play_sfx_click()
	settings_modal.visible = true

func _on_balance_updated(coins: int, gems: int, shards: int) -> void:
	var prev_coins = int(coins_label.text)
	var prev_gems = int(gems_label.text)
	var prev_shards = int(shards_label.text)

	coins_label.text = str(coins)
	gems_label.text = str(gems)
	shards_label.text = str(shards)

	var animate = func(lbl, prev, curr):
		if curr == prev: return
		var tw = create_tween()
		var clr = Color(0.3, 1.0, 0.4) if curr > prev else Color(1.0, 0.3, 0.3)
		tw.tween_property(lbl, "modulate", clr, 0.15)
		tw.tween_property(lbl, "modulate", Color.WHITE, 0.3)
	
	animate.call(coins_label, prev_coins, coins)
	animate.call(gems_label, prev_gems, gems)
	animate.call(shards_label, prev_shards, shards)

func switch_view(view_name: String) -> void:
	if current_tab == view_name and current_view_node != null:
		return
	AudioManager.play_sfx_click()
	current_tab = view_name
	_update_nav_buttons()

	if current_view_node != null:
		current_view_node.queue_free()
		current_view_node = null

	var scene_to_load: PackedScene = null
	match view_name:
		"gacha":
			scene_to_load = gacha_scene
		"roster":
			scene_to_load = roster_scene
		"dorm":
			scene_to_load = dorm_scene
		"dating":
			scene_to_load = dating_scene
		"shop":
			scene_to_load = shop_scene

	if scene_to_load:
		current_view_node = scene_to_load.instantiate()
		current_view_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		current_view_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		view_container.add_child(current_view_node)

func _update_nav_buttons() -> void:
	var tabs = {
		"gacha": btn_gacha,
		"roster": btn_roster,
		"dorm": btn_dorm,
		"dating": btn_dating,
		"shop": btn_shop
	}
	
	for tab_id in tabs:
		var btn = tabs[tab_id] as Button
		if tab_id == current_tab:
			StyleHelper.apply_button_style(btn, StyleHelper.COLOR_ACCENT_PINK, 14)
		else:
			StyleHelper.apply_button_style(btn, Color(0.25, 0.22, 0.35), 14)

func _on_toast_requested(message: String, is_success: bool) -> void:
	toast_label.text = message
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(12)
	style.bg_color = Color(0.1, 0.45, 0.25, 0.95) if is_success else Color(0.65, 0.15, 0.2, 0.95)
	style.set_border_width_all(2)
	style.border_color = Color(0.3, 0.9, 0.5, 0.8) if is_success else Color(1.0, 0.3, 0.4, 0.8)
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.4)
	toast_panel.add_theme_stylebox_override("panel", style)
	
	toast_panel.visible = true
	toast_panel.modulate.a = 0.0
	
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()

	_toast_tween = create_tween()
	_toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.2)
	_toast_tween.tween_interval(2.5)
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.3)
	_toast_tween.tween_callback(func(): toast_panel.visible = false)

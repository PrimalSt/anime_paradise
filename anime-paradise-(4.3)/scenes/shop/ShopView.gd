extends Control

@onready var items_container: HFlowContainer = $VBoxContainer/Scroll/ItemsContainer
@onready var btn_tab_items: Button = $VBoxContainer/TabHBox/BtnItems
@onready var btn_tab_furniture: Button = $VBoxContainer/TabHBox/BtnFurniture

var current_tab: String = "items"
var shop_catalog: Dictionary = {}
var btn_tab_special: Button

var SPECIAL_OFFERS = [
	{"id": "dango_milk", "name": "Данго-молоко ⭐", "type": "food", "hunger_restore": 35, "affection_bonus": 15, "price": 35, "currency": "coins", "original_price": 50},
	{"id": "golden_ribbon", "name": "Золотая лента ⭐", "type": "gift", "affection_bonus": 40, "price": 210, "currency": "coins", "original_price": 300},
	{"id": "music_box", "name": "Музыкальная шкатулка ⭐", "type": "gift", "affection_bonus": 30, "price": 140, "currency": "coins", "original_price": 200},
]

const ITEM_ICONS = {
	"dango_milk": "🍡",
	"strawberry_cake": "🍰",
	"matcha_tea": "🍵",
	"spicy_ramen": "🍜",
	"curry_ramen": "🍜",
	"mapo_tofu": "🍲",
	"spicy_tofu": "🍲",
	"tea_buns": "🥟",
	"wagyu_steak": "🥩",
	"beef_steak": "🥩",
	"cinnamon_roll": "🥐",
	"miso_soup": "🥣",
	"golden_ribbon": "🎀",
	"music_box": "🎵",
	"cozy_bed": "🛏️",
	"plush_sofa": "🛋️",
	"tea_table": "🪑",
	"sakura_carpet": "🌸",
	"bonsai_plant": "🪴",
	"anime_poster": "🖼️",
	"crystal_chandelier": "💡"
}

func _ready() -> void:
	btn_tab_special = Button.new()
	btn_tab_special.text = "⭐ Акции"
	btn_tab_special.custom_minimum_size = Vector2(100, 32)
	$VBoxContainer/TabHBox.add_child(btn_tab_special)

	btn_tab_items.pressed.connect(func():
		AudioManager.play_sfx_click()
		current_tab = "items"
		update_tab_buttons()
		render_shop()
	)
	btn_tab_furniture.pressed.connect(func():
		AudioManager.play_sfx_click()
		current_tab = "furniture"
		update_tab_buttons()
		render_shop()
	)
	btn_tab_special.pressed.connect(func():
		AudioManager.play_sfx_click()
		current_tab = "special"
		update_tab_buttons()
		render_shop()
	)

	update_tab_buttons()
	load_shop()

func update_tab_buttons() -> void:
	StyleHelper.apply_button_style(btn_tab_items, Color(0.25, 0.22, 0.35), 12)
	StyleHelper.apply_button_style(btn_tab_furniture, Color(0.25, 0.22, 0.35), 12)
	StyleHelper.apply_button_style(btn_tab_special, Color(0.25, 0.22, 0.35), 12)
	
	if current_tab == "items":
		StyleHelper.apply_button_style(btn_tab_items, StyleHelper.COLOR_ACCENT_PINK, 12)
	elif current_tab == "furniture":
		StyleHelper.apply_button_style(btn_tab_furniture, StyleHelper.COLOR_ACCENT_GOLD, 12)
	elif current_tab == "special":
		StyleHelper.apply_button_style(btn_tab_special, StyleHelper.COLOR_ACCENT_CYAN, 12)

func load_shop() -> void:
	NetworkManager.get_shop_catalog(func(success: bool, data: Variant):
		if success and data is Dictionary:
			shop_catalog = data
			render_shop()
	)

func render_shop() -> void:
	for child in items_container.get_children():
		items_container.remove_child(child)
		child.queue_free()

	var list_to_show = []
	if current_tab == "special":
		list_to_show = SPECIAL_OFFERS
	else:
		list_to_show = shop_catalog.get(current_tab, [])
		
	for item in list_to_show:
		var card = create_item_card(item)
		items_container.add_child(card)

func create_item_card(item: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(270, 240)
	var accent = StyleHelper.COLOR_ACCENT_PINK if current_tab == "items" else StyleHelper.COLOR_ACCENT_GOLD
	if current_tab == "special": accent = StyleHelper.COLOR_ACCENT_GOLD
	StyleHelper.apply_panel_style(panel, accent, 14, 0.92)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	if current_tab == "special":
		var badge = Label.new()
		badge.text = "АКЦИЯ -30%"
		badge.add_theme_font_size_override("font_size", 14)
		badge.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(badge)

	var top_hbox = HBoxContainer.new()
	vbox.add_child(top_hbox)

	var icon_lbl = Label.new()
	var item_id = item.get("id", "")
	icon_lbl.text = ITEM_ICONS.get(item_id, "🎁")
	icon_lbl.add_theme_font_size_override("font_size", 28)
	top_hbox.add_child(icon_lbl)

	var title_lbl = Label.new()
	title_lbl.text = item.get("name", "")
	title_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(title_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = item.get("description", "")
	desc_lbl.custom_minimum_size = Vector2(0, 48)
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	var stats_lbl = Label.new()
	var itype = item.get("type", "")
	if itype == "food":
		stats_lbl.text = "Сытость: +" + str(item.get("hunger_restore", 0)) + " | Симпатия: +" + str(item.get("affection_bonus", 0))
	elif itype == "gift":
		stats_lbl.text = "Симпатия: +" + str(item.get("affection_bonus", 0)) + " ❤️"
	else:
		stats_lbl.text = "Уют в комнате: +" + str(item.get("comfort", 10)) + " 🛋️"
	stats_lbl.add_theme_font_size_override("font_size", 12)
	stats_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6))
	vbox.add_child(stats_lbl)

	var price = int(item.get("price", 50))
	var currency = item.get("currency", "coins")
	var curr_icon = "🪙" if currency == "coins" else "💎"

	if current_tab == "special" and item.has("original_price"):
		var orig_lbl = RichTextLabel.new()
		orig_lbl.bbcode_enabled = true
		orig_lbl.text = "[center][color=#999999][s]Старая цена: " + str(item.get("original_price")) + " " + curr_icon + "[/s][/color][/center]"
		orig_lbl.custom_minimum_size = Vector2(0, 18)
		orig_lbl.scroll_active = false
		vbox.add_child(orig_lbl)

	var btn_buy = Button.new()
	btn_buy.custom_minimum_size = Vector2(0, 40)
	btn_buy.text = "Купить (" + curr_icon + " " + str(price) + ")"
	StyleHelper.apply_button_style(btn_buy, StyleHelper.COLOR_ACCENT_CYAN, 10)
	btn_buy.pressed.connect(func():
		AudioManager.play_sfx_click()
		buy_item(item.get("id"), price, currency)
	)
	vbox.add_child(btn_buy)

	return panel

func buy_item(item_id: String, _price: int, _currency: String) -> void:
	NetworkManager.buy_shop_item(item_id, 1, func(success: bool, data: Variant):
		if success and data is Dictionary:
			AudioManager.play_sfx_coins()
			var new_bal = data.get("new_balance", {})
			GameSession.set_balances(
				int(new_bal.get("coins", GameSession.coins)),
				int(new_bal.get("love_gems", GameSession.love_gems)),
				GameSession.soul_shards
			)
			GameSession.show_toast("Предмет успешно куплен!", true)
		else:
			var err = "Недостаточно средств"
			if data is Dictionary:
				err = data.get("error", err)
			elif data is String and data != "":
				err = data
			GameSession.show_toast(err, false)
	)

extends Node

signal balance_updated(coins: int, love_gems: int, soul_shards: int)
signal waifus_updated(waifus: Array)
signal dorm_updated(dorm_data: Dictionary)
signal toast_requested(message: String, is_success: bool)
signal view_switch_requested(view_name: String)

var coins: int = 0
var love_gems: int = 0
var soul_shards: int = 0

var user_profile: Dictionary = {}
var user_waifus: Array = []
var all_characters_catalog: Dictionary = {}
var all_cases: Array = []
var current_dorm: Dictionary = {}
var user_inventory: Array = []
var preselected_dating_waifu_id: int = -1

var _texture_cache: Dictionary = {}

func switch_to_view(view_name: String) -> void:
	view_switch_requested.emit(view_name)

func get_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if _texture_cache.has(path):
		return _texture_cache[path]

	var tex: Texture2D = null

	# 1. Try standard ResourceLoader if imported
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			tex = res

	# 2. Direct disk loading fallback (loads JPG/PNG directly without needing Godot import)
	if tex == null:
		var global_path = ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(global_path) or FileAccess.file_exists(path):
			var img = Image.load_from_file(global_path)
			if img and not img.is_empty():
				tex = ImageTexture.create_from_image(img)

	if tex != null:
		_texture_cache[path] = tex
	return tex

func get_character_texture(char_id: String, outfit_id: String = "default") -> Texture2D:
	if char_id == "":
		return null
	if outfit_id != "" and outfit_id != "default":
		var out_jpg = "res://assets/characters/" + char_id + "_" + outfit_id + ".jpg"
		var out_png = "res://assets/characters/" + char_id + "_" + outfit_id + ".png"
		var tex = get_texture(out_jpg)
		if tex:
			return tex
		tex = get_texture(out_png)
		if tex:
			return tex
	var png_path = "res://assets/characters/" + char_id + ".png"
	var jpg_path = "res://assets/characters/" + char_id + ".jpg"
	var tex = get_texture(png_path)
	if tex:
		return tex
	return get_texture(jpg_path)

func get_background_texture(bg_id: String) -> Texture2D:
	if bg_id == "":
		return null
	if bg_id.begins_with("res://"):
		return get_texture(bg_id)
	var jpg_path = "res://assets/backgrounds/" + bg_id + ".jpg"
	var png_path = "res://assets/backgrounds/" + bg_id + ".png"
	if ResourceLoader.exists(jpg_path) or FileAccess.file_exists(ProjectSettings.globalize_path(jpg_path)):
		return get_texture(jpg_path)
	if ResourceLoader.exists(png_path) or FileAccess.file_exists(ProjectSettings.globalize_path(png_path)):
		return get_texture(png_path)
	return get_texture(jpg_path)

func _ready() -> void:
	NetworkManager.auth_state_changed.connect(_on_auth_state_changed)
	NetworkManager.network_error.connect(_on_network_error)

func _on_auth_state_changed(is_logged_in: bool) -> void:
	if is_logged_in:
		refresh_all_data()

func _on_network_error(msg: String) -> void:
	show_toast(msg, false)

func show_toast(msg: String, is_success: bool = true) -> void:
	toast_requested.emit(msg, is_success)

func set_balances(c: int, g: int, s: int) -> void:
	coins = c
	love_gems = g
	soul_shards = s
	balance_updated.emit(coins, love_gems, soul_shards)

func refresh_all_data() -> void:
	# 1. Fetch Profile
	NetworkManager.get_profile(func(success: bool, data: Variant):
		if success and data is Dictionary:
			user_profile = data
			set_balances(
				int(data.get("coins", 0)),
				int(data.get("love_gems", 0)),
				int(data.get("soul_shards", 0))
			)
			if data.get("can_claim_daily_bonus", false):
				NetworkManager.claim_daily_bonus(func(claim_success: bool, claim_data: Variant):
					if claim_success and claim_data is Dictionary:
						show_toast(claim_data.get("message", "Ежедневный бонус получен!"), true)
						set_balances(
							int(claim_data.get("coins", coins)),
							int(claim_data.get("love_gems", love_gems)),
							int(claim_data.get("soul_shards", soul_shards))
						)
				)
	)

	# 2. Fetch Catalog
	NetworkManager.get_catalog(func(success: bool, data: Variant):
		if success and data is Array:
			all_characters_catalog.clear()
			for c in data:
				if c is Dictionary and c.has("id"):
					all_characters_catalog[c["id"]] = c
	)

	# 3. Fetch User Waifus
	refresh_waifus()

	# 4. Fetch Cases
	NetworkManager.get_cases(func(success: bool, data: Variant):
		if success and data is Array:
			all_cases = data
	)

	# 5. Fetch Dorm
	refresh_dorm()

	# 6. Fetch Inventory
	refresh_inventory()

func refresh_inventory() -> void:
	NetworkManager.get_inventory(func(success: bool, data: Variant):
		if success and data is Array:
			user_inventory = data
	)

func refresh_waifus() -> void:
	NetworkManager.get_user_waifus(func(success: bool, data: Variant):
		if success and data is Array:
			user_waifus = data
			waifus_updated.emit(user_waifus)
	)

func refresh_dorm() -> void:
	NetworkManager.get_dorm(func(success: bool, data: Variant):
		if success and data is Dictionary:
			current_dorm = data
			dorm_updated.emit(current_dorm)
	)

func get_waifu_by_id(waifu_id: int) -> Dictionary:
	for w in user_waifus:
		if int(w.get("id", -1)) == waifu_id:
			return w
	return {}

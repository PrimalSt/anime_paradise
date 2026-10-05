extends Node

signal auth_state_changed(is_logged_in: bool)
signal network_error(error_message: String)

var base_url: String = "http://127.0.0.1:8000/api"
var auth_token: String = ""
var current_user_id: int = -1
var current_username: String = ""

const SAVE_PATH = "user://auth.save"

func _ready() -> void:
	load_saved_token()

func load_saved_token() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var text = file.get_as_text()
		var json = JSON.new()
		if json.parse(text) == OK:
			var data = json.data
			if data is Dictionary and data.has("token"):
				auth_token = data.get("token", "")
				current_username = data.get("username", "")
				current_user_id = int(data.get("user_id", -1))
				if auth_token != "":
					emit_signal("auth_state_changed", true)

func save_token(token: String, username: String, user_id: int) -> void:
	auth_token = token
	current_username = username
	current_user_id = user_id
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"token": token,
		"username": username,
		"user_id": user_id
	}
	file.store_string(JSON.stringify(data))
	emit_signal("auth_state_changed", true)

func clear_token() -> void:
	auth_token = ""
	current_username = ""
	current_user_id = -1
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	emit_signal("auth_state_changed", false)

func request_api(endpoint: String, method: int = HTTPClient.METHOD_GET, body: Variant = null, callback: Callable = Callable()) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var headers = PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json"
	])

	if auth_token != "":
		headers.append("Authorization: Bearer " + auth_token)

	var url = base_url + endpoint
	var body_string = ""
	if body != null:
		body_string = JSON.stringify(body)

	http_request.request_completed.connect(func(result: int, response_code: int, response_headers: PackedStringArray, response_body: PackedByteArray):
		var json_str = response_body.get_string_from_utf8()
		var parsed = null
		if json_str != "":
			var json = JSON.new()
			if json.parse(json_str) == OK:
				parsed = json.data

		if response_code >= 200 and response_code < 300:
			if callback.is_valid():
				callback.call(true, parsed)
		else:
			var error_msg = "Ошибка сервера (" + str(response_code) + ")"
			if parsed is Dictionary and parsed.has("detail"):
				error_msg = str(parsed["detail"])
			emit_signal("network_error", error_msg)
			if callback.is_valid():
				callback.call(false, {"error": error_msg, "code": response_code})

		http_request.queue_free()
	)

	var err = http_request.request(url, headers, method, body_string)
	if err != OK:
		emit_signal("network_error", "Не удалось отправить запрос: " + str(err))
		if callback.is_valid():
			callback.call(false, {"error": "Request failed"})
		http_request.queue_free()

# Convenience Methods
func login(username: String, password: String, callback: Callable) -> void:
	request_api("/auth/login", HTTPClient.METHOD_POST, {"username": username, "password": password}, func(success: bool, data: Variant):
		if success and data is Dictionary and data.has("access_token"):
			save_token(data["access_token"], data["username"], int(data["user_id"]))
		if callback.is_valid():
			callback.call(success, data)
	)

func register(username: String, password: String, callback: Callable) -> void:
	request_api("/auth/register", HTTPClient.METHOD_POST, {"username": username, "password": password}, func(success: bool, data: Variant):
		if success and data is Dictionary and data.has("access_token"):
			save_token(data["access_token"], data["username"], int(data["user_id"]))
		if callback.is_valid():
			callback.call(success, data)
	)

func guest_login(callback: Callable) -> void:
	request_api("/auth/guest", HTTPClient.METHOD_POST, {}, func(success: bool, data: Variant):
		if success and data is Dictionary and data.has("access_token"):
			save_token(data["access_token"], data["username"], int(data["user_id"]))
		if callback.is_valid():
			callback.call(success, data)
	)

func get_profile(callback: Callable) -> void:
	request_api("/auth/me", HTTPClient.METHOD_GET, null, callback)

func claim_daily_bonus(callback: Callable) -> void:
	request_api("/auth/daily-bonus", HTTPClient.METHOD_POST, null, callback)

func get_cases(callback: Callable) -> void:
	request_api("/gacha/cases", HTTPClient.METHOD_GET, null, callback)

func roll_case(case_id: String, count: int, callback: Callable) -> void:
	request_api("/gacha/roll", HTTPClient.METHOD_POST, {"case_id": case_id, "count": count}, callback)

func get_user_waifus(callback: Callable) -> void:
	request_api("/waifus/", HTTPClient.METHOD_GET, null, callback)

func get_catalog(callback: Callable) -> void:
	request_api("/waifus/catalog", HTTPClient.METHOD_GET, null, callback)

func headpat_waifu(waifu_id: int, callback: Callable) -> void:
	request_api("/waifus/" + str(waifu_id) + "/headpat", HTTPClient.METHOD_POST, {}, callback)

func feed_waifu(waifu_id: int, item_id: String, callback: Callable) -> void:
	request_api("/waifus/" + str(waifu_id) + "/feed", HTTPClient.METHOD_POST, {"item_id": item_id}, callback)

func equip_outfit(waifu_id: int, outfit_id: String, callback: Callable) -> void:
	request_api("/waifus/" + str(waifu_id) + "/equip-outfit", HTTPClient.METHOD_POST, {"outfit_id": outfit_id}, callback)

func unlock_outfit(waifu_id: int, outfit_id: String, callback: Callable) -> void:
	request_api("/waifus/" + str(waifu_id) + "/unlock-outfit", HTTPClient.METHOD_POST, {"outfit_id": outfit_id, "cost": 50}, callback)

func toggle_favorite(waifu_id: int, callback: Callable) -> void:
	request_api("/waifus/" + str(waifu_id) + "/favorite", HTTPClient.METHOD_POST, {}, callback)

func ascend_waifu(waifu_id: int, callback: Callable) -> void:
	request_api("/waifus/" + str(waifu_id) + "/ascend", HTTPClient.METHOD_POST, {}, callback)

func claim_milestone(waifu_id: int, milestone_level: int, callback: Callable) -> void:
	request_api("/waifus/" + str(waifu_id) + "/claim-milestone", HTTPClient.METHOD_POST, {"milestone_level": milestone_level}, callback)

func get_dorm(callback: Callable) -> void:
	request_api("/dorm/", HTTPClient.METHOD_GET, null, callback)

func collect_dorm_income(callback: Callable) -> void:
	request_api("/dorm/collect", HTTPClient.METHOD_POST, {}, callback)

func save_dorm_layout(furniture_layout: Array, callback: Callable) -> void:
	request_api("/dorm/layout", HTTPClient.METHOD_POST, {"furniture_layout": furniture_layout}, callback)

func assign_dorm_waifus(waifu_ids: Array, callback: Callable) -> void:
	request_api("/dorm/assign", HTTPClient.METHOD_POST, {"waifu_ids": waifu_ids}, callback)

func set_dorm_theme(theme: String, callback: Callable) -> void:
	request_api("/dorm/theme", HTTPClient.METHOD_POST, {"theme": theme}, callback)

func clean_dorm(callback: Callable) -> void:
	request_api("/dorm/clean", HTTPClient.METHOD_POST, {}, callback)


func get_dating_locations(callback: Callable) -> void:
	request_api("/dating/locations", HTTPClient.METHOD_GET, null, callback)

func start_date(waifu_id: int, location_id: String, callback: Callable) -> void:
	request_api("/dating/start", HTTPClient.METHOD_POST, {"waifu_id": waifu_id, "location_id": location_id}, callback)

func submit_date_choice(waifu_id: int, location_id: String, node_id: String, choice_index: int, callback: Callable) -> void:
	request_api("/dating/choice", HTTPClient.METHOD_POST, {
		"waifu_id": waifu_id,
		"location_id": location_id,
		"node_id": node_id,
		"choice_index": choice_index
	}, callback)

func get_shop_catalog(callback: Callable) -> void:
	request_api("/shop/catalog", HTTPClient.METHOD_GET, null, callback)

func get_inventory(callback: Callable) -> void:
	request_api("/shop/inventory", HTTPClient.METHOD_GET, null, callback)

func buy_shop_item(item_id: String, quantity: int, callback: Callable) -> void:
	request_api("/shop/buy", HTTPClient.METHOD_POST, {"item_id": item_id, "quantity": quantity}, callback)

extends PanelContainer

@onready var username_input: LineEdit = $MarginContainer/VBoxContainer/UsernameInput
@onready var password_input: LineEdit = $MarginContainer/VBoxContainer/PasswordInput
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var btn_login: Button = $MarginContainer/VBoxContainer/HBoxContainer/BtnLogin
@onready var btn_register: Button = $MarginContainer/VBoxContainer/HBoxContainer/BtnRegister
@onready var btn_guest: Button = $MarginContainer/VBoxContainer/BtnGuest

func _ready() -> void:
	StyleHelper.apply_panel_style(self, StyleHelper.COLOR_ACCENT_PINK, 18, 0.96)
	StyleHelper.apply_button_style(btn_login, StyleHelper.COLOR_ACCENT_PINK, 10)
	StyleHelper.apply_button_style(btn_register, StyleHelper.COLOR_ACCENT_CYAN, 10)
	StyleHelper.apply_button_style(btn_guest, StyleHelper.COLOR_ACCENT_GOLD, 10)

	var input_style = StyleBoxFlat.new()
	input_style.set_corner_radius_all(8)
	input_style.bg_color = Color(0.12, 0.11, 0.18, 0.9)
	input_style.set_border_width_all(1)
	input_style.border_color = Color(0.35, 0.3, 0.5, 0.7)
	username_input.add_theme_stylebox_override("normal", input_style)
	password_input.add_theme_stylebox_override("normal", input_style)

	btn_login.pressed.connect(_on_login)
	btn_register.pressed.connect(_on_register)
	btn_guest.pressed.connect(_on_guest)
	username_input.text_submitted.connect(func(_text): password_input.grab_focus())
	password_input.text_submitted.connect(func(_text): _on_login())

func _on_login() -> void:
	var u = username_input.text.strip_edges()
	var p = password_input.text
	if u == "" or p == "":
		status_label.text = "Заполните логин и пароль"
		return

	status_label.text = "Вход..."
	AudioManager.play_sfx_click()
	NetworkManager.login(u, p, func(success: bool, data: Variant):
		if success:
			status_label.text = ""
			password_input.text = ""
			visible = false
		else:
			var err = "Ошибка входа"
			if data is Dictionary:
				err = data.get("error", err)
			elif data is String and data != "":
				err = data
			status_label.text = err
	)

func _on_register() -> void:
	var u = username_input.text.strip_edges()
	var p = password_input.text
	if u == "" or p == "":
		status_label.text = "Заполните логин и пароль"
		return

	status_label.text = "Регистрация..."
	AudioManager.play_sfx_click()
	NetworkManager.register(u, p, func(success: bool, data: Variant):
		if success:
			status_label.text = ""
			password_input.text = ""
			visible = false
		else:
			var err = "Ошибка регистрации"
			if data is Dictionary:
				err = data.get("error", err)
			elif data is String and data != "":
				err = data
			status_label.text = err
	)

func _on_guest() -> void:
	status_label.text = "Создание гостевого аккаунта..."
	AudioManager.play_sfx_click()
	NetworkManager.guest_login(func(success: bool, data: Variant):
		if success:
			status_label.text = ""
			password_input.text = ""
			visible = false
		else:
			var err = "Ошибка создания гостя"
			if data is Dictionary:
				err = data.get("error", err)
			elif data is String and data != "":
				err = data
			status_label.text = err
	)

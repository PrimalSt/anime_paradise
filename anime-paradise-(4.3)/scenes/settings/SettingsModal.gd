extends Control

@onready var close_btn = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnClose
@onready var master_slider = $PanelContainer/MarginContainer/VBoxContainer/Sliders/MasterRow/MasterSlider
@onready var bgm_slider = $PanelContainer/MarginContainer/VBoxContainer/Sliders/BGMRow/BGMSlider
@onready var sfx_slider = $PanelContainer/MarginContainer/VBoxContainer/Sliders/SFXRow/SFXSlider

func _ready() -> void:
	StyleHelper.apply_panel_style($PanelContainer)
	
	close_btn.pressed.connect(_on_close)
	
	master_slider.value_changed.connect(_on_master_changed)
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	# Load current values
	master_slider.value = AudioManager.get_master_volume() * 100.0
	bgm_slider.value = AudioManager.get_bgm_volume() * 100.0
	sfx_slider.value = AudioManager.get_sfx_volume() * 100.0

func _on_close() -> void:
	AudioManager.play_sfx_click()
	visible = false

func _on_master_changed(value: float) -> void:
	AudioManager.set_master_volume(value / 100.0)

func _on_bgm_changed(value: float) -> void:
	AudioManager.set_bgm_volume(value / 100.0)

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value / 100.0)

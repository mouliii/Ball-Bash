extends Control

func _ready():
	Config.LoadSettings()
	$Options/Display_Mode/dp_mode.selected = Config.LoadValue("video_settings", "display_mode")
	$Options/MaxFps/fps_box.text = str(Config.LoadValue("video_settings", "max_fps"))
	$Options/fov/fov_box.text = str(Config.LoadValue("gameplay", "fov"))
	$Options/Vsync/vsync.pressed = Config.LoadValue("video_settings", "vsync")
	$Options/show_fps/showfps.pressed = Config.LoadValue("gameplay", "show_fps")
	$Options/bloom/bloom.pressed = Config.LoadValue("video_settings", "bloom")


func _on_vsync_toggled(button_pressed):
	Config.SaveSetting("video_settings", "vsync", button_pressed)


func _on_fps_box_text_changed(new_text):
	Config.SaveSetting("video_settings", "max_fps", int(new_text))


func _on_fps_slider_value_changed(value):
	Config.SaveSetting("video_settings", "max_fps", int(value))
	get_node("Options/MaxFps/fps_box").text = str(value)


func _on_bloom_toggled(button_pressed):
	Config.SaveSetting("video_settings", "bloom", button_pressed)


func _on_fov_slider_value_changed(value):
	Config.SaveSetting("gameplay", "fov", value)
	get_node("Options/fov/fov_box").text = str(value)


func _on_showfps_toggled(button_pressed):
	Config.SaveSetting("gameplay", "show_fps", button_pressed)


func _on_dp_mode_item_selected(index):
	Config.SaveSetting("video_settings", "display_mode", index)

func _on_SaveExit_pressed():
	Config.LoadSettings()
	hide()
	get_parent().get_node("MainMenuContainer").show()

func _on_Test_pressed():
	pass # Replace with function body.

func _on_fov_box_text_changed(new_text):
	Config.SaveSetting("gameplay", "fov", float(new_text))


extends Node

const filePath:String = "res://"
var fileName:String = "config.ini"

func SaveSetting(section:String, key:String, value)->void:
	var file = ConfigFile.new()
	var isOpen = file.load(filePath + fileName)
	if isOpen == OK:
		if file.has_section(section):
			if file.has_section_key(section, key):
				file.set_value(section, key, value)
				file.save(filePath + fileName)
			else:
				push_error("config: no section key found")
		else:
			push_error("config: no section found")

func LoadSettings()->void:
	var file = ConfigFile.new()
	var isOpen = file.load(filePath + fileName)
	if isOpen == OK:
		var dp = file.get_value("video_settings", "display_mode", null)
		match dp:
			0:
				OS.window_fullscreen = 0
				OS.window_borderless = 0
				OS.window_maximized = false
				#OS.window_size = Vector2(1024,600)
				#OS.window_position = OS.get_screen_size() / 4
			1:
				OS.window_fullscreen = 1
			2:
				OS.window_borderless = 1
				OS.window_maximized = true
		OS.vsync_enabled = file.get_value("video_settings", "vsync", 1)
		Engine.target_fps = file.get_value("video_settings", "max_fps", 144)
		# bloom? testaa scenessä?
		# fov sama kun ylemmässä?
		# fps mittari kait sama kuin ^
	else:
		CreateDefaultSettings()

func CreateDefaultSettings()->void:
	var file = ConfigFile.new()
	file.set_value("video_settings", "display_mode", 0)
	file.set_value("video_settings", "vsync", 0)
	file.set_value("video_settings", "max_fps", 144)
	file.set_value("video_settings", "bloom", 1)
	file.set_value("gameplay", "fov", 70)
	file.set_value("gameplay", "show_fps", 0)
	file.set_value("gameplay", "cart_color", Color(1,1,1,1))
	file.save(filePath + fileName)

func LoadValue(section:String, key:String):
	var file = ConfigFile.new()
	var isOpen = file.load(filePath + fileName)
	if isOpen == OK:
		return file.get_value(section, key)
	else:
		return null

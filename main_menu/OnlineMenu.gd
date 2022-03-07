extends Control

var serverPid

# not used #
func _on_Join_pressed():
	get_node("VBoxContainer").hide()
	get_node("Join").show()


func _on_Connect_pressed():
	var client = load("res://online/Client.tscn").instance()
	get_node("/root").add_child(client)
	SetPlayerInfo()
	if !$Join/VBoxContainer/GridContainer/LineEdit2.text.empty():
		client.ip = $Join/VBoxContainer/GridContainer/LineEdit2.text
		client.port = $Join/VBoxContainer/GridContainer/LineEdit3.text
	client.ConnectToServer()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://online/Lobby.tscn")


func _on_ColorPicker_color_changed(color):
	get_node("Join/VBoxContainer/GridContainer/TextButton").self_modulate = color


func _on_HostGame_pressed():
	# server exe
	var _exePath:String = OS.get_executable_path().get_base_dir().plus_file("server/server.exe")
	var absPath:String = "F:\\Godot_v3.2.1-stable_mono_win64\\exported_games\\BallBash\\server\\server.exe"
	var port:String = ""
	if !$Join/VBoxContainer/GridContainer/LineEdit3.text.empty():
		port = $Join/VBoxContainer/GridContainer/LineEdit3.text
	serverPid = OS.execute(absPath, [port], false)
	# yield servun käynnistys
	var client = load("res://online/Client.tscn").instance()
	get_node("/root").add_child(client)
	SetPlayerInfo()
	if !$Join/VBoxContainer/GridContainer/LineEdit3.text.empty():
		client.port = $Join/VBoxContainer/GridContainer/LineEdit3.text
	client.ConnectToServer()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://online/Lobby.tscn")

func SetPlayerInfo()->void:
	var name:String = get_node("Join/VBoxContainer/GridContainer/LineEdit").text
	var color:Color = get_node("Join/VBoxContainer/ColorPicker").color
	get_node("/root/Online").playerInfo.name = name
	get_node("/root/Online").playerInfo.color = color

func _on_Button_pressed():
	hide()
	get_parent().get_node("MainMenuContainer").show()

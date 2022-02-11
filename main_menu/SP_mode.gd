extends Control


func _on_Single_pressed():
	get_node("VBoxContainer").hide()
	$LevelSelect.show()
	get_node("LevelSelect/GridContainer/1").grab_focus()

func _on_Back_pressed():
	hide()
	$LevelSelect.hide()
	get_parent().ShowMainMenu()

extends VBoxContainer

var gameRules:Dictionary = {
	"Wins":3,
	"Hp":15,
	"Abilities": ["ForcePush"],
	"EnableAi": true,
	"Objects": []
}

func _on_WinBox_value_changed(value):
	gameRules["Wins"] = int(value)
	get_parent().ChangeRules({"Wins":value})


func _on_StartHpBox_value_changed(value):
	gameRules["Hp"] = int(value)
	get_parent().ChangeRules({"Hp":value})


func _on_EnableAi_toggled(button_pressed):
	gameRules["EnableAi"] = button_pressed
	get_parent().ChangeRules({"EnableAi":button_pressed})


func _on_ForceBox_toggled(button_pressed):
	if button_pressed:
		gameRules["Abilities"].append("ForcePush")
	else:
		gameRules["Abilities"].erase("ForcePush")
	get_parent().ChangeRules({"Abilities":gameRules["Abilities"]})


func _on_MagnetBox_toggled(button_pressed):
	if button_pressed:
		gameRules["Abilities"].append("ForceMagnet")
	else:
		gameRules["Abilities"].erase("ForceMagnet")
	get_parent().ChangeRules({"Abilities":gameRules["Abilities"]})


func _on_ArenaWallBox_toggled(button_pressed):
	if button_pressed:
		gameRules["Arena"]["Objects"].append("Wall")
	else:
		gameRules["Arena"]["Objects"].erase("Wall")
	get_parent().ChangeRules(gameRules["Arena"])

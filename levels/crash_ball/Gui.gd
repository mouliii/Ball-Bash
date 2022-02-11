extends CanvasLayer

signal restartGame()
signal randomWinner()
onready var playerHealth = get_node("GUI/PlayerInfo")
var menuOpenTime:float = 5.0


func _ready():
	var key:String = OS.get_scancode_string(InputMap.get_action_list("ui_accept")[0].scancode)
	$GUI/ForceWin/Button.text = "Press " + key + " to force win"

func UpdateGui(player:int, _damage:int) -> void:
	$GUI/Ball_counter.text = "balls: " + str(get_parent().get_node("Balls").get_child_count())
	#players 1-4 -> 0-3
	var playerIndex:int = player - 1
	for player in get_parent().get_node("Players").get_children():
		if player.position_id == playerIndex:
			playerHealth.get_child(playerIndex).text = str(player.health)

func SetupGui() -> void:
	for i in range(0,4):
		playerHealth.get_child(i).text = str(get_parent().get_node("Players").get_child(i).health)

func UpdateBallCount() -> void:
	$GUI/Ball_counter.text = "balls: " + str(get_parent().get_node("Balls").get_child_count())


func _on_Retry_pressed():
	emit_signal("restartGame")
	get_node("GUI/RetryMenu").hide()
	$GUI/PauseMenu/VBoxContainer2.hide()
	$GUI/PauseMenu.hide()


func _on_Quit_pressed():
	var value = get_tree().change_scene("res://main_menu/MainMenu.tscn")
	if value != OK:
		push_error("failed to change scene")

func SetScore()->void:
	var node = get_node("GUI/ScoreScreen/VBoxContainer")
	for i in range(0,4):#node.get_children():
		node.get_child(i).get_child(1).text = str(get_parent().score[i])


func _on_Button_pressed():
	$GUI/ForceWin.hide()
	emit_signal("randomWinner")


func _on_Resume_pressed():
	get_tree().paused = false
	$GUI/PauseMenu.hide()


func _on_PauseRetry_pressed():
	if get_node("/root/Main").score[0] > 0:
		$GUI/PauseMenu/VBoxContainer.hide()
		$GUI/PauseMenu/VBoxContainer2.show()
		$GUI/PauseMenu/VBoxContainer2/PauseBack.grab_focus()
	else:
		get_node("GUI/RetryMenu").hide()
		$GUI/PauseMenu/VBoxContainer2.hide()
		$GUI/PauseMenu.hide()
		get_tree().paused = false
		emit_signal("restartGame")


func _on_PauseQuit_pressed():
	$GUI/PauseMenu/VBoxContainer.hide()
	$GUI/PauseMenu/VBoxContainer3.show()
	$GUI/PauseMenu/VBoxContainer3/Nope.grab_focus()


func _on_PauseBack_pressed():
	$GUI/PauseMenu/VBoxContainer.show()
	$GUI/PauseMenu/VBoxContainer2.hide()
	$GUI/PauseMenu/VBoxContainer/Resume.grab_focus()


func _on_Nope_pressed():
	$GUI/PauseMenu/VBoxContainer.show()
	$GUI/PauseMenu/VBoxContainer3.hide()
	$GUI/PauseMenu/VBoxContainer/Resume.grab_focus()


func _on_Yep_pressed():
	var value = get_tree().change_scene("res://main_menu/MainMenu.tscn")
	if value != OK:
		push_error("failed to change scene")

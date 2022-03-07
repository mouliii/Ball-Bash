extends Control

onready var server = get_node("/root/Online")

const lobbyStateTexts:Array = ["Waiting for players", "Game starting"]
const readyButtonTexts:Array = ["Ready", "Cancel"]
var gameSettings:Dictionary = {}

func _ready():
	print("in lobby")
	for button in range(0,4):
		# warning-ignore:return_value_discarded
		get_node("PositionContainer").get_child(button).connect("pressed", self, "ChoosePosition", [button])

func UpdateLobby(_info:Dictionary)->void:
	var players:Dictionary = server.GetAllPlayers()
	var n:int = 1
	for player in players.keys():
		get_node("VBoxContainer/GridContainer/Label" + str(n)).text = players[player].name
		get_node("VBoxContainer/GridContainer/ColorRect" + str(n)).color = players[player].color
		var posToLock:int = players[player].id
		if posToLock != -1:
			$PositionContainer.get_child(posToLock).disabled = true
			$PositionContainer.get_child(posToLock).text = players[player].name
		n += 1

func ResetConnectedPlayers()->void:
	pass

func SetPlayerReady(who:int, state:bool)->void:
	var ids:Array = server.GetAllPlayerIds()
	var n:int = 1
	for id in ids:
		if id == who:
			get_node("VBoxContainer/GridContainer/CheckBox" + str(n)).pressed = state
		n += 1
	TestForAllReady()

func _on_Button_pressed():
	server.SendStartGame()

func SetupLobbyLayout(isHost:bool):
	$VBoxContainer/Button.visible = isHost
	$VBoxContainer/LobbyState.visible = !isHost
	for node in $RulesContainer/GridContainer.get_children():
		if node is CheckBox:
			node.disabled = false
		elif node is SpinBox:
			node.editable = true
	
func SetLobbyTexts(id:int)->void:
	$VBoxContainer/Button.text = lobbyStateTexts[id]
	$VBoxContainer/LobbyState.text = lobbyStateTexts[id]

func _on_ReadyButton_pressed():
	var btn = $VBoxContainer/ReadyButton
	btn.text = (readyButtonTexts[1] if btn.pressed else readyButtonTexts[0])
	server.SendReadyState(btn.pressed)

func SetGameOptions()->void:
	gameSettings["WinCondition"] = {"Wins": get_node("RulesContainer/GridContainer/WinBox").value }
	gameSettings["Character"] = {
		"Hp": get_node("RulesContainer/GridContainer/StartHpBox").value,
		"Abilities": []
		 }
	gameSettings["Arena"] = { "Objects": [] }

func LoadGame(playerIds:Array, playerColors:Array, abilities:Array)->void:
	var world = load("res://online/World.tscn").instance()
	get_node("/root").add_child(world)
	world.CreatePlayers(playerIds, playerColors, abilities)
	self.hide()

func ChoosePosition(pos:int)->void:
	server.SendChosenPosition(pos)

func UpdatePosition(id:int, pos:int)->void:
	get_node("PositionContainer").get_child(pos).text = server.GetAllPlayers()[id].name
	if id == get_tree().get_network_unique_id():
		for i in range(0,4):
			get_node("PositionContainer").get_child(i).disabled = true
		get_node("VBoxContainer/ReadyButton").text = "Ready"
		get_node("VBoxContainer/ReadyButton").disabled = false
	else:
		get_node("PositionContainer").get_child(pos).text = server.GetAllPlayers()[id].name
		get_node("PositionContainer").get_child(pos).disabled = true

func ChangeRules(dict:Dictionary)->void:
	server.ChangeRules(dict)

func UpdateRules(dict:Dictionary)->void:
	match dict.keys()[0]:
		"Wins":
			$RulesContainer/GridContainer/WinBox.value = dict.values()[0]
		"Hp":
			$RulesContainer/GridContainer/StartHpBox.value = dict.values()[0]
		"Abilities":
			pass
#			get_node("RulesContainer/GridContainer/ForceBox").pressed = false
#			#get_node("RulesContainer/GridContainer/MagnetBox").pressed = false
#			for ability in dict["Abilities"]:
#				if ability == "ForcePush":
#					get_node("RulesContainer/GridContainer/ForceBox").pressed = true
#				#elif ability == "ForceMagnet":
#				#	get_node("RulesContainer/GridContainer/MagnetBox").pressed = true
		"EnableAi":
			$RulesContainer/GridContainer/EnableAi.pressed = dict.values()[0]
		"Objects":
			# array
			pass
		_:
			push_error("INVALID DICT KEY - LOBBY: UPDATE RULES!")

func ResetLobby()->void:
	for button in $PositionContainer.get_children():
		button.disabled = false
		button.text = "Open"
	$VBoxContainer/ReadyButton.pressed = false
	$VBoxContainer/ReadyButton.disabled = true
	$VBoxContainer/ReadyButton.text = "Choose position->v"

func TestForAllReady()->void:
	var nConnectedPlayers:int = server.GetAllPlayerIds().size()
	var nPlayersReady:int = 0
	for i in range(0,4):
		var boxNode:CheckBox = get_node("VBoxContainer/GridContainer/CheckBox" + str(i+1))
		if boxNode.pressed:
			nPlayersReady += 1
	if nPlayersReady == nConnectedPlayers:
		$VBoxContainer/Button.disabled = false
		$VBoxContainer/Button.text = "Start game"
	else:
		$VBoxContainer/Button.disabled = true
		$VBoxContainer/Button.text = "Waiting for players"


func _on_QuitButton_pressed():
	get_tree().change_scene("res://main_menu/MainMenu.tscn")

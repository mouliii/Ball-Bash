extends Control

onready var server = get_node("/root/Online")
#fetch#receive
func _ready():
	print("in lobby")
	for i in range(1,5):
		var node = get_node("VBoxContainer/GridContainer/CheckBox" + str(i))
		node.connect("toggled", self, "ToggleCheckBox")

func UpdateLobby(info:Dictionary, who:int)->void:
	ResetConnectedPlayers()
	var n = 1
	for key in info.keys():
		get_node("VBoxContainer/GridContainer/Label" + str(n)).text = info[key].name
		get_node("VBoxContainer/GridContainer/ColorRect" + str(n)).color = info[key].color
		if who == key:
			get_node("VBoxContainer/GridContainer/CheckBox" + str(n)).disabled = false
		else:
			get_node("VBoxContainer/GridContainer/CheckBox" + str(n)).disabled = true
		n += 1

func ResetConnectedPlayers()->void:
	for i in range(1,5):
		get_node("VBoxContainer/GridContainer/Label" + str(i)).text = "Empty slot"
		get_node("VBoxContainer/GridContainer/CheckBox" + str(i)).disabled = true

func SetPlayerReady(who:int, ready:bool)->void:
	var n = 1
	var players = server.GetAllPlayers()
	for p in players.keys():
		if who == p:
			get_node("VBoxContainer/GridContainer/CheckBox" + str(n)).pressed = ready
		n += 1


func ToggleCheckBox(state:bool)->void:
	server.SendReadyState(state)

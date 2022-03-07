extends Node


var ip:String = "127.0.0.1"
#var ip:String = "192.168.x.x"
var port:int = 28960
const maxClients := 4
var peer = NetworkedMultiplayerENet.new()

var connectedPlayers = {}

var playersDoneLoading:Array = []
var playersReady:Array = []
# "P" = POSITON, "B" = BALLS, "T" = TIMESTAMP, "D" = DESTROY BALL(S)
var gameStateCollection = {"T":{},"P":{},"B":{},"D":{}}

###############
var spawnPoints:Array = [Vector3(0, 0, 4.05), Vector3(0, 0, -4.05), Vector3(-4.05, 0, 0), Vector3(4.05, 0, 0)]

var gameRules:Dictionary = {
	"Wins":3,
	"Hp":15,
	"Abilities": ["ForcePush"],
	"EnableAi": true,
	"Objects": []
}

func _ready():
	Engine.target_fps = 60
	OS.vsync_enabled = false
	# load pck
	var success = ProjectSettings.load_resource_pack("../exported_games/BallBash/BallBash.pck")
	var gamepckPath:String = OS.get_executable_path().get_base_dir().get_base_dir().plus_file("BallBash.pck")
	var success_exported = ProjectSettings.load_resource_pack(gamepckPath)
	if success_exported:
		print("successfully loaded .pck file")
	else:
		push_error("noonniih")
	HostGame()
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "PlayerConnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"PlayerDisconnected")
	set_physics_process(false)

func _physics_process(_delta):
	UpdateGame()

func HostGame():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, maxClients)
	get_tree().set_network_peer(peer)

func PlayerConnected(id:int)->void:
	print("player " + str(id) + " connected")

func PlayerDisconnected(id:int)->void:
	print("player " + str(id) + " disconnected")
	connectedPlayers.erase(id)
	rpc_id(0, "DeletePlayer", id)

remote func RegisterPlayer(info:Dictionary)->void:
	var sender:int = get_tree().get_rpc_sender_id()
	var isHost:bool = connectedPlayers.empty()
	if isHost == true:
		rpc_id(sender, "SetupLobbyForHost")
	connectedPlayers[sender] = info
	rpc_id(0, "RegisterPlayer", sender, info)
	rpc_id(sender, "ReceiveAllConnectedPlayers", connectedPlayers)



############
# LOBBY
############

remote func StartGame()->void:
	var game = load("res://ServerWorld.tscn").instance()
	get_node("/root").add_child(game)
	print("Game created.. adding players")
	# player position id 
	var plrPos:Array = SetupPlayerPositions(gameRules["EnableAi"])
	game.CreatePlayers(plrPos)
	game.SetupGame()
	var playerColors:Array = GenerateCartColors(plrPos)
	var playerIds:Array = []
	for i in gameStateCollection["P"]:
		playerIds.append(i) # ?
	rpc_id(0, "StartGame", plrPos, playerColors, gameRules["Abilities"])


remote func UpdatePlayerReady(status:bool)->void:
	var id:int = get_tree().get_rpc_sender_id()
	rpc_id(0, "UpdatePlayerReady", id, status)
	if status:
		playersReady.append(id)
	else:
		playersReady.erase(id)

remote func ReceivePlayerPosition(pos:int)->void:
	var id:int = get_tree().get_rpc_sender_id()
	connectedPlayers[id].id = pos
	rpc_id(0, "UpdatePlayerPosition", id, pos)

func SetupPlayerPositions(botsIncluded:bool)->Array:
	var posids:Array = [-1,-1,-1,-1]
	if botsIncluded:
		for player in connectedPlayers.keys():
			posids[connectedPlayers[player].id] = player
	else:	# bots not enabled
		posids = [-999,-999,-999,-999]
		for player in connectedPlayers.keys():
			posids[connectedPlayers[player].id] = player
	return posids

remote func UpdateRules(subDict:Dictionary)->void:
	gameRules[subDict.keys()[0]] = subDict.values()[0]
	rpc_id(0, "UpdateRules", subDict)

func GenerateCartColors(plrPos:Array)->Array:
	var colors:Array = []
	var limit:float = 0.4
	for i in range(0,4):
		if connectedPlayers.has(plrPos[i]):
			colors.append(connectedPlayers[plrPos[i]].color)
		else:#bot
			var botColor:Color = Color(randf(),randf(),randf(),1.0)
			var colorOk:bool = true
			while !colorOk:
				for c in range(0,colors.size()):
					var color:Color = colors[c]
					var diffR:float =  abs(botColor.r - color.r)
					var diffG:float =  abs(botColor.g - color.g)
					var diffB:float =  abs(botColor.b - color.b)
					var difference:float = (diffR*diffR) + (diffG*diffG) + (diffB*diffB)
					if (limit * limit) > difference:
						colorOk = true
					else:
						colorOk = false
						botColor = Color(randf(),randf(),randf(),1.0)
			colors.append(Color(randf(),randf(),randf(),1.0))
	return colors

############
# GAME			# oma node ?
############

remote func PlayerLoadComplete()->void:
	var id:int = get_tree().get_rpc_sender_id()
	playersDoneLoading.append(id)
	rpc_id(id, "UpdateHealth", 5, gameRules["Hp"])
	if playersDoneLoading.size() == playersReady.size():
		print("everyone ready starting..")
		get_node("/root/World").StartBallCountDown()
		rpc_id(0, "BeginCountdown")
		set_physics_process(true)

remote func ReceivePlayerState(receivedPlayerState:Dictionary)->void:
	var playerId:String = str(get_tree().get_rpc_sender_id())
	if gameStateCollection["P"][playerId]["T"] < receivedPlayerState["T"]:
		gameStateCollection["P"][playerId] = receivedPlayerState

func UpdateGame()->void:
	var processedStates:Dictionary = gameStateCollection.duplicate(true)
	for player in processedStates["P"].keys():
		processedStates["P"][player].erase("T")
	processedStates["T"] = OS.get_system_time_msecs()
	rpc_unreliable_id(0, "GetNewGameState", processedStates)

func ActivateBarrier(id:int)->void:
	rpc_id(0, "ActivateBarrier", id)

func DisableScoringLines()->void:
	rpc_id(0, "DisableScoringLines")

func ResetGame(positionids:Array)->void:
	rpc_id(0, "ResetGame", positionids)

func UpdateHealth(position:int, hp:int)->void:
	rpc_id(0, "UpdateHealth", position, hp)

func DisablePlayerControls(id:int, state:int)->void:
	rpc_id(id, "PlayerDead", state)

func PlayerDied(who:int)->void:
	rpc_id(0, "PlayerDied", who)

func ShowRoundWinner(position:int):
	rpc_id(0, "ShowScoreScreen", position)

func StopSendingUpdates()->void:
	rpc_id(0, "StopSendingUpdates")

func ReturnToLobby()->void:
	set_physics_process(false)
	get_node("/root/World").set_physics_process(false)
	rpc_id(0, "ReturnToLobby")
	get_node("/root/World").queue_free()
	for i in connectedPlayers.keys():
		connectedPlayers[i].id = -1
	rpc_id(connectedPlayers.keys()[0], "SetupLobbyForHost")
	gameStateCollection = {"T":{},"P":{},"B":{},"D":{}}

remote func UseSkill(who:int, ability:String, addInfo:String)->void:
	if who > 1000:
		get_node("/root/World").UseSkill(who, ability, addInfo)
	rpc_id(0, "UseSkill", who, ability, addInfo)

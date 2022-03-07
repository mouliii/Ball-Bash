extends Node


var ip:String = "127.0.0.1"
var port:int = 27015
var network = NetworkedMultiplayerENet.new()

var connectedPlayers = {}
var playerInfo = {name = "unnamed", color = Color(randf(), randf(), randf(), 1.0), id = -1}

var lastRTT = 0
var RTT = 0

func _ready():
	pass
	#ConnectToServer()

func ConnectToServer()->void:
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("clinet id: " + str(get_tree().get_network_unique_id()))
	
	network.connect("connection_succeeded", self, "OnConnectionSucceeded")
	network.connect("connection_failed", self, "OnConnectionFailed")

func OnConnectionSucceeded()->void:
	print("connection successfull")
	rpc_id(1, "RegisterPlayer", playerInfo)

func OnConnectionFailed()->void:
	print("connection failed")
	get_tree().network_peer = null

func GetConnectionStatus():
	var network_peer := get_tree().network_peer
	if network_peer:
		return network_peer.get_connection_status()

func Disconnect():
	print("disconnected")
	network.close_connection()
	network.disconnect("connection_succeeded", self, "OnConnectionSucceeded")
	network.disconnect("connection_failed", self, "OnConnectionFailed")

func GetAllPlayerIds()->Array:
	return connectedPlayers.keys()

func GetAllPlayers()->Dictionary:
	return connectedPlayers

remote func RegisterPlayer(who:int, info:Dictionary)->void:
	connectedPlayers[who] = info
	UpdateLobbyPlayers()

remote func DeletePlayer(who:int)->void:
	connectedPlayers.erase(who)
	UpdateLobbyPlayers()

remote func ReceiveAllConnectedPlayers(info:Dictionary):
	for player in info.keys():
		connectedPlayers[player] = info[player]
	UpdateLobbyPlayers()

remote func SetupLobbyForHost()->void:
	for _i in range(0,10):
		yield(get_tree().create_timer(1.0), "timeout")
		if get_node_or_null("/root/Lobby"):
			get_node("/root/Lobby").SetupLobbyLayout(true)
			break

##############################
# LOBBY FUNCS
##############################
func SendReadyState(state:bool)->void:
	rpc_id(1, "UpdatePlayerReady", state)

remote func UpdatePlayerReady(who:int, state:bool)->void:
	get_node("/root/Lobby").SetPlayerReady(who, state)

func UpdateLobbyPlayers()->void:
	get_node("/root/Lobby").UpdateLobby(connectedPlayers)

func SendChosenPosition(pos:int)->void:
	rpc_id(1, "ReceivePlayerPosition", pos)

remote func UpdatePlayerPosition(id:int, pos:int)->void:
	get_node("/root/Lobby").UpdatePosition(id, pos)

remote func SetLobbyStateText(id:int):
	get_node("/root/Lobby").SetLobbyTexts(id)

func SendStartGame()->void:
	rpc_id(1, "StartGame")

func ChangeRules(dict:Dictionary)->void:
	rpc_id(1, "UpdateRules", dict)

remote func UpdateRules(dict:Dictionary)->void:
	get_node("/root/Lobby").UpdateRules(dict)

remote func StartGame(playerIds:Array, playerColors:Array, abilities:Array)->void:
	get_node("/root/Lobby").LoadGame(playerIds, playerColors, abilities)

##############################
# GAME FUNCS
##############################

func SendLoadingDone()->void:
	rpc_id(1, "PlayerLoadComplete")

remote func BeginCountdown()->void:
	get_tree().paused = false
	get_node("/root/World").PlayCountdown()

func SendPlayerState(playerState:Dictionary)->void:
	rpc_unreliable_id(1, "ReceivePlayerState", playerState)

remote func GetNewGameState(states:Dictionary)->void:
	get_node("/root/World").UpdateGameState(states)
	var curTime = OS.get_system_time_msecs()
	RTT = curTime - lastRTT
	lastRTT = curTime

remote func ActivateBarrier(id:int)->void:
	get_node("/root/World").UpdateBarrier(id)

remote func DisableScoringLines()->void:
	get_node("/root/World").DisableScoringLines()

remote func ResetGame(positionids:Array)->void:
	get_node("/root/World").ResetGame(positionids)

remote func UpdateHealth(position:int, hp:int)->void:
	get_node("/root/World").UpdateHealth(position, hp)

remote func PlayerDead(state:int)->void:
	get_node("/root/World").DisableControls(state)

remote func PlayerDied(who:int)->void:
	get_node("/root/World").TriggerDeath(who)

remote func ShowScoreScreen(pos_id:int)->void:
	get_node("/root/World").ShowScore(pos_id)

remote func ReturnToLobby()->void:
	get_node("/root/Lobby").show()
	get_node("/root/World").queue_free()
	get_node("/root/Lobby").ResetLobby()

remote func StopSendingUpdates()->void:
	get_node("/root/World").set_physics_process(false)

remote func UseSkill(who:int, ability:String, addInfo:String)->void:
	get_node("/root/World").UseSkill(who, ability, addInfo)

func SendSkillUse(who:int, ability:String, addInfo:String)->void:
	rpc_id(1, "UseSkill", who, ability, addInfo)

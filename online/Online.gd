extends Node

signal playerConnected(info)

var ip = "127.0.0.1"
var port:int = 28960
var maxClients:int = 4

var peer = null
# local player
var myInfo = { name = "unnamed", color = Color(randf(), randf(), randf(), 1.0) }
# all players
var players = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
#	get_tree().connect("connection_failed", self, "_connected_fail")
#	get_tree().connect("server_disconnected", self, "_server_disconnected")


func _player_connected(player_id)->void:
	print("player " + str(player_id) + " connected")
	rpc_id(player_id, "RegisterPlayer", myInfo)

func _player_disconnected(player_id)->void:
	print("player " + str(player_id) + " disconnected")
	PlayerDisconnected(player_id)

func _connected_ok()->void:
	emit_signal("playerConnected")

func GetConnectionStatus()->int:
	var status:int = get_tree().network_peer.get_connection_status()
	return status

func HostGame():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, maxClients)
	get_tree().set_network_peer(peer)
	# servu always id 1
	players[1] = myInfo

func JoinGame():
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	# Store the info
	players[get_tree().get_network_unique_id()] = myInfo

remote func RegisterPlayer(info:Dictionary):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	players[id] = info
	# update lobby
	UpdateLobby()

func GetAllPlayers()->Dictionary:
	return players

func GetAllPlayerIds()->PoolIntArray:
	var ids = get_tree().get_network_connected_peers()
	return ids

func PlayerDisconnected(who:int)->void:
	players.erase(who)
	UpdateLobby()

func GetPlayers()->Dictionary:
	return players

remote func UpdateLobby()->void:
	get_node("/root/Lobby").UpdateLobby(players, get_tree().get_network_unique_id())

remote func UpdatePlayerState(who:int, state:bool):
	get_node("/root/Lobby").SetPlayerReady(who, state)

remote func ServerUpdatePlayerState(state:bool)->void:
	var id:int = get_tree().get_rpc_sender_id()
	get_node("/root/Lobby").SetPlayerReady(id, state)
	rpc_id(0, "UpdatePlayerState", id, state)

###############
# lobby funcs #
###############

func SendReadyState(state:bool)->void:
	var caller:int = get_tree().get_network_unique_id()
	if caller != 1:
		rpc_id(1,"ServerUpdatePlayerState", state)
	else:
		rpc_id(0, "UpdatePlayerState", 1, state)

###############
# game funcs  #
###############










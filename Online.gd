extends Node

signal playerConnected(info)
signal playerDisconnected(info)

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
#	get_tree().connect("connected_to_server", self, "_connected_ok")
#	get_tree().connect("connection_failed", self, "_connected_fail")
#	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(player_id)->void:
	print("player " + str(player_id) + " connected")
	rpc_id(1, "RegisterPlayer", myInfo)
	

func _player_disconnected(player_id)->void:
	print("player " + str(player_id) + " disconnected")
	emit_signal("playerDisconnected", players)

func HostGame():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, maxClients)
	get_tree().set_network_peer(peer)
	RegisterPlayer(myInfo)

func JoinGame():
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)

remote func RegisterPlayer(info:Dictionary):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	players[id] = info
	# update gui
	emit_signal("playerConnected")

func GetPlayers()->Dictionary:
	return players
















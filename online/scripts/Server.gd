extends Node


var network = NetworkedMultiplayerENet.new()
var port:int = 28960
var maxClients:int = 4

var connectedPlayers = {}
var nPlayersReady:int = 0

func _ready():
	StartServer()

func StartServer()->void:
	network.create_server(port, maxClients)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "OnPlayerConnect")
	network.connect("peer_disconnected", self, "OnPlayerDisconnect")
	network.connect("server_disconnected", self, "OnServerDisconnect")

func OnPlayerConnect(player_id)->void:
	print("Player: " + str(player_id) + " connected")

func OnPlayerDisconnect(player_id)->void:
	print("Player: " + str(player_id) + " disconnected")

func OnServerDisconnect()->void:
	print("Server disconected")
	network.close_connection()

remote func RegisterPlayer(info:Dictionary):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	connectedPlayers[id] = info

func GetPlayersData()->Dictionary:
	return connectedPlayers


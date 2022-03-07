extends Spatial

onready var server = get_node("/root/Online")
onready var arena = get_node("Arena")
onready var gui = get_node("CanvasLayer/GUI")
const actualPlayerTemplate = preload("res://carts/Player.tscn")
const npcTemplate = preload("res://carts/PlayerTemplate.tscn")
const ballTemplate = preload("res://assets/balls/BallTemplate.tscn")
onready var balls = $Balls

var playerRef = null
var playerState:Dictionary = {}
var lastUpdateTimeStamp = 0
var score:Array = [0,0,0,0]
var health:Array = [5,5,5,5]

# laita meshit päälle pelaajsata

func _ready():
	#ResetGame()
	server.SendLoadingDone()
	for line in arena.get_node("Goal_barriers").get_children():
		line.get_child(1).hide()
	get_tree().paused = true


func _physics_process(_delta):
	playerState = {"T": OS.get_system_time_msecs(), "P": playerRef.global_transform.origin}
	server.SendPlayerState(playerState)
	$CanvasLayer/stats/Label.text = str(server.RTT)

func CreatePlayers(playerIds:Array, playerColors:Array, abilities:Array)->void:
	SetupGui(playerIds, playerColors)
	var selfId:int = get_tree().get_network_unique_id()
	for i in range(0, playerIds.size()):
		if selfId == int(playerIds[i]):
			var player = actualPlayerTemplate.instance()
			$Players.add_child(player, true)
			player.name = str(playerIds[i])
			player.position_id = i
			if i > 1:
				player.get_node("Controls").isSide = true
			player.global_transform.origin = get_node("Arena").GetSpawnPoints()[i]
			player.get_node("Mesh/Indicator").show()
			player.get_node("Mesh/Cart").show()
			player.global_transform = player.global_transform.looking_at(Vector3(0,player.global_transform.origin.y,0), Vector3.UP)
			RotateCamera(i)
			playerRef = player
			player.balls = get_node("Balls")
			# abilities
			for ability in abilities:
				var skill = load("res://carts/abilities/" + ability + ".tscn").instance()
				player.add_child(skill)
			var attackOSH = load("res://online/OnlineSkillHelper.tscn").instance()
			player.add_child(attackOSH)
			# material bullshittery
			var mesh:Mesh = player.get_node("Mesh/Cart").mesh.duplicate(true)
			var material:Material = player.get_node("Mesh/Cart").get_active_material(0).duplicate(true)
			player.get_node("Mesh/Cart").mesh = mesh
			player.get_node("Mesh/Cart").mesh.surface_set_material(0, material)
			player.ChangeCartColor(server.connectedPlayers[selfId].color)
		else:	# is bot
			if int(playerIds[i]) != -999:
				var player = npcTemplate.instance()
				$Players.add_child(player, true)
				player.name = str(playerIds[i])
				player.global_transform.origin = get_node("Arena").GetSpawnPoints()[i]
				player.global_transform = player.global_transform.looking_at(Vector3(0,player.global_transform.origin.y,0), Vector3.UP)
				player.ChangeCartColor(playerColors[i])
				player.balls = get_node("Balls")
				# abilities
				for ability in abilities:
					var skill = load("res://carts/abilities/" + ability + ".tscn").instance()
					player.add_child(skill)
			else: # not bot, enable visuals
				UpdateBarrier(i)

func RotateCamera(id:int)->void:
	match id:
		0:
			#default
			pass
		1:
			$SpringArm.rotate_y(deg2rad(180))
		2:
			$SpringArm.rotate_y(deg2rad(270))
		3:
			$SpringArm.rotate_y(deg2rad(90))

func UpdateGameState(newGameState:Dictionary)->void:
	if newGameState["T"] > lastUpdateTimeStamp:
		var playeridString:String = str(get_tree().get_network_unique_id())
		newGameState["P"].erase(playeridString)
		for p in newGameState["P"].keys():
			get_node("Players/" + str(p)).SetPosition(newGameState["P"][p]["P"])
		
		for d in newGameState["D"].keys():
			$Balls.get_node(d).queue_free()
		
		for b in newGameState["B"].keys():
			if balls.has_node(b):
				balls.get_node(b).SetPosition(newGameState["B"][b]["P"])
			else:
				var ball = ballTemplate.instance()
				balls.add_child(ball, true)
				ball.name = b
				ball.SetPosition(newGameState["B"][b]["P"])

func UpdateBarrier(id:int)->void:
	arena.get_node("Goal_barriers").get_child(id).get_child(0).disabled = false
	arena.get_node("Goal_barriers").get_child(id).get_child(1).show()
	arena.SetLineColor(arena.lineColor["Red"], id)
	#get_node("Players/"+ str(id)).TriggerDeath()

func DisableScoringLines()->void:
	arena.DisableScoringLines()

func ResetGame(positionids:Array)->void:
	arena.DisableBlockers()
	arena.EnableScoringLines()
	arena.SetAllLines(arena.lineColor["Blue"])
	for i in range(0,4):
		if int(positionids[i]) == -999:
			UpdateBarrier(i)
	playerRef.DisableControls(0)
	for player in $Players.get_children():
		player.ShowSkin()
	HideCurrentScore()
	PlayCountdown()
	playerRef.get_node("OnlineSkillHelper").set_process(true)
	playerRef.ResetSkills()

func DisableControls(state:int)->void:
	playerRef.DisableControls(state)
	playerRef.get_node("OnlineSkillHelper").set_process(false)
	PlayerDead()

func PlayerDead()->void:
	playerRef.TriggerDeath()

func TriggerDeath(who)->void:
	get_node("Players/" + str(who)).TriggerDeath()

func UpdateHealth(position:int, hp:int)->void:
	if position == 5:
		for i in range(0,4):
			health[i] = hp
	else:
		health[position] = hp
	UpdateHpGui(position, hp)

func UpdateHpGui(position:int, hp:int)->void:
	if position == 5:
		for i in range(0,4):
			gui.get_node("PlayerInfo").get_node(str(i+1)).text = str(hp)
	else:
		gui.get_node("PlayerInfo").get_node(str(position+1)).text = str(hp)

func UpdateCurrentScore()->void:
	pass

func PlayCountdown()->void:
	$CanvasLayer/Countdown/AnimationTree.get("parameters/playback").start("3")

func ShowCurrentScore()->void:
	$CanvasLayer/GUI/ScoreScreen.show()

func HideCurrentScore()->void:
	$CanvasLayer/GUI/ScoreScreen.hide()

func ReturnToLobby()->void:
	pass

func SetupGui(ids:Array, playerColors:Array)->void:
	for i in range(0,4):
		if int(ids[i]) == -999:
			# top screen
			var tRect:ColorRect = get_node("CanvasLayer/GUI/PlayerInfo/ColorRect"+str(i+1))
			tRect.hide()
			#tRect.self_modulate.a = 0.0
			var label:Label = get_node("CanvasLayer/GUI/PlayerInfo/"+str(i+1))
			label.hide()
			#label.text = ""
			# hide player from ScoreScreen
			get_node("CanvasLayer/GUI/ScoreScreen/VBoxContainer").get_child(i).hide()
		else:
			if server.connectedPlayers.has(ids[i]):
				# score screen
				var label:Label = get_node("CanvasLayer/GUI/ScoreScreen/VBoxContainer/Player"+str(i+1)+"/Name")
				label.text = server.connectedPlayers[ids[i]].name
				# health screen
				var tRect:ColorRect = get_node("CanvasLayer/GUI/PlayerInfo/ColorRect"+str(i+1))
				tRect.color = server.connectedPlayers[ids[i]].color
			else:
				# score screen
				var label:Label = get_node("CanvasLayer/GUI/ScoreScreen/VBoxContainer/Player"+str(i+1)+"/Name")
				label.text = "Bot"
				# health screen
				var tRect:ColorRect = get_node("CanvasLayer/GUI/PlayerInfo/ColorRect"+str(i+1))
				tRect.color = playerColors[i]

func ShowScore(position_id:int)->void:
	score[position_id] += 1
	get_node("CanvasLayer/GUI/ScoreScreen/VBoxContainer/Player" + str(position_id+1) + "/Wins").text = str(score[position_id])
	ShowCurrentScore()

func UseSkill(who:int, skill:String, addInfo:String)->void:
	if who == get_tree().get_network_unique_id():
		return
	var player = get_node("Players/" + str(who))
	match skill:
		"ForcePush":
			player.get_node("ForcePush").UseForcePush()
		"ForceMagnet":
			if addInfo == "Hold":
				pass
			elif addInfo == "Release":
				pass





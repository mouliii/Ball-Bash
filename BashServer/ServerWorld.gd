extends Node

const playerTemplate = preload("res://PlayerTemplate.tscn")
onready var server = get_node("/root/Online")
var arena = null
var ball_template = null
onready var ballTimer = get_node("BallTimer")
onready var balls = $Balls

var ballSpawnTime:float = 1.0
var maxActiveBalls:int = 4
var ballSpawnPoints:Array = []

var gameStats:Dictionary = {}
var positionids:Array = [-1,-1,-1,-1]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var arenaScene = load("res://levels/crash_ball/arena.tscn").instance()
	add_child(arenaScene)
	arena = get_node("Arena")
	arena.connect("ballDropped", self, "StartBallTimer")
	arena.hide()

	# load rules
	ball_template = load("res://assets/balls/Ball.tscn")
	for cannon in arena.get_node("Cannons").get_children():
		var point = cannon.get_child(1)
		ballSpawnPoints.append(point.global_transform.origin)
	# load modifiers
	# start countdown
	#SpawnBall()
	#ballTimer.start(3.0)
	
	set_physics_process(false)

func _physics_process(_delta):
	for player in gameStats.keys():
		var plr = get_node_or_null("Players/" + str(gameStats[player].Id))
		if plr:
			if plr.isBot:
				server.gameStateCollection["P"][gameStats[player].Id]["P"] = plr.global_transform.origin
	server.gameStateCollection["D"].clear()
	var currentGameState:Dictionary = server.gameStateCollection.duplicate(true)
	for playerID in currentGameState["P"]:
		var player = currentGameState["P"][playerID]
		get_node("Players/" + str(playerID)).global_transform.origin = player["P"]
	
	var ballDict:Dictionary = {}
	for ball in balls.get_children():
		ballDict[ball.name] = {"P": ball.global_transform.origin}
	server.gameStateCollection["B"] = ballDict

func StartBots()->void:
	for i in $Players.get_children():
		i.StartBot()

func GetBallSpawnPoint() -> Vector3:
	var rng:int = randi() % 4
	var spawnPoint:Vector3 = arena.ballSpawnPoints[rng]
	return spawnPoint

func SpawnBall() -> void:
	var ball = ball_template.instance()
	$Balls.add_child(ball, true)
	ball.connect("goal", self, "HealthChanged")
	ball.connect("onlineSelfDestruct", self, "DestroyBall")
	ball.global_transform.origin = GetBallSpawnPoint()
	ball.LaunchBall()

func DestroyBall(who)->void:
	server.gameStateCollection["D"][who.name] = 1

func StartBallTimer():
	ballTimer.start(ballSpawnTime)

func HealthChanged(player:int, damage:int):
	if ballTimer.is_stopped():
		ballTimer.start(ballSpawnTime)
	ReduceHealth(player, damage)

func ReduceHealth(player:int, _damage:int):
	var playerIndex:int = player - 1
	gameStats[playerIndex].Health -= 1
	server.UpdateHealth(playerIndex, gameStats[playerIndex].Health)
	if gameStats[playerIndex].Health <= 0:
		var combatant = get_node_or_null("Players/" + str(gameStats[playerIndex].Id))
		if combatant:
			if !combatant.isBot:
				server.DisablePlayerControls(int(gameStats[playerIndex].Id), 1)
			combatant.get_child(0).disabled = true
			server.ActivateBarrier(playerIndex)
			arena.get_node("Goal_barriers").get_child(playerIndex).get_child(0).disabled = false
			arena.get_node("Goal_barriers").get_child(playerIndex).get_child(1).show()
			arena.SetLineColor(arena.lineColor["Red"], playerIndex)
			server.PlayerDied(int(gameStats[playerIndex].Id))
		var winner:int = TestWinner()
		if winner != -1: # position_id
			for p in $Players.get_children():
				if p.isBot:
					p.DisableBot()
			gameStats[winner]["Score"] += 1
			if gameStats[winner]["Score"] >= server.gameRules["Wins"]:
				server.ShowRoundWinner(winner)
				arena.DisableScoringLines()
				server.StopSendingUpdates()
				yield(get_tree().create_timer(5.0), "timeout")
				server.ReturnToLobby()
				return
			server.ShowRoundWinner(winner)
			arena.DisableScoringLines()
			yield(get_tree().create_timer(5.0), "timeout")
			# 3,2,1,go
			ResetGame()

func TestWinner()->int:
	var idAlive:int = -1
	var nAlive:int = 0
	for p in gameStats.keys():
		if gameStats[p].Health > 0:
			idAlive = p
			nAlive += 1
	if nAlive > 1:
		return -1
	else:
		return idAlive

func _on_BallTimer_timeout():
	SpawnBall()
	if get_node("Balls").get_child_count() < maxActiveBalls:
		ballTimer.start(ballSpawnTime)

func SetupGame():
	arena.DisableBlockers()
	arena.EnableScoringLines()
	arena.SetAllLines(arena.lineColor["Blue"])
	
	for p in $Players.get_children():
		if p.isBot:
			p.EnableBot()
	
	for i in range(0,4):
		if int(positionids[i]) == -999:
			arena.get_node("Goal_barriers").get_child(i).get_child(0).disabled = false
			arena.get_node("Goal_barriers").get_child(i).get_child(1).show()
			arena.SetLineColor(arena.lineColor["Red"], i)
	
	for player in gameStats.keys():
		if int(gameStats[player].Id) == -999:
			continue
		gameStats[player]["Health"] = server.gameRules["Hp"]
		var plr = get_node("Players/" + gameStats[player].Id)
		if plr:
			plr.get_child(0).disabled = false
			if plr.isBot:
				plr.EnableBot()

	for ball in $Balls.get_children():
		ball.queue_free()
	ballTimer.start(3.0)

func CreatePlayers(ids:Array)->void:
	positionids = ids
	# positions [0->id, 1->id]
	var spawnPoints:Array = arena.GetSpawnPoints()
	for i in range(0,4):
		if ids[i] == -999:
			gameStats[i] = {"Health": 0, "Score": 0, "Id": -999}
			continue
		var player = playerTemplate.instance()
		get_node("Players").add_child(player, true)
		player.name = str(ids[i])
		player.position_id = i
		player.global_transform.origin = spawnPoints[i]
		player.global_transform = player.global_transform.looking_at(Vector3(0,player.global_transform.origin.y,0), Vector3.UP)
		player.balls = get_node("Balls")
		if ids[i] == -1:
			player.isBot = true
			player.name = str(player.get_rid().get_id())
			positionids[i] = player.name
		for ability in server.gameRules["Abilities"]:
			var skill = load("res://carts/abilities/" + ability + ".tscn").instance()
			player.add_child(skill)
		server.gameStateCollection["P"][player.name] = {"T":0, "P": spawnPoints[i]}
		gameStats[i] = {"Health": 5, "Score": 0, "Id": player.name}
	
	set_physics_process(true)

func ResetGame()->void:
	SetupGame()
	server.UpdateHealth(5, server.gameRules["Hp"])
	server.ResetGame(positionids)

func StartBallCountDown()->void:
	ballTimer.start(3.0)

func UseSkill(who:int, skill:String, addInfo:String)->void:
	var player = get_node("Players/" + str(who))
	match skill:
		"ForcePush":
			player.get_node("ForcePush").UseForcePush()
		"ForceMagnet":
			if addInfo == "Hold":
				pass
			elif addInfo == "Release":
				pass











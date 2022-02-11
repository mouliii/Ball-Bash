extends Spatial

onready var animPlayer = get_node("CanvasLayer/AnimationPlayer")
onready var ball_template = preload("res://assets/balls/Ball.tscn")
onready var character_template = preload("res://carts/Player.tscn")
onready var arena = get_node("arena")
onready var ballTimer = get_node("BallTimer")
onready var gui = get_node("CanvasLayer")
onready var gameTests = get_node("GameTests")

var ballSpawnTime:float = 1.0
var maxActiveBalls:int = 4

var score:Array = [0,0,0,0]
var rules:Dictionary = {}

# multiple controllers
# https://godotengine.org/qa/44307/how-to-make-a-local-multiplayer-game

func _ready():
	# load config
	$arena.get_node("WorldEnvironment").environment.glow_enabled = Config.LoadValue("video_settings", "bloom")
	$Camera.fov = Config.LoadValue("gameplay", "fov")
	if Config.LoadValue("gameplay", "show_fps"):
		var meter = load("res://assets/UI/FpsMeter.tscn").instance()
		get_node("CanvasLayer/GUI").add_child(meter)
	# load arena objects
	var arenaModifiers:Array = gameTests.LoadArenaModifiers(GameModes.selectedChallenge)
	for mod in arenaModifiers.size():
		var path:String = "res://levels/Mods/"
		var object = load(path + arenaModifiers[mod] + ".tscn").instance()
		arena.add_child(object)
	# game
	randomize()
	SetupGame()
	gui.SetupGui()
	arena.connect("ballDropped", self, "StartBallTimer")
	gui.connect("restartGame", self, "SetupGame")
	gui.connect("randomWinner", self, "RandomWinner")
	set_process(false)
	set_physics_process(false)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = true
		$CanvasLayer/GUI/PauseMenu.show()
		$CanvasLayer/GUI/PauseMenu/VBoxContainer/Resume.grab_focus()

func HealthChanged(player:int, damage:int):
	if ballTimer.is_stopped():
		ballTimer.start(ballSpawnTime)
	ReduceHealth(player, damage)
	gui.UpdateGui(player, damage)

func GetBallSpawnPoint() -> Vector3:
	var rng:int = randi() % 4
	var spawnPoint:Vector3 = arena.ballSpawnPoints[rng]
	return spawnPoint

func SpawnBall() -> void:
	var ball = ball_template.instance()
	$Balls.add_child(ball)
	ball.connect("goal", self, "HealthChanged")
	ball.global_transform.origin = GetBallSpawnPoint()
	ball.LaunchBall()
	gui.UpdateBallCount()

func _on_BallTimer_timeout():
	SpawnBall()
	if get_node("Balls").get_child_count() < maxActiveBalls:
		ballTimer.start(ballSpawnTime)

func StartBallTimer():
	# todo erroria kun alt f4 pelistä 
	ballTimer.start(ballSpawnTime)

func ReduceHealth(player:int, damage:int):
	var playerIndex:int = player - 1
	var refPlayer = null
	for p in $Players.get_children():
		if p.position_id == playerIndex:
			refPlayer = p
	refPlayer.health -= damage
	if refPlayer.health <= 0:
		arena.get_node("Goal_barriers").get_child(playerIndex).get_child(0).disabled = false
		arena.get_node("Goal_barriers").get_child(playerIndex).get_child(1).show()
		refPlayer.TriggerDeath()
		arena.SetLineColor(arena.lineColor["Red"], refPlayer.position_id)
		#arena/Mesh/arena/line0
		if refPlayer.position_id == 0:
			if rules["WinCondition"].InstantFail:
				GameLost()
			else:
				$AutoWin.start(3.0)
		TestWin(gameTests.GetWinner())
		

func SetupGame():
	arena.DisableBlockers()
	arena.EnableScoringLines()
	arena.SetAllLines(arena.lineColor["Blue"])
	
	if $Players.get_child_count() == 0:
		rules = gameTests.LoadRules(GameModes.selectedChallenge)
		
		var player:KinematicBody = load("res://carts/Player.tscn").instance()
		$Players.add_child(player)
		player.position_id = 0
		player.name = "Player1"
		player.DisableControls(0)
		player.health = rules["Player"].Hp
		player.global_transform.origin = arena.GetSpawnPoints()[0]
		player.axis_lock_motion_z = true
		player.add_to_group("Players")
		player.balls = get_node("Balls")
		for ability in rules["Player"].Abilities:
			var skill = load("res://carts/abilities/" + ability + ".tscn").instance()
			player.add_child(skill)
		
		# todo test
		#characterInstance.get_node("Controls").set_script(load("res://carts/cpu_controls.gd"))
		for i in range(0,3):
			var npc = character_template.instance()
			$Players.add_child(npc)
			npc.get_node("Controls").set_script(load("res://carts/cpu_controls.gd"))
			npc.DisableControls(0)
			npc.position_id = i + 1
			npc.name = "Player" + str(i+2)
			npc.health = rules["Npc"].Hp
			npc.global_transform.origin = arena.GetSpawnPoints()[i+1]
			npc.add_to_group("Players")
			npc.balls = get_node("Balls")
			if i == 0:
				npc.rotate_y(deg2rad(180))
				npc.axis_lock_motion_z = true
			elif i == 1:
				npc.rotate_y(deg2rad(-90))
				npc.axis_lock_motion_x = true
			elif i == 2:
				npc.rotate_y(deg2rad(90))
				npc.axis_lock_motion_x = true
			for ability in rules["Npc"].Abilities:
				var skill = load("res://carts/abilities/" + ability + ".tscn").instance()
				npc.add_child(skill)
	else:
		for p in $Players.get_children():
			p.DisableControls(0)
			p.health = rules["Npc"].Hp
			p.ShowSkin()
		$Players.get_child(0).health = rules["Player"].Hp
		for b in $Balls.get_children():
			b.queue_free()
	gui.SetupGui()
	$CanvasLayer/AnimationTree.get("parameters/playback").start("3")

func StartGameCountdown(_pitaa_olla_joku_string_koska_godot:String)->void:
	# animPlayer.connect ei tee signaalia joten custom track "0" animaatioon
	set_process(true)
	set_physics_process(true)
	SpawnBall()
	ballTimer.start(1.0)

func _on_AutoWin_timeout():
	# output press X to randomize winner
	$CanvasLayer/GUI/ForceWin.show()
	$CanvasLayer/GUI/ForceWin/Button.grab_focus()

func _on_RestartGame_timeout():
	$CanvasLayer/GUI/ScoreScreen.hide()
	SetupGame()

func GameLost()->void:
	arena.DisableBlockers()
	arena.DisableScoringLines()
	$CanvasLayer/GUI/RetryMenu.show()
	$CanvasLayer/GUI/RetryMenu/VBoxContainer/Retry.grab_focus()
	score = [0,0,0,0]
	for p in $Players.get_children():
		p.get_node("Controls").set_script(null)


func _on_ReturnToMainMenu_timeout():
	$CanvasLayer/GUI/ScoreScreen/TextureRect.hide()
	var value = get_tree().change_scene("res://main_menu/MainMenu.tscn")
	if value != OK:
		push_error("failed to change scene")


func GetRewardName()->String:
	var chall:int = int(GameModes.selectedChallenge.x)
	var tName:String = ""
	match chall:
		1:
			tName = "trohpy_unlocked.png"
		2:
			tName = "gem_unlocked.png"
		3:
			tName = "crystal_unlocked.png"
		4:
			tName = "relic_unlocked.png"
		_:
			push_error("ei oo tollast rewardii: " + str(chall))
	return tName

func RandomWinner()->void:
	var winner:int = randi() % 3 + 1
	var winnerPlr:KinematicBody = $Players.get_child(winner)
	TestWin(winnerPlr)
	# animaatio

func TestWin(winner:KinematicBody)->void:
	#var winner:KinematicBody = gameTests.GetWinner()
	# round win
	if winner:
		$AutoWin.stop()
		$RestartGame.stop()
		ballTimer.stop()
		arena.DisableBlockers()
		arena.DisableScoringLines()
		$CanvasLayer/GUI/ScoreScreen.hide()
		$CanvasLayer/GUI/ForceWin.hide()
		score[winner.position_id] += 1
		gui.SetScore()
		# cup win
		var cupWinner:KinematicBody = gameTests.GetCupWinner(score, rules["WinCondition"].Wins)
		if cupWinner:
			if cupWinner.position_id == 0:
				SaveLoad.SaveProgress(int(GameModes.selectedChallenge.y), int(GameModes.selectedChallenge.x))
				$CanvasLayer/GUI/RewardScreen.show()
				$CanvasLayer/GUI/RewardScreen/TextureRect.texture = load("res://assets/rewards/" + GetRewardName()) 
				$ReturnToMainMenu.start(gui.menuOpenTime)
			else:
				GameLost()
		else:
			$CanvasLayer/GUI/ScoreScreen.show()
			$RestartGame.start(gui.menuOpenTime)
	# win animaatio

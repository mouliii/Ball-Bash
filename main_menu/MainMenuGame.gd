extends Spatial

onready var camera = get_node("Camera")
var camSpeed := 1.0
var mainCamActive:bool = true
onready var arena = get_node("MenuArena")
onready var ball_template = preload("res://assets/balls/Ball.tscn")
onready var character_template = preload("res://carts/Player.tscn")
onready var ballTimer = get_node("BallTimer")

var ballSpawnTime:float = 1.0
var maxActiveBalls:int = 4

func _ready():
	StartGame()
	SpawnBall()
	ballTimer.start(1.0)

func _process(delta):
	camera.look_at(Vector3(0,0,0), Vector3.UP)
	camera.translate(Vector3.RIGHT * camSpeed * delta)

func StartGame():
	for blocker in arena.get_node("Goal_barriers").get_children():
		blocker.get_child(0).disabled = true
		blocker.get_child(1).hide()
		
	var characterInstance = character_template.instance()
	$Players.add_child(characterInstance)
	characterInstance.position_id = 0
	characterInstance.health = 5
	characterInstance.global_transform.origin = arena.GetSpawnPoints()[0]
	characterInstance.axis_lock_motion_z = true
	characterInstance.add_to_group("Players")
	characterInstance.balls = get_parent().get_node("MenuGame/Balls")
	characterInstance.get_node("Controls").set_script(load("res://carts/cpu_controls.gd"))
	characterInstance.get_node("Controls").minReactionTime = 0.01
	characterInstance.get_node("Controls").maxReactionTime = 0.1
	for i in range(0,3):
		var npc = character_template.instance()
		$Players.add_child(npc)
		npc.get_node("Controls").set_script(load("res://carts/cpu_controls.gd"))
		npc.position_id = i + 1
		npc.health = 5
		npc.global_transform.origin = arena.GetSpawnPoints()[i+1]
		npc.add_to_group("Players")
		npc.balls = get_parent().get_node("MenuGame/Balls")
		npc.get_node("Controls").minReactionTime = 0.01
		npc.get_node("Controls").maxReactionTime = 0.1
		if i == 0:
			npc.rotate_y(deg2rad(180))
			npc.axis_lock_motion_z = true
		elif i == 1:
			npc.rotate_y(deg2rad(-90))
			npc.axis_lock_motion_x = true
		elif i == 2:
			npc.rotate_y(deg2rad(90))
			npc.axis_lock_motion_x = true
			
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

func StartBallTimer():
	ballTimer.start(ballSpawnTime)

func _on_BallTimer_timeout():
	if get_node("Balls").get_child_count() < maxActiveBalls:
		SpawnBall()
		ballTimer.start(ballSpawnTime)

func HealthChanged(_player:int, _damage:int):
	# ihan vaan koska signalia lentää kun painaa quit game
	pass


func _on_OptionsMenu_visibility_changed():
	mainCamActive = !mainCamActive
	if mainCamActive:
		$Camera.current = true
	else:
		$SettingsCamera.current = true


func _on_fov_slider_value_changed(value):
	$SettingsCamera.fov = value


func _on_fov_box_text_changed(new_text):
	var val:int = int(new_text)
	if val > 30:
		$SettingsCamera.fov = int(new_text)

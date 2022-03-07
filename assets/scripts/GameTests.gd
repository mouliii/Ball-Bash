extends Node


export var players:NodePath
var levelInfo:Dictionary = {}
var selectedLevel:Vector2 = Vector2(0,0)

func GetWinner()->KinematicBody:
	var alive:int = 0
	var winner:KinematicBody = null
	for p in get_node(players).get_children():
		if p.health > 0:
			alive += 1
			winner = p
	if alive > 1:
		return null
	else:
		return winner

func LoadRules(level:Vector2) -> Dictionary:
	return GameModes.levelRules["Level" + str(level.y)]["Challenge" + str(level.x)]

func GetCupWinner(score:Array, reqWins:int)->KinematicBody:
	var winner:KinematicBody = null
	for p in range(0, 4):
		if score[p] >= reqWins:
			winner = get_node(players).get_child(p)
			return winner
	return null

func LoadArenaModifiers(level:Vector2)->Array:
	var mods:Array = GameModes.levelRules["Level" + str(level.y)]["Challenge" + str(level.x)]["Arena"].Objects
	return mods







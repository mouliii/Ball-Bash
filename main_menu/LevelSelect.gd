extends Control

onready var levelList = get_node("LevelList")

func _ready():
	LoadIcons()
	var nLevels:int = 8
	for b in range(0,nLevels):
		var node = $GridContainer
		node.get_child(b).connect("pressed", self, "_on_button_pressed", [node.get_child(b)])
		node.get_child(b).connect("mouse_entered", self, "_on_mouse_enter", [node.get_child(b)])

func _on_mouse_enter(button)->void:
	button.grab_focus()

func _on_button_pressed(button)->void:
	var coords:Vector2 = Vector2()
	coords.y = int(int(button.name) / $GridContainer.columns)
	coords.x = int(int(button.name) % $GridContainer.columns)
	# offset, koska design spaghjewttos
	coords += Vector2(1,1)
	#print(coords)
	GameModes.selectedChallenge = coords
	
	var _load = get_tree().change_scene("res://levels/crash_ball/Main.tscn")

	if _load == OK:
		pass

func LoadIcons()->void:
	SaveLoad.LoadData()
	for x in range(0,SaveLoad.data.size() - 1, 4):
		# trophy
		if SaveLoad.data[x] == 0:
			$GridContainer.get_child(x).get_child(0).texture = load("res://assets/rewards/trohpy_locked2.png")
		else:
			$GridContainer.get_child(x).get_child(0).texture = load("res://assets/rewards/trohpy_unlocked.png")
		# gem
		if SaveLoad.data[x+1] == 0:
			$GridContainer.get_child(x+1).get_child(0).texture = load("res://assets/rewards/gem_locked2.png")
		else:
			$GridContainer.get_child(x+1).get_child(0).texture = load("res://assets/rewards/gem_unlocked.png")
		# crystal
		if SaveLoad.data[x+2] == 0:
			$GridContainer.get_child(x+2).get_child(0).texture = load("res://assets/rewards/crystal_locked2.png")
		else:
			$GridContainer.get_child(x+2).get_child(0).texture = load("res://assets/rewards/crystal_unlocked.png")
		# relic
		if SaveLoad.data[x+3] == 0:
			$GridContainer.get_child(x+3).get_child(0).texture = load("res://assets/rewards/relic_locked2.png")
		else:
			$GridContainer.get_child(x+3).get_child(0).texture = load("res://assets/rewards/relic_unlocked.png")

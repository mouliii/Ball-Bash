extends Spatial

signal ballDropped()

var ballSpawnPoints:Array = []
var lineColor:Dictionary = {"Blue": "009bff", "Red": "ff1000"}

func _ready():
	for cannon in $Cannons.get_children():
		var point = cannon.get_child(1)
		ballSpawnPoints.append(point.global_transform.origin)

func GetSpawnPoints() -> Array:
	var arr:Array = []
	for point in $Spawn_points.get_children():
		arr.append(point.global_transform.origin)
	return arr

func DisableBlockers()->void:
	for i in get_node("Goal_barriers").get_children():
		i.get_child(0).disabled = true
		i.get_child(1).hide()

func DisableScoringLines()->void:
	for i in get_node("Goal_lines").get_children():
		i.get_child(0).disabled = true
	get_node("RogueBallCatcher").monitoring = false

func EnableScoringLines()->void:
	for i in get_node("Goal_lines").get_children():
		i.get_child(0).disabled = false
	get_node("RogueBallCatcher").monitoring = true

func _on_RogueBallCatcher_body_exited(body):
	if get_node("RogueBallCatcher").monitoring:
		if body:
			if body.is_in_group("Balls"):
				body.queue_free()
				emit_signal("ballDropped")

func SetLineColor(color:Color, player:int)->void:
	$GoalLineMM.multimesh.set_instance_color(player, color)

func SetAllLines(color:Color)->void:
	for i in range(0,4):
		$GoalLineMM.multimesh.set_instance_color(i, color)

func SetLineColor_old(color:Color, player:int)->void:
	var mat:Material = get_node("Mesh/arena").get_node("line" + str(player)).mesh.surface_get_material(0)
	mat.albedo_color = color
	get_node("Mesh/arena").get_node("line" + str(player)).mesh.surface_set_material(0, mat)
#
func SetAllLines_old(color:Color)->void:
	for i in range(4):
		var mat:Material = get_node("Mesh/arena").get_node("line" + str(i)).mesh.surface_get_material(0)
		mat.albedo_color = color
		get_node("Mesh/arena").get_node("line" + str(i)).mesh.surface_set_material(0, mat)


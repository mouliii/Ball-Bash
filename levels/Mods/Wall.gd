extends Spatial

var spawnTime:float = 10.0
var duaration:float = 5.0
var spawnPoints:NodePath

func _ready():
	spawnPoints = "../Spawn_points"
	$MeshInstance.hide()
	$MeshInstance/StaticBody/CollisionShape.disabled = true
	$SpawnTimer.start(spawnTime)

func Spawn()->void:
	var pos:Vector3 = GetSpawnPoint()
	global_transform.origin = Vector3(pos.x,global_transform.origin.y, pos.z)
	global_transform = global_transform.looking_at(Vector3(0.0,global_transform.origin.y, 0.0), Vector3.UP)
	$MeshInstance.show()
	$MeshInstance/StaticBody/CollisionShape.disabled = false
	$DurationTimer.start(duaration)

func DisableWall()->void:
	$MeshInstance.hide()
	$MeshInstance/StaticBody/CollisionShape.disabled = true

func GetSpawnPoint()->Vector3:
	var rng:int = randi() % 3 + 1
	var pos:Vector3 = get_node(spawnPoints).get_child(rng).global_transform.origin
	return pos

func _on_SpawnTimer_timeout():
	Spawn()

func _on_DurationTimer_timeout():
	DisableWall()
	$SpawnTimer.start(spawnTime)

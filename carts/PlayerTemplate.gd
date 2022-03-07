extends KinematicBody

var isBot := false

export (NodePath) var balls

var position_id:int = -1
var speed:float = 400
var health:int = 5
var indicatorColor:Color

var forceAvailable:bool = true
const forcePushRadius := 1.8
var forcePushCooldown:float = 3.0
const forceInternalCD := 0.3

func _ready():
	var mesh:Mesh = $Mesh/Cart.mesh.duplicate(true)
	var material:Material = $Mesh/Cart.get_active_material(0).duplicate(true)
	$Mesh/Cart.mesh = mesh
	$Mesh/Cart.mesh.surface_set_material(0, material)

func SetPosition(pos:Vector3)->void:
	global_transform.origin = pos

func TriggerDeath():
	#todo animation
	$Mesh.hide()
	$CollisionShape.disabled = true
	if get_node_or_null("ForcePush"):
		get_node("ForcePush").DisableAll()
	if get_node_or_null("ForceMagnet"):
		get_node("ForceMagnet").DisableAll()

func ShowSkin()->void:
	$Mesh.show()
	$CollisionShape.disabled = false

func ChangeCartColor(color:Color)->void:
	var material:Material = $Mesh/Cart.get_active_material(0)
	material.albedo_color = color
	$Mesh/Cart.mesh.surface_set_material(0, material)

func ChangeIndicatorColor(color)->void:
	pass # asdfasd

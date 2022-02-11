extends KinematicBody

# interpolate visuals smoothning transforms
var old_visual_transform:Transform = Transform()
var visual_transfrom:Transform = Transform()
#onready var balls = get_parent().get_node("Balls")
export (NodePath) var balls

var position_id:int = -1
var speed:float = 400
var health:int = 5

var forceAvailable:bool = true
const forcePushRadius := 1.8
var forcePushCooldown:float = 3.0
const forceInternalCD := 0.3

func _ready():
	old_visual_transform = get_node("Mesh").global_transform
	visual_transfrom = get_node("Mesh").global_transform

# interpolate visuals
func _process(_delta):
	visual_transfrom = old_visual_transform.interpolate_with(visual_transfrom, \
		Engine.get_physics_interpolation_fraction())

func _physics_process(_delta):
	old_visual_transform = visual_transfrom

func TriggerDeath():
	#todo animation
	$Mesh.hide()
	$CollisionShape.disabled = true
	DisableControls(1)
	if get_node_or_null("ForcePush"):
		get_node("ForcePush").DisableAll()
	if get_node_or_null("ForceMagnet"):
		get_node("ForceMagnet").DisableAll()

func ChangeIndicatorColor(color:Color)->void:
	var material:Material = $Mesh/Indicator.get_active_material(0)
	material.albedo_color = color
	$Mesh/Indicator.mesh.surface_set_material(0, material)

func _on_Timer_timeout():
	ChangeIndicatorColor(Color(2,2,0))

func _on_CPU_forceReaction_timeout():
	pass # Replace with function body.

func ShowSkin()->void:
	$Mesh.show()
	$CollisionShape.disabled = false

func DisableControls(value:bool)->void:
	$Controls.set_physics_process(false if value else true)

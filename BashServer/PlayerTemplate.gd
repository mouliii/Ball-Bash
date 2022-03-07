extends KinematicBody

onready var balls = get_node("../../Balls")
var isBot := false

var position_id:int = -1
var speed:float = 400
var health:int = 5
var indicatorColor:Color

var forceAvailable:bool = true
const forcePushRadius := 1.8
var forcePushCooldown:float = 3.0
const forceInternalCD := 0.3

func _ready():
	DisableBot()

func DisableBot()->void:
	$CollisionShape.disabled = true
	$Node.set_physics_process(false)

func EnableBot()->void:
	$CollisionShape.disabled = false
	$Node.set_physics_process(true)

func ChangeIndicatorColor(color)->void:
	pass # asdfasd

extends Spatial

signal indicatorColor()

var forceAvailable:bool = true
var forcePushCooldown:float = 3.0
const forceInternalCD := 0.3
const forcePushRadius := 1.8


func _ready():
	var shape:CylinderShape = CylinderShape.new()
	shape.radius = forcePushRadius
	shape.height = 0.76
	$ForcePushArea/CollisionShape.shape = shape
	$ForcePushArea/CollisionShape.disabled = true
	# warning-ignore:return_value_discarded
	self.connect("indicatorColor", get_parent(), "ChangeIndicatorColor")

func UseForcePush()->void:
	$ForcePushArea/CollisionShape.disabled = false
	$Particles.emitting = true
	if TestForOverlap():
		forceAvailable = true
		emit_signal("indicatorColor", Color(2,2,0))
	else:
		forceAvailable = false
		$ForcePushArea/CollisionShape.disabled = true
		$Cooldown.start(forcePushCooldown)
		emit_signal("indicatorColor", Color(2,0,0))

func _on_ForcePushArea_body_entered(body)->void:
	if body.is_in_group("Balls"):
		var player_pos =  Vector2($Position3D.global_transform.origin.x, $Position3D.global_transform.origin.z)
		var ball_pos = Vector2(body.global_transform.origin.x, body.global_transform.origin.z)
		var delta_pos = ball_pos - player_pos;
		#var angleToBall = atan2(player_pos.y - ball_pos.y, player_pos.x - ball_pos.x)
		var new_dir = delta_pos.normalized()
		body.direction = Vector3(new_dir.x, 0, new_dir.y)
		body.SetSpeed(body.pushSpeed)
	$ForcePushArea/CollisionShape.set_deferred("disabled", true)

func CanUseForcePush()->bool:
	return forceAvailable


func TestForOverlap()->bool:
	for ball in get_parent().balls.get_children():
		var ballPos:Vector2 = Vector2(ball.global_transform.origin.x, ball.global_transform.origin.z)
		var playerPos:Vector2 = Vector2(get_parent().global_transform.origin.x, get_parent().global_transform.origin.z)
		if ballPos.distance_to(playerPos) < forcePushRadius:
			return true
	return false

func CPUForceAvalable()->bool:
	if forceAvailable && $CPU_forceReaction.is_stopped() && $CPU_force_internalCD.is_stopped():
		return true
	else:
		return false

func _on_CPU_forceReaction_timeout():
	pass # Replace with function body.


func _on_CPU_force_internalCD_timeout():
	pass # Replace with function body.


func _on_Cooldown_timeout():
	forceAvailable = true
	emit_signal("indicatorColor", Color(2,2,0))

func DisableAll()->void:
	$Cooldown.stop()
	$CPU_forceReaction.stop()
	$CPU_force_internalCD.stop()
	$ForcePushArea/CollisionShape.disabled = true
	$Particles.emitting = false
	
func Reset()->void:
	forceAvailable = true

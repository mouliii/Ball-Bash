extends Spatial

signal changeColor()

var maxHoldTime:float = 5.0
var attachedBalls:Dictionary = {}
var isActive:bool = false


func _ready():
	# warning-ignore:return_value_discarded
	self.connect("changeColor", get_parent(), "ChangeIndicatorColor")
	# local to scene vissii bugaa 3.x versioissa nii pitää duplicatee
	var uniqueMat:Material = $Magnet.mesh.surface_get_material(0).duplicate()
	$Magnet.mesh.surface_set_material(0, uniqueMat)
	$AreaMagnet/CollisionShape.disabled = true
	set_process(false)

func _process(_delta):
	for i in attachedBalls.keys():
		var ball:KinematicBody = attachedBalls[i].name
		ball.global_transform.origin = global_transform.origin + attachedBalls[i].offset
	var color:Color = lerp(Color(1,1,0), Color(1,0,0), 1 - ($HoldTimer.time_left / maxHoldTime))
	emit_signal("changeColor", color)

func ActivateMagnet()->void:
	$Magnet.show()
	$AreaMagnet/CollisionShape.disabled = false
	isActive = true
	$HoldTimer.start(maxHoldTime)
	$AnimationPlayer.play("pulsing")
	set_process(true)

func ShootBalls()->void:
	$Magnet.hide()
	for i in attachedBalls.keys():
		var ball:KinematicBody = attachedBalls[i].name
		var dir:Vector3 = (global_transform.origin - ball.global_transform.origin).normalized()
		ball.direction = dir
		ball.SetSpeed(ball.magnetLaunchSpeed)
	attachedBalls.clear()
	DeactivateMagnet()

func DeactivateMagnet()->void:
	$Magnet.hide()
	$AreaMagnet/CollisionShape.disabled = true
	$AnimationPlayer.stop()
	for i in attachedBalls.keys():
		var ball:KinematicBody = attachedBalls[i].name
		var dir:Vector3 = (global_transform.origin - ball.global_transform.origin).normalized()
		ball.direction = dir
		ball.SetSpeed(ball.magnetSlowSpeed)
	attachedBalls.clear()
	var push = get_node_or_null("../ForcePush")
	if push:
		if push.forceAvailable:
			emit_signal("changeColor", Color(1,1,0))
		else:
			emit_signal("changeColor", Color(1,0,0))
	else:
		emit_signal("changeColor", Color(1,0,0))
	isActive = false
	set_process(false)

func _on_AreaMagnet_body_entered(body):
	if body.is_in_group("Balls"):
		var pos:int = len(attachedBalls.keys())
		var offset:Vector3 = body.global_transform.origin - global_transform.origin
		attachedBalls[pos] = {"name":body, "offset": offset}
		body.speed = 0
		body.direction = Vector3(0,0,0)

func _on_HoldTimer_timeout():
	DeactivateMagnet()

func DisableAll():
	$Magnet.hide()
	$AreaMagnet/CollisionShape.disabled = true
	$AnimationPlayer.stop()
	$HoldTimer.stop()
	if !attachedBalls.empty():
		ShootBalls()
	attachedBalls.clear()
	isActive = false


func _on_CPU_ReleaseTimer_timeout():
	ShootBalls()

extends Spatial

onready var parent = get_parent()
var old_transform:Transform = Transform()
var target_transform:Transform = Transform()
var isSide:bool = false

func _ready():
	old_transform = get_node("../Mesh").global_transform
	target_transform = get_node("../Mesh").global_transform

func _physics_process(delta):
	
	if Input.is_action_just_pressed("force_magnet"):
		var magnet = get_node_or_null("../ForceMagnet")
		if magnet:
			if !magnet.isActive:
				magnet.ActivateMagnet()
	elif Input.is_action_just_released("force_magnet"):
		var magnet = get_node_or_null("../ForceMagnet")
		if magnet:
			magnet.ShootBalls()
	
	if Input.is_action_just_pressed("force_push"):
		var push = get_node_or_null("../ForcePush")
		var magnet = get_node_or_null("../ForceMagnet")
		var canUsePush:bool = false
		if magnet:
			canUsePush = false if magnet.isActive else true
		else:
			canUsePush = true
		# push skill
		if push and canUsePush:
			if push.forceAvailable:
				push.UseForcePush()
	# ei jaksa enään säätää
	match parent.position_id:
		0:
			var input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			var vel = transform.basis.x * input * parent.speed * delta
			var newPos = global_transform.origin.move_toward(global_transform.origin + vel, parent.speed * delta * delta)
			newPos.x = clamp(newPos.x, -2.7, 2.7)
			parent.global_transform.origin = newPos
		1:
			var input = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
			var vel = transform.basis.x * input * parent.speed * delta
			var newPos = global_transform.origin.move_toward(global_transform.origin + vel, parent.speed * delta * delta)
			newPos.x = clamp(newPos.x, -2.7, 2.7)
			parent.global_transform.origin = newPos
		2:
			var input = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
			var vel = -transform.basis.z * input * parent.speed * delta
			var newPos = global_transform.origin.move_toward(global_transform.origin + vel, parent.speed * delta * delta)
			newPos.z = clamp(newPos.z, -2.7, 2.7)
			parent.global_transform.origin = newPos
		3:
			var input = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
			var vel = transform.basis.z * input * parent.speed * delta
			var newPos = global_transform.origin.move_toward(global_transform.origin + vel, parent.speed * delta * delta)
			newPos.z = clamp(newPos.z, -2.7, 2.7)
			parent.global_transform.origin = newPos

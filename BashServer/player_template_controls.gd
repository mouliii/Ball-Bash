extends Node

onready var parent = get_parent()
var target:KinematicBody = null
var lastTarget:KinematicBody = null
var cartOffset:float = 0.0

var minReactionTime := 0.1
var maxReactionTime := 0.2
var minOffsetValue := -1.0
var maxOffsetValue := 1.0
var maxReactionDistance := 3.0

func _init():
	parent = get_parent()

func _ready():
	pass

func _physics_process(delta):
	#var input:int = 0
	#var vel:Vector3 = Vector3()
	# asd
	var targetPos:Vector3 = Vector3()
	if parent.position_id  <= 1:
		target = FindTarget()
		if target != lastTarget:
			cartOffset = GetRandomCartOffset()
		if target:
			# asd
			targetPos = target.global_transform.origin
			if target.global_transform.origin.x > parent.global_transform.origin.x + cartOffset:
				pass#input = 1
			else:
				pass#input = -1
		else:
			# asd
			targetPos = Vector3(0,parent.global_transform.origin.y, parent.global_transform.origin.z)
			if parent.global_transform.origin.distance_to(Vector3(0,parent.global_transform.origin.y,parent.global_transform.origin.z)) > 0.2:
				if 0 > parent.global_transform.origin.x:
					pass#input = 1
				else:
					pass#input = -1
	# sivu pelaajat
	else:
		target = FindTarget()
		if target != lastTarget:
			cartOffset = GetRandomCartOffset()
		if target:
			# asd
			targetPos = target.global_transform.origin
			if target.global_transform.origin.z > parent.global_transform.origin.z + cartOffset:
				pass#input = 1
			else:
				pass#input = -1
		else:
			# asd
			targetPos = Vector3(parent.global_transform.origin.x,parent.global_transform.origin.y, 0)
			if parent.global_transform.origin.distance_to(Vector3(parent.global_transform.origin.x,parent.global_transform.origin.y,0)) > 0.2:
				if 0 > parent.global_transform.origin.z:
					pass#input = 1
				else:
					pass#input = -1

	if target:
		var magnet = get_node_or_null("../ForceMagnet")
		if magnet:
			if target != lastTarget:
				if randf() > 0.9:
					if !magnet.isActive:
						if -target.direction.dot(-parent.transform.basis.z) > 0:
							var holdTimer:int = randi() % 5 + 1
							magnet.ActivateMagnet()
							magnet.get_node("CPU_ReleaseTimer").start(holdTimer)
		var push = get_node_or_null("../ForcePush")
		if push:
			if magnet:
				if !magnet.isActive:
					UsePush(push)
			else:
				UsePush(push)
	lastTarget = target


	if parent.position_id  <= 1:
		#vel = transform.basis.x * input * parent.speed * delta
		var newpos = parent.global_transform.origin.move_toward( \
			Vector3(targetPos.x ,parent.global_transform.origin.y, parent.global_transform.origin.z), parent.speed * delta * delta)
		newpos.x = clamp(newpos.x, -2.7, 2.7)
		parent.global_transform.origin = newpos
	else:
		#vel = transform.basis.z * input * parent.speed * delta
		var newpos = parent.global_transform.origin.move_toward( \
			Vector3(parent.global_transform.origin.x, parent.global_transform.origin.y, targetPos.z), parent.speed * delta * delta)
		newpos.z = clamp(newpos.z, -2.7, 2.7)
		parent.global_transform.origin = newpos

func FindTarget() -> KinematicBody:
	for ball in parent.balls.get_children():
		if (-ball.direction.dot(-parent.transform.basis.z) > 0):
			if ball.global_transform.origin.distance_to(parent.global_transform.origin) < maxReactionDistance:
				return ball
	return null

func UsePush(push)->void:
	if push.CPUForceAvalable():
		if target.global_transform.origin.distance_to(parent.global_transform.origin) < parent.forcePushRadius:
			if -target.direction.dot(-parent.transform.basis.z) > 0:
				push.UseForcePush()
				push.get_node("CPU_force_internalCD").start(push.forceInternalCD)
				push.get_node("CPU_forceReaction").start(GetRandomReactionTime())
				get_node("/root/Online").UseSkill(int(parent.name), "ForcePush", " ")

func GetRandomCartOffset()->float:
	var rand:float = rand_range(minOffsetValue, maxOffsetValue)
	return rand

func GetRandomReactionTime()->float:
	var rand:float = rand_range(minReactionTime, maxReactionTime)
	return rand

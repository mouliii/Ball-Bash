extends KinematicBody

signal goal(player, damage)

var minSpeed := 200.0
var maxSpeed := 900.0
var speed := 280.0
var pushSpeed := 320.0
var magnetLaunchSpeed := 650.0
var magnetSlowSpeed := 230.0
var direction := Vector3.ONE
var velocity := Vector3()
var spawnUpwardMomentum:float = 2.0

func _ready():
	add_to_group("Balls")
	$AddListening.start(0.6)

func _physics_process(delta):
	var old_vy = velocity.y
	velocity = direction * speed * delta
	velocity.y = old_vy
	velocity.y -= 6 * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name != "Floor":
			#transform.origin.y = 0.2 #
			direction = direction.bounce(collision.normal)
			if collision.collider.is_in_group("Balls"):
				var collidingBall:KinematicBody = collision.collider
				collidingBall.direction = collidingBall.direction.bounce(collision.normal * -1)
				#collidingBall.speed = clamp(collidingBall.speed, collidingBall.minSpeed, collidingBall.maxSpeed)
			elif collision.collider.is_in_group("Players"):
				pass
				# warning-ignore:return_value_discarded
				#move_and_collide(velocity * \
				#	 global_transform.origin.direction_to(-collision.collider.global_transform.origin) * delta)
			#direction.y = 0.0
	speed = clamp(speed, minSpeed, maxSpeed)

func LaunchBall():
	randomize()
	direction = global_transform.origin.direction_to(Vector3())
	direction.y = 0		# 5 deg+/-
	var rand = rand_range(-0.087,0.087)
	direction = direction.rotated(Vector3.UP, rand)
	# initial height
	velocity.y = spawnUpwardMomentum

func _on_Area_area_entered(area):
	# layer/mask ei toimi areassa (jostain syystä) +1 tää triggeröity uudes skillis
	# tai sit reversee tän ja if area.name == semihintänpitäsosuu
	# atm en muista
	if area.name == "ForcePushArea":
		return
	if area.name == "AreaMagnet":
		return
	emit_signal("goal", int(area.name), 1)
	$RemoveBall.start(0.5)

func _on_Timer_timeout():
	remove_from_group("Balls")
	queue_free()

func _on_AddListening_timeout():
	# ei toimi vaikka mitä koittais, aina mahd. tippuu spawnin aikana
	get_node("Area").monitorable = true
	get_node("Area").monitoring = true
	get_node("Area/CollisionShape").disabled = false

func SetSpeed(setSpeed:float)->void:
	if speed > setSpeed:
		return
	speed = setSpeed

func GetBallRadius()->float:
	var radius:float = $CollisionShape.shape.radius
	return radius

tool
extends Spatial

export var Setup: bool = false setget set_positions 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_positions(_val:bool)->void:
	for i in range(0,4):
		var pos:Vector3 = get_node("../../arena/Spawn_points").get_child(i).global_transform.origin
		var cartTransform:Transform = Transform(Basis(), Vector3())
		var indTransform:Transform = Transform(Basis(), Vector3())
		#newTransform = newTransform.rotated(Vector3.RIGHT, deg2rad(-90))
		match i:
			0:
				cartTransform = cartTransform.rotated(Vector3.UP, deg2rad(0))
				cartTransform.origin = pos + Vector3(0, 0.226, 0.252)
				indTransform = indTransform.rotated(Vector3.UP, deg2rad(0))
				indTransform.origin = pos + Vector3(0, 0.365, -0.254)
			1:
				cartTransform = cartTransform.rotated(Vector3.UP, deg2rad(180))
				cartTransform.origin = pos + Vector3(0, 0.226, -0.252)
				indTransform = indTransform.rotated(Vector3.UP, deg2rad(0))
				indTransform.origin = pos + Vector3(0, 0.365, 0.254)
			2:
				cartTransform = cartTransform.rotated(Vector3.UP, deg2rad(-90))
				cartTransform.origin = pos + Vector3(-0.252, 0.226, 0.0)
				indTransform = indTransform.rotated(Vector3.UP, deg2rad(0))
				indTransform.origin = pos + Vector3(0.254, 0.365, 0.0)
			3:
				cartTransform = cartTransform.rotated(Vector3.UP, deg2rad(90))
				cartTransform.origin = pos + Vector3(0.252, 0.226, 0)
				indTransform = indTransform.rotated(Vector3.UP, deg2rad(0))
				indTransform.origin = pos + Vector3(-0.254, 0.365, 0.0)
		$Carts.multimesh.set_instance_color(i,Color("308300"))#308300
		$Carts.multimesh.set_instance_transform(i, cartTransform)
		$Indicator.multimesh.set_instance_transform(i, indTransform)
		$Indicator.multimesh.set_instance_color(i, Color.yellow)

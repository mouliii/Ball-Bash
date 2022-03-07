tool
extends MultiMeshInstance

export var Setup: bool = false setget set_positions 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_positions(_val:bool)->void:
	for i in range(0,4):
		var pos:Vector3 = get_node("../Spawn_points").get_child(i).global_transform.origin
		var newTransform:Transform = Transform(Basis(), Vector3())
		newTransform = newTransform.rotated(Vector3.RIGHT, deg2rad(-90))
		if i > 1:
			newTransform = newTransform.rotated(Vector3.UP, deg2rad(-90))
		newTransform.origin = pos * 1.01
		self.multimesh.set_instance_transform(i, newTransform)
		self.multimesh.set_instance_color(i, Color("009bff"))
		# .looking_at(Vector3(0,0,0),Vector3.UP)

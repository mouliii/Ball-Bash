extends Node


func CanUseForcePush()->bool:
	return get_parent().get_node("ForcePush").CanUseForcePush()

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("force_push"):
		if get_parent().get_node_or_null("ForcePush"):
			if CanUseForcePush():
				get_node("/root/Online").SendSkillUse(get_tree().get_network_unique_id(), "ForcePush", " ")

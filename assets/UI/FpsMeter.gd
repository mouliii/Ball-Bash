extends Control

const fps:String = "Fps: "

func _process(_delta):
	$Label.text = fps + str(Engine.get_frames_per_second())

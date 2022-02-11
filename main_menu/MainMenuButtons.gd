extends Control

onready var container = get_node("MainMenuContainer")

func _ready():
	get_tree().paused = false
	container.get_node("Play").grab_focus()
	for button in container.get_children():
		button.connect("mouse_entered", self, "_on_mouse_enter", [button])

func _on_mouse_enter(button:Button)->void:
	button.grab_focus()


func _on_Play_pressed():
	container.hide()
	get_node("Mode").show()
	get_node("Mode/VBoxContainer").show()
	get_node("Mode/VBoxContainer/Single").grab_focus()


func _on_Options_pressed():
	get_node("MainMenuContainer").hide()
	get_node("OptionsMenu").show()


func _on_Quit_pressed():
	get_tree().quit()

func ShowMainMenu()->void:
	container.show()
	get_node("MainMenuContainer/Play").grab_focus()

extends Control

# Declare member variables here.
@export var start_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect button signals
	$StartButton.pressed.connect(_on_start_button_pressed)

# Start game button pressed
func _on_start_button_pressed():
	if start_scene:
		get_tree().change_scene_to_packed(start_scene)
		
# Exit button pressed
func _on_exit_button_pressed():
	get_tree().quit()

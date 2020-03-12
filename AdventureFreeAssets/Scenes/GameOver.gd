extends Control

onready var restart_game_button: Button = $RestartGame

onready var quit_button: Button = $QuitToMenu
onready var anim_quit_button: AnimationPlayer = $QuitToMenu/AnimationPlayer

func _ready():
	quit_button.connect("pressed", self, "_on_quit_button_pressed")
	pass

func _on_quit_button_pressed():
	anim_quit_button.play("pressed")
	
func _set_button_position():
	quit_button.set_position(Vector2(1.500, 175 ))
	

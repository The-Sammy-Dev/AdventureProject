extends Control


onready var anim_back_options: Button = $InOptions/Back/AnimBackButton
onready var back_options_button: Button = $InOptions/Back
onready var in_options_button: Control = $InOptions

onready var anim_water: AnimationPlayer = $Water/AnimationPlayer
onready var anim_main_menu: AnimationPlayer = $AnimMainMenu

var _mouse_entered
onready var anim_player: AnimatedSprite = $AnimatedSprite

onready var play_game_button: Button = $Buttons/PlayButton
onready var anim_play_game_button: AnimationPlayer = $Buttons/PlayButton/AnimPlayGame

onready var options_button: Button = $Buttons/Options
onready var anim_options_button: AnimationPlayer = $Buttons/Options/AnimOptions
var _can_mouse_entered = true

onready var credits_button: Button = $Buttons/Credits
onready var anim_credits_button: AnimationPlayer = $Buttons/Credits/AnimCredits

onready var exit_game_button: Button = $Buttons/ExitGame
onready var anim_exit_game_button: AnimationPlayer = $Buttons/ExitGame/AnimExitGame

func _ready():
	anim_water.play("water_idle")
	anim_player.play("idle")
	in_options_button.visible = false
	
	play_game_button.connect("mouse_entered", self, "_on_PlayButton_mouse_entered")
	play_game_button.connect("mouse_exited", self, "_on_PlayButton_mouse_exited")
	play_game_button.connect("pressed", self, "_on_PlayButton_pressed")
	
	options_button.connect("mouse_entered", self, "_on_OptionsButton_mouse_entered")
	options_button.connect("mouse_exited", self, "_on_OptionsButton_mouse_exited")
	options_button.connect("pressed", self, "_on_OptionsButton_pressed")
	back_options_button.connect("pressed", self, "_on_BackOptions_pressed")
	
	credits_button.connect("mouse_entered", self, "_on_CreditsButton_mouse_entered")
	credits_button.connect("mouse_exited", self, "_on_CreditsButton_mouse_exited")
	credits_button.connect("pressed", self, "_on_CreditsButton_pressed")
	
	
	exit_game_button.connect("mouse_entered", self, "_on_ExitButton_mouse_entered")
	exit_game_button.connect("mouse_exited", self, "_on_ExitButton_mouse_exited")
	exit_game_button.connect("pressed", self, "_on_ExitButton_pressed")

# PLAY BUTTON

func _on_PlayButton_pressed():
	pass

func _on_PlayButton_mouse_entered():
	$Buttons/PlayButton/Label.modulate = Color(.3, .3, .3)
	anim_play_game_button.play("Hover")

func _on_PlayButton_mouse_exited():
	$Buttons/PlayButton/Label.modulate = Color(0, 0, 0)
	anim_play_game_button.play("Hover_end")


# OPTIONS BUTTON

func _on_OptionsButton_pressed():
	_block_signals(true)
	options_button.set_block_signals(true)
	anim_options_button.play("pressed")
	yield(anim_options_button,"animation_finished")
	anim_main_menu.play("any_button_pressed")
	yield(anim_main_menu,"animation_finished")
	print("terminou")
	in_options_button.visible = true
	anim_main_menu.play("in_options")
	_block_signals(false)
	anim_back_options.play("idle")
	
func _on_OptionsButton_mouse_entered():
	anim_options_button.play("Hover")
#	$Buttons/Options/Label.modulate = Color(.3, .3, .3)

func _on_OptionsButton_mouse_exited():
	anim_options_button.play("Hover_end")
#	$Buttons/Options/Label.modulate = Color(0, 0, 0)

func _on_BackOptions_pressed():
	
	anim_back_options.play("pressed")
	yield(anim_back_options,"animation_finished")
	anim_main_menu.play_backwards("in_options")
	yield(anim_main_menu,"animation_finished")
	anim_main_menu.play("playbackwards_pressed")
#	_when_any_button_is_pressed(true, true, true, true)
# CREDITS BUTTON

func _on_CreditsButton_pressed():
	pass

func _on_CreditsButton_mouse_entered():
	anim_credits_button.play("Hover")
	$Buttons/Credits/Label.modulate = Color(.3, .3, .3)
	
func _on_CreditsButton_mouse_exited():
	anim_credits_button.play("Hover_end")
	$Buttons/Credits/Label.modulate = Color(0, 0, 0)
	
# EXIT BUTTON

func _on_ExitButton_pressed():
	_block_signals(true)
	anim_exit_game_button.play("pressed")
	yield(anim_exit_game_button,"animation_finished")
	get_tree().quit()
	
func _on_ExitButton_mouse_entered():
	$Buttons/ExitGame/Label.modulate = Color(.3, .3, .3)
	anim_exit_game_button.play("Hover")
	
func _on_ExitButton_mouse_exited():
	$Buttons/ExitGame/Label.modulate = Color(0, 0, 0)
	anim_exit_game_button.play("Hover_end")

func _when_any_button_is_pressed(PlayButton: bool, 
								OptionsButton: bool, 
								CreditsButton: bool,
								 ExitButton: bool):
	if PlayButton:
		anim_play_game_button.play_backwards("pressed",1)
	if OptionsButton:
		anim_options_button.play_backwards("pressed",1 )
	if CreditsButton:
		anim_credits_button.play_backwards("pressed",1 )
	if ExitButton:
		anim_exit_game_button.play_backwards("pressed", 1)

func _block_signals(_true_or_false: bool):
	play_game_button.set_block_signals(_true_or_false)
	options_button.set_block_signals(_true_or_false)
	credits_button.set_block_signals(_true_or_false)
	exit_game_button.set_block_signals(_true_or_false)
	
	

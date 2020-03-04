extends Control

onready var anim = $Anim
onready var resume_button: Button = $ResumeButton
onready var options_button: Button = $OptionsButton
onready var exit_button: Button = $ExitButton
onready var sound_bar: HSlider = $SoundBar
onready var in_options_button = false
onready var effects_bar: HSlider = $SoundsEffects

func _ready() -> void:
	sound_bar.visible = false
	effects_bar.visible = false
	
	Event.connect("game_paused", self, "_on_Event_game_pause")
	resume_button.connect("pressed", self, "_on_resume_button_pressed")
	options_button.connect("pressed", self, "_on_options_button_pressed")
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("input_pause"):
		_pause_and_resume()
		
func _pause_and_resume():
	if anim.current_animation_position > 0 and in_options_button:return
	if get_tree().paused :
		if in_options_button:
			sound_bar.visible = false
			effects_bar.visible = false
			_button_visible(true)
			anim.play("pause")
			yield(anim, "animation_finished")
			in_options_button = false
			return
		else:
			anim.play_backwards("pause", 1)
			yield(anim, "animation_finished")
			visible = false
	
	else:
		visible = true
		_button_visible(true)
		anim.play("pause")
		
	get_tree().paused = !get_tree().paused
	
func _on_options_button_pressed():
	if get_tree().paused == true:
		in_options_button = true
		anim.play_backwards("pause", 1)
		
		yield(anim, "animation_finished")
		
		_button_visible(false)
		sound_bar.visible = true
		effects_bar.visible = true
	
func _on_Event_game_pause():
	visible = true
	anim.play("pause")
	get_tree().paused = true

func _on_resume_button_pressed():
	_resume_game()

func _button_visible(_visible: bool):
	resume_button.visible = _visible
	options_button.visible = _visible
	exit_button.visible = _visible
	
func _resume_game():
	anim.play_backwards("pause", 1)
	
	yield(anim, "animation_finished")
	
	visible = false
	get_tree().paused = false
	Event.emit_signal("resume_game")
	

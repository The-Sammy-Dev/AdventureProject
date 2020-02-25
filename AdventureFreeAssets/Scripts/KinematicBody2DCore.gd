extends KinematicBody2D

class_name KinematicBody2DCore

enum states {idle, run, walking, jump, attack, dead}
enum types {player, enemy}

export (types) var type = types.player
export (int) var walk_speed = 120
export (int) var run_speed = 450
export (int) var jump_speed = -800
export (int) var maxGravity = 40
onready var gravity = maxGravity
export (int) var maxLife = 6
export (bool) var showBarLife: bool = true
export (float) var powerAttack: float = 2.0
var hiting = 0
var dirHiting = 1

var floating = false
var speed = 1
var WATER_K = .25
var water = null
var water_height

signal gameover

var bodyEntered: KinematicBody2DCore
var velocity = Vector2.ZERO
var life
var state
var anim
var new_anim
var jumping = false
var attacking = false
var dying = false
var buoyancy = 0

func _ready() -> void:
	# Adiciona ao grupo dos "types" -> player ou enemy
	add_to_group(Common._findState(type, types))
	gravity = maxGravity
	
	life = maxLife
	if has_node("barlife"):
		$barlife.min_value = 0
		$barlife.max_value = maxLife
		$barlife.hide()
	
	
	# Conecta o sprite das animações
	$sprite.connect("animation_finished", self, "_on_sprite_animation_finished")
	# Conecta a área para detecção de ataque
	$area_attack.connect("body_entered", self, "_on_area_attack_body_entered")
	$area_attack.connect("body_exited", self, "_on_area_attack_body_exited")
	$area_attack.connect("area_entered", self, "_on_area_attack_area_entered")
	
	# Coloca o personagem como IDLE
	_change_state(states.idle)

func _change_state(new_state) -> void:
	# Muda a animação e o state machine
	state = new_state
	new_anim = Common._findState(state, states)

func _get_input() -> void:
	# Aqui escutamos os controles
	
	# Se o tipo desse personagem não for player, então ignora os controles
	if type != types.player: return
	
	# Se estiver morrendo, não escuta mais os controles
	if dying: return
	
	velocity.x = 0
	
	# Obtém os sinais dos controles: True / False
	var right:bool = Input.is_action_pressed('ui_right')
	var left:bool = Input.is_action_pressed('ui_left')
	var jump:bool = Input.is_action_just_pressed('ui_select') || Input.is_action_just_pressed('ui_up')
	var run:bool = Input.is_action_pressed('ui_run')
	var attack:bool = Input.is_action_pressed('ui_attack')
	
	# Se é pra atacar, mas não estiver pulando
	if attack and !jumping:
		attacking = true
	
	# Controla a velocidade, inicia com velocidade de caminhada: walking
	var speed = walk_speed
	var state_walking = states.walking
	if run: # Se estiver segurando tecla de corrida, sobrescreve a velocidade e o state
		speed = run_speed
		state_walking = states.run

	# Se é pra pular e estiver no chão
	if jump and (is_on_floor() or weakref(water).get_ref()):
		attacking = false
		if !water:
			jumping = true
			_playAudioSfx(str(Common._findState(states.jump, states), "_up")) # Executa o audio
			_change_state(states.jump)
		if water:
			buoyancy = 30
		else:
			velocity.y = jump_speed
	# Se é pra andar para direita, mas não está atacando
	if right and !attacking:
		_change_state(state_walking)
		velocity.x += speed
	# Se é pra andar para esquerda, mas não está atacando
	if left and !attacking:
		_change_state(state_walking)
		velocity.x -= speed

	# Se estiver se movimentando, pega a direção
	if velocity.x != 0:
		$sprite.flip_h = velocity.x < 0
	
	# Se não está pulando e não está atacando
	if !jumping and !attacking:
		# Se soltou ou apertou as duas direções ao mesmo tempo, volta pra IDLE
		if (!right and !left) or (left and right):
			_change_state(states.idle)

func _process(delta) -> void:
	# Em process vamos controlar os states e animações!
	# Como o process se baseia no processamento do hardware, aqui é o melhor lugar para isso
	# Aqui não vamos controlar a física!

	# Se estiver morrendo, sai do _process()
	if dying: return
	
	# Obtém os controles
	_get_input()
	
	# Apenas pegamos qual o nome do state de jump e de attack
	var jump_anim = Common._findState(states.jump, states)
	var attack_anim = Common._findState(states.attack, states)
	
	# Se estiver pulando, e a animação atual não for pulando
	if jumping and $sprite.animation != jump_anim:
		# reseta a animação
		$sprite.frame = 0
		$sprite.play(jump_anim)
		return # para aqui
	
	# Se estiver atacando, e a animação atual não for atacando
	if attacking and $sprite.animation != attack_anim:
		# reseta a animação
		$sprite.frame = 0
		$sprite.play(attack_anim)
		_playAudioSfx(attack_anim) # Executa o audio
		
		if weakref(bodyEntered).get_ref():
			if bodyEntered.is_in_group(Common._findState(types.enemy, types)):
				bodyEntered.hit(powerAttack)
		
		return # para aqui
	
	# Para todas as outras animações, segue normal
	if new_anim != anim:
		anim = new_anim
		$sprite.play(anim)
		_playAudioSfx(anim) # Executa o audio
		
func _physics_process(delta) -> void:
	# Agora aqui vamos controlar a física, então precisamos de frames padrões
	#if floating and water != null:
		#var ct = global_position.y - (water.global_position.y - water_height)
		#global_position.y -=  ((WATER_K * ( ct ))  ) * 1.5
		
	# Se estiver morrendo, então sai do _physics_process()
	if dying: return
	
	if buoyancy > 0  and weakref(water):
		buoyancy -= 1
		position.y -= 5
		#return
	
	if hiting > 0 and weakref(bodyEntered):
		hiting -= 1
		if $sprite.flip_h:
			position.x += 10
		else:
			position.x -= 10
		
	# Se encostou no chão, mas estava pulando, então muda pra IDLE
	if is_on_floor() and state == states.jump:
		_change_state(states.idle)
	
	# Se está atacando
	if state == states.attack:
		_change_state(states.attack)
	
	# Calcula a gravidade
	velocity.y += gravity
	# Configura e obtém os cálculos da movimentação, para uma suavidade nos movimentos
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_sprite_animation_finished() -> void:
	# Quando a animação terminar de executar
	# Se estiver pulando
	if jumping:
		$sprite.play(anim)
		jumping = false
	
	# Se estiver atacando
	if attacking:
		$sprite.play(anim)
		attacking = false
		
	if dying:
		if type == types.player:
			yield(get_tree().create_timer(5), "timeout")
			emit_signal("gameover")
			queue_free()
			
		if type == types.enemy:
			_stopAudioSfx(Common._findState(states.attack, states))
			yield(get_tree().create_timer(1), "timeout")
			queue_free()

func _on_area_attack_body_entered(body):
	if body.is_in_group(Common._findState(types.player, types)) or body.is_in_group(Common._findState(types.enemy, types)):
		bodyEntered = body
		dirHiting = sign(body.global_position.x - self.global_position.x)
	
func _on_area_attack_body_exited(body):
	if body.is_in_group(Common._findState(types.player, types)) or body.is_in_group(Common._findState(types.enemy, types)):
		bodyEntered = null

func _on_area_attack_area_entered(area):
	# Se quiser implementar algo comum para todos
	pass
	
func hit(power):
	if dying: return
	life -= power
	life = clamp(life, 0, maxLife)
	
	if has_node("barlife"):
		$barlife.value = life
		if showBarLife:
			$barlife.show()
	
	if life == 0:
		_dying()
	else:
		var ct = 1
		if type == types.enemy:
			hiting = 5 * power
		while ct < 10:
			$sprite.modulate.r = ct % 2
			$sprite.modulate.g = .5
			$sprite.modulate.b = .5
			$sprite.modulate.a = ct % 2
			yield(get_tree().create_timer(.08), "timeout")
			ct += 1
		
		$sprite.modulate = Color(1,1,1,1)

func _dying():
	dying = true
	
	if has_node("barlife"):
		$barlife.hide()
	
	_change_state(states.dead)
	_playAudioSfx(Common._findState(states.dead, states)) # Executa o audio
	$sprite.play(Common._findState(states.dead, states))

func _stopAudioSfx(state) -> void:
	if has_node("sfx"):
		if get_node("sfx").has_node(state):
			var audioNode: AudioStreamPlayer = get_node(str("sfx/", state))
			audioNode.stop()
			
func _playAudioSfx(state, wait_finish=false) -> void:
	#if dying and type == types.enemy: return
	if has_node("sfx"):
		if get_node("sfx").has_node(state):
			var audioNode: AudioStreamPlayer = get_node(str("sfx/", state))
			if wait_finish:
				if audioNode.is_playing():
					yield(audioNode, "finished")
			audioNode.play()

func _on_water_entered(_water, _altura, _tensao, _amortecimento):
	if not floating:
		water = _water
		water_height = _altura
		velocity.y /= 4
		gravity = 0
		if has_node("barlife"):
			$barlife.hide()
		floating = true
		#yield(get_tree().create_timer(1), "timeout")
		#_dying()

func _on_water_exited():
	#yield(get_tree().create_timer(.5),"timeout")
	gravity = maxGravity
	water = null
	floating = false
	_change_state(states.jump)
	jumping = true

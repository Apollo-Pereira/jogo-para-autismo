extends CharacterBody3D

const SPEED = 5.0
const ACCEL = 10.0           # aceleração
const DECEL = 15.0           # desaceleração
const JUMP_VELOCITY = 4.5

@export var sensitivity = 0.02
@export var controller_sensitivity = 2.0

@onready var camera: Camera3D = $Camera3D

signal atualizar_posicao(pos: Vector3)

var dialogo_ativo := false
var mouse_capturado := true  # controla estado do mouse

func _ready() -> void:
	add_to_group("Jogador")
	# Trava o mouse no centro da tela no início
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Conectando os sinais do diálogo
	for avatar in get_tree().get_nodes_in_group("avatares"):
		avatar.connect("dcomecou", Callable(self, "_on_dialogo_comecou"))
		avatar.connect("dterminou", Callable(self, "_on_dialogo_terminou"))


func _input(event: InputEvent) -> void:
	# Alterna o mouse com ESC
	if event.is_action_pressed("ui_cancel"):
		mouse_capturado = !mouse_capturado
		Input.set_mouse_mode(mouse_capturado if Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE)

	# Só mexe a câmera pelo mouse se o diálogo não está ativo e o mouse está capturado
	if not dialogo_ativo and mouse_capturado and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotation.x = clamp(
			camera.rotation.x - (event.relative.y * sensitivity),
			deg_to_rad(-90),
			deg_to_rad(90)
		)

func _physics_process(delta: float) -> void:
	# Movimento do personagem
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var target_vel = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * SPEED

	# Aplica aceleração e desaceleração
	var accel = ACCEL if target_vel.length() > 0 else DECEL
	velocity.x = move_toward(velocity.x, target_vel.x, accel * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, accel * delta)

	# Controle da câmera pelo gamepad (somente se não há diálogo)
	if not dialogo_ativo and mouse_capturado:
		var cam_x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
		var cam_y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")

		if cam_x != 0.0:
			rotate_y(-cam_x * controller_sensitivity * delta)
		if cam_y != 0.0:
			camera.rotation.x = clamp(
				camera.rotation.x - (cam_y * controller_sensitivity * delta),
				deg_to_rad(-90),
				deg_to_rad(90)
			)

	move_and_slide()
	emit_signal("atualizar_posicao", position)

# ===========================
# Funções dos sinais do diálogo
# ===========================
func _on_dialogo_comecou() -> void:
	dialogo_ativo = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_dialogo_terminou() -> void:
	dialogo_ativo = false
	if mouse_capturado:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var sensitivity = 0.02
@export var controller_sensitivity = 2.0 # sensibilidade separada para controle

@onready var camera: Camera3D = $Camera3D

signal atualizar_posicao(pos: Vector3)

var dialogo_ativo := false # bloqueia a câmera quando o diálogo está ativo

func _ready() -> void:
	add_to_group("Jogador")
	# Conectando os sinais do diálogo
	if has_signal("dcomecou"):
		connect("dcomecou", Callable(self, "_on_dialogo_comecou"))
	if has_signal("dterminou"):
		connect("dterminou", Callable(self, "_on_dialogo_terminou"))

func _input(event: InputEvent) -> void:
	# Só mexe a câmera pelo mouse se o diálogo não está ativo
	if not dialogo_ativo and event is InputEventMouseMotion:
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
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Controle da câmera pelo gamepad (somente se não há diálogo)
	if not dialogo_ativo:
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

func _on_dialogo_terminou() -> void:
	dialogo_ativo = false

extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var sensitivity = 0.02
@onready var camera: Camera3D = $Camera3D

signal atualizar_posicao(pos: Vector3)

func _ready() -> void:
	add_to_group("Jogador")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x - (event.relative.y * sensitivity), deg_to_rad(-90),deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	emit_signal("atualizar_posicao", position)

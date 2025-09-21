extends Node3D

@onready var tracker: Node3D = $Texto_de_Interface/Label3D
@onready var jogador: Node3D = $"../Jogador"

func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_body_entered)
	$Area3D.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Jogador"):
		print("O player entrou na área do NPC!")
		tracker.track(body)
		$dialogue_manager.start("dialogue")
		

func _on_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Jogador"):
		print("O player saiu da área do NPC.")
		tracker.untrack(body)


func _on_dialogue_manager_made_choice(choice: String, message: String) -> void:
	if choice == """Podemos conversar e inventar
 uma história juntos pra passar o tempo.""":
		$dialogue_manager.continue_to("dialogue2")

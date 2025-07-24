extends Label3D
var jogador_posicao: Vector3 = Vector3.ZERO
var conectado := false

func track(alvo: Node) -> void:
	if not conectado and alvo.has_signal("atualizar_posicao"):
		alvo.atualizar_posicao.connect(Callable(self, "_on_atualizar_posicao"))
		conectado = true
		visible = true
func untrack(alvo: Node) -> void:
	if conectado and alvo.has_signal("atualizar_posicao"):
		alvo.atualizar_posicao.disconnect(Callable(self, "_on_atualizar_posicao"))
		conectado = false
		visible = false
func _on_atualizar_posicao(pos: Vector3) -> void:
	jogador_posicao = pos
	look_at(Vector3(pos.x,pos.y+1.7,pos.z),Vector3(0,1,0),true)

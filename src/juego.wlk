import wollok.game.*

class AutoAEsquivar {
	var property position
	
	method image() = "img/auto-rotado-azul.png"
	
	method bajar() {
		position = position.down(1)
	}
}

object autosAEsquivar {
	var property listaAutos = []
	var property cantAutos = 0
	
	method spawnAuto() {
		listaAutos.add( new AutoAEsquivar(position = game.at(cantAutos,11)) )
		cantAutos += 1
		game.addVisual( listaAutos.last() )
	}
	
	method bajarAutos() {
		listaAutos.map{i => i.bajar()}
	}
}

object auto {
	var property position = game.center()
	
	method image() = "img/auto-rotado.png"
}

object pantalla {

	method inicializar() {
		self.configuracionPredeterminada()
		self.agregarVisuales()
		// TODO: self.definirColisiones()
	}
	
	method configuracionPredeterminada() {
		game.title("jueguito")
		game.height(12)
		game.width(12)
		game.boardGround("img/fondo.png")
	}
	
	method agregarVisuales() {
		game.addVisualCharacter(auto)
		game.onTick( 2000, "spawn", {autosAEsquivar.spawnAuto()} )
		game.onTick( 4000, "bajar", {autosAEsquivar.bajarAutos()} )
	}
}

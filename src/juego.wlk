import wollok.game.*

class AutoAEsquivar {
	var property position
	
	method image() = "img/auto-rotado-azul.png"
	
	method bajar() {
		game.onTick( 1000, "bajar", {position = position.down(1)} )
	}
}

object autosAEsquivar {
	var property listaAutos = []
	
	method spawnAuto() {
		listaAutos.add( new AutoAEsquivar(position = game.at(5.randomUpTo(8),11)) )
		game.addVisual( listaAutos.last() )
		listaAutos.last().bajar()
	}
	
	method bajarAutos() {
		listaAutos.forEach{ i => i.bajar() }
	}
	
	method chequearAutos() { // Se analiza si algún auto ya no está en pantalla para borrarlo.
		listaAutos.forEach{ i => if (i.position().y() < 1) {self.despawnAuto(i)} }
	}
	
	method despawnAuto(auto) {
		game.removeVisual(auto)
		listaAutos.remove(auto) // Se borra el índice del auto para que no haya referencia al objeto y se libere memoria.
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
		self.gestionarAutos()
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
	}
	
	method gestionarAutos() {
		game.onTick( 2000, "spawn", {autosAEsquivar.spawnAuto()} )
		//game.onTick( 500, "bajar", {autosAEsquivar.bajarAutos()} )
		game.onTick( 5000, "chequearQueEstenEnPantalla", {autosAEsquivar.chequearAutos()} )
	}
}

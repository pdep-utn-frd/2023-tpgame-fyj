import wollok.game.*

class AutoAEsquivar {
	var property position
	
	method image() = "img/auto-rotado-azul.png"
	
	method bajar() {
		game.onTick( 500, "bajar", {position = position.down(1)} )
	}
}

class Linea_L {
	var property position = game.at(5,11)
	
	method image() = "img/linea-l.png"
	
	method bajar() {
		game.onTick( 250, "bajar", {position = position.down(1)} )
	}
}

class Linea_R {
	var property position = game.at(6,11)
	
	method image() = "img/linea-r.png"
	
	method bajar() {
		game.onTick( 250, "bajar", {position = position.down(1)} )
	}
}

object cosasQueCaen {
	var property listaCosas = []
	
	method spawnAuto() {
		listaCosas.add( new AutoAEsquivar(position = game.at(4.randomUpTo(8),11)) )
		game.addVisual( listaCosas.last() )
		listaCosas.last().bajar()
	}
	
	method chequearCosas() { // Se analiza si alguna de las cosas ya no está en pantalla para borrarla.
		listaCosas.forEach{ i => if (i.position().y() < 1) {self.despawnCosa(i)} }
	}
	
	method despawnCosa(auto) {
		game.removeVisual(auto) // Se borra el índice del auto para que no haya referencia al
		listaCosas.remove(auto) //objeto y se libere memoria.
	}
	
	method spawnLinea() {
		listaCosas.add( new Linea_L() )
		game.addVisual( listaCosas.last() )
		listaCosas.last().bajar()
		listaCosas.add( new Linea_R() )
		game.addVisual( listaCosas.last() )
		listaCosas.last().bajar()
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
		game.onTick( 2500, "spawn", {cosasQueCaen.spawnAuto()} )
		game.onTick( 1500, "linea", {cosasQueCaen.spawnLinea()} )
		game.onTick( 2000, "chequearQueEstenEnPantalla", {cosasQueCaen.chequearCosas()} )
	}
}

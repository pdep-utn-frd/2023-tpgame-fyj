import wollok.game.*

class CosaQueCae {
	var property velocidad 		// Cada cuántos milisegundos desciende una celda.
	var property position
	
	method image()
	
	method bajar() {
		game.onTick( velocidad, 
		"bajar"+self.toString(), {position = position.down(1)} )
	}
	
	method reaparecer()
}

class AutoAEsquivar inherits CosaQueCae(velocidad = 500, position = game.at(6,11)) {
	const imageIndexRange = new Range(start = 0, end = 1)
	var imageIndex = imageIndexRange.anyOne()
	
	override method image() = "img/auto" + imageIndex.toString() + ".png"
	
	override method reaparecer() {
		game.removeTickEvent("bajar"+self.toString())
		imageIndex = imageIndexRange.anyOne()
		self.image()
		velocidad = 250.randomUpTo(1000).truncate(0)
		position = game.at(4.randomUpTo(8),11)
		self.bajar()
	}
	/* para que no se superpongan los autos. no funciona.
	override method bajar() {
		game.onTick( velocidad, 
		"bajar"+self.toString(), 
		{
			if (not pantalla.laCeldaDeAbajoEstaOcupada(self)) position = position.down(1)
		} 
		)
	}
	*/
}

object linea inherits CosaQueCae(velocidad = 250, position = game.at(5,11)) {
	
	override method image() = "img/linea-l-gruesa.png"	
	
	override method reaparecer() {
		position = game.at(5,11)
	}
}

object autoAEsquivar1 inherits AutoAEsquivar(velocidad = 500, position = game.at(6,11)) {

}

object autoAEsquivar2 inherits AutoAEsquivar(velocidad = 500, position = game.at(6,11)) {

}

object autoAEsquivar3 inherits AutoAEsquivar(velocidad = 500, position = game.at(6,11)) {

}


object auto {
	var property position = game.center()
	
	method image() = "img/auto-rotado.png"
}

object tablero {
	var puntaje = 0
	
	method position() = game.at(6, game.height()-1)
	
	method text() = "Puntos: " + puntaje.toString()
	
	method calcularPuntos() {
		game.onTick( 5000, "Sumar Punto", {puntaje += 2} )
	}
}

object pantalla {
	const listaCaen = [linea, autoAEsquivar1, autoAEsquivar2, autoAEsquivar3]
	
	method laCeldaDeAbajoEstaOcupada(cosaQueCae) = listaCaen.any{i => i.position() == cosaQueCae.position().down(1)}
	
	method inicializar() {
		self.configuracionVentana()
		self.agregarVisuales()
		tablero.calcularPuntos()
		// TODO: self.definirColisiones()
	}
	
	method configuracionVentana() {
		game.title("jueguito")
		game.height(12)
		game.width(12)
		game.boardGround("img/fondo.png")
	}
	
	method agregarVisuales() {
		game.addVisualCharacter(auto)
		game.addVisual(tablero)
		
		game.addVisual(linea)
		linea.bajar()
		
		self.aparecerEnemigos()
		
		game.onTick( 250,
			 "mantener en pantalla",
			  {
			  	listaCaen.forEach{ i => if (i.position().y() < 1) i.reaparecer()}
			  }
		)
	}
	
	method aparecerEnemigos() {
		var contAux = 1
		game.onTick( 1500,
			"hacer aparecer paulatinamente",
			{
				if ( not listaCaen.all{i => game.hasVisual(i)} ) 
				{
					game.addVisual(listaCaen.get(contAux))
					listaCaen.get(contAux).bajar()
					contAux += 1
				}
				else game.removeTickEvent("hacer aparecer paulatinamente")
			}
		)
	}
}

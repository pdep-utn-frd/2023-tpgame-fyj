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
	
	method chocar() {}
}

class AutoAEsquivar inherits CosaQueCae(velocidad = 500, position = game.at(4.randomUpTo(8),11)) {
	const imageIndexRange = new Range(start = 0, end = 1)
	var imageIndex = imageIndexRange.anyOne()
	
	var property image = "img/auto" + imageIndex.toString() + ".png"
	
	override method reaparecer() {
		game.removeTickEvent("bajar"+self.toString()) //Para que pueda variar la velocidad tiene que hacerse un nuevo onTick.
		
		imageIndex = imageIndexRange.anyOne()
		image = "img/auto" + imageIndex.toString() + ".png"
		
		velocidad = 50.randomUpTo(1000).truncate(0)
		position = game.at(4.randomUpTo(8),11)
		self.bajar()
	}
	
	override method chocar() {
		pantalla.gameOver()
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

class Policia {
	var property position
	var imageIndex = 0
	
	var property image = "img/auto-policia-" + imageIndex.toString() + ".png"
	
	
	method perseguir() {
		if (imageIndex == 0 or imageIndex == 1)
			imageIndex = 2
		else
			imageIndex = 1
		image =	"img/auto-policia-" + imageIndex.toString() + ".png"
		
		if (position.y() < auto.position().y()-1)
			position = game.at(auto.position().x(), position.y()+1)
		else
			position = game.at(auto.position().x(), position.y())
	}
	
	method noPerseguir() {
		imageIndex = 0
		image = "img/auto-policia-" + imageIndex.toString() + ".png"
		
		if (position.y() >= 0)
			position = position.down(1)
	}
	
	method chocar() {
		pantalla.gameOver()
	}
}

object linea inherits CosaQueCae(velocidad = 250, position = game.at(5,11)) {
	
	override method image() = "img/linea-l-gruesa.png"	
	
	override method reaparecer() {
		position = game.at(5,11)
	}
}

object autoAEsquivar1 inherits AutoAEsquivar {}

object autoAEsquivar2 inherits AutoAEsquivar {}

object autoAEsquivar3 inherits AutoAEsquivar {}

object policiaL inherits Policia(position = game.at(-1,-1)) {}

object policiaR inherits Policia(position = game.at(game.width()+1,-1)) {}

object auto {
	var property position = game.center()
	
	method image() = "img/auto.png"
}

object tablero {
	var puntaje = 0
	
	method position() = game.at(1, game.height()-1)
	
	method text() = "Puntos: " + puntaje.toString()
	
	method calcularPuntos() {
		game.onTick( 5000, "sumar punto", {puntaje += 2} )
	}
	
	method chocar() {}
}

object finDelJuego {
	
	method position() = game.center()
	
	method text() = "Fin del Juego"
	
	method chocar() {}
}

object pantalla {
	const listaCaen = [linea, autoAEsquivar1, autoAEsquivar2, autoAEsquivar3]
	
	method laCeldaDeAbajoEstaOcupada(cosaQueCae) = listaCaen.any{i => i.position() == cosaQueCae.position().down(1)}
	
	method inicializar() {
		self.configuracionVentana()
		self.agregarVisuales()
		tablero.calcularPuntos()
		self.definirColisiones()
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
		
		game.addVisual(policiaL)
		game.addVisual(policiaR)
		
		game.onTick ( 250,
			"chequear auto en carril",
			{
				if (auto.position().x() < 4) policiaL.perseguir()
				else policiaL.noPerseguir()
				
				if (auto.position().x() > 7) policiaR.perseguir()
				else policiaR.noPerseguir()
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
	
	method definirColisiones() {
		game.onCollideDo(auto, { cosaQueCae => cosaQueCae.chocar()})
	}
	
	method gameOver() {
		listaCaen.forEach{ i => game.removeTickEvent("bajar"+i.toString()) }
		game.removeTickEvent("mantener en pantalla")
		game.removeTickEvent("sumar punto")
		game.removeTickEvent("chequear auto en carril")
		game.addVisual(finDelJuego)
		game.removeVisual(auto)
	}
}

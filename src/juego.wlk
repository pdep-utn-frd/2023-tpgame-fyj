import wollok.game.*
import classes.*

object linea inherits CosaQueCae(velocidad = 150, position = game.at(5, game.height()-1)) {
	
	override method image() = "img/linea.png"	
	
	override method reaparecer() {
		position = game.at(5, game.height()-1)
	}
}

object autoAEsquivar1 inherits AutoAEsquivar {}

object autoAEsquivar2 inherits AutoAEsquivar {}

object autoAEsquivar3 inherits AutoAEsquivar {}

object policiaL inherits Policia(position = game.at(-1,-1)) {}

object policiaR inherits Policia(position = game.at(game.width()+1,-1)) {}

object barreraL inherits Barrera {}

object barreraR inherits Barrera {}

object auto {
	var property position = game.at(5, game.center().y()-2)
	
	method image() = "img/auto.png"
}

object tablero {
	var puntaje = 0
	
	method position() = game.at(game.width()-6, game.height()-6)
	
	method text() = "Puntos: " + puntaje.toString()
	
	method calcularPuntos() {
		pantalla.enlistarTickEvent(100,
			"sumar punto",
			{
				if (auto.position().x() > 3 and auto.position().x() < 7) puntaje += 1
			}
		)
	}
}

object finDelJuego {
	
	method position() = game.at(game.width()-6, game.center().y())
	
	method text() = "Fin del Juego"
}

object vallas {
	var property image = "img/vallas-0.png"
	
	method position() = game.at(0,0)
	
	method mover() {
		pantalla.enlistarTickEvent(250,
			"mover vallas",
			{
				if (image == "img/vallas-0.png") 
					image= "img/vallas-1.png"
				else 
					image= "img/vallas-0.png"
			}
		)
	}
}

object pantalla {
	const listaCaen = [linea, autoAEsquivar1, autoAEsquivar2, autoAEsquivar3]
	const listaTickEvents = []
	//method laCeldaDeAbajoEstaOcupada(cosaQueCae) = listaCaen.any{i => i.position() == cosaQueCae.position().down(1)}
	
	method inicializar() {
		self.configuracionVentana()
		self.agregarVisuales()
		tablero.calcularPuntos()
		self.definirColisiones()
	}
	
	method configuracionVentana() {
		game.title("jueguito")
		game.cellSize(31)
		game.height(20)
		game.width(20)
		game.boardGround("img/fondo.png")
	}
	
	method agregarVisuales() {
		game.addVisualCharacter(auto)
		game.addVisual(tablero)
		
		game.addVisual(linea)
		linea.bajar()
		
		game.addVisual(vallas)
		vallas.mover()
		
		self.aparecerEnemigos()
		
		self.enlistarTickEvent(250,
			"mantener en pantalla",
			{
				listaCaen.forEach{ i => if (i.position().y() < 1) i.reaparecer()}
				if (auto.position().x() == 0 or auto.position().x() == 11)
					self.gameOver()
			}
		)
		
		game.addVisual(policiaL)
		game.addVisual(policiaR)
		policiaL.vigilar()
		policiaR.vigilar()
		
		game.addVisual(barreraL)
		game.addVisual(barreraR)
	}
	
	method enlistarTickEvent(velocidad, nombreTickEvent, bloque) {
		listaTickEvents.add(nombreTickEvent)
		
		game.onTick( velocidad,
			nombreTickEvent,
			bloque
		)
	}
	
	method removerTickEvent(nombreTickEvent) {
		listaTickEvents.remove(nombreTickEvent)
		game.removeTickEvent(nombreTickEvent)
	}
	
	method aparecerEnemigos() {
		var contAux = 1
		game.onTick( 2500,
			"hacer aparecer paulatinamente",
			{
				if ( not listaCaen.all{i => game.hasVisual(i)} ) {
					game.addVisual(listaCaen.get(contAux))
					listaCaen.get(contAux).bajar()
					contAux += 1
				}
				else game.removeTickEvent("hacer aparecer paulatinamente")
			}
		)
	}
	
	method definirColisiones() {
		game.onCollideDo(auto, { cosa => cosa.chocar()})
		barreraL.coliciones()
		barreraR.coliciones()
	}
	
	method gameOver() {
		listaTickEvents.forEach{i => self.removerTickEvent(i)}
		game.addVisual(finDelJuego)
		game.removeVisual(auto)
	}
}

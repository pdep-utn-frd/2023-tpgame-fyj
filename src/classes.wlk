import wollok.game.*
import juego.*

class CosaQueCae {
	var property velocidad 		// Cada cuántos milisegundos desciende una celda.
	var property position
	const nombreTickEvent = self.toString()+"-bajar"
	
	method image()
	
	method bajar() {
		pantalla.enlistarTickEvent(velocidad, 
			nombreTickEvent, 
			{
			position = position.down(1)
			}
		)
	}
	
	method reaparecer()
	
	method chocar() {}
}

class AutoAEsquivar inherits CosaQueCae(velocidad = 500, position = game.at(4.randomUpTo(7).truncate(0), 19)) { 
//ese 19 debería ser game.height()-1 pero por algún motivo no funciona.
	const imageIndexRange = new Range(start = 0, end = 1)
	var imageIndex = imageIndexRange.anyOne()
	
	var property image = "img/auto" + imageIndex.toString() + ".png"
	
	override method reaparecer() {
		pantalla.removerTickEvent(nombreTickEvent)		// Para que pueda variar la velocidad
														//tiene que hacerse un nuevo onTick.
		imageIndex = imageIndexRange.anyOne()
		image = "img/auto" + imageIndex.toString() + ".png"
		
		velocidad = 50.randomUpTo(400).truncate(0)
		position = game.at(4.randomUpTo(7).truncate(0), game.height()-1)
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
	const nombreTickEvent = self.toString()+"-vigilar"
	var property position
	var imageIndex = 0
	var property image = "img/auto-policia-" + imageIndex.toString() + ".png"
	
	method columnas() {if (self.toString() == "policiaL") return [1,2,3] else return [7,8,9]}
	
	method barrera() {if (self.toString() == "policiaL") return barreraL else return barreraR}
	
	method vigilar() {
		var temp = 0
		
		pantalla.enlistarTickEvent(150,
			nombreTickEvent,
			{
				if ( self.columnas().any{i => i == auto.position().x()} ) {
					self.perseguir()
					temp += 1
					if (temp == 10) self.barrera().bajar()
				}
				else {
					self.noPerseguir()
					temp = 0
				}
			}
		)
	}
	
	method perseguir() {
		// Cambiar la imagen, para que parpadeen las luces de policía.
		if (imageIndex == 0 or imageIndex == 1)
			imageIndex = 2
		else
			imageIndex = 1
		image =	"img/auto-policia-" + imageIndex.toString() + ".png"
		
		// Cambiar la posición, para que se acerque al auto del jugador.
		if (position.y() < auto.position().y()-1)
			position = game.at(auto.position().x(), position.y()+1)
		else
			position = game.at(auto.position().x(), position.y())
	}
	
	method noPerseguir() {
		imageIndex = 0
		image = "img/auto-policia-" + imageIndex.toString() + ".png"
		
		if (position.y() >= -1)
			position = position.down(1)
	}
	
	method chocar() {
		pantalla.gameOver()
	}
}

class Barrera {
	const nombreTickEventBajar = self.toString() + "-bajar"
	const nombreTickEventColisiones = self.toString() + "-colisiones"
	var property position = self.origen()
	var imageIndex = 0
	var property image = "img/barrera-" + imageIndex.toString() + ".png"
	
	method columnas() {if (self.toString() == "barreraL") return [1,2,3] else return [7,8,9]}
	
	method origen() {if (self.toString() == "barreraL") return game.at(1, game.height()) else return game.at(7, game.height())}
	
	method bajar() {
		position = self.origen()
		
		pantalla.enlistarTickEvent(250,
			nombreTickEventBajar, 
			{
				// Cambiar la imagen.
				if (imageIndex == 0) 
					imageIndex = 1
				else 
					imageIndex = 0
				image = "img/barrera-" + imageIndex.toString() + ".png"
			
				// Cambiar la posición.
				position = position.down(1)
				
				if (position.y() < -1) pantalla.removerTickEvent(nombreTickEventBajar)
			}
		)
	}
	
	method coliciones() {
		pantalla.enlistarTickEvent(250,
			nombreTickEventColisiones,
			{
				if (position.y() == auto.position().y() and ( self.columnas().any{i => i == auto.position().x()} )) {
					self.chocar()
				}
			}
		)
	}

	method chocar() {
		pantalla.gameOver()
	}
}

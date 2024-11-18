
class Vikingo{
	var casta
	var tipo
	var cantArmas
	var cantVidasCobradas
	var cantMonedasOro = 0
	
	method esProductivo() = casta.puedeIr(self) and tipo.puedeIr(self)
	
	method cantArmas() = cantArmas
	method cantVidasCobradas() = cantVidasCobradas
	method tipo() = tipo
	
	method sumarArmas(cuantas){
		cantArmas += cuantas
	}
	method sumarVidaCobrada(){
		cantVidasCobradas++
	}
	method sumarMonedasDeOro(cantidad){
		cantMonedasOro += cantidad
	}
	
	method ascenderSocialmente(){
		casta.ascender(self)
	}
	method casta(cual){
		casta = cual
	}
}

object soldado{
	method puedeIr(vikingo) = vikingo.cantVidasCobradas() > 20 and vikingo.cantArmas() > 0 
	
	method ascender(vikingo){
		vikingo.sumarArmas(10)
	}
} 

class  Granjero{
	var cantHijos
	var cantHectareas

	method puedeIr(_) = (cantHectareas / 2) >= cantHijos
	

	method ascender(vikingo){
		cantHijos += 2
		cantHectareas +=2
	}
}


object noble{
	method puedeIr(_) = true
	
	method ascender(_){}
}

object castaMedia{
	method puedeIr(_) = true
	
	method ascender(vikingo){
		vikingo.casta(noble)
	}
}

object esclavo{
	method puedeIr(vikingo) = vikingo.cantArmas() == 0 
	
	method ascender(vikingo){
		vikingo.casta(castaMedia)
		vikingo.tipo().ascender(vikingo)
	}
}

class Expedicion{
	var vikingos = #{}
	var lugares = #{} // aca estarian las aldeas y las capitales
	
	method vikingos() = vikingos
	
	method subirVikingo(vikingo){
		if (vikingo.esProductivo())
			vikingos.add(vikingo)
		else
			throw new DomainException(message = "El vikingo no puede subir a la expedicion")
	}

	method valeLaPena() = 
		lugares.all({lugar => lugar.valeLaPena(self)})
		
	method cantVikingos() = vikingos.size()
	
	method realizarInvasion(){
		lugares.forEach({lugar => lugar.invadir(self)})
	}
}

class Lugar{
	method cantMonedasDeOro()
	
	method invadir(expedicion){
		expedicion.vikingos().forEach({vik => self.producirEfecto(vik,expedicion)})
	}
	method producirEfecto(vikingo,expedicion){
		vikingo.sumarMonedasDeOro(self.monedasXVikingo(expedicion))
	}
	
	method monedasXVikingo(expedicion) = self.cantMonedasDeOro() / expedicion.cantVikingos()
}

class Capital inherits Lugar{
	var cantDefensoresDerrotados
	var factorRiqueza
	

	method valeLaPena(expedicion) = self.cantMonedasDeOro() >= expedicion.cantVikingos() * 3
		
	override method cantMonedasDeOro() =
		cantDefensoresDerrotados * factorRiqueza
		
	override method producirEfecto(vikingo,expedicion){
		super(vikingo,expedicion)
		vikingo.sumarVidaCobrada()
	}
}

class Aldea inherits Lugar{
	var estaDefendida
	var cantCrucifijos

	method valeLaPena(expedicion) =
		self.cantMonedasDeOro() >= 15
	
	override method cantMonedasDeOro() = cantCrucifijos
	
	override method producirEfecto(vikingo,expedicion){
		if (!estaDefendida){
			super(vikingo,expedicion)
			cantCrucifijos = 0
		}
	}
	
}

class AldeaAmurallada inherits Aldea{
	var cantMinima
	
	override method valeLaPena(expedicion) =
		super(expedicion) and (expedicion.cantVikingos() > cantMinima)	
}


// Parcial Objetos

object fechaActual{
	method fecha() = new Date(day = 26, month = 6, year = 2003)
}

object pDepfoni{
	const property precioFijo = 0
	const property precioXSegundo = 0
	const property precioXMB = 0
	
	method consumo(tipo,caract) = tipo.consumo(caract)
}


class Linea{
	var consumos = []
	var packs = []
	// Punto 2
		// Sacar información de los consumos realizados por una línea:
		// Conocer el costo promedio de todos los consumos realizados dentro de un rango de fechas inicial y final.
	method costoPromedioEntre(fInicial,fFinal) = 
		self.consumosEntreFechas(fInicial,fFinal).sum({c => c.costo()}) / 
		self.consumosEntreFechas(fInicial,fFinal).size()
		
	method consumosEntreFechas(fInicial,fFinal) = 
		consumos.filter({c => c.fecha().between(fInicial,fFinal)})
		
		// Conocer el costo total que gastó la línea entre todos los consumos de los últimos 30 días.
	method consumosUltimos30Dias(diaActual) = 
		consumos.filter({c => c.date().between(diaActual.minusDays(30),diaActual)})
	
	// Punto 4
		// Poder agregar algun pack
	method agregarPack(pack){
		packs = packs + [pack]	
	}
	
	// Punto 5
		// Sabes si una linea puede hacer un consumo
	method puedeHacerConsumo(consumo) = 
		packs.any({pack => pack.puedeSatisfacer(consumo)})
		
	// Punto 6
		// Realizar un consumo en la línea
	method realizarUnConsumo(consumo){
		// 	*Si no se puede realizar el consumo, porque no me alcanzan los packs, debe lanzarse un error.
		if (!self.puedeHacerConsumo(consumo))
			self.error("No se puede realizar el consumo")
			 
		consumos.add(consumo)
		packs.find({pack => pack.puedeSatisfacer(consumo)}).gastar(consumo)
	}
	
	// Punto 7
		// Realizar una limpieza de packs, que elimine los packs vencidos o completamente acabados.
	method realizarLimpiezaDePacks(){
		packs.removeAllSuchThat({pack => pack.sePuedeRetirar()})
	}
}

// Tipos de pack: 

// Clase abstracta
class Pack{
	const property fechaVencimiento
	
	method estaAcabado()
	method estaVencido() = fechaActual.fecha() > fechaVencimiento
	
	method sePuedeRetirar() = self.estaAcabado() or self.estaVencido()
	
	method puedeSatisfacer(consumo) = consumo.fecha() < fechaVencimiento 
}


class PackCredito inherits Pack{
	var creditoDisponible

	override method puedeSatisfacer(consumo) = 
		super(consumo) and consumo.costo() < creditoDisponible
		
	method gastar(consumo){
		creditoDisponible -= consumo.costo()
	}
		 
	method estaAcabado() = creditoDisponible < 0
}

class MBLibres inherits Pack{
	var mbDisponibles
	
	override method puedeSatisfacer(consumo) =
		super(consumo) and consumo.cantMB() < mbDisponibles
	
	method costo(consumo){
		mbDisponibles -= consumo.cantMB()
	}
	
	method estaAcabado() = mbDisponibles < 0
} 

// seria MBLibres++
class MBLibresPlus inherits MBLibres{
	override method puedeSatisfacer(consumo) = 
		super(consumo) or (consumo.cantMB() < 0.1)
}

// Tipos de consumo: (interfaz Consumo)
// Tienen que entender:
// 	 costo()

class ConsumoInternet{
	const fecha
	const property cantMB
	// Punto 1
	method costo() = pDepfoni.precioXMB() * cantMB
}

class ConsumoLlamada{
	const fecha
	const property tiempo
	// Punto 1
	method costo() = 
		if (tiempo > 60)
			pDepfoni.precioFijo() + (tiempo - 60) * pDepfoni.precioXSegundo()
		else
			pDepfoni.precioFijo()
}

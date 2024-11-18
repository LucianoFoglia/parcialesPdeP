// Parcial Objetos

object inmobiliaria{
	var property porcentajeVenta = 1.5
	var property empleados = []

// Punto 2
	// Saber cuál fue el mejor empleado según los siguientes criterios:
	method mejorEmpleadoSegun(criterio) =
		empleados.max({empl => criterio.cualidad(empl)}) 
}

class Empleado{
	var property operaciones = []
	var property cantReservas
	
	method operacionesCerradas() = operaciones.filter({oper => oper.estaCerrada()})
	method cantOperacionesCerradas() = self.operacionesCerradas().size()
	method reservas() = operaciones.filter({ope => ope.inmueble().estaReservada()})
	method cantReservas() = 
		self.reservas().size()
		
	// Punto 3
	method vaATenerProblemasConOtro(otroEmpleado) =
		self.algunaCerradaMismaZona(otroEmpleado) and 
		(otroEmpleado.leRoboOperaciones(self) or self.leRoboOperaciones(otroEmpleado))
		
	method algunaCerradaMismaZona(otroEmpleado) =
		operaciones.any({ope => otroEmpleado.algunaMismaZonaQue(ope)})
		
	method algunaMismaZonaQue(operacion) = 
		self.operacionesCerradas().any({ope => ope.inmueble().zona() == operacion.inmueble().zona()})
	
	// Supongo que los empleados son distintos, no chequeo eso
	// Chequeo si la reserva de self no se la robo otroEmpleado. Si otroEmpleado no le robo a self pero
	// otroEmpleado si le robo a self, daria false ya que no es simetrica. Para solucionarlo, pongo el
	// or en el metodo vaATenerProblemasConOtro()
	method leRoboOperaciones(otroEmpleado) =
		self.reservas().any({reserva => otroEmpleado.seLaVendio(reserva)})
	
	method seLaVendio(reserva) = 
		self.operacionesCerradas().any({ope => ope.inmueble() == reserva.inmueble()})	
}


// Tipos de criterio
object comisionesTotales{
	method cualidad(empleado) =
		empleado.operacionesCerradas().sum({oper => oper.comision()})
}

object operacionesCerradas{
	
	// según la cantidad de operaciones cerradas.
	method cualidad(empleado) = 
		empleado.cantOperacionesCerradas()
	
}

object resevadas{
	// según la cantidad de reservas.
	method cualidad(empleado) =
		empleado.cantReservas()	
}

// Fin de tipos de criterio


// Tipos de operaciones
class Venta{
	var property inmueble
	var property empleado
// Punto 1
	// Saber cuál fue la comisión de una operación concretada (venta o alquiler).
	method comision() = inmueble.precio() * (inmobiliaria.porcentajeVenta()/100)
	method estaCerrada() = true
}

class Alquiler{
	var property inmueble
	var property empleado
	const cantMeses
// la comisión que le corresponde al agente es igual a la cantidad de meses 
// por el valor del inmueble, dividido 50.000.
	method comision() = 
		inmueble.precio() * cantMeses / 50000
	method estaCerrada() = true
}

class Reserva{
	var property inmueble
	var property empleado
	method estaCerrada() = false
}

// Fin tipos de operaciones


class Inmueble{
	var property cantAmbientes
	var property metrosCuadrados
	var property tipo
	var property reservadaPor = null
	var property zona
	
	
	method estaReservada() = reservadaPor != null
	method precio() = tipo.precio(self) + zona.precio()
	method aptoVenta() = true
}

class Local inherits Inmueble{
	override method aptoVenta() = false
}

class Galpon inherits Casa{
	override method precio(_) = super(_) / 2
}

object aLaCalle{
	method precio(_) = 15
}

// Tipos de inmueble
class Casa{
	var precio
	
	method precio(_) = precio 
}

object ph{
	method precio(inmueble) = 50000.min(inmueble.cantAmbientes() * 14000)
} 

object departamento{
	method precio(inmueble) = 350000 * inmueble.cantAmbientes()
}

class Locales{
	
}

// Fin tipos de inmueble
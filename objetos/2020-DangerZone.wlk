// Parcial Objetos


class Empleado{
	var property tipoEmpleado
	var property salud
	var property habilidades = #{}
	
	// 1) Saber si un empleado está incapacitado.
	// 		Sabemos que los empleados quedan incapacitados cuando su salud se 
	//		encuentra por debajo de su salud crítica.
	method estaIncapacitado() = self.salud() < tipoEmpleado.saludCritica()
	
	// Punto 2
	// 		Saber si un empleado puede usar una habilidad, que se cumple si no está incapacitado 
	//		y efectivamente posee la habilidad indicada.
	method puedeUsar(habilidad) = !self.estaIncapacitado() and habilidades.contains(habilidad)
	
	
	// Punto 3
	// 	  Hacer que un empleado o un equipo cumpla una misión.
	//	  Esto sólo puede llevarse a cabo si quien la cumple reúne todas las habilidades requeridas 
	//	  de la misma (si puede usarlas todas).
	method puedecumplirMision(mision) = 
		mision.habilidadesNecesarias().all({habilidad => habilidades.contains(habilidad)})
	
	
	// Punto 4
	// 	 Luego, el empleado que cumplió la misión recibe daño en base a la peligrosidad de la misión. 
	method cumplirMision(mision){
		if (self.puedecumplirMision(mision)){
			salud -= mision.peligrosidad()
			tipoEmpleado.postMision()
		}
	}
}

class Jefe inherits Empleado{
	var subordinados = []
	// Punto 2		
	//		En el caso de los jefes, también consideramos
	//		que la posee si alguno de sus subordinados la puede usar.
	override method puedeUsar(habilidad) = super(habilidad) or subordinados.any({subo => subo.puedeUsar(habilidad)})		
}

object espia{
	method saludCritica() = 15
	
	// Punto 5
	//	 Los espías aprenden las habilidades de la misión que no poseían.
	method postMision(empleado,mision){
		// No tengo que sacar los repetidos porque son ambos son conjuntos
		empleado.habilidades(empleado.habilidades().union(mision.habilidadesNecesarias()) )
	}
}

class Oficinista{
	var cantEstrellas = 0
	
	// Punto 5
	// Los oficinistas consiguen una estrella. Cuando un oficinista junta tres estrellas adquiere la 
	// suficiente experiencia como para empezar a trabajar de espía.
	method postMision(empleado,_){
		cantEstrellas++
		if (cantEstrellas == 3)
			empleado.tipoEmpleado(espia)
	}
	method saludCritica() = 40- 5 * cantEstrellas 
}


class Mision{
	var habilidadesNecesarias = #{}
	var peligrosidad
	
	method peligrosidad() = peligrosidad
	method habilidadesNecesarias() = habilidadesNecesarias
}

class Equipo{
	var integrantes = []
	
	// Punto 3
	//		Para los equipos alcanza con que al menos uno de sus
	//	 	integrantes pueda usar cada una de ellas.
	method puedecumplirMision(mision) =
		mision.habilidadesNecesarias().all({habilidad => self.algunoPuedeUsar(habilidad)})
		
	method algunoPuedeUsar(habilidad) = integrantes.any({persona => persona.puedeUsar(habilidad)})
	
	// Punto 4
	// 	 Luego, el equipo que cumplió la misión recibe daño en base a la peligrosidad 
	// 	 de la misión. Para los equipos, esto implica que todos los integrantes reciban un tercio del daño total.
	method cumplirMision(mision){
		if (self.puedecumplirMision(mision)){
			integrantes.forEach({
				integrante => integrante.salud(integrante.salud() + (mision.peligrosidad() / 3) )})
			
			integrantes.filter({empl => empl.salud() > 0}).postMision()
			}
	}

}



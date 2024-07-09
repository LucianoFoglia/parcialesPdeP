%%% Parcial Paradigma Lógico - Pdep JM 2022 UTN.BA

%%% Apellido y nombre: Luciano Foglia
%%% Legajo: 2036241

% Punto 1:
% Nivel 1:
necesidad(respiracion, fisiologico).
necesidad(alimentacion, fisiologico).
necesidad(descanso, fisiologico).
necesidad(reproduccion, fisiologico).
necesidad(limpiarCabeza,fisiologico).

% Nivel 2:
necesidad(integridadFisica, seguridad).
necesidad(empleo, seguridad).
necesidad(salud, seguridad).

% Nivel 3:
necesidad(amistad, social).
necesidad(afecto, social).
necesidad(intimidad, social).
necesidad(liberacion, social).
necesidad(emparche, social).

% Nivel 4:
necesidad(confianza, reconocimiento).
necesidad(respeto, reconocimiento).
necesidad(exito, reconocimiento).

% Nivel 5:
% nivelSuperior(Arriba,Abajo).
nivelSuperior(autorrealizacion, reconocimiento).
nivelSuperior(reconocimiento, social).
nivelSuperior(social, seguridad).
nivelSuperior(seguridad, fisiologico).


% Punto 2:
nivelesDeSeparacion(Necesidad1,Necesidad2,Cant):-
    necesidad(Necesidad1,Nivel1),
    necesidad(Necesidad2,Nivel2),
    diferenciaEntreNiveles(Nivel1,Nivel2,Cant).
nivelesDeSeparacion(Necesidad1,Necesidad2,Cant):-
    necesidad(Necesidad1,Nivel1),
    necesidad(Necesidad2,Nivel2),
    diferenciaEntreNiveles(Nivel2,Nivel1,Cant).

diferenciaEntreNiveles(Nivel,Nivel,0).
diferenciaEntreNiveles(Nivel1,Nivel2,1):-
    nivelSuperior(Nivel1,Nivel2).
diferenciaEntreNiveles(Nivel1,Nivel2,CantFinal):-
    not(nivelSuperior(Nivel1,Nivel2)),
    nivelSuperior(Nivel1,Intermediario),
    diferenciaEntreNiveles(Intermediario,Nivel2,Cant),
    CantFinal is Cant + 1.

% Punto 3:
necesita(carla,alimentacion).
necesita(carla,descanso).
necesita(carla,empleo).

necesita(juan,afecto).
necesita(juan,exito).

necesita(roberto,amigos(1000000)).

% objeto(Cosa,Razon) 
necesita(manuel,objeto(bandera,liberacion)).
necesita(charly,emparche).
necesita(charly,limpiarCabeza).

% Para separar necesidades de necesidades consideradas en la piramide
queNecesita(Persona,Necesidad):-
    necesita(Persona,Necesidad),
    necesidad(Necesidad,_).
queNecesita(Persona,amistad):-
    necesita(Persona,amigos(_)).
queNecesita(Persona,Necesidad):-
    necesita(Persona,objeto(_,Necesidad)).

% Generador de personas
persona(Persona):-
    necesita(Persona,_).

% Generador de niveles
nivel(Nivel):-
    necesidad(_,Nivel).

% Punto 4:
necesidadMayorJerarquia(Persona,NecesidadMayor):-
    queNecesita(Persona,NecesidadMayor),
    necesidad(NecesidadMayor,NivelMayor),
    jerarquiaNivel(NivelMayor,JerarquiaMayor),
    forall((necesita(Persona,OtraNecesidad),necesidad(OtraNecesidad,OtroNivel),jerarquiaNivel(OtroNivel,OtraJerarquia),
            OtraNecesidad \= NecesidadMayor),JerarquiaMayor > OtraJerarquia).

% Considero la jerarquia de un nivel como su distancia al nivel 0 (fisiologico)
jerarquiaNivel(Nivel,Jerarquia):-
    diferenciaEntreNiveles(Nivel,fisiologico,Jerarquia).

% Punto 5:        
pudoSatisfacerAlgunNivel(Persona):-
    persona(Persona),
    pudoSatisfacerNivel(Persona,_).

pudoSatisfacerNivel(Persona,Nivel):-
    persona(Persona),
    nivel(Nivel),
    forall(necesidad(Necesidad,Nivel),not(necesita(Persona,Necesidad))).

% Punto 6:
% A)
cumpleMaslow(Persona):-
    persona(Persona),
    nivel(Nivel),
    forall(queNecesita(Persona,Necesidad),necesidad(Necesidad,Nivel)).
    
% B)
todosCumplenMaslow():-
    persona(_),
    forall(persona(Persona),cumpleMaslow(Persona)).

% C)
laMayoriaCumpleMaslow():-
    mayoria(Mayoria),
    findall(Cumple,cumpleMaslow(Cumple),Cumplidores),
    length(Cumplidores,CantCumplen),
    CantCumplen >= Mayoria.

mayoria(Mayoria):-
    findall(Persona,persona(Persona),PersonasRepe),
    list_to_set(PersonasRepe,Personas),
    length(Personas,Cant),
    Mayoria is (Cant//2) + 1.

% Punto 7:
% suceso(Afectado,Causa/Necesidad,Consecuencia/QueLeDieron).
% Functores -> comida(Cual,Cantidad), bebida(Cual,Marca), ropa(QuePrenda,Talle)
quiereYLeDieron(jesusDeNazareth,comida(milanesasCarne,3),comida(arroz,1)).
quiereYLeDieron(jesusDeNazareth,bebida(vino,rutini),bebida(chocolatada,cindor)).
quiereYLeDieron(jesusDeNazareth,ropa(remera,m),ropa(remera,s)).

suceso(jesusDeNazareth,serForastero,dieron(alojamiento)).
suceso(jesusDeNazareth,enfermo,dieron(atencionMedica)).
suceso(jesusDeNazareth,irPreso,visitaron).

calorias(arroz,200).
calorias(chocolatada,180).
calorias(vino,350).
calorias(hamburguesa,950).

% Quiero saber cuantas calorias consumio con lo recibido
caloriasTotales(Persona,CaloriasTotales):-
    quiereYLeDieron(Persona,_,_),
    findall(Caloria,(quiereYLeDieron(Persona,_,Recibido),caloriasXConsumible(Recibido,Caloria)),Calorias),
    sum_list(Calorias, CaloriasTotales).

caloriasXConsumible(comida(Tipo,Cant),Calorias):-
    calorias(Tipo,CaloriasXUnidad),
    Calorias is CaloriasXUnidad * Cant.
caloriasXConsumible(bebida(Tipo,_),Calorias):-
    calorias(Tipo,Calorias).

/*
D) El polimorfismo me permite modelar mejor los hechos, hacerlos mas expresivos. Como consecuencia de trabajar un mismo predicado con distintos
   functores, debo recurrir a predicados auxiliares en los que utilizo pattern matching para poder discriminar por functor. Tambien, gracias a esto,
   si en un futuro quiero agregar mas functores para representar distintas cosas, se puede construir sobre el codigo. No deberia ser necesaria modificar
   caloriasTotales/2.
*/


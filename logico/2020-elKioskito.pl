% atiende(Nombre,Dia,Horario(Fin,Salida)).
atiende(dodain,lunes,horario(9,15)).
atiende(dodain,miercoles,horario(9,15)).
atiende(dodain,viernes,horario(9,15)).

atiende(lucas,martes,horario(10,20)).

atiende(juanC,sabados,horario(18,22)).
atiende(juanC,domingos,horario(18,22)).

atiende(juanFdS,jueves,horario(10,20)).
atiende(juanFdS,viernes,horario(12,20)).

atiende(leoC,lunes,horario(14,18)).
atiende(leoC,miercoles,horario(14,18)).

atiende(martu,miercoles,horario(23,24)).

atiende(vale,Dia,Horario):-
    atiende(dodain,Dia,Horario).
atiende(vale,Dia,Horario):-
    atiende(juanC,Dia,Horario).

% Punto 2: quien atiende el kiosko

quienAtiende(Dia,Hora,Persona):-
    atiende(Persona,Dia,horario(Inicio,Fin)),
    between(Inicio, Fin, Hora).

% Punto 3: ForeverAlone

foreverAlone(Persona,Dia,Hora):-
    quienAtiende(Dia,Hora,Persona),
    forall((quienAtiende(Dia,Hora,Persona),quienAtiende(Dia,Hora,Persona2)),
            Persona2 = Persona).

% Punto 4: posibilidades de atención
atiendenUnDia(Dia,Personas):-
    findall(Persona,distinct(atiende(Persona,Dia,_)),PersonasPosibles),
    sublistas(PersonasPosibles,Personas).

sublistas([],[]).
sublistas([_|Posibles],Personas):-
    sublistas(Posibles,Personas).
sublistas([Posible|Posibles],[Posible|Personas]):-
    sublistas(Posibles,Personas).

% Punto 5
% golosinas(Precio).
% cigarrillos(Marcas)
% bebidad(Tipo,Cantidad)
% venta(Persona,fecha(Dia,Numero,Mes),producto(...,...),Orden).
venta(dodain,fecha(lunes,10,agosto),golosinas(1200),1).
venta(dodain,fecha(lunes,10,agosto),cigarrillos([jockey]),2).
venta(dodain,fecha(lunes,10,agosto),golosinas(50),3).

venta(lucas,fecha(martes,11,agosto),golosinas(600),1).

venta(dodain,fecha(miercoles,12,agosto),bebidas(alcoholicas,8),1).
venta(dodain,fecha(miercoles,12,agosto),bebidas(noAlcoholicas,1),2).
venta(dodain,fecha(miercoles,12,agosto),golosinas(10),3).

venta(martu,fecha(miercoles,12,agosto),golosinas(1000),1).
venta(martu,fecha(miercoles,12,agosto),cigarrillos([chesterfield,colorado,parisiennes]),2).

venta(lucas,fecha(martes,18,agosto),bebidas(noAlcoholicas,2),1).
venta(lucas,fecha(martes,18,agosto),cigarrillos([derby]),2).

ventaImportante(golosinas(Monto)):-
    Monto > 100.

ventaImportante(cigarrillos(Cigarrillos)):-
    length(Cigarrillos, Cant),
    Cant > 5.
    
ventaImportante(bebidas(alcoholicas,_)).
ventaImportante(bebidas(noAlcoholicas),Cant):-
    Cant > 5.

diasQueAtendio(Persona,Fecha):-
    venta(Persona,Fecha,_,_).

esSuertuda(Persona):-
    venta(Persona,_,_,_),
    forall(diasQueAtendio(Persona,Fecha),(venta(Persona,Fecha,Venta,1),
            ventaImportante(Venta))).

:-begin_tests(kioskito).
    
    test(atienden_los_viernes, set(Persona = [vale, dodain, juanFdS])):-
        atiende(Persona,viernes,_).
    
    test(personas_que_atienden_un_dia_puntual_y_hora_puntual, set(Persona = [vale, dodain, leoC])):-
        quienAtiende(lunes, 14, Persona).
    
    test(dias_que_atiende_una_persona_en_un_horario_puntual, set(Dia = [lunes, miercoles, viernes])):-
      quienAtiende(Dia, 10, vale).

  
    test(una_persona_esta_forever_alone_porque_atiende_sola, set(Persona=[lucas])):-
      foreverAlone(Persona, martes, 19).
   
    test(persona_que_no_cumple_un_horario_no_puede_estar_forever_alone, fail):-
      foreverAlone(martu, miercoles, 22).
    
   
    test(posibilidades_de_atencion_en_un_dia_muestra_todas_las_variantes_posibles, set(Personas=[[],[dodain],[dodain,leoC],[dodain,leoC,martu],[dodain,leoC,martu,vale],[dodain,leoC,vale],[dodain,martu],[dodain,martu,vale],[dodain,vale],[leoC],[leoC,martu],[leoC,martu,vale],[leoC,vale],[martu],[martu,vale],[vale]])):-
      atiendenUnDia(miercoles, Personas).
    
    
    test(personas_suertudas, set(Persona = [martu, dodain])):-
      esSuertuda(Persona).
    
    :-end_tests(kioskito).
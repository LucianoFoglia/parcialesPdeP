% Punto 1:
cree(gabriel,campanita).
cree(gabriel,magoDeOz).
cree(gabriel,cavenaghi).
cree(juan,conejoDePascua).
cree(macarena,reyesMagos).
cree(macarena,magoCapria).
cree(macarena,campanita).

% suenio(Persona,Tipo).
% Tipo -> cantante(CantVentas), futbolista(Equipo), ganarLoteria([NumerosApostados])
suenio(gabriel,ganarLoteria([5,9])).
suenio(gabriel,futbolista(arsenal)).
suenio(juan,cantante(100000)).
suenio(macarena,cantante(10000)).
/*
Para modelar los suenios, utilice functores ya que de esta manera es posible tener todos los suenios bajo el mismo hecho.
Tambien, entra el juego el concepto de universo cerrado ya que por ejemplo, para el caso de diego, no agregue un hecho mostrando eso.
*/


% Punto 2:
equipoChico(arsenal).
equipoChico(aldosivi).

personaAmbiciosa(Persona):-
    persona(Persona),
    findall(Dificultad,(suenio(Persona,Suenio),dificultadSuenio(Suenio,Dificultad)),DificultadesSuenios),
    sum_list(DificultadesSuenios, Dificultades),
    Dificultades > 20.

dificultadSuenio(cantante(Numero),6):-
    Numero > 500000.
dificultadSuenio(cantante(Numero),4):-
    Numero =< 500000.

dificultadSuenio(ganarLoteria(Numeros),Dificultad):-
    length(Numeros, CantNumeros),
    Dificultad is CantNumeros * 10.

dificultadSuenio(futbolista(Equipo),3):-
    equipoChico(Equipo).
dificultadSuenio(futbolista(Equipo),16):-
    not(equipoChico(Equipo)).

persona(Persona):-
    suenio(Persona,_).
    

% Punto 3:
tieneQuimica(campanita,Persona):-
    suenio(Persona,Suenio),
    cree(Persona,campanita),
    dificultadSuenio(Suenio,Dificultad),
    Dificultad < 5.

tieneQuimica(Personaje,Persona):-
    cree(Persona,Personaje),
    Personaje \= campanita,
    forall(suenio(Persona,Suenio),esPuro(Suenio)),
    not(personaAmbiciosa(Persona)).

esPuro(futbolista(_)).
esPuro(cantante(CantVentas)):-
    CantVentas < 200000.

personaje(Personaje):-
    cree(_,Personaje).


% Punto4:
amigos(campanita,reyesMagos).
amigos(camapanita,conejoDePascua).
amigos(conejoDePascua,cavenaghi).

puedeAlegrar(Personaje,Persona):-
    suenio(Persona,_),
    tieneQuimica(Personaje,Persona),
    not(estaEnfermo(Personaje)).

estaEnfermo(camapanita).
estaEnfermo(reyesMagos).
estaEnfermo(conejoDePascua).

backup(Personaje,Backup):-
    amigos(Personaje,Backup).
backup(Personaje,Backup):-
    amigos(Personaje,Intermediario),
    amigos(Intermediario,Backup).
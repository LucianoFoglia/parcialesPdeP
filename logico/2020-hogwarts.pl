% Base de Conocimiento
casa(gryffindor).
casa(slytherin).
casa(ravenclaw).
casa(hufflepuff).

tipoSangre(harry,mestiza).
tipoSangre(draco,pura).
tipoSangre(hermione,impura).

caracter(harry,[corajudo,amistoso,orgulloso,inteligente]).
caracter(draco,[inteligente,orgulloso]).
caracter(hermione,[inteligente,orgulloso,responsable]).

odiariaIr(harry,slytherin).
odiariaIr(draco,hufflepuff).

% Ademas nos interesa saber cuáles son las características principales que el sombrero tiene en cuenta para elegir la casa más apropiada:
% Para Gryffindor, lo más importante es tener coraje.
casaApropiada(gryffindor,Persona):-
    caracter(Persona,Caracteristicas),
    member(corajudo, Caracteristicas).

% Para Slytherin, lo más importante es el orgullo y la inteligencia.
casaApropiada(slytherin,Persona):-
    caracter(Persona,Caracteristicas),
    member(orgulloso, Caracteristicas),
    member(inteligente, Caracteristicas).

% Para Ravenclaw, lo más importante es la inteligencia y la responsabilidad.
casaApropiada(ravenclaw,Persona):-
    caracter(Persona,Caracteristicas),
    member(inteligente, Caracteristicas),
    member(responsable, Caracteristicas).

% Para Hufflepuff, lo más importante es ser amistoso.
casaApropiada(hufflepuff,Persona):-
    caracter(Persona,Caracteristicas),
    member(amistoso, Caracteristicas).


% Se pide:


% 1- Saber si una casa permite entrar a un mago, lo cual se cumple para cualquier mago y cualquier casa excepto en el caso de Slytherin, 
%   que no permite entrar a magos de sangre impura.
permiteEntrar(Casa,_):-
    casa(Casa),
    Casa \= slytherin.
permiteEntrar(slytherin,Mago):-
    tipoSangre(Mago,Tipo),
    Tipo \= impura.

%2- Saber si un mago tiene el carácter apropiado para una casa, lo cual se cumple para cualquier mago si sus características incluyen
%   todo lo que se busca para los integrantes de esa casa, independientemente de si la casa le permite la entrada.
caracterApropiado(Casa,Mago):-
    casaApropiada(Casa,Mago).


% 3- Determinar en qué casa podría quedar seleccionado un mago sabiendo que tiene que tener el carácter adecuado para la casa,
%    la casa permite su entrada y además el mago no odiaría que lo manden a esa casa. Además Hermione puede quedar seleccionada en Gryffindor, 
%    porque al parecer encontró una forma de hackear al sombrero.
puedeQuedarSeleccionado(gryffindor,hermione).
puedeQuedarSeleccionado(Casa,Mago):-
    caracterApropiado(Casa,Mago),
    permiteEntrar(Casa,Mago),
    not(odiariaIr(Mago,Casa)).

% 4- Definir un predicado cadenaDeAmistades/1 que se cumple para una lista de magos si todos ellos se caracterizan por ser amistosos y cada uno 
%   podría estar en la misma casa que el siguiente. No hace falta que sea inversible, se consultará de forma individual.
cadenaDeAmistades([]).
cadenaDeAmistades([Mago|Magos]):-
    sonTodosAmistosos([Mago|Magos]),
    mismaCasaQueElSiguiente(Mago,Magos),
    cadenaDeAmistades(Magos).

sonTodosAmistosos(Magos):-
    forall(member(Mago,Magos),(caracter(Mago,Caracteristicas),member(amistoso,Caracteristicas))).

mismaCasaQueElSiguiente(_,[]).
mismaCasaQueElSiguiente(Mago,[OtroMago|_]):-
    puedeQuedarSeleccionado(Casa,Mago),
    puedeQuedarSeleccionado(Casa,OtroMago).

%%% Parte 2 - La copa de las casas
accion(harry,fueraDeCama). % -75
accion(hermione,fueA(tercerPiso)). % -75
accion(hermione,fueA(seccionResBiblioteca)). % -10
accion(harry,fueA(bosque)). % -50
accion(harry,fueA(tercerPiso)). % -75
accion(draco,fueA(mazmorras)).
accion(ron,buenaAccion(ganarAjedrezMagico,50)). % +50
accion(hermione,buenaAccion(salvarAmigos,50)). % +50
accion(harry,buenaAccion(ganarleAVoldemort,60)). % +60

accion(hermione,responderPregunta("Donde se encuentra un Bezoar",20,snape)).
accion(hermione,responderPregunta("Como hacer levitar una pluma",25,flitwick)).

puntosARestarPor(fueA(bosque),-50).
puntosARestarPor(fueA(seccionResBiblioteca),-10).
puntosARestarPor(fueA(tercerPiso),-75).
puntosARestarPor(fueraDeCama,-75).

esDe(hermione, gryffindor).
esDe(ron, gryffindor).
esDe(harry, gryffindor).
esDe(draco, slytherin).
esDe(luna, ravenclaw).

/*
1)A) Saber si un mago es buen alumno, que se cumple si hizo alguna acción y ninguna de las cosas que hizo se considera una mala acción 
     (que son aquellas que provocan un puntaje negativo).
*/
buenAlumno(Mago):-
    accion(Mago,_),
    not(tieneAccionesMalas(Mago)).

tieneAccionesMalas(Mago):-
    accion(Mago,fueA(Lugar)),
    puntosARestarPor(Lugar,_).
/*
1)B) Saber si una acción es recurrente, que se cumple si más de un mago hizo esa misma acción.
*/
accionRecurrente(Accion):-
    accion(Mago1,Accion),
    accion(Mago2,Accion),
    Mago1 \= Mago2.

% 2) Saber cuál es el puntaje total de una casa, que es la suma de los puntos obtenidos por sus miembros.
puntajeTotal(Casa,Puntaje):-
    casa(Casa),
    findall(Puntos,(esDe(Mago,Casa),accion(Mago,Accion),puntajeDeUnaAccion(Accion,Puntos)),Puntajes),
    sum_list(Puntajes, Puntaje).

puntajeDeUnaAccion(buenaAccion(_,Puntos),Puntos).
puntajeDeUnaAccion(Accion,Puntos):-
    puntosARestarPor(Accion,Puntos).

puntajeDeUnaAccion(responderPregunta(_,Dificultad,Profesor),Dificultad):-
    Profesor \= snape.
puntajeDeUnaAccion(responderPregunta(_,Dificultad,snape),Puntos):-
    Puntos is Dificultad // 2.
% 3) Saber cuál es la casa ganadora de la copa, que se verifica para aquella casa que haya obtenido una cantidad mayor de puntos que todas las otras.
casaGanadora(Ganadora):-
    findall(Puntaje,puntajeTotal(_,Puntaje),Puntajes),
    max_list(Puntajes, PuntajeMax),
    puntajeTotal(Ganadora, PuntajeMax).

% Punto 4)
% accion(QuienRespondio,respuestaPregunta(Cual,Dificultad,Profesor)).
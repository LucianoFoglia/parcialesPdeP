nombre(jugador(Nombre,_,_,_,_,_), Nombre).
nombre(criatura(Nombre,_,_,_), Nombre).
nombre(hechizo(Nombre,_,_), Nombre).

vida(jugador(_,Vida,_,_,_,_), Vida).
vida(criatura(_,_,Vida,_), Vida).
vida(hechizo(_,curar(Vida),_), Vida).

danio(hechizo(_,danio(Danio),_), Danio).
danio(criatura(_,Danio,_,_), Danio).

mana(jugador(_,_,Mana,_,_,_), Mana).
mana(criatura(_,_,_,Mana), Mana).
mana(hechizo(_,_,Mana), Mana).

cartasMazo(jugador(_,_,_,Cartas,_,_), Cartas).
cartasMano(jugador(_,_,_,_,Cartas,_), Cartas).
cartasCampo(jugador(_,_,_,_,_,Cartas), Cartas).

/*
% jugadores
jugador(Nombre,PuntosVida,PuntosMana,CartasMazo,CartasMano,CartasCampo).

% cartas
criatura(Nombre, PuntosDaño, PuntosVida, CostoMana)
hechizo(Nombre, FunctorEfecto, CostoMana)

% efectos
danio(CantidadDaño)
cura(CantidadCura)
*/

% jugador(Nombre,PuntosVida,PuntosMana,CartasMazo,CartasMano,CartasCampo).
jugador(jugador(carlos,150,20,[hechizo(bolaDeFuego,danio(250),15),hechizo(curacion,cura(185),8)], [criatura(slime,300,150,8),criatura(arbol,245,12,8)],[criatura(zombie,150,150,12)])).

jugador(jugador(ana,200,150,[hechizo(curacion,cura(560),27)], [criatura(centaruro,2500,15000,400),criatura(cerdo,323,149,18)],
    [criatura(pollo,150,125,12)])).

jugador(jugador(guerrero,200,150,[], [criatura(cataputa,1500,15000,400),criatura(cerdo,323,149,18)],
    [criatura(pollo,150,125,12)])).

jugador(jugador(wachin,150,150,[], [criatura(slime,300,150,8),criatura(arbol,245,12,8),criatura(chupaAlmas,245,12,140)],[])).

% Punto 1:
% Relacionar un jugador con una carta que tiene. La carta podría estar en su mano, en el campo o en el mazo.
tieneCarta(Jugador,Carta):-
    jugador(Jugador),
    cartasMazo(Jugador,Cartas),
    member(Carta,Cartas).
tieneCarta(Jugador,Carta):-
    jugador(Jugador),
    cartasCampo(Jugador,Cartas),
    member(Carta,Cartas).
tieneCarta(Jugador,Carta):-
    jugador(Jugador),
    cartasMano(Jugador,Cartas),
    member(Carta,Cartas).

% Punto 2:
% Saber si un jugador es un guerrero. Es guerrero cuando todas las cartas que tiene, ya sea en el mazo, la mano o el campo, son criaturas.
esGuerrero(Jugador):-
    jugador(Jugador),
    forall(tieneCarta(Jugador,Carta),esCriatura(Carta)).

esCriatura(criatura(_,_,_,_)).

% Punto 3:
% Relacionar un jugador consigo mismo después de empezar el turno. Al empezar el turno, la primera carta del mazo pasa a estar en la mano
% y el jugador gana un punto de maná.
postTurno(Jugador,jugador(Nombre, PuntosVida, PuntosMana,Cartas, [Cabeza|CartasM], CartasCampo)):-
    jugador(Jugador),
    nombre(Jugador,Nombre),
    vida(Jugador,PuntosVida),
    mana(Jugador, Mana),
    PuntosMana is Mana + 1,
    cartasMazo(Jugador,[Cabeza|Cartas]),
    cartasMano(Jugador,CartasM),
    cartasCampo(Jugador,CartasCampo).

% Punto 4:
% A)
% Saber si un jugador tiene la capacidad de jugar una carta, esto es verdadero cuando el jugador 
% tiene igual o más maná que el costo de maná de la carta. 
puedeJugarCarta(Jugador,Carta):-
    mana(Jugador,ManaJugador),
    mana(Carta,ManaCarta),
    ManaJugador >= ManaCarta.

% B)
/*
Relacionar un jugador y las cartas que va a poder jugar en el próximo turno, una carta se puede jugar en el próximo turno si tras
empezar ese turno está en la mano y además se cumplen las condiciones del punto 4.a.
*/
puedeJugarCartaProximoTurno(Jugador,Carta):-
    jugador(Jugador),
    postTurno(Jugador,JugadorPostTurno),
    cartasMano(JugadorPostTurno,CartasMano),
    member(Carta,CartasMano),
    puedeJugarCarta(JugadorPostTurno,Carta).

% Punto 5:
/*
Conocer, de un jugador, todas las posibles jugadas que puede hacer en el próximo turno, esto es, el conjunto de cartas que podrá jugar al mismo 
tiempo sin que su maná quede negativo.
Nota: Se puede asumir que existe el predicado jugar/3 como se indica en el punto 7.b. No hace falta implementarlo para resolver este punto. 
Importante: También hay formas de resolver este punto sin usar jugar/3.
Tip: Pensar en explosión combinatoria.
*/
posiblesJugadas(Jugador,CartasJugadas):-
    jugador(Jugador),
    cartasPosibles(Jugador,CartasPosibles),
    puedeJugarlas(CartasPosibles,CartasJugadas),
    manaPositivo(Jugador,CartasJugadas).

cartasPosibles(Jugador,CartasPosibles):-
    jugador(Jugador),
    cartasMano(Jugador,CartasMano),
    findall(CartaPosible,(member(CartaPosible,CartasMano),puedeJugarCarta(Jugador,CartaPosible)),CartasPosibles).

puedeJugarlas([],[]).
puedeJugarlas([Posible|Posibles],[Posible|Jugadas]):-
    puedeJugarlas(Posibles,Jugadas).
puedeJugarlas([_|Posible],Jugadas):-
    puedeJugarlas(Posible,Jugadas).

manaPositivo(Jugador,[]):-
    mana(Jugador,Mana),
    Mana >= 0.
manaPositivo(Jugador,[Carta|Cartas]):-
    jugar(Jugador,Carta,JugadorPostCarta),
    mana(Jugador,Mana),
    Mana >= 0,
    manaPositivo(JugadorPostCarta,Cartas).


% Punto 6:
% Relacionar a un jugador con el nombre de su carta más dañina.
cartaMasDanina(Jugador,CartaDanina):-
    tieneCarta(Jugador,CartaDanina),
    danio(CartaDanina,MayorDanio),
    not((tieneCarta(Jugador,OtraCarta),danio(OtraCarta,OtroDanio),OtraCarta \= CartaDanina, MayorDanio =< OtroDanio)).

% Punto 7: A)
jugarContra(Jugador,hechizo(_,danio(Danio),_),jugador(Nombre,PuntosVidaRestantes,PuntosMana,CartasMazo,CartasMano,CartasCampo)):-
    vida(Jugador,Vida),
    nombre(Jugador,Nombre),
    mana(Jugador,PuntosMana),
    PuntosVidaRestantes is Vida - Danio,
    cartasMazo(Jugador,CartasMazo),
    cartasMano(Jugador,CartasMano),
    cartasCampo(Jugador,CartasCampo).

% Punto 7: B)
jugar(Jugador,hechizo(Nombre,cura(CuantoCura),CostoMana),jugador(Nombre,VidaFinal,ManaRestante,CartasMazo,CartasManoFinal,CartasCampo)):-
    puedeJugarCarta(Jugador,hechizo(Nombre,cura(CuantoCura),CostoMana)),
    vida(Jugador,Vida),
    nombre(Jugador,Nombre),
    manaPostCarta(Jugador,hechizo(Nombre,cura(CuantoCura),CostoMana),ManaRestante),
    VidaFinal is CuantoCura + Vida,
    cartasYSacarCartaUsada(Jugador,CartasMazo,_,CartasManoFinal,CartasCampo,hechizo(Nombre,cura(CuantoCura),CostoMana)).

jugar(Jugador,Carta,jugador(Nombre,Vida,ManaRestante,CartasMazo,CartasManoFinal,CartasCampo)):-
    esCriatura(Carta),
    puedeJugarCarta(Jugador,Carta),
    vida(Jugador,Vida),
    nombre(Jugador,Nombre),
    manaPostCarta(Jugador,Carta,ManaRestante),
    cartasYSacarCartaUsada(Jugador,CartasMazo,_,CartasManoFinal,CartasCampo,Carta).    

manaPostCarta(Jugador,Carta,ManaRestante):-
    mana(Jugador,PuntosMana),
    mana(Carta,CostoMana),
    ManaRestante is PuntosMana - CostoMana.

cartasYSacarCartaUsada(Jugador,CartasMazo,CartasMano,CartasManoFinal,CartasCampo,CartaUsada):-
    cartasMazo(Jugador,CartasMazo),
    cartasMano(Jugador,CartasMano),
    cartasCampo(Jugador,CartasCampo),
    delete(CartasMano,CartaUsada,CartasManoFinal).
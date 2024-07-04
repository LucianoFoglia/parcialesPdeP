% Base de conocimiento
persona(bart).
persona(larry).
persona(otto).
persona(marge).

%los magios son functores alMando(nombre, antiguedad), novato(nombre) y elElegido(nombre).
persona(alMando(burns,29)).
persona(alMando(clark,20)).
persona(novato(lenny)).
persona(novato(carl)).
persona(elElegido(homero)).

hijo(homero,abbe).
hijo(bart,homero).
hijo(larry,burns).

salvo(carl,lenny).
salvo(homero,larry).
salvo(otto,burns).

%Los beneficios son functores confort(descripcion), confort(descripcion, caracteristica), 
% dispersion(descripcion), economico(descripcion, monto).
gozaBeneficio(carl, confort(sillon)).
gozaBeneficio(lenny, confort(sillon)).
gozaBeneficio(lenny, confort(estacionamiento, techado)).
gozaBeneficio(carl, confort(estacionamiento, libre)).
gozaBeneficio(clark, confort(viajeSinTrafico)).
gozaBeneficio(clark, dispersion(fiestas)).
gozaBeneficio(burns, dispersion(fiestas)).
gozaBeneficio(lenny, economico(descuento, 500)).


% 1) Saber si una persona puede ser aspiranteMagio/1. Un aspirante a magio es una persona que es descendiente de un magio o le salvó la vida a un magio.
aspiranteMagio(Persona):-
    persona(Persona),
    salvo(Persona,NombreMagio),
    nombre(Magio,NombreMagio),
    esMagio(Magio).
aspiranteMagio(Persona):-
    persona(Persona),
    descendiente(Persona,NombreMagio),
    nombre(Magio,NombreMagio),
    esMagio(Magio).

nombre(Persona,Persona):-
    persona(Persona),
    not(esMagio(Persona)).
nombre(alMando(Nombre,_),Nombre):-
    persona(alMando(Nombre,_)).
nombre(novato(Nombre),Nombre):-
    persona(novato(Nombre)).
nombre(elElegido(Nombre),Nombre):-
    persona(elElegido(Nombre)).

descendiente(Persona,Ascendente):-
    hijo(Persona,Ascendente).
descendiente(Persona,Ascendente):-
    hijo(Persona,Intemediario),
    hijo(Intemediario,Ascendente).

esMagio(alMando(_,_)).
esMagio(novato(_)).
esMagio(elElegido(_)).

% Punto 2:
puedeDarOrdenes(DaOrdenes,RecibeOrdenes):-
    persona(elElegido(DaOrdenes)),
    esMagio(RecibeOrdenes).
puedeDarOrdenes(DaOrdenes,RecibeOrdenes):-
    persona(alMando(DaOrdenes,_)),
    persona(novato(RecibeOrdenes)).
puedeDarOrdenes(DaOrdenes,RecibeOrdenes):-
    persona(alMando(DaOrdenes,NivelDa)),
    persona(alMando(RecibeOrdenes,NivelRecibe)),
    NivelDa > NivelRecibe.

% Punto 3:
sienteEnvidia(NombreEnvidioso,Nombres):-
    nombre(Envidioso,NombreEnvidioso),
    persona(Envidioso),
    findall(Nombre,(esEnvidioso(Envidioso,Persona),nombre(Persona,Nombre)),Nombres).

esEnvidioso(NombreEnvidioso,Persona):-
    aspiranteMagio(NombreEnvidioso),
    esMagio(Persona).

esEnvidioso(Envidioso,Persona):-
    persona(Envidioso),
    not(esMagio(Envidioso)),
    not(aspiranteMagio(Envidioso)),
    aspiranteMagio(Persona).

esEnvidioso(Envidioso,Persona):-
    persona(novato(Envidioso)),
    persona(alMando(Persona,_)).

% Punto 4:
% Definir el predicado masEnvidioso/1, permite conocer las personas más envidiosas. (Nota: definirlo sin usar forall/2).
masEnvidioso(Persona):-
    sienteEnvidia(Persona,Envidiados),
    length(Envidiados,CantEnvidiados),
    not((sienteEnvidia(OtraPersona,OtrosEnvidiados),length(OtrosEnvidiados,OtraCantEnvidiados),
         Persona \= OtraPersona,OtraCantEnvidiados > CantEnvidiados)).

% Punto 5: Definir el predicado soloLoGoza/2, que relaciona una persona y el  beneficio que sólo es aprovechado por él y nadie más de la logia. 

soloLoGoza(Persona,Beneficio):-
    gozaBeneficio(Persona,Beneficio),
    not((gozaBeneficio(OtraPersona,Beneficio),OtraPersona \= Persona)).
/*
soloLoGoza(Persona,Beneficio):-
    gozaBeneficio(Persona,Beneficio),
    forall((gozaBeneficio(OtraPersona,OtroBeneficio),OtraPersona \= Persona),Beneficio \= OtroBeneficio).
*/
% Punto 6:
tipoDeBeneficioMasAprovechado(TipoMAsAprovechado):-
    findall(Tipo,(gozaBeneficio(_,Beneficio),tipoBeneficio(Beneficio,Tipo)),Tipos),
    masVecesSeRepitio(Tipos,TipoMAsAprovechado).

masVecesSeRepitio(Lista,MasSeRepitio):-
    member(MasSeRepitio,Lista),
    contar(Lista,MasSeRepitio,CantMaxima),
    not((member(OtroElemento,Lista),contar(Lista,OtroElemento,Cant),Cant > CantMaxima,OtroElemento \= MasSeRepitio)).

contar(Lista,Elemento,Cantidad):-
    findall(1,(member(Cosa,Lista),Cosa = Elemento),Cosas),
    sum_list(Cosas,Cantidad).

tipoBeneficio(confort(_),confort).
tipoBeneficio(confort(_,_),confort).
tipoBeneficio(dispersion(_),dispersion).
tipoBeneficio(economico(_),economico).
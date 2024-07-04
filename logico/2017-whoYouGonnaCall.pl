herramientasRequeridas(ordenarCuarto, [aspiradora(100), trapeador, plumero]).
herramientasRequeridas(ordenarCuarto, [escoba, trapeador, plumero]).
herramientasRequeridas(limpiarTecho, [escoba, pala]).
herramientasRequeridas(cortarPasto, [bordedadora]).
herramientasRequeridas(limpiarBanio, [sopapa, trapeador]).
herramientasRequeridas(encerarPisos, [lustradpesora, cera, aspiradora(300)]).

% Punto 1:
tiene(egon,aspiradora(200)).
tiene(egon,trapeador).

tiene(egon,sopapa).
tiene(egon,escoba).
tiene(egon,pala).

tiene(peter,trapeador).
tiene(winston,varitaDeNeutrones).

% Punto 2:
tieneEsaHerramienta(Persona,HerramientaRequerida):-
    tiene(Persona,HerramientaRequerida).

tieneEsaHerramienta(Persona,aspiradora(PotenciaRequerida)):-
    tiene(Persona,aspiradora(PotenciaPropia)),
    PotenciaPropia >= PotenciaRequerida.

% Punto 3:
puedeRealizarUnaTarea(Persona,Tarea):-
    herramientasRequeridas(Tarea,_),
    tiene(Persona,varitaDeNeutrones).

puedeRealizarUnaTarea(Persona,Tarea):-
    herramientasRequeridas(Tarea,HerramientasRequeridas),
    tiene(Persona,_),
    forall(member(HerramientaRequerida,HerramientasRequeridas),
           tieneEsaHerramienta(Persona,HerramientaRequerida)).

% Punto 4:
% tareaPedidida(Cliente,Tarea,MetrosCuadrados).
tareaPedida(juan,limpiarBanio,10).
tareaPedida(juan,limpiarTecho,5).
tareaPedida(carlos,limpiarBanio,15).
tareaPedida(maria,encerarPisos,2).

% precio(Tarea, PrecioXMetroCuadrado).
precio(limpiarBanio,150).
precio(limpiarTecho,130).
precio(encerarPisos,200).

precioACobrar(Cliente,PrecioTotal):-
    tareaPedida(Cliente,_,_),
    findall(Precio,precioDeUnaTarea(Cliente,Precio),Precios),
    sum_list(Precios, PrecioTotal).

precioDeUnaTarea(Cliente,Precio):-
    tareaPedida(Cliente,Tarea,Metros2),
    precio(Tarea,PrecioXMetroCuadrado),
    Precio is Metros2 * PrecioXMetroCuadrado.

% Punto 5:
aceptaPedidos(CazaFantasmas,Cliente):-
    puedeRealizarTodasLasTareas(CazaFantasmas,Cliente),
    estaDispuestoAHacerlo(CazaFantasmas,Cliente).

puedeRealizarTodasLasTareas(Persona,Cliente):-
    forall(tareaPedida(Cliente,Tarea,_),puedeRealizarUnaTarea(Persona,Tarea)).

% Sabemos que Ray sólo acepta pedidos que no incluyan limpiar techos
estaDispuestoAHacerlo(ray,Cliente):-
    not(tareaPedida(Cliente,limpiarTecho,_)).

% Winston sólo acepta pedidos que paguen más de $500
estaDispuestoAHacerlo(winston,Cliente):-
    precioACobrar(Cliente,Precio),
    Precio > 500.

% Egon está dispuesto a aceptar pedidos que no tengan tareas complejas
estaDispuestoAHacerlo(egon,Cliente):-
    not(tieneTareasComplejas(Cliente)).

% Peter está dispuesto a aceptar cualquier pedido
estaDispuestoAHacerlo(peter,Cliente):-
    tareaPedida(Cliente,_,_).

tieneTareasComplejas(Cliente):-
    tareaPedida(Cliente,Tarea,_),
    herramientasRequeridas(Tarea,Herramientas),
    length(Herramientas,CantHerramientas),
    CantHerramientas > 2.
tareaCompleja(limpiarTecho).

% Punto 6:
/*
Necesitamos agregar la posibilidad de tener herramientas reemplazables, que incluyan 2 herramientas de las que pueden 
tener los integrantes como alternativas, para que puedan usarse como un requerimiento para poder llevar a cabo una tarea.
*/
/*
A) Modelaria este tipo de informacion agregando un hecho herramientasRequeridas/2 que indique otro conjunto de
   herramientas para esa tarea.
*/
% B) Ningun cambio.

/*
C) Es facil de incorporar ya que los predicados principales (los "madre"), trabajan a las acciones como si fueran
   todas iguales. Recien en los predicados "de menor nivel", trabajo con los functores. Esto es posible gracias al
   pensamiento top down y a 
*/
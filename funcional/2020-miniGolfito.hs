module Library where
import PdePreludat

doble :: Number -> Number
doble numero = numero + numero

-- Modelo inicial
data Jugador = UnJugador {
  nombre :: String,
  padre :: String,
  habilidad :: Habilidad
} deriving (Eq, Show)

data Habilidad = Habilidad {
  fuerzaJugador :: Number,
  precisionJugador :: Number
} deriving (Eq, Show)

-- Jugadores de ejemplo
bart = UnJugador "Bart" "Homero" (Habilidad 25 60)
todd = UnJugador "Todd" "Ned" (Habilidad 15 80)
rafa = UnJugador "Rafa" "Gorgory" (Habilidad 10 1)

data Tiro = UnTiro {
  velocidad :: Number,
  precision :: Number,
  altura :: Number
} deriving (Eq, Show)

type Puntos = Number

-- Funciones útiles
between n m x = elem x [n .. m]

maximoSegun f = foldl1 (mayorSegun f)
mayorSegun f a b
  | f a > f b = a
  | otherwise = b

{-
    1)Sabemos que cada palo genera un efecto diferente, por lo tanto elegir el palo correcto puede ser la diferencia entre
      ganar o perder el torneo.
        A) Modelar los palos usados en el juego que a partir de una determinada habilidad generan un tiro que se compone por 
           velocidad, precisión y altura.
            
-}

type Palo = Habilidad -> Tiro
-- I) El putter genera un tiro con velocidad igual a 10, el doble de la precisión recibida y altura 0.
putter :: Palo
putter habilidad = UnTiro {velocidad = 10,precision = precisionJugador habilidad * 2,altura = 0}

-- II) La madera genera uno de velocidad igual a 100, altura igual a 5 y la mitad de la precisión.
madera :: Palo
madera habilidad = UnTiro {velocidad = 100, altura = 5, precision = precisionJugador habilidad / 2}

-- III) Los hierros, que varían del 1 al 10 (número al que denominaremos n), generan un tiro de velocidad igual a 
--      la fuerza multiplicada por n, la precisión dividida por n y una altura de n-3 (con mínimo 0). Modelarlos de 
--      la forma más genérica posible.
hierros :: Number -> Palo
hierros n habilidad = UnTiro {velocidad = fuerzaJugador habilidad * n, precision = precisionJugador habilidad / n, altura = max (n-3) 0}

-- B) Definir una constante palos que sea una lista con todos los palos que se pueden usar en el juego.

palos = [putter,madera,(hierros 1),(hierros 2),(hierros 3),(hierros 4),(hierros 5),(hierros 6),(hierros 7),(hierros 8),(hierros 9),(hierros 10)]

{-
    2) Definir la función golpe que dados una persona y un palo, obtiene el tiro resultante de usar ese palo con las habilidades de la persona.
       Por ejemplo si Bart usa un putter, se genera un tiro de velocidad = 10, precisión = 120 y altura = 0.
-}

golpe :: Jugador -> Palo -> Tiro
golpe persona palo = palo (habilidad persona)

{-
  3) Lo que nos interesa de los distintos obstáculos es si un tiro puede superarlo, y en el caso de poder superarlo,
     cómo se ve afectado dicho tiro por el obstáculo. En principio necesitamos representar los siguientes obstáculos:
-}

tiroDetenido = UnTiro 0 0 0
data Obstaculo = UnObstaculo{
  tiroPostObstaculo :: Tiro -> Tiro,
  superaObstaculo :: Tiro -> Bool
}deriving (Show,Eq)

-- Por obstaculo, tengo que hacer 2 funciones -> Si el tiro lo supera y como queda despues del obstaculo. Tambien tengo que hacer su data
type PostObstaculo = Tiro -> Tiro
type PasaObstaculo = Tiro -> Bool
{-
  A) Un túnel con rampita sólo es superado si la precisión es mayor a 90 yendo al ras del suelo, independientemente 
  de la velocidad del tiro. Al salir del túnel la velocidad del tiro se duplica, la precisión pasa a ser 100 y la altura 0.
-}

postTunelConRampita :: PostObstaculo
postTunelConRampita tiro 
  | superaTunelConRampita tiro = tiro {velocidad = velocidad tiro * 2, precision = 100, altura = 0}
  | otherwise = tiroDetenido

superaTunelConRampita :: PasaObstaculo
superaTunelConRampita tiro = altura tiro == 0 && precision tiro > 90

tunelConRampita = UnObstaculo postTunelConRampita superaTunelConRampita

{-
  B) Una laguna es superada si la velocidad del tiro es mayor a 80 y tiene una altura de entre 1 y 5 metros. Luego de superar
  una laguna el tiro llega con la misma velocidad y precisión, pero una altura equivalente a la altura original dividida por el largo de la laguna.
-}

tiroPostLaguna :: Number -> PostObstaculo
tiroPostLaguna largo tiro
  | superaLaguna largo tiro = tiro {altura = altura tiro / largo}
  | otherwise = tiroDetenido

superaLaguna :: Number -> PasaObstaculo
superaLaguna largo tiro = velocidad tiro > 80 && between 1 5 (altura tiro)

laguna n = UnObstaculo (tiroPostLaguna n) (superaLaguna n)

{-
  C) Un hoyo se supera si la velocidad del tiro está entre 5 y 20 m/s yendo al ras del suelo con una precisión mayor a 95.
  Al superar el hoyo, el tiro se detiene, quedando con todos sus componentes en 0.
-}

tiroPostHoyo :: PostObstaculo
tiroPostHoyo _ = tiroDetenido

superaHoyo :: PasaObstaculo
superaHoyo tiro = between 5 20 (velocidad tiro) && altura tiro == 0 && precision tiro > 95

hoyo = UnObstaculo tiroPostHoyo superaHoyo

-- Ejercicio 4)
--  A) Definir palosUtiles que dada una persona y un obstáculo, permita determinar qué palos le sirven para superarlo.

palosUtiles :: Jugador -> Obstaculo -> [Palo]
palosUtiles persona obstaculo = filter (superaObstaculoConEsePalo persona obstaculo) palos

superaObstaculoConEsePalo :: Jugador -> Obstaculo -> Palo -> Bool
superaObstaculoConEsePalo persona obstaculo palo = superaObstaculo obstaculo (golpe persona palo) 

{-
    B) Saber, a partir de un conjunto de obstáculos y un tiro, cuántos obstáculos consecutivos se pueden superar.
       Por ejemplo, para un tiro de velocidad = 10, precisión = 95 y altura = 0, y una lista con dos túneles con rampita 
       seguidos de un hoyo, el resultado sería 2 ya que la velocidad al salir del segundo túnel es de 40, por ende no supera el hoyo.
       BONUS: resolver este problema sin recursividad, teniendo en cuenta que existe una función
           takeWhile :: (a -> Bool) -> [a] -> [a] que podría ser de utilidad.
-}

obstaculos1 = [tunelConRampita,tunelConRampita,hoyo]
tiro1 = UnTiro 10 95 0

cuantosObstaculoConsecutivosSupera :: [Obstaculo] -> Tiro -> Number
cuantosObstaculoConsecutivosSupera [] _ = 0
cuantosObstaculoConsecutivosSupera (obs1:obsS) tiroOG
  | superaObstaculo obs1 tiroOG = 1 + cuantosObstaculoConsecutivosSupera (obsS) (tiroPostObstaculo obs1 tiroOG)
  | otherwise = 0

{-
  C) Definir paloMasUtil que recibe una persona y una lista de obstáculos y determina 
     cuál es el palo que le permite superar más obstáculos con un solo tiro.
-}

paloMasUtil :: Jugador -> [Obstaculo] -> Palo
paloMasUtil persona obstaculos = maximoSegun (cuantosObstaculoConsecutivosSupera obstaculos.golpe persona) palos

{-
  5) Dada una lista de tipo [(Jugador, Puntos)] que tiene la información de cuántos puntos ganó cada niño al finalizar el
  torneo, se pide retornar la lista de padres que pierden la apuesta por ser el “padre del niño que no ganó”. Se dice que un niño
  ganó el torneo si tiene más puntos que los otros niños.
-}

padresQuePerdieron :: [(Jugador,Puntos)] -> [String]
padresQuePerdieron lista = ((map (padre.fst)).niniosPerdedores) lista

niniosPerdedores :: [(Jugador,Puntos)] -> [(Jugador,Puntos)]
niniosPerdedores lista = filter (((/= ninioGanador lista).fst)) lista

ninioGanador :: [(Jugador,Puntos)] -> Jugador
ninioGanador lista = fst (maximoSegun snd lista)

listaPuntos = [(bart,10),(todd,2),(rafa,15)]
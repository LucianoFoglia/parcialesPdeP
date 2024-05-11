module Library where
import PdePreludat

data Auto = UnAuto{
    color :: String,
    velocidad :: Number,
    distancia :: Number
} deriving (Show,Eq)

type Carrera = [Auto]

-- Ejercicio 1)

estaCerca :: Auto -> Auto -> Bool
estaCerca auto otroAuto = (abs (distancia auto - distancia otroAuto) < 10) && (auto /= otroAuto)

vaTranquilo :: Auto -> Carrera -> Bool
vaTranquilo auto carrera = all (not.(estaCerca auto)) carrera && (distancia auto) == maximum (listaDistancias carrera)

listaDistancias = map distancia

posicionDeUnAuto :: Auto -> Carrera -> Number
posicionDeUnAuto auto carrera =  (length carrera) - (length.(filter (not.leGana auto))) carrera + 1

leGana :: Auto -> Auto -> Bool
leGana otroAuto auto = distancia auto > distancia otroAuto
-- Pregunta si Auto le gana a OtroAuto

-- Ejercicio 2)

correr :: Number -> Auto -> Auto
correr tiempo auto = auto{distancia = distancia auto + (tiempo * velocidad auto)}

alterarVelocidad :: (Number -> Number) -> Auto -> Auto
alterarVelocidad funcion auto = auto{velocidad = max 0 (funcion (velocidad auto))}

bajarVelocidad  :: Number -> Auto -> Auto
bajarVelocidad numero auto = alterarVelocidad (flip (-) numero) auto


-- Ejercicio 3)

type PowerUp = Auto -> Carrera -> Carrera

terremoto :: PowerUp
terremoto auto carrera = afectarALosQueCumplen (estaCerca auto) (bajarVelocidad 50) carrera


miguelitos :: Number -> PowerUp
miguelitos reduccion auto carrera = afectarALosQueCumplen (leGana auto) (bajarVelocidad reduccion) carrera

jetPack :: Number -> PowerUp
jetPack tiempo auto carrera = afectarALosQueCumplen (==auto) (cambiosJetPack tiempo) carrera

cambiosJetPack :: Number -> Auto -> Auto
cambiosJetPack tiempo auto = auto {distancia = distancia (correr tiempo (alterarVelocidad (*2) auto))}

afectarALosQueCumplen :: (a -> Bool) -> (a -> a) -> [a] -> [a]
afectarALosQueCumplen criterio efecto lista = 
    map (efectoSiCumpleCriterio criterio efecto) lista

efectoSiCumpleCriterio :: (a -> Bool) -> (a -> a) -> a -> a
efectoSiCumpleCriterio criterio efecto x
    | criterio x = efecto x
    | otherwise = x


-- Ejercicio 4)
-- Ejercicio 4)A)

simularCarrera :: Carrera -> [(Carrera -> Carrera)] -> [(Number,String)] -- [(Pos,Color)]
simularCarrera carrera eventos = obtenerPosiciones (aplicarListaEventos carrera eventos)

obtenerPosiciones :: Carrera -> [(Number,String)]
obtenerPosiciones carrera = map (\x -> (posicionDeUnAuto x carrera,color x)) carrera

aplicarListaEventos :: Carrera -> [(Carrera -> Carrera)] -> Carrera
aplicarListaEventos carrera [] = carrera
aplicarListaEventos carrera (x:xs) = aplicarListaEventos (x carrera) xs

-- Ejercicio 4)B)

correnTodos :: Number -> Carrera -> Carrera
correnTodos tiempo carrera = map (correr tiempo) carrera

usaPowerUp :: PowerUp -> String -> Carrera -> Carrera
usaPowerUp powerUp colorBusco carrera = powerUp (obtenerAutoPorColor colorBusco carrera) carrera

obtenerAutoPorColor :: String -> Carrera -> Auto
obtenerAutoPorColor colorBuscado = head.(filter ((==colorBuscado).(color)))

mercedes = UnAuto "Rojo" 120 0
ford = UnAuto "Blanco" 120 0
chevrolet = UnAuto "Azul" 120 0
fiat = UnAuto "Negro" 120 0

carrera1 = [mercedes,ford,chevrolet,fiat]
eventos1 = [(correnTodos 30),(usaPowerUp (jetPack 3) "Azul" ),(usaPowerUp terremoto "Blanco"),(correnTodos 40),
            (usaPowerUp (miguelitos 20) "Blanco"),(usaPowerUp (jetPack 6) "Negro"),(correnTodos 10)]

{-
5) En base a tu solución, responder:
    a) Si se quisiera agregar un nuevo power up, un misil teledirigido, que para poder activarlo se deba indicar el 
    color del auto al que se quiere impactar, ¿la solución actual lo permite o sería necesario cambiar algo de lo
    desarrollado en los puntos anteriores? Justificar.
        Podria agregarse esa nueva funcion. Por ahi, para que resulte mas comodo, habria que agregar algunba funcion auxiliar
    b) Si una carrera se conformara por infinitos autos, ¿sería posible usar las funciones del punto 1b y 1c de modo
    que terminen de evaluarse? Justificar.
        No seria posible. En ambos casos, debe leer la lista entera. Ya sea para averiguar su longitud o para comparar un elemento con el resto
-}
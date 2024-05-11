module Library where
import PdePreludat

-- Parcial Functional Master Series

-- Nombre: Foglia, Luciano (reemplazar por el tuyo)
-- Legajo: 203624-1 (reemplazar por el tuyo)

type Palabra = String
type Verso = String
type Estrofa = [Verso]
type Artista = String

esVocal :: Char -> Bool
esVocal = flip elem "aeiouáéíóú"

tieneTilde :: Char -> Bool
tieneTilde = flip elem "áéíóú"


--Ejercicio 1

type Rima = Palabra -> Palabra -> Bool

lasPalabrasRiman :: Rima
lasPalabrasRiman pal1 pal2 = (pal1 /= pal2) && (esRimaAsonante pal1 pal2 || esRimaConsonante pal1 pal2)

esRimaConsonante :: Rima
esRimaConsonante pal1 pal2 = (tomarUltimas 3 pal1) == (tomarUltimas 3 pal2)

esRimaAsonante ::Rima
esRimaAsonante pal1 pal2 = ultimas2Vocales pal1 == ultimas2Vocales pal2

ultimas2Vocales = (tomarUltimas 2).vocales

vocales = filter esVocal

tomarUltimas :: Number -> String -> String
tomarUltimas n = (take n).reverse

{-
    Clases de equivalencia de lasPalabrasRiman
    - Palabras que tengan rima asonante
    - Palabras que no tengan rima asonante
    - Palabras que tengan rima consonante
    - Palabras que no tengan rima consonante
    - Palabras que sean iguales
-}

--Ejercicio 2

type Congujacion = Verso -> Verso -> Bool

porMedioDeRimas :: Congujacion
porMedioDeRimas verso1 verso2 = lasPalabrasRiman (ultimaPalabra verso1) (ultimaPalabra verso2)

hacenAnadiplosis :: Congujacion
hacenAnadiplosis verso1 verso2 = (ultimaPalabra verso1) == (primerPalabra verso2)

primerPalabra = head.words
ultimaPalabra = last.words


--Ejercicio 3)

type Patron = Estrofa -> Bool


esPatronSimple :: Number -> Number -> Patron
esPatronSimple num1 num2 estrofa = porMedioDeRimas (tomarElemento num1 estrofa) (tomarElemento num2 estrofa)

tomarElemento posicion = (last.(take posicion)) 

estrofa1 = ["esta rima es fácil como patear un penal","solamente tiene como objetivo servir de ejemplo",
            "los versos del medio son medio fríos","porque el remate se retoma al final"]


esEstrofaEsdrujula :: Patron
esEstrofaEsdrujula estrofa = all esPalabraEsdrujula (ultimasPalabras estrofa)

esPalabraEsdrujula :: Verso -> Bool
esPalabraEsdrujula palabra = tieneTilde ((!!) (obtenerVocales palabra) 2)

obtenerVocales = filter esVocal

ultimasPalabras = map ultimaPalabra

estrofa2 = ["a ponerse los guantes y subir al cuadrilátero",
            "que después de este parcial acerca el paradigma lógico",
            "no entiendo por qué está fallando mi código",
            "si todas estas frases terminan en esdrújulas"]


anafora :: Patron
anafora estrofa = sonTodasIguales (map primerPalabra estrofa)

sonTodasIguales :: (Eq a) => [a] -> Bool
sonTodasIguales (x:xs) = all (== x) xs

estrofa3 = ["paradigmas hay varios, recién vamos por funcional",
            "paradigmas de programación es lo que analizamos acá",
            "paradigmas que te invitan a otras formas de razonar",
            "paradigmas es la materia que más me gusta cursar"]

esCadena :: Congujacion -> Patron
esCadena _ [a] = True
esCadena conjugacion [a,b] = conjugacion a b
esCadena conjugacion (x:y:xs) = conjugacion x y && esCadena conjugacion (y:xs) 

estrofa4 = ["este es un ejemplo de un parcial compuesto",
            "compuesto de funciones que se operan entre ellas",
            "ellas también pueden pasarse por parámetro",
            "parámetro que recibe otra función de alto orden"]


combinaDos :: Patron -> Patron -> Estrofa -> Bool
combinaDos pat1 pat2 estrofa = pat1 estrofa && pat2 estrofa

estrofa5 = ["estrofa que sirve como caso ejémplico",
            "estrofa dedicada a la gente fanática",
            "estrofa comenzada toda con anáfora",
            "estrofa que termina siempre con esdrújulas"]


patronAabb = combinaDos (esPatronSimple 1 2) (esPatronSimple 3 4)

patronAbab = combinaDos (esPatronSimple 1 3) (esPatronSimple 2 4)

patronAbba = combinaDos (esPatronSimple 1 4) (esPatronSimple 2 3)

patronHardcore = combinaDos (esCadena porMedioDeRimas) esEstrofaEsdrujula


{-
    Ejercicio 3)C)
    ¿Se podría saber si una estrofa con infinitos versos cumple con el patrón hardcore? 
    ¿Y el aabb? Justifique en cada caso específicamente por qué (no valen respuestas genéricas).
-}

data PuestaEnEscena = UnaEscena {
    publicoExaltado :: Bool,
    potencia :: Number,
    estrofa :: Estrofa,
    artista :: Artista
}deriving (Show,Eq)

escena1 = UnaEscena True 10 estrofa1 "Juan"

type Estilo = PuestaEnEscena -> PuestaEnEscena

gritar :: Estilo
gritar escena = escena {potencia = (potencia escena) * 1.5 }

responderUnAcote :: Bool -> Estilo
responderUnAcote efectividad escena
    | efectividad = escena{potencia = potencia escena * 1.2, publicoExaltado = True}
    | otherwise = escena {potencia = potencia escena * 1.2}

tirarTecnicas :: Patron -> Estilo
tirarTecnicas patron escena
    | patron (estrofa escena) = escena {potencia = potencia escena * 1.1,publicoExaltado = True}
    | otherwise = escena {potencia = potencia escena * 1.1}


--Ejercicio 4)

tirarFreestyle :: Artista -> Estilo -> Estrofa -> PuestaEnEscena 
tirarFreestyle artista estilo estrofa = estilo (UnaEscena False 1 estrofa artista)

type Jurado = [((PuestaEnEscena -> Bool),Number)]

alToke = [((patronAabb.estrofa),0.5),(((combinaDos (esPatronSimple 1 4) esEstrofaEsdrujula).estrofa),1),(publicoExaltado,1),(((>2).potencia),2)]

estrofa6 = ["esta rima es fácil como patear un penal",
            "porque el remate se retoma al final",
            "solamente tiene como objetivo servir de guapa",
            "los versos del medio son papa"]

escena2 = UnaEscena False 1 estrofa6 "Carlos"


puntajePuestaEnEscena :: Estilo -> Jurado -> PuestaEnEscena -> Number
puntajePuestaEnEscena estilo jurado escena
    | ((>3).(sumarSiEsTrue.(evaluarFunciones estilo jurado))) escena = 3
    | otherwise = (sumarSiEsTrue.(evaluarFunciones estilo jurado)) escena

evaluarFunciones :: Estilo -> Jurado -> PuestaEnEscena -> [(Bool,Number)]
evaluarFunciones estilo jurado escena = map (\(x,y) -> (($ tirarFreestyle (artista escena) estilo (estrofa escena)) x, y)) jurado

sumarSiEsTrue :: [(Bool,Number)] -> Number
sumarSiEsTrue lista = foldl sumaEspecial 0 lista

sumaEspecial :: Number -> (Bool,Number) -> Number
sumaEspecial num (x,y)
    | x = num + y
    | otherwise = num

-- Ejercicio 6)
{-
    Por último, llega el momento de las batallas.
    Una batalla se da siempre entre dos artistas. Cada artista deberá presentar diferentes puestas en escenas y la batalla consistirá
    de todas esas puestas en escena. El primer artista comenzará haciendo una puesta en escena, luego el segundo hará la suya, y de esta
    manera se irán turnando (de forma indefinida) hasta que la batalla termine.
    Al final, el artista ganador es quien haya sumado más puntos por parte del conjunto de jurados de la batalla y es quien se lleva el 
    cinto a la casa.

    A partir de una batalla y un conjunto de jurados, saber qué artista se lleva el cinto a la casa.
-}

lucho = [((patronAabb.estrofa),0.5),(((combinaDos (esPatronSimple 1 4) esEstrofaEsdrujula).estrofa),1),(publicoExaltado,1),(((>2).potencia),2)]

jurados = [alToke,lucho]
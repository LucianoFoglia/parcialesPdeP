module Library where
import PdePreludat

doble :: Number -> Number
doble numero = numero + numero

{-
    1) Modelar a las personas, de las cuales nos interesa:
        *la edad
        * cuáles son los ítems que tiene
        * la cantidad de experiencia que tiene
       Las criaturas teniendo en cuenta lo descrito anteriormente, y lo que queremos hacer en el punto siguiente.
-}

type Item = String -- ????

data Persona = UnaPersona{
    edad :: Number,
    items :: [Item],
    experiencia :: Number
}deriving (Show,Eq)

data Criatura = UnaCriatura{
    peligrosidad :: Number,
    comoDeshacerse :: (Persona -> Bool)
}deriving (Show,Eq)


{-
     * El siempredetras: la peligrosidad de esta criatura legendaria es 0, ya que no le hace nada a la persona que está acechando, 
       es tan inofensivo que nunca nadie pudo afirmar que estaba siendo acechado. Sin embargo, no hay nada que se pueda hacer 
       para que te deje en paz.
     * Los gnomos: individualmente son inofensivos, pero se especializan en atacar en grupo. 
       La peligrosidad es 2 elevado a la cantidad de gnomos agrupados. Una persona puede deshacerse de un grupo de gnomos si tiene un
       soplador de hojas entre sus ítems.
     * Los fantasmas: se categorizan del 1 al 10 dependiendo de qué tan poderosos sean, y el nivel de peligrosidad es esa categoría multiplicada por 20.
       Cada fantasma tiene un asunto pendiente distinto, con lo cual se debe indicar para cada uno qué tiene que cumplir la persona para resolver su 
       conflicto.
-}
comoDeshacerseSiempreDetras :: Persona -> Bool
comoDeshacerseSiempreDetras persona = True

siempredetras = UnaCriatura 0 comoDeshacerseSiempreDetras
gnomos cant = UnaCriatura (2^cant) ((elem "Soplador de hojas").items)
fantasma nivel asunto = UnaCriatura (nivel * 20) asunto


{-
    2) Hacer que una persona se enfrente a una criatura, que implica que si esa persona puede deshacerse de ella gane tanta experiencia como 
    la peligrosidad de la criatura, o que se escape (que le suma en 1 la experiencia, porque de lo visto se aprende) en caso de que no 
    pueda deshacerse de ella.
-}


enfrentarCriatura :: Criatura -> Persona -> Persona
enfrentarCriatura criatura persona
    | comoDeshacerse criatura persona = ganarExperiencia (peligrosidad criatura) persona
    | otherwise = ganarExperiencia 1 persona

ganarExperiencia :: Number -> Persona -> Persona
ganarExperiencia num persona = persona{experiencia = experiencia persona + num}

-- Ejercicio 3)
-- A) Determinar cuánta experiencia es capaz de ganar una persona luego de enfrentar sucesivamente a un grupo de criaturas.

cuantaExperienciaGana :: [Criatura] -> Persona -> Number
cuantaExperienciaGana [] _ = 0
cuantaExperienciaGana (c1:cs) persona
    | comoDeshacerse c1 persona = peligrosidad c1 + cuantaExperienciaGana cs persona
    | otherwise = 0 + cuantaExperienciaGana cs persona

{-
    B) Mostrar un ejemplo de consulta para el punto anterior incluyendo las siguientes criaturas: 
        * al siempredetras
        * a un grupo de 10 gnomos
        * un fantasma categoría 3 que requiere que la persona tenga menos de 13 años y un disfraz de oveja entre sus ítems para que se vaya
        * un fantasma categoría 1 que requiere que la persona tenga más de 10 de experiencia.
-}

condicionRara persona = ((< 13).edad) persona && ((elem "disfraz de oveja").items) persona

criaturas1 = [siempredetras,gnomos 10,fantasma 3 (condicionRara),fantasma 1 ((10<).experiencia)]


{-
    1) Definir recursivamente la función:
        que a partir de dos listas retorne una lista donde cada elemento:
        - se corresponda con el elemento de la segunda lista, en caso de que el mismo no cumpla con la condición indicada
        - en el caso contrario, debería usarse el resultado de aplicar la primer función con el par de elementos de dichas listas
        Sólo debería avanzarse sobre los elementos de la primer lista cuando la condición se cumple. 
        > zipWithIf (*) even [10..50] [1..7]
        [1,20,3,44,5,72,7] ← porque [1, 2*10, 3, 4*11, 5, 6*12, 7]
-}

zipWithIf :: (a -> b -> b) -> (b -> Bool) -> [a] -> [b] -> [b] 
zipWithIf _ _ [] x = x -- Me parece que este caso no habria que contemplarlo
zipWithIf _ _ x [] = []
zipWithIf modificador condicion (x:xs) (y:ys)
    | condicion y = (modificador x y ):(zipWithIf modificador condicion xs ys)
    | otherwise = (y:(zipWithIf modificador condicion (x:xs) ys))

{-
    2) Notamos que la mayoría de los códigos del diario están escritos en código César, que es una simple sustitución de todas las letras
    por otras que se encuentran a la misma distancia en el abecedario. Por ejemplo, si para encriptar un mensaje se sustituyó la a por la x,
    la b por la y, la c por la z, la d por la a, la e por la b, etc.. Luego el texto "jrzel zrfaxal!" que fue encriptado de esa forma se 
    desencriptaría como "mucho cuidado!".
-}

{-
    A) Hacer una función abecedarioDesde :: Char -> [Char] que retorne las letras del abecedario empezando por la letra indicada. 
    O sea, abecedarioDesde 'y' debería retornar 'y':'z':['a' .. 'x'].
-}

abecedarioDesde :: Char -> [Char]
abecedarioDesde letra = moverAbecedario letra abecedario

moverAbecedario :: Char -> [Char] -> [Char]
moverAbecedario letra (x:xs)
    | x == letra = (x:xs)
    | otherwise = (moverAbecedario letra (xs ++ [x])) 

abecedario = ['a'..'z']

{-
    B) Hacer una función desencriptarLetra :: Char -> Char -> Char que a partir una letra clave (la que reemplazaría a la a) y la letra que 
    queremos desencriptar, retorna la letra que se corresponde con esta última en el abecedario que empieza con la letra clave. 
    Por ejemplo: desencriptarLetra 'x' 'b' retornaría 'e'.
-}

desencriptarLetra :: Char -> Char -> Char
desencriptarLetra letraClave letraADesencriptar = tomarPosicion (obtenerPosicion letraADesencriptar (abecedarioDesde letraClave)) abecedario

tomarPosicion n = last.(take n)

obtenerPosicion :: Char -> [Char] -> Number
obtenerPosicion letra (x:xs)
    | letra == x = 1
    | otherwise = 1 + obtenerPosicion letra xs

{-
    C) Definir la función cesar :: Char -> String -> String que recibe la letra clave y un texto encriptado y retorna todo el texto desencriptado,
    teniendo en cuenta que cualquier caracter del mensaje encriptado que no sea una letra (por ejemplo '!') se mantiene igual. Usar zipWithIf 
    para resolver este problema.
-}

cesar :: Char -> String -> String
cesar letraClave texto = desencriptarAux (repeat letraClave) texto

esLetra :: Char -> Bool
esLetra letra = elem letra abecedario

desencriptarAux :: String -> String -> String
desencriptarAux clave texto = 
    zipWithIf desencriptarLetra esLetra clave texto

-- D) Realizar una consulta para obtener todas las posibles desencripciones (una por cada letra del abecedario) usando cesar para el 
--    texto "jrzel zrfaxal!".
cesarConTodasLasLetras :: String -> String -> [String]
cesarConTodasLasLetras _ [] = []
cesarConTodasLasLetras texto (x:xs) = [cesar x texto]  ++ (cesarConTodasLasLetras texto xs)

{-
    3 - BONUS) Un problema que tiene el cifrado César para quienes quieren ocultar el mensaje es que es muy fácil de desencriptar, y por eso es 
    que los mensajes más importantes del diario están encriptados con cifrado Vigenére, que se basa en la idea del código César, pero lo hace 
    a partir de un texto clave en vez de una sola letra.
    Supongamos que la clave es "pdep" y el mensaje encriptado es "wrpp, irhd to qjcgs!".
-}

vigenere :: String -> String -> String
vigenere textoClave textoADesencriptar = desencriptarAux textoClave textoADesencriptar


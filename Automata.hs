module Automata where

{--------
 - ZIPER -
 ---------}

{- Notre univers (un zipper).
   C'est un ruban infini à droite et à gauche.
 -}
data Universe a = Universe [a] a [a]

{- Voyager à gauche -}
left :: Universe a -> Universe a
left (Universe (x : xs) v ys) = Universe xs x (v: ys)

{- Voyager à droite -}
right :: Universe a -> Universe a
right (Universe xs v (y : ys)) = Universe (v : xs) y ys

{------------
 - COMONADE -
 ------------}

{- Extrait la valeur courante -}
extract :: Universe a -> a
extract (Universe _ v _) = v

{- C'est un foncteur -}
instance Functor Universe where
  fmap f (Universe xs v ys) = Universe (fmap f xs) (f v) (fmap f ys)

{- Construit un univers de tous les univers translaté -}
duplicate :: Universe a -> Universe (Universe a)
duplicate u = Universe (tail $ iterate left u ) u (tail $ iterate right u)

{---------------
 - CONVOLUTION -
 ---------------}

{- Les règles expriment si la case observée doit
   être vivante ou morte à la prochaine itération -}

{- Règle : Vivant si : Gauche != Droite -}
rule_lr :: Universe Bool -> Bool
rule_lr u = lv /= rv
  where
    lv = extract . left  $ u
    rv = extract . right $ u

{- Application d'une règle -}
next :: (Universe a -> a) -> Universe a -> Universe a
next rule universe = fmap rule $ duplicate universe

{- Règle 30 -}
rule_30 :: Universe Bool -> Bool
rule_30 u = toB $ case (toN lv, toN v, toN rv) of
    (1, 1, 1) -> 0
    (1, 1, 0) -> 0
    (1, 0, 1) -> 0
    (1, 0, 0) -> 1
    (0, 1, 1) -> 1
    (0, 1, 0) -> 1
    (0, 0, 1) -> 1
    (0, 0, 0) -> 0
  where
    lv = extract . left  $ u
    v  = extract u
    rv = extract . right $ u


{------------------------------
 Quelques valeurs prédéfinies :
 ------------------------------}

single_universe :: Universe Bool
single_universe = Universe (repeat False) True (repeat False)

duo_universe :: Universe Bool
duo_universe = Universe (False : False : False : True : repeat False) False (False : False : False : True : repeat False)

{--------------------------
 - Affichage d'un univers -
 --------------------------}

type Rule = Universe Bool -> Bool
toN :: Bool -> Int
toN True  = 1
toN False = 0
toB :: Int -> Bool
toB x = x /= 0

display :: Int -> Universe Bool -> [Bool]
display size (Universe xs v ys) = l ++ [v] ++ r
  where
    l = (reverse . take size $ xs)
    r = take size ys

color :: Bool -> Char
color True = '█'
color False = ' '

showUniverse :: Int -> Universe Bool -> String
showUniverse size = (fmap color) . (display size)


showLife :: Int -> Int -> Rule -> Universe Bool -> IO ()
showLife w h r u = mapM putStrLn view >> return ()
  where
    view = take h . fmap (showUniverse (w `div` 2)) $ list_states
    list_states = iterate (next r) u

{- Example : showLife 50 10 rule_lr duo_universe -}
{-           showLife 90 400 rule_30 single_universe -}

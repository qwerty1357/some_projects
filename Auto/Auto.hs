module Auto( Auto, accepts,
           emptyA, epsA, symA,
           leftA, thenA,
           fromLists, toLists, sumA
           ) where


import Data.List



data Auto a q = A {  states       :: [q]
                   , initStates   :: [q]
                   , isAccepting  :: q -> Bool
                   , transition   :: q -> a -> [q]
                  }


accepts :: Eq q => Auto a q -> [a] -> Bool
accepts (A states initStates isAccepting transition) word =
    any isAccepting (step word initStates)
        where
            step _ [] = []
            step [] ss = ss
            step (w:ws) ss = step ws (nub (concat (map (\s -> transition s w) ss)))


emptyA :: Auto a ()
emptyA = A [] [] (\_ -> False) (\_ _ -> [])


epsA :: Auto a ()
epsA = A [()] [()] (== ()) (\_ _ -> [])


symA :: Eq a => a -> Auto a Bool
symA c = A [False, True] [False] (\b -> b) trans
    where
        trans False c2 = if (c == c2) then [True] else []
        trans True _ = []


leftA :: Auto a q -> Auto a (Either q r)
leftA (A states initStates isAccepting transition) =
    A (map (Left) states)
      (map (Left) initStates)
      (either isAccepting (\_ -> False))
      transition2
          where
              transition2 (Left s) w = map (Left) (transition s w)
              transition2 (Right s) w = []


sumA :: Auto a q1 -> Auto a q2 -> Auto a (Either q1 q2)
sumA (A states initStates isAccepting transition) (A states2 initStates2 isAccepting2 transition2) =
    A ((map (Left) states) ++ (map (Right) states2))
      ((map (Left) initStates) ++ (map (Right) initStates2))
      (either isAccepting isAccepting2)
      transition3
          where
              transition3 (Left s) w = map (Left) (transition s w)
              transition3 (Right s) w = map (Right) (transition2 s w)


thenA :: Auto a q1 -> Auto a q2 -> Auto a (Either q1 q2)
thenA (A states initStates isAccepting transition) (A states2 initStates2 isAccepting2 transition2) =
                  A ((map (Left) states) ++ (map (Right) states2))
                    (map (Left) initStates)
                    (either (\q -> (isAccepting q) && (any isAccepting2 initStates2)) isAccepting2)
                    (either (\q c -> map (Left) (transition q c) ++ map (Right) (if isAccepting q then
                                                                                (concat [(transition2 q_ c) | q_ <- initStates2])
                                                                                else []))
                            (\q c -> map (Right) (transition2 q c)))


fromLists :: (Eq q, Eq a) => [q] -> [q] -> [q] -> [(q, a, [q])] -> Auto a q
fromLists states initStates accStates t = A
    states
    initStates
    (\e -> elem e accStates)
    (\state c -> trans state c t)
        where
            trans _ _ [] = []
            trans q1 a1 ((q2, a2, q3):qs) =
                if q1 == q2 && a1 == a2 then q3 ++ trans q1 a1 qs else trans q1 a1 qs


toLists :: (Enum a, Bounded a) => Auto a q -> ([q], [q], [q], [(q, a, [q])])
toLists (A states initStates isAccepting transition) =
    (states,
    initStates,
    (filter isAccepting states),
    ([(s, c, (transition s c)) | s <- states, c <- (enumFromTo minBound maxBound), not (null (transition s c))]))

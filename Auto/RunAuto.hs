import Auto
import Data.Char
import Data.Maybe
import System.Environment
import System.IO
import Text.Read



expandTransitions :: Int -> [Char] -> [Int] -> [(Int, Char, [Int])]
expandTransitions state (c:chars) states =
    [(state, c, states)] ++ (expandTransitions state chars states)
expandTransitions _ [] _ = []



parseTransitions :: [String] -> Maybe [(Int, Char, [Int])]
parseTransitions [] = Just []
parseTransitions (s:ss) = do
    case (words s) of
        (a:b:c) -> do
                let from = readMaybe a :: Maybe Int
                let to = map (\c2 -> readMaybe c2 :: Maybe Int) c
                if ((isNothing from) || not (all isUpper b) || (any isNothing to) || (fromJust from < 0) ) then
                        Nothing
                else
                        if (null ss) then
                        Just $ expandTransitions (fromJust from) b (map fromJust to)
                        else
                        case (parseTransitions ss) of
                                Nothing -> Nothing
                                Just transitions -> Just $ (transitions) ++ (expandTransitions (fromJust from) b (map fromJust to) )
        _ -> Nothing


readHead :: [String] -> Maybe [String]
readHead (a:b:c:d) = Just (a:b:c:d)
readHead _ = Nothing


checkNaturalList :: [Int] -> Int -> Bool
checkNaturalList [] _ = True
checkNaturalList l n = (all (> 0) l) && (all (<= n) l)


checkNaturalNumb :: Int -> Bool
checkNaturalNumb n = n >= 0


-- Zwracam BAD INPUT jeśli:
-- brak argumentu
-- deklarowana liczba stanów ujemna
-- stany nie są z dobrego zakresu (> 0, < deklarowana liczba stanów)
-- na końcu nie ma słowa z alfabetu (A-Z) (nie uwzględniam pustego słowa)
-- tranzycje nie pasują do wzorca
main :: IO()
main = do
    args <- getArgs
    if (null args) then
        putStrLn "BAD INPUT"
    else do
        content <- readFile (args !! 0)
        let list = filter (not . null) (lines content)
        case list of
            (numberOfStates:initStates:acceptStates:transitions) -> do
                if (null transitions) then
                    putStrLn "BAD INPUT"
                else do
                    let numberOfStates_ = readMaybe numberOfStates :: Maybe Int
                    let initStates_ = readMaybe initStates :: Maybe [Int]
                    let acceptStates_ = readMaybe acceptStates :: Maybe [Int]
                    let transitions_ = parseTransitions (init transitions)
                    let word = (last transitions)
                    if ((isNothing numberOfStates_) || (isNothing initStates_) || (isNothing acceptStates_) || (isNothing transitions_) ||
                        (not (all isUpper word)) || (fromJust numberOfStates_ < 0) || (not (checkNaturalNumb (fromJust numberOfStates_))) ||
                        (not (checkNaturalList (fromJust initStates_ ) (fromJust numberOfStates_))) ||
                        (not (checkNaturalList (fromJust acceptStates_ ) (fromJust numberOfStates_)))) then
                        putStrLn "BAD INPUT"
                    else
                        putStrLn $ show (accepts (fromLists (take (fromJust numberOfStates_) [1,2..]) (fromJust initStates_) (fromJust acceptStates_) (fromJust transitions_)) word)
            _ -> putStrLn "BAD INPUT"

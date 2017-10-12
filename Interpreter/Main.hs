module Main where


import System.IO
import System.Environment ( getArgs, getProgName )
import System.Exit ( exitFailure, exitSuccess )

import LexGrammar
import ParGrammar
import SkelGrammar
import PrintGrammar
import AbsGrammar
import Interpreter
import TypeChecker

import Control.Monad.Error
import Control.Exception
import Control.Monad.State


import ErrM

type ParseFun a = [Token] -> Err a

myLLexer = myLexer

type Verbosity = Int

putStrV :: Verbosity -> String -> IO ()
putStrV v s = if v > 1 then putStrLn s else return ()


main :: IO ()
main = do
  args <- getArgs
  handle <- openFile (head args) ReadMode
  input <- hGetContents handle
  case pProgram (myLexer input) of
    Bad s    -> hPutStrLn stderr $ "Parsing failed: " ++ show s
    Ok  tree -> do 
              --putStrLn "\nParse Successful!"
              --showTree v tree
              --liftIO $ print "teraz ttypeChecker"
              out <- runErrorT (execStateT (checkProgram tree) initTCEnv)
              case out of
                Left err -> hPutStrLn stderr $ "Error: " ++ err
                _ -> do
                    --liftIO $ print "teraz Interpreter"
                    out <- runErrorT (execStateT (processProgram tree) initEnv)
                    case out of
                      Left err -> hPutStrLn stderr $ "Error: " ++ err
                      Right state -> exitSuccess


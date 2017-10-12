module Interpreter where

import AbsGrammar
import Data.Map as M
import Data.List as L
import Data.Maybe
import Control.Monad.State
import Control.Monad.Error
import Control.Exception



type VEnv = M.Map Ident Loc

type FEnv = M.Map Ident Loc

type Store = M.Map Loc Val

type StoreF = M.Map Loc Func

type Loc = Int

type StateTEnv = StateT Env (ErrorT String IO)

type EnvME = M.Map Int VEnv

type EnvMF = M.Map Int FEnv



data Env = Env {
    envME :: EnvME,
    envMF :: EnvMF,
    store :: Store,
    storeF :: StoreF
}



data Func = Func (Maybe Type, [ArgsDecl], Instructions, Maybe Return, VEnv, FEnv) deriving (Show, Eq, Ord)


data Val = ValInt Integer | ValBool Bool deriving (Show, Eq, Ord)



instance Show Env where
    show env = "Vars: " ++ show (envME env) ++ "\nStore: " ++ show (store env) ++ "\nFuncs: " ++  show (envMF env) ++ "\n" ++ "StoreF:: " ++  show (storeF env) ++ "\n"



initEnv :: Env

initEnv = Env {
    envME = M.singleton 0 M.empty,
    envMF = M.singleton 0 M.empty,
    storeF = M.empty,
    store = M.empty
}


getVEnv :: EnvME -> VEnv

getVEnv e = fromJust $ M.lookup ((M.size e) - 1) e 


getFEnv :: EnvMF -> FEnv

getFEnv e = fromJust $ M.lookup ((M.size e) - 1) e 


initVal :: Type -> Val

initVal t = case t of
    TInt -> ValInt 0
    TBool -> ValBool False



processProgram :: Program -> StateTEnv Env

processProgram (Prog progName (Instr decls stmts)) = do
    processDecls decls;
    processStmts stmts;



processDecls :: [Decl] -> StateTEnv Env

processDecls (d:ds) = do
    env <- processDecl d
    put env
    processDecls ds
processDecls [] = do
  env <- get;
  return env



processStmts :: [Stmt] -> StateTEnv Env

processStmts (s:stmts) = do
    env <- processStmt s
    put $ env
    processStmts stmts
processStmts [] = do
  env <- get;
  return env



--------------------------------------
-------------DECLARATIONS-------------
--------------------------------------

processDecl :: Decl -> StateTEnv Env

processDecl (DVar t var) = do
    (Env envME envFE store storeF) <- get
    let venv = M.lookup ((M.size envME) - 1) envME
    case venv of
        Just v -> do
            let venv = M.insert var (M.size store) v
            let envme = M.insert ((M.size envME) - 1) venv envME
            return $ Env envme envFE (M.insert (M.size store) (initVal t) store) storeF



processDecl (DValFunc t var args instrs ret) = do
    (Env envME envMF store storeF) <- get
    let fenv = M.lookup ((M.size envMF) - 1) envMF
    case fenv of
        Just f -> do
            let fenv = M.insert var (M.size storeF) f
            let envmf = M.insert ((M.size envMF) - 1) fenv envMF
            let storef = M.insert (M.size storeF) (Func (Just t, args, instrs, Just ret, (getVEnv envME), fenv)) storeF
            return $ Env envME envmf store storef



processDecl (DVoidFunc var args instrs) = do
    (Env envME envMF store storeF) <- get
    let fenv = M.lookup ((M.size envMF) - 1) envMF
    case fenv of
        Just f -> do
            let fenv = M.insert var (M.size storeF) f
            let envmf = M.insert ((M.size envMF) - 1) fenv envMF
            let storef = M.insert (M.size storeF) (Func (Nothing, args, instrs, Nothing, (getVEnv envME), fenv)) storeF
            return $ Env envME envmf store storef



--------------------------------------
--------------STATEMENTS--------------
--------------------------------------

processStmt :: Stmt -> StateTEnv Env

processStmt (SExp exp) = do
    val <- processExp exp
    env <- get
    return $ env



processStmt (SAssign var exp) = do
    (Env envME envFE store storeF) <- get
    let venv = M.lookup ((M.size envME) - 1) envME
    case venv of
        Just venv -> do
            let check = M.lookup var venv
            case check of
                Just loc -> do
                    case exp of
                        ECpp1 _ _ -> do
                            val <- processExp exp
                            (Env envME envFE store storeF) <- get
                            return $ Env envME envFE (M.insert loc val store) storeF
                        ECpp2 _ _ -> do 
                            val <- processExp exp
                            (Env envME envFE store storeF) <- get
                            return $ Env envME envFE (M.insert loc val store) storeF
                        ECall _ _ -> do
                            val <- processExp exp
                            (Env envME envFE store storeF) <- get
                            return $ Env envME envFE (M.insert loc val store) storeF
                        _ -> do
                            val <- processExp exp
                            return $ Env envME envFE (M.insert loc val store) storeF



processStmt (SAdd var exp) = do
    (Env venv fenv store storeF) <- processStmt (SAssign var (EAdd (EVar var) exp))
    return $ Env venv fenv store storeF



processStmt (SSub var exp) = do
    (Env venv fenv store storeF) <- processStmt (SAssign var (ESub (EVar var) exp))
    return $ Env venv fenv store storeF



processStmt (SMul var exp) = do
    (Env venv fenv store storeF) <- processStmt (SAssign var (EMul (EVar var) exp))
    return $ Env venv fenv store storeF



processStmt (SDiv var exp) = do
    (Env venv fenv store storeF) <- processStmt (SAssign var (EDiv (EVar var) exp))
    return $ Env venv fenv store storeF



processStmt (SIf exp stmts) = do
    val <- processExp exp
    env <- get
    case val of
        (ValBool b) ->
            case b of 
                True -> processStmts stmts
                False -> return $ env



processStmt (SIfE exp stmts1 stmts2) = do
    val <- processExp exp
    env <- get
    case val of
        (ValBool b) ->
            case b of 
                True -> processStmts stmts1
                False -> processStmts stmts2



processStmt (SWhile exp stmts) = do
    val <- processExp exp
    env <- get
    case val of
        (ValBool b) ->
            case b of 
                True -> do
                    processStmts stmts
                    processStmt (SWhile exp stmts)
                False -> return $ env



processStmt (SFor var exp1 exp2 stmts) = do
    from <- processExp exp1
    to <- processExp exp2
    env <- processStmt (SAssign var $ exp1)
    put $ env
    processStmt $ SWhile (ELe (EVar var) (EInt (getInt to))) (stmts++[(SAdd var (EInt 1))])
    env <- get
    return $ env



processStmt (SRFor var exp1 exp2 stmts) = do
    from <- processExp exp1
    to <- processExp exp2
    env <- processStmt (SAssign var $ exp1)
    put $ env
    processStmt $ SWhile (EGe (EVar var) (EInt (getInt to))) (stmts++[(SSub var (EInt 1))])
    env <- get
    return $ env



processStmt (SPrint exp) = do
    val <- processExp exp
    env <- get
    case val of
        ValInt val -> liftIO $ print val
        ValBool val -> liftIO $ print val
    return env




--------------------------------------
-------------EXPRESSIONS--------------
--------------------------------------

processExp :: Exp -> StateTEnv Val

processExp (EInt n) = do
    return $ ValInt n



processExp (Emin exp) = do
    val <- processExp exp
    return $ ValInt (getInt val * (-1))



processExp (Eneg exp) = do
    val <- processExp exp
    case val of
        (ValBool b) ->
            case b of 
                True -> return $ ValBool False
                False -> return $ ValBool True



processExp (EBool b) = do
    case b of 
        BTrue -> return $ ValBool True
        BFalse -> return $ ValBool False



processExp (EAdd exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    return $ ValInt (getInt val1 + getInt val2)



processExp (ESub exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    return $ ValInt (getInt val1 - getInt val2)



processExp (EMul exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    return $ ValInt (getInt val1 * getInt val2)



processExp (EDiv exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case val2 of
        (ValInt 0) -> do
            case (exp1, val2) of
                (EVar (Ident var), ValInt v) -> do
                    throwError $ "Division by 0 (In: " ++ show var ++ "/" ++ show v ++ ")" 
                (EInt v, ValInt v2) -> do
                    throwError $ "Division by 0 (In: " ++ show v ++ "/" ++ show v2 ++ ")" 
            return $ ValInt (div (getInt val1) (getInt val2))
        _ -> do
            return $ ValInt (div (getInt val1) (getInt val2))



processExp (EAnd exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValBool b1, ValBool b2) ->
            case (b1, b2) of 
                (True, True) -> return $ ValBool True
                _ -> return $ ValBool False



processExp (EOr exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValBool b1, ValBool b2) ->
            case (b1, b2) of 
                (False, False) -> return $ ValBool False
                _ -> return $ ValBool True



processExp (EEq exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValInt val1, ValInt val2) -> 
            if (val1 == val2) then return $ ValBool True
            else return $ ValBool False
        (ValBool val1, ValBool val2) -> 
            if (val1 == val2) then return $ ValBool True
            else return $ ValBool False


processExp (ENeq exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValInt val1, ValInt val2) -> 
            if (val1 /= val2) then return $ ValBool True
            else return $ ValBool False
        (ValBool val1, ValBool val2) -> 
            if (val1 /= val2) then return $ ValBool True
            else return $ ValBool False



processExp (ELt exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValInt val1, ValInt val2) -> 
            if (val1 < val2) then return $ ValBool True
            else return $ ValBool False



processExp (ELe exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValInt val1, ValInt val2) -> 
            if (val1 <= val2) then return $ ValBool True
            else return $ ValBool False



processExp (EGt exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValInt val1, ValInt val2) -> 
            if (val1 > val2) then return $ ValBool True
            else return $ ValBool False



processExp (EGe exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    case (val1, val2) of
        (ValInt val1, ValInt val2) -> 
            if (val1 >= val2) then return $ ValBool True
            else return $ ValBool False



processExp (EVar var) = do
    (Env envME envMF store storeF) <- get
    let check = M.lookup var (getVEnv envME)
    case check of
        Just loc -> do
            let val = M.lookup loc store
            case val of
                Just (ValInt v) -> return $ ValInt v
                Just (ValBool v) -> return $ ValBool v



processExp (ETer exp1 exp2 exp3) = do
    val1 <- processExp exp1
    case val1 of
        (ValBool val1) -> do
            case val1 of
                True -> do
                    val2 <- processExp exp2
                    return val2
                _ -> do
                    val3 <- processExp exp3
                    return val3



processExp (ECpp1 var cpp) = do
    val <- processExp (EVar var)
    env <- processCpp var cpp
    put $ env
    return val



processExp (ECpp2 cpp var) = do
    env <- processCpp var cpp
    put $ env
    val <- processExp (EVar var)
    return val



processExp (ECall var args) = do
    (Env envME envMF store storeF) <- get
    let check = M.lookup var (getFEnv envMF)
    case check of
        Just loc -> do
            let f = M.lookup loc storeF
            case f of
                Just f -> do
                    let storedVEnv = getFuncVEnv f
                    let storedFEnv = getFuncFEnv f
                    let declArgs = getFuncArgs f
                    let (Instr decls stmts) = getFuncInstrs f
                    put $ Env (M.insert (M.size envME) M.empty envME) (M.insert (M.size envMF) M.empty envMF) store storeF
                    processArgs declArgs args
                    processDecls decls
                    (Env envME envMF store storeF) <- get
                    let venv = M.lookup ((M.size envME) - 1) envME
                    let fenv = M.lookup ((M.size envMF) - 1) envMF
                    put $ Env (M.insert ((M.size envME) - 1) (M.union (fromJust venv) storedVEnv) envME) (M.insert ((M.size envMF) - 1) (M.union (fromJust fenv) storedFEnv) envMF) store storeF
                    (Env envME envMF store storeF) <- get
                    funcUpdate (M.keys (fromJust (M.lookup ((M.size envMF) - 1) envMF))) storedVEnv storedFEnv
                    processStmts stmts
                    let funcRet = getFuncRet f
                    case funcRet of
                        Just (Ret exp) -> do
                            val <- processExp exp
                            Env envME envMF store storeF <- get
                            put $ Env (M.delete ((M.size envME) - 1) envME) (M.delete ((M.size envMF) - 1) envMF) store storeF
                            return val
                        Nothing -> do
                            Env envME envMF store storeF <- get
                            put $ Env (M.delete ((M.size envME) - 1) envME) (M.delete ((M.size envMF) - 1) envMF) store storeF
                            return (ValInt 1)
        Nothing -> do
            throwError $ "No function " ++ show var




funcUpdate :: [Ident] -> VEnv -> FEnv -> StateTEnv ()

funcUpdate (v:vars) venv fenv = do
    (Env envME envMF store storeF) <- get
    let envf = M.lookup ((M.size envMF) - 1) envMF
    let getLoc = M.lookup v (fromJust envf)
    let (Func (t, args, instrs, ret, venvf, fenvf)) = fromJust (M.lookup (fromJust getLoc) storeF)
    let f = fromJust (M.lookup (fromJust getLoc) storeF)
    let storedVEnv = getFuncVEnv f
    let storedFEnv = getFuncFEnv f
    let currVEnv = M.union venv (getFuncVEnv f)
    let currFEnv = M.union fenv (getFuncFEnv f)
    put $ Env envME envMF store (M.insert (fromJust getLoc) (Func (t, args, instrs, ret, currVEnv, currFEnv)) storeF)
    funcUpdate vars venv fenv


funcUpdate [] _ _ = do
    (Env envME envMF store storeF) <- get
    put $ Env envME envMF store storeF



processArgs :: [ArgsDecl] -> [Arguments] -> StateTEnv ()

processArgs (a:args) ((Args e):exps) = do
    (Env envME envMF store storeF) <- get
    let venv = M.lookup ((M.size envME) - 1) envME
    let fenv = M.lookup ((M.size envMF) - 1) envMF
    let venvOld = M.lookup ((M.size envME) - 2) envME
    let fenvOld = M.lookup ((M.size envMF) - 2) envMF
    put $ Env (M.insert ((M.size envME) - 1) (fromJust venvOld) envME) (M.insert ((M.size envMF) - 1) (fromJust fenvOld) envMF) store storeF
    val <- processExp e
    (Env envME envMF store storeF) <- get
    case a of
        ADecl t var -> do
            let venv' = (M.insert var (M.size (store)) (fromJust venv))
            let store' = (M.insert (M.size (store)) val store)
            put $ Env (M.insert ((M.size envME) - 1) venv' envME) (M.insert ((M.size envMF) - 1) (fromJust fenv) envMF) store' storeF
        ARef t var -> do
            case e of
                (EVar evar) -> do
                    let loc = fromJust (M.lookup evar (fromJust venvOld))
                    let venv' = (M.insert var loc (fromJust venv))
                    put $ Env (M.insert ((M.size envME) - 1) venv' envME) (M.insert ((M.size envMF) - 1) (fromJust fenv) envMF) store storeF
    processArgs args exps

processArgs [] [] = do
    env <- get;
    put $ env



processCpp :: Ident -> CppExp -> StateTEnv Env

processCpp var cpp = do
    (Env envME envMF store storeF) <- get
    let check = M.lookup var (getVEnv envME)
    case check of
        Just loc -> do
            let val = M.lookup loc store
            case val of
                Just (ValInt v) -> do
                    case cpp of
                        CInc -> do
                            return $ Env envME envMF (M.insert loc (ValInt (v + 1)) store) storeF
                        CDec -> do
                            return $ Env envME envMF (M.insert loc (ValInt (v - 1)) store) storeF



getInt (ValInt n) = n


initNewVEnv :: VEnv
initNewVEnv = M.empty


initNewFEnv :: FEnv
initNewFEnv = M.empty


getFuncType :: Func -> Maybe Type
getFuncType (Func (a, _, _, _, _, _)) = a


getFuncArgs :: Func -> [ArgsDecl]
getFuncArgs (Func (_, a, _, _, _, _)) = a


getFuncInstrs :: Func -> Instructions
getFuncInstrs (Func (_, _, a, _, _, _)) = a


getFuncRet :: Func -> Maybe Return
getFuncRet (Func (_, _, _, a, _, _)) = a


getFuncVEnv :: Func -> VEnv
getFuncVEnv (Func (_, _, _, _, a, _)) = a


getFuncFEnv :: Func -> FEnv
getFuncFEnv (Func (_, _, _, _, _, a)) = a



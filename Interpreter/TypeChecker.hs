module TypeChecker where



import AbsGrammar
import Data.Map as M
import Data.List as L
import Data.Maybe
import Control.Monad.State
import Control.Monad.Error
import Control.Exception



type VEnv = M.Map Ident Loc

type FEnv = M.Map Ident Loc

type Store = M.Map Loc Type

type StoreF = M.Map Loc Func

type Loc = Int

type StateTEnv = StateT Env (ErrorT String IO)

type EnvME = M.Map Int VEnv

type EnvMF = M.Map Int FEnv

type Stack = [String]



data Env = Env {
    stack :: Stack,
    envME :: EnvME,
    envMF :: EnvMF,
    store :: Store,
    storeF :: StoreF
}



data Func = Func (Maybe Type, [ArgsDecl], Maybe Return, VEnv, FEnv) deriving (Show, Eq, Ord)


initTCEnv :: Env

initTCEnv = Env {
    stack = ["MAIN"],
    envME = M.singleton 0 M.empty,
    envMF = M.singleton 0 M.empty,
    storeF = M.empty,
    store = M.empty
}


getVEnv :: EnvME -> VEnv

getVEnv e = fromJust $ M.lookup ((M.size e) - 1) e 



getFEnv :: EnvMF -> FEnv

getFEnv e = fromJust $ M.lookup ((M.size e) - 1) e 



checkProgram :: Program -> StateTEnv Env

checkProgram (Prog progName (Instr decls stmts)) = do
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



processDecl :: Decl -> StateTEnv Env

processDecl (DVar t var) = do
    (Env stack envME envFE store storeF) <- get
    let venv = M.lookup ((M.size envME) - 1) envME
    let check = M.lookup var (fromJust venv)
    case check of
        Just v -> do
            throwError $ "Ambiguous declaration of variable (" ++ show (getName var) ++ "). In " ++ show stack 
        Nothing -> do
            case venv of
                Just v -> do
                    let venv = M.insert var (M.size store) v
                    let envme = M.insert ((M.size envME) - 1) venv envME
                    case t of 
                        TInt -> do
                            return $ Env stack  envme envFE (M.insert (M.size store) TInt store) storeF
                        TBool -> do
                            return $ Env stack envme envFE (M.insert (M.size store) TBool store) storeF



processDecl (DValFunc t var args instrs ret) = do
    (Env stack envME envMF store storeF) <- get
    let fenv = M.lookup ((M.size envMF) - 1) envMF
    let fun = M.lookup var (fromJust fenv)
    case fun of
        Just f -> do 
            throwError $ "Ambiguous declaration of function (" ++ show (getName var) ++ "). In " ++ show stack 
        Nothing -> do
            case fenv of
                Just f -> do
                    let s = stack ++ ([getName var])
                    put $ (Env s envME envMF store storeF)
                    (Env stack envME envMF store storeF) <- get
                    let fenv = M.insert var (M.size storeF) f
                    let envmf = M.insert ((M.size envMF) - 1) fenv envMF
                    let storef = M.insert (M.size storeF) (Func (Just t, args, Just ret, (getVEnv envME), fenv)) storeF
                    put $ (Env stack envME envmf store storef)
                    (Env stack envME envMF store storeF) <- get
                    let check = M.lookup var (getFEnv envMF)
                    case check of
                        Just loc -> do
                            let f = M.lookup loc storeF
                            case f of
                                Just f -> do
                                    let storedVEnv = getFuncVEnv f
                                    let storedFEnv = getFuncFEnv f
                                    let declArgs = getFuncArgs f
                                    let (Instr decls stmts) = instrs
                                    put $ Env stack (M.insert (M.size envME) M.empty envME) (M.insert (M.size envMF) M.empty envMF) store storeF
                                    (Env stack envME envMF store storeF) <- get
                                    processArgs declArgs
                                    processDecls decls
                                    (Env stack  envME envMF store storeF) <- get
                                    let venv = M.lookup ((M.size envME) - 1) envME
                                    let fenv = M.lookup ((M.size envMF) - 1) envMF
                                    put $ Env stack (M.insert ((M.size envME) - 1) (M.union (fromJust venv) storedVEnv) envME) (M.insert ((M.size envMF) - 1) (M.union (fromJust fenv) storedFEnv) envMF) store storeF
                                    (Env stack  envME envMF store storeF) <- get
                                    funcUpdate (M.keys (fromJust (M.lookup ((M.size envMF) - 1) envMF))) storedVEnv storedFEnv
                                    processStmts stmts
                                    let funcRet = getFuncRet f
                                    case funcRet of
                                        Just (Ret exp) -> do
                                            val <- processExp exp
                                            Env stack envME envMF store storeF <- get
                                            put $ Env stack (M.delete ((M.size envME) - 1) envME) (M.delete ((M.size envMF) - 1) envMF) store storeF
                                            (Env stack envME envMF store storeF) <- get
                                            (Env stack envME envMF store storeF) <- get
                                            let s2 = init stack
                                            return (Env s2 envME envMF store storeF)



processDecl (DVoidFunc var args instrs) = do
    (Env stack envME envMF store storeF) <- get
    let fenv = M.lookup ((M.size envMF) - 1) envMF
    let fun = M.lookup var (fromJust fenv)
    case fun of
        Just f -> do 
            throwError $ "Ambiguous declaration of function (" ++ show (getName var) ++ "). In " ++ show stack 
        Nothing -> do
            case fenv of
                Just f -> do
                    let s = stack ++ ([getName var])
                    put $ (Env s envME envMF store storeF)
                    (Env stack envME envMF store storeF) <- get
                    let fenv = M.insert var (M.size storeF) f
                    let envmf = M.insert ((M.size envMF) - 1) fenv envMF
                    let storef = M.insert (M.size storeF) (Func (Nothing, args, Nothing, (getVEnv envME), fenv)) storeF
                    put $ (Env stack envME envmf store storef)
                    (Env stack envME envMF store storeF) <- get
                    let check = M.lookup var (getFEnv envMF)
                    case check of
                        Just loc -> do
                            let f = M.lookup loc storeF
                            case f of
                                Just f -> do
                                    let storedVEnv = getFuncVEnv f
                                    let storedFEnv = getFuncFEnv f
                                    let declArgs = getFuncArgs f
                                    let (Instr decls stmts) = instrs
                                    put $ Env stack (M.insert (M.size envME) M.empty envME) (M.insert (M.size envMF) M.empty envMF) store storeF
                                    processArgs declArgs
                                    processDecls decls
                                    (Env stack envME envMF store storeF) <- get
                                    let venv = M.lookup ((M.size envME) - 1) envME
                                    let fenv = M.lookup ((M.size envMF) - 1) envMF
                                    put $ Env stack (M.insert ((M.size envME) - 1) (M.union (fromJust venv) storedVEnv) envME) (M.insert ((M.size envMF) - 1) (M.union (fromJust fenv) storedFEnv) envMF) store storeF
                                    (Env stack envME envMF store storeF) <- get
                                    funcUpdate (M.keys (fromJust (M.lookup ((M.size envMF) - 1) envMF))) storedVEnv storedFEnv
                                    processStmts stmts
                                    let funcRet = getFuncRet f
                                    case funcRet of
                                        Nothing -> do
                                            Env stack envME envMF store storeF <- get
                                            put $ Env stack (M.delete ((M.size envME) - 1) envME) (M.delete ((M.size envMF) - 1) envMF) store storeF
                                            (Env stack envME envMF store storeF) <- get
                                            (Env stack envME envMF store storeF) <- get
                                            let s2 = init stack
                                            return (Env s2 envME envMF store storeF)



processStmts :: [Stmt] -> StateTEnv Env

processStmts (s:stmts) = do
    env <- processStmt s
    put $ env
    processStmts stmts
processStmts [] = do
  env <- get;
  return env




processStmt :: Stmt -> StateTEnv Env

processStmt (SExp exp) = do
    val <- processExp exp
    env <- get
    return $ env



processStmt (SAssign var exp) = do
    (Env stack envME envFE store storeF) <- get
    let venv = M.lookup ((M.size envME) - 1) envME
    case venv of
        Just venv -> do
            let check = M.lookup var venv
            case check of
                Just loc -> do
                    let locS = M.lookup loc store
                    val <- processExp exp
                    case (locS, val) of
                        (Just TInt, TInt) -> do
                            case exp of
                                ECpp1 _ _ -> do
                                    val <- processExp exp
                                    (Env stack envME envFE store storeF) <- get
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                                ECpp2 _ _ -> do 
                                    val <- processExp exp
                                    (Env stack envME envFE store storeF) <- get
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                                ECall _ _ -> do
                                    val <- processExp exp
                                    (Env stack envME envFE store storeF) <- get
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                                _ -> do
                                    val <- processExp exp
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                        (Just TBool, TBool) -> do
                            case exp of
                                ECpp1 _ _ -> do
                                    val <- processExp exp
                                    (Env stack envME envFE store storeF) <- get
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                                ECpp2 _ _ -> do 
                                    val <- processExp exp
                                    (Env stack envME envFE store storeF) <- get
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                                ECall _ _ -> do
                                    val <- processExp exp
                                    (Env stack envME envFE store storeF) <- get
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                                _ -> do
                                    val <- processExp exp
                                    return $ Env stack envME envFE (M.insert loc val store) storeF
                        (_, _) -> do
                            throwError $ "Cannot assign expression to variable of different type (" ++ show (fromJust locS) ++ " " ++ show (getName var)++ " := " ++ show val ++ "). In " ++ show stack

                _ -> do
                    val <- processExp exp
                    val2 <- checkHigher (EVar var) ((M.size envME) - 1)
                    case (val, val2) of
                        (TInt, TInt) -> do
                            return $ Env stack envME envFE store storeF
                        (TBool, TBool) -> do
                            return $ Env stack envME envFE store storeF
                        _ -> do
                            throwError $ "Cannot assign expression to variable of different type (" ++ show (getName var) ++ "). In " ++ show stack 



processStmt (SAdd var exp) = do
    (Env stack venv fenv store storeF) <- processStmt (SAssign var (EAdd (EVar var) exp))
    return $ Env stack venv fenv store storeF



processStmt (SSub var exp) = do
    (Env stack venv fenv store storeF) <- processStmt (SAssign var (ESub (EVar var) exp))
    return $ Env stack venv fenv store storeF



processStmt (SMul var exp) = do
    (Env stack venv fenv store storeF) <- processStmt (SAssign var (EMul (EVar var) exp))
    return $ Env stack venv fenv store storeF



processStmt (SDiv var exp) = do
    (Env stack venv fenv store storeF) <- processStmt (SAssign var (EDiv (EVar var) exp))
    return $ Env stack venv fenv store storeF



processStmt (SIf exp stmts) = do
    val <- processExp exp
    (Env stack envME envFE store storeF) <- get
    case val of
        TBool -> processStmts stmts
        _ -> throwError $ "Not a bool expression in 'if' statement. Got: " ++ show val ++ ". In " ++ show stack



processStmt (SIfE exp stmts1 stmts2) = do
    val <- processExp exp
    (Env stack envME envFE store storeF) <- get
    case val of
        TBool -> do
            processStmts stmts1
            processStmts stmts2
        _ -> throwError $ "Not a bool expression in 'if-else' statement. Got: " ++ show val ++ ". In " ++ show stack



processStmt (SWhile exp stmts) = do
    val <- processExp exp
    (Env stack envME envFE store storeF) <- get
    case val of
        TBool -> do
            processStmts stmts
            return $ Env stack envME envFE store storeF
        _ -> throwError $ "Not a bool expression in loop. Got: " ++ show val ++ ". In " ++ show stack



processStmt (SFor var exp1 exp2 stmts) = do
    from <- processExp exp1
    to <- processExp exp2
    env <- processStmt (SAssign var $ exp1)
    put $ env
    processStmt $ SWhile (ELe (EVar var) (EInt 1)) (stmts)
    env <- get
    return $ env



processStmt (SRFor var exp1 exp2 stmts) = do
    from <- processExp exp1
    to <- processExp exp2
    env <- processStmt (SAssign var $ exp1)
    put $ env
    processStmt $ SWhile (EGe (EVar var) (EInt 1)) (stmts)
    env <- get
    return $ env



processStmt (SPrint exp) = do
    val <- processExp exp
    env <- get
    case val of
        TInt -> return env
        TBool -> return env


processExp :: Exp -> StateTEnv Type

processExp (EInt n) = do
    return $ TInt



processExp (Emin exp) = do
    val <- processExp exp
    (Env stack envME envFE store storeF) <- get
    case val of
        TBool -> do
            throwError $ "Expected int in expression: '-" ++ show val ++ "'. In " ++ show stack
        _ -> do
            return $ TInt



processExp (Eneg exp) = do
    val <- processExp exp
    (Env stack envME envFE store storeF) <- get
    case val of
        TBool -> do
            return $ TBool
        TInt -> do
            throwError $ "Expected bool in expression: '!" ++ show val ++ "'. In " ++ show stack



processExp (EBool b) = do
    case b of 
        BTrue -> do
            return $ TBool
        BFalse -> do
            return $ TBool



processExp (EAdd exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> do
            return $ TInt
        (_, _) -> do
            throwError $ "In addition expected int. Got: " ++ show val1 ++ " + " ++ show val2 ++ ". In " ++ show stack



processExp (ESub exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> do
            return $ TInt
        (_, _) -> do
            throwError $ "In subtraction expected int. Got: " ++ show val1 ++ " - " ++ show val2 ++ ". In " ++ show stack



processExp (EMul exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> do
            return $ TInt
        (_, _) -> do
            throwError $ "In multiplication expected int. Got: " ++ show val1 ++ " * " ++ show val2 ++ ". In " ++ show stack



processExp (EDiv exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> do
            return $ TInt
        (_, _) -> do
            throwError $ "In division expected int. Got: " ++ show val1 ++ " / " ++ show val2 ++ ". In " ++ show stack



processExp (EAnd exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TBool, TBool) -> do
            return $ TBool
        (_, _) -> do
            throwError $ "Not a bool in logical expression (and). Got: " ++ show val1 ++ " && " ++ show val2 ++ ". In " ++ show stack



processExp (EOr exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TBool, TBool) -> do
            return $ TBool
        (_, _) -> do
            throwError $ "Not a bool in logical expression (or). Got: " ++ show val1 ++ " || " ++ show val2 ++ ". In " ++ show stack



processExp (EEq exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> 
            return $ TBool
        (TBool, TBool) -> 
            return $ TBool
        (_, _) -> do
            throwError $ "Cannot compare variables of different types (" ++ show val1 ++ ", " ++ show val2 ++ ")" ++ ". In " ++ show stack



processExp (ENeq exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> 
            return $ TBool
        (TBool, TBool) -> 
            return $ TBool
        (_, _) -> do
            throwError $ "Cannot compare variables of different types (" ++ show val1 ++ ", " ++ show val2 ++ ")" ++ ". In " ++ show stack



processExp (ELt exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> 
            return $ TBool
        (_, _) -> throwError $ "Expected int in comparison: " ++ show val1 ++ " < " ++ show val2 ++ ". In " ++ show stack



processExp (ELe exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> 
            return $ TBool
        (_, _) -> throwError $ "Expected int in comparison: " ++ show val1 ++ " <= " ++ show val2 ++ ". In " ++ show stack



processExp (EGt exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> 
            return $ TBool
        (_, _) -> throwError $ "Expected int in comparison: " ++ show val1 ++ " > " ++ show val2 ++ ". In " ++ show stack



processExp (EGe exp1 exp2) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    (Env stack envME envFE store storeF) <- get
    case (val1, val2) of
        (TInt, TInt) -> 
            return $ TBool
        (_, _) -> throwError $ "Expected int in comparison: " ++ show val1 ++ " >= " ++ show val2 ++ ". In " ++ show stack



processExp (EVar var) = do
    (Env stack envME envMF store storeF) <- get
    let check = M.lookup var (getVEnv envME)
    case check of
        Just loc -> do
            let val = M.lookup loc store
            case val of
                Just TInt -> return $ TInt
                Just TBool -> return $ TBool
        _ -> do
            val <- checkHigher (EVar var) ((M.size envME) - 1)
            return val



processExp (ETer exp1 exp2 exp3) = do
    val1 <- processExp exp1
    val2 <- processExp exp2
    val3 <- processExp exp3
    (Env stack envME envFE store storeF) <- get
    case (val1, val2, val3) of
        (TBool, TBool, TBool) -> do
            return $ TBool
        (TBool, TInt, TInt) -> do
            return $ TInt
        _ -> do
            throwError $ "Wrong paramteters types in expression. (" ++ show val1 ++ " ? " ++ show val2 ++ " : " ++ show val3 ++ ")" ++ ". In " ++ show stack



processExp (ECpp1 var cpp) = do
    val <- processExp (EVar var)
    (Env stack envME envFE store storeF) <- processCpp var cpp
    put $ (Env stack envME envFE store storeF)
    return $ TInt



processExp (ECpp2 cpp var) = do
    env <- processCpp var cpp
    put $ env
    val <- processExp (EVar var)
    return TInt



processExp (ECall var args) = do
    (Env stack envME envMF store storeF) <- get
    func <- checkHigherF (ECall var args) ((M.size envMF) - 1) 
    let declArgs = getFuncArgs func
    if (length declArgs == length args) then
        checkArgs declArgs args var
    else do
        (Env stack envME envMF store storeF) <- get
        throwError $ "In function " ++ show (getName var) ++ " wrong number of paramteters in " ++ show stack
    return TInt


getName (Ident var) = var


checkHigherF :: Exp -> Int -> StateTEnv Func

checkHigherF (ECall var args) level = do
    (Env stack envME envMF store storeF) <- get
    let envF = M.lookup level envMF
    let check = M.lookup var (fromJust envF)
    case check of
        Just v -> do
            let t = M.lookup v storeF
            return $ (fromJust t)
        Nothing -> do
            if level > 0 then 
                checkHigherF (ECall var args) (level - 1)
            else
                throwError $ "Unknown function: " ++ show (getName var) ++ ". In " ++ show stack



checkHigher :: Exp -> Int -> StateTEnv Type

checkHigher (EVar var) level = do
    (Env stack envME envMF store storeF) <- get
    let envV = M.lookup level envME
    let check = M.lookup var (fromJust envV)
    case check of
        Just v -> do
            let t = M.lookup v store
            return $ (fromJust t)
        Nothing -> do
            if level > 0 then 
                checkHigher (EVar var) (level - 1)
            else
                throwError $ "Unknown variable: " ++ show (getName var) ++ ". In " ++ show stack




checkArgs :: [ArgsDecl] -> [Arguments] -> Ident ->  StateTEnv ()

checkArgs (d:declArgs) ((Args a):args) var = do
    (Env stack envME envMF store storeF) <- get
    aType <- processExp a
    case (d, aType, a) of
        (ADecl TInt dv, TInt, _) -> do
            put $ Env stack envME envMF store storeF
        (ADecl TBool dv, TBool, _) -> do
            put $ Env stack envME envMF store storeF
        (ARef TInt dv, TInt, EVar evar) -> do
            put $ Env stack envME envMF store storeF
        (ARef TBool dv, TBool, EVar evar) -> do
            put $ Env stack envME envMF store storeF
        (_, _, _) -> do
            throwError $ "In function " ++ show (getName var) ++ " parameters' types mismatched" ++ ". In " ++ show stack



checkArgs [] [] _ = do
    (Env stack envME envMF store storeF) <- get
    put $ Env stack envME envMF store storeF



funcUpdate :: [Ident] -> VEnv -> FEnv -> StateTEnv ()

funcUpdate [] _ _ = do
    (Env stack envME envMF store storeF) <- get
    put $ Env stack envME envMF store storeF



funcUpdate (v:vars) venv fenv = do
    (Env stack envME envMF store storeF) <- get
    let envf = M.lookup ((M.size envMF) - 1) envMF
    let getLoc = M.lookup v (fromJust envf)
    let (Func (t, args, ret, venvf, fenvf)) = fromJust (M.lookup (fromJust getLoc) storeF)
    let f = fromJust (M.lookup (fromJust getLoc) storeF)
    let currVEnv = M.union venv (getFuncVEnv f)
    let currFEnv = M.union fenv (getFuncFEnv f)
    put $ Env stack envME envMF store (M.insert (fromJust getLoc) (Func (t, args, ret, currVEnv, currFEnv)) storeF)
    funcUpdate vars venv fenv



processArgs :: [ArgsDecl] -> StateTEnv ()

processArgs (a:args)  = do
    (Env stack envME envMF store storeF) <- get
    let venv = M.lookup ((M.size envME) - 1) envME
    let fenv = M.lookup ((M.size envMF) - 1) envMF
    case a of
        ADecl t var -> do
            let venv' = (M.insert var (M.size (store)) (fromJust venv))
            let store' = (M.insert (M.size (store)) t store)
            put $ Env stack (M.insert ((M.size envME) - 1) venv' envME) (M.insert ((M.size envMF) - 1) (fromJust fenv) envMF) store' storeF
        ARef t var -> do
            let venv' = (M.insert var (M.size (store)) (fromJust venv))
            let store' = (M.insert (M.size (store)) t store)
            put $ Env stack (M.insert ((M.size envME) - 1) venv' envME) (M.insert ((M.size envMF) - 1) (fromJust fenv) envMF) store' storeF
    processArgs args

processArgs [] = do
    env <- get
    put $ env



processCpp :: Ident -> CppExp -> StateTEnv Env

processCpp var cpp = do
    (Env stack envME envMF store storeF) <- get
    let check = M.lookup var (getVEnv envME)
    case check of
        Just loc -> do
            let val = M.lookup loc store
            case val of
                Just TInt -> do
                    case cpp of
                        CInc -> do
                            return $ Env stack envME envMF (M.insert loc TInt store) storeF
                        CDec -> do
                            return $ Env stack envME envMF (M.insert loc TInt store) storeF
                _ -> do
                    case cpp of
                        CDec -> do
                            throwError $ "Cannot decrement bool variable (" ++ show (getName var) ++ ")" ++ ". In " ++ show stack
                        CInc -> do
                            throwError $ "Cannot increment bool variable (" ++ show (getName var) ++ ")" ++ ". In " ++ show stack
        Nothing -> do
            val <- checkHigher (EVar var) ((M.size envME) - 1)
            case val of
                TInt -> do
                    return $ (Env stack envME envMF store storeF) 
                TBool -> do
                    case cpp of
                        CDec -> do
                            throwError $ "Cannot decrement bool variable (" ++ show (getName var) ++ ")" ++ ". In " ++ show stack
                        CInc -> do
                            throwError $ "Cannot increment bool variable (" ++ show (getName var) ++ ")" ++ ". In " ++ show stack



initNewVEnv :: VEnv
initNewVEnv = M.empty


initNewFEnv :: FEnv
initNewFEnv = M.empty


getFuncType :: Func -> Maybe Type
getFuncType (Func (a, _, _, _, _)) = a


getFuncArgs :: Func -> [ArgsDecl]
getFuncArgs (Func (_, a, _, _, _)) = a


getFuncRet :: Func -> Maybe Return
getFuncRet (Func (_, _, a, _, _)) = a


getFuncVEnv :: Func -> VEnv
getFuncVEnv (Func (_, _, _, a, _)) = a


getFuncFEnv :: Func -> FEnv
getFuncFEnv (Func (_, _, _, _, a)) = a




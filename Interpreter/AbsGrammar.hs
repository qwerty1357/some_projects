

module AbsGrammar where

-- Haskell module generated by the BNF converter




newtype Ident = Ident String deriving (Eq, Ord, Show, Read)
data Program = Prog Ident Instructions
  deriving (Eq, Ord, Show, Read)

data Instructions = Instr [Decl] [Stmt]
  deriving (Eq, Ord, Show, Read)

data Decl
    = DVar Type Ident
    | DValFunc Type Ident [ArgsDecl] Instructions Return
    | DVoidFunc Ident [ArgsDecl] Instructions
  deriving (Eq, Ord, Show, Read)

data ArgsDecl = ADecl Type Ident | ARef Type Ident
  deriving (Eq, Ord, Show, Read)

data Arguments = Args Exp
  deriving (Eq, Ord, Show, Read)

data Return = Ret Exp
  deriving (Eq, Ord, Show, Read)

data Stmt
    = SExp Exp
    | SAssign Ident Exp
    | SAdd Ident Exp
    | SSub Ident Exp
    | SMul Ident Exp
    | SDiv Ident Exp
    | SIf Exp [Stmt]
    | SIfE Exp [Stmt] [Stmt]
    | SWhile Exp [Stmt]
    | SFor Ident Exp Exp [Stmt]
    | SRFor Ident Exp Exp [Stmt]
    | SPrint Exp
  deriving (Eq, Ord, Show, Read)

data Exp
    = ETer Exp Exp Exp
    | EOr Exp Exp
    | EAnd Exp Exp
    | EEq Exp Exp
    | ENeq Exp Exp
    | ELt Exp Exp
    | EGt Exp Exp
    | ELe Exp Exp
    | EGe Exp Exp
    | EAdd Exp Exp
    | ESub Exp Exp
    | EMul Exp Exp
    | EDiv Exp Exp
    | Eneg Exp
    | Emin Exp
    | ECpp1 Ident CppExp
    | ECpp2 CppExp Ident
    | EVar Ident
    | EInt Integer
    | EBool Boolean
    | ECall Ident [Arguments]
  deriving (Eq, Ord, Show, Read)

data CppExp = CInc | CDec
  deriving (Eq, Ord, Show, Read)

data Boolean = BTrue | BFalse
  deriving (Eq, Ord, Show, Read)

data Type = TInt | TBool
  deriving (Eq, Ord, Show, Read)

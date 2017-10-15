package gramatyka;

import java.util.ArrayList;

public class ContextFreeGrammar implements Cloneable {
    protected ArrayList<Terminal> alphabet;
    protected ArrayList<Nonterminal> nonterminals;
    protected ArrayList<Production> productions;
    protected Nonterminal startSymbol;

    protected ContextFreeGrammar () {
        //do not call it from here
    }

    public ContextFreeGrammar(String terminal, String nonterminal, String[][] rightSidesOfProductions) throws GrammarException {
        alphabet = new ArrayList<Terminal>();
        nonterminals = new ArrayList<Nonterminal>();
        productions = new ArrayList<Production>();
        Terminal t;
        Nonterminal nt;
        if ((terminal.length() == 0) || (nonterminal.length() == 0)) {
            throw new GrammarException("Alphabet or nonterminals is empty");
        }

        for (int i = 0; i < terminal.length(); i++) {
            t = new Terminal(terminal.charAt(i));
           
            for (Terminal term : alphabet) {
                if (term.getChar() == t.getChar())
                    throw new GrammarException("Duplicate in alphabet");
            }
            alphabet.add(t);
        }

        for (int i = 0; i < nonterminal.length(); i++) {
            nt = new Nonterminal(nonterminal.charAt(i));
            for (Nonterminal nonterm : nonterminals) {
                if (nonterm.getChar() == nt.getChar())
                    throw new GrammarException("Duplicate in nonterminals");
            }
            nonterminals.add(nt);
        }
        //correctness of number of productions
        if (!(rightSidesOfProductions.length == nonterminal.length())) {
            throw new GrammarException("Number of productions is incorrect");
        }
        startSymbol = nonterminals.get(0);
        //ArrayList<Symbol> rhs = new ArrayList<Symbol>();
        Production prod;

        for (int i = 0; i < rightSidesOfProductions.length; i++) {
            for (int j = 0; j < rightSidesOfProductions[i].length; j++) {
                ArrayList<Symbol> rhs = new ArrayList<Symbol>();
                for (int k = 0; k < rightSidesOfProductions[i][j].length(); k++)   
                    rhs.add(findInGrammar(rightSidesOfProductions[i][j].charAt(k)));
                prod = new Production(nonterminals.get(i), rhs);

                boolean isTheSame = false;
                int lengthOfRightSideOfProd;
                for (Production p : productions) {
                    if (p.rhs != null) {
                        if ((p.rhs.size() == prod.rhs.size()) && (p.lhs == prod.lhs)) {
                            lengthOfRightSideOfProd = p.rhs.size();
                            isTheSame = true;
                            for (int m = 0; m < lengthOfRightSideOfProd; m++ ) {
                                if (p.rhs.get(m) != prod.rhs.get(m))
                                    isTheSame = false;
                            }
                            if (isTheSame) {
                                throw new GrammarException("Duplicate in productions of the same nonterminal");
                            }
                        }
                    }
                }
                productions.add(prod);
            }

            if (rightSidesOfProductions[i].length == 0) {
                ArrayList<Symbol> rhs = new ArrayList<Symbol>();
                rhs = null;
                //checking if we don't have multiple empty productions
                //if (p.rhs == null) && (l.rhs.getChar() == nonterminals.get(i))
                for (Production p : productions) {
                    if ((p.rhs == null) && (p.lhs == nonterminals.get(i)))
                        throw new GrammarException("dupa-wyjątek");
                }
                prod = new Production(nonterminals.get(i), rhs);
                productions.add(prod);
            }
        }
    }

    private Symbol findInGrammar(char c) throws GrammarException {       
        if (Character.isUpperCase(c)) {
            for (Nonterminal nt : this.nonterminals) {
                if (c == nt.getChar())
                    return nt;
            }
        }
        else if (Character.isLowerCase(c)) {
            for (Terminal t : this.alphabet) {
                if (c == t.getChar())
                    return t;
            }
        }
        throw new GrammarException("Bad character");
    }

    public ContextFreeGrammar(ContextFreeGrammar G) {
        //ContextFreeGrammar G = new ContextFreeGrammar();
        this.alphabet = new ArrayList<Terminal>();
        this.nonterminals = new ArrayList<Nonterminal>();
        this.productions = new ArrayList<Production>();
        for (Terminal a : G.alphabet)
            this.alphabet.add(new Terminal(a));
        for (Nonterminal nt : G.nonterminals)
            this.nonterminals.add(new Nonterminal(nt));
        for (Production prod : G.productions)
            this.productions.add(new Production(prod));
        this.startSymbol = new Nonterminal(G.startSymbol);
    }

    @Override
    public String toString() {
        String str;
        int x = 0;
        str = "Gramatyka: <";
        if (this.ifGreibach()) {
            x++;
            str += "Greibach";
        }
        if (this.ifChomsky()) {
            if (x > 0)
                str += "/Chomsky";
            else
                str += "Chomsky";
            x++;
        }
        if (this.ifRegular()) {
            if (x > 0)
                str += "/Regular";
            else
                str += "Regular";
            x++;
        }
        str += ">\n";
        str += "Terminale: ";
        for (Terminal t : alphabet) {
            str += t.toString();
        }
        str += "\n";
        str += "Nieterminale: ";
        for (Nonterminal nt : nonterminals) {
            str += nt.toString();
        }
        str += "\n";
        str += "Produkcje:\n";
        for (Production p : productions) {
            str += p.toString() + "\n";
        }
        return str;
    }

    protected boolean ifRegular() {
        int type = 0;   //0 - undefined; 1 - left-type; 2 - right-type
        for (Production prod : productions) {
            if (prod.rhs != null) {
                if (prod.rhs.size() > 2)
                    return false;
                else if (prod.rhs.size() == 2) {
                    // call only one time to set type of grammar
                    if (type == 0) {
                        if (prod.rhs.get(0) instanceof Terminal)
                            type = 1;
                        else {
                            type = 2;
                        }
                    }
                    // checking if left-type
                    if (type == 1) {
                        if (!(prod.rhs.get(0) instanceof Terminal))
                            return false;
                        if (!(prod.rhs.get(1) instanceof Nonterminal))
                            return false;
                    }
                    // otherwise checking if right-type
                    else {
                        if (!(prod.rhs.get(0) instanceof Nonterminal))
                            return false;
                        if (!(prod.rhs.get(1) instanceof Terminal))
                            return false;
                    }
                }
                else if (prod.rhs.size() == 1) {
                   if (!(prod.rhs.get(0) instanceof Terminal))
                       return false;
                }
            }
        }
        return true;
    }

    protected boolean ifGreibach() {
        for (Production prod : productions) {
            if (prod.rhs != null) {
                if (prod.rhs.get(0) instanceof Nonterminal)
                    return false;
                else {
                    for (int i = 1; i < prod.rhs.size(); i++) {
                        if (!(prod.rhs.get(i) instanceof Nonterminal))
                            return false;
                    }
                }
            }
            else
                return false;
        }
        return true;
    }

    protected boolean ifChomsky() {
        for (Production prod : productions) {
            if (prod.rhs != null) {
                if (prod.rhs.size() > 2)
                    return false;
                else if (prod.rhs.size() == 2) {
                    if (prod.rhs.get(0) instanceof Nonterminal) {
                        if (prod.rhs.get(1) instanceof Terminal)
                            return false;
                    }
                    else
                        return false;
                }
                else if (prod.rhs.size() == 1)
                    if (prod.rhs.get(0) instanceof Nonterminal)
                        return false;
            }
            else
                return false;
        }
        return true;
    }
}
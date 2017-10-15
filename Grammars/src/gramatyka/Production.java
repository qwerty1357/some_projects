package gramatyka;

import java.util.ArrayList;

public class Production {
    protected Nonterminal lhs;
    protected ArrayList<Symbol> rhs;
    protected ArrayList<Production> productions;

    Production(Nonterminal nonterminal, ArrayList<Symbol> al) {
        rhs = new ArrayList<Symbol>();
        this.lhs = nonterminal;
        this.rhs = al;
    }

    Production(Production prod) {
        this.lhs = new Nonterminal(prod.lhs);
        this.rhs = new ArrayList<Symbol>();
        if (prod.rhs != null) {
            for (Symbol s : prod.rhs) {
                if (s instanceof Terminal) {
                    this.rhs.add(new Terminal((Terminal) s));
                }
                else {
                    this.rhs.add(new Nonterminal((Nonterminal) s));
                }
            }
        }
        else 
            this.rhs = null;
    }

    @Override
    public String toString() {
        String str;
        str = lhs.toString() + " -> ";
        if (rhs == null)
                str += "&";
        else {
            for (Symbol r : rhs)
                str += r.toString();
        }
        return str;
    }
}
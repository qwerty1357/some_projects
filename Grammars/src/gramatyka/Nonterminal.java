package gramatyka;

public class Nonterminal extends Symbol implements Cloneable {

    Nonterminal(char c) throws GrammarException {
        super(c);
        if (Character.isUpperCase(c)) {
            setChar(c);
        }
        else {
            throw new GrammarException("nonterminal can be only upperCase letter");
        }
    }

    Nonterminal(Nonterminal nt) {
        super(nt);
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Nonterminal))
            return false;
        if (obj == this)
            return true;
        Nonterminal nt = (Nonterminal) obj;
        return nt.getChar() == this.getChar();
    }

}
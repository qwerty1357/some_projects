package gramatyka;

public class Terminal extends Symbol {

    Terminal(char c) throws GrammarException {
        super(c);
        if (Character.isLowerCase(c)) {
            setChar(c);
        }
        else {
            throw new GrammarException("terminal can be only LowerCase letter");
        }
    }

    Terminal(Terminal t) {
        super(t);
    }
}
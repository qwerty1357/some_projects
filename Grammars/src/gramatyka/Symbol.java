package gramatyka;

public abstract class Symbol implements Cloneable{
    private char c;

    Symbol(char c) throws GrammarException {
       this.c = c;
    }

    Symbol(Symbol s) {
        this.c = s.c;
    }

    protected char getChar() {
        return this.c;
    } 

    protected void setChar(char c) {
        this.c = c;
    }

    @Override
    public String toString() {
        return ("" + c);
    }
}
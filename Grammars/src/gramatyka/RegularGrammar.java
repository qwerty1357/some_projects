package gramatyka;

public class RegularGrammar  extends ContextFreeGrammar {

    public RegularGrammar(ContextFreeGrammar G) throws GrammarException {
        super(G);
        if (!(G.ifRegular()))
            throw new GrammarException("You can create only Regular Grammar");
    }
}

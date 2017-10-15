package gramatyka;

public class NormalGreibachGrammar extends ContextFreeGrammar {

    public NormalGreibachGrammar(ContextFreeGrammar G) throws GrammarException {
        super(G);
        if (!(G.ifGreibach()))
            throw new GrammarException("You can create only Greibach Grammar");
    }

}
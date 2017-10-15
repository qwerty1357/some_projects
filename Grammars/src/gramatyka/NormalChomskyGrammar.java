package gramatyka;

public class NormalChomskyGrammar extends ContextFreeGrammar {

    public NormalChomskyGrammar(ContextFreeGrammar G) throws GrammarException {
        super(G);
        if (!(G.ifChomsky()))
            throw new GrammarException("You can create only Chomsky Grammar");
    }
}
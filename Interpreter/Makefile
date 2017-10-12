all:
	happy -gca ParGrammar.y
	alex -g LexGrammar.x
	ghc --make Main.hs -o interpreter

clean:
	-rm -f *.log *.aux *.hi *.o *.dvi interpreter

distclean: clean
	-rm -f DocGrammar.* LexGrammar.* ParGrammar.* LayoutGrammar.* SkelGrammar.* PrintGrammar.* Main.* AbsGrammar.* interpreter ErrM.* SharedString.* ComposOp.* grammar.dtd XMLGrammar.* Makefile*

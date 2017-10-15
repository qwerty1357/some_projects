package gramatyka;

public class Main {

    public static void main(String[] args) throws GrammarException {

        try {
        System.out.print("G1:\n");
        String nt = "SPQR";
        String t = "ab";
        String[] S = new String[] {"P", "Q", "R"};
        String[] P = new String[] {"a", "aP", "aPb"};
        String[] Q = new String[] {"b", "Qb", "aQb"};
        String[] R = new String[] {};
        String[][] SPQR = new String[][] {S, P, Q, R};
        ContextFreeGrammar G1 = new ContextFreeGrammar(t, nt, SPQR);
        System.out.println(G1.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G2:\n");
        String nt2 = "SPQR";
        String t2 = "abc";
        String[] S2 = new String[] {"aR", "aP", "aQ"};
        String[] P2 = new String[] {"a", "aP", "cP", "aQ"};
        String[] Q2 = new String[] {"b", "bQ", "aQ"};
        String[] R2 = new String[] {};
        String[][] SPQR2 = new String[][] {S2, P2, Q2, R2};
        ContextFreeGrammar G2 = new ContextFreeGrammar(t2, nt2, SPQR2);
        System.out.println(G2.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G3:\n");
        String nt3 = "SABCDEF";
        String t3 = "abcde";
        String[] S3 = new String[] {"cB", "cC", "cD"};
        String[] A3 = new String[] {"a", "aB", "cC", "aD"};
        String[] B3 = new String[] {"b", "bF", "aE"};
        String[] C3 = new String[] {"d"};
        String[] D3 = new String[] {"e"};
        String[] E3 = new String[] {"e"};
        String[] F3 = new String[] {"e"};
        String[][] SPQR3 = new String[][] {S3, A3, B3, C3, D3, E3, F3};
        ContextFreeGrammar G3 = new ContextFreeGrammar(t3, nt3, SPQR3);
        System.out.println(G3.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G4:\n");
        String nt4 = "S";
        String t4 = "abc";
        String[] S4 = new String[] {"a"};
        String[][] SPQR4 = new String[][] {S4};
        ContextFreeGrammar G4 = new ContextFreeGrammar(t4, nt4, SPQR4);
        System.out.println(G4.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G5:\n");
        String nt5 = "SABCDEFGHIJK";
        String t5 = "abdefgh";
        String[] S5 = new String[] {"aABCD", "bABCDEF"};
        String[] A5 = new String[] {"aADEF", "bA", "dSS", "eAB"};
        String[] B5 = new String[] {"b", "fAB", "gCB"};
        String[] C5 = new String[] {"hABC"};
        String[] D5 = new String[] {"aABCD", "bABCDEF"};
        String[] E5 = new String[] {"aADEF", "bABC", "dSS", "eA"};
        String[] F5 = new String[] {"b", "fBC", "gSA"};
        String[] G5 = new String[] {"hSB","a", "b", "d"};
        String[] H5 = new String[] {"aABCD", "bABCDEF"};
        String[] I5 = new String[] {"aADEF", "bABCD", "dSS", "eABCDEF"};
        String[] J5 = new String[] {"b", "fAB", "gABC"};
        String[] K5 = new String[] {"hABCDEFGHIJK"};
        String[][] SPQR5 = new String[][] {S5, A5, B5, C5, D5, E5, F5, G5, H5, I5, J5, K5};
        ContextFreeGrammar G_5 = new ContextFreeGrammar(t5, nt5, SPQR5);
        System.out.println(G_5.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G6:\n");
        String nt6 = "SABCDEFGHIJK";
        String t6 = "abdefgh";
        String[] S6 = new String[] {"aABCD", "bABCDEF"};
        String[] A6 = new String[] {"aADEF", "bA", "dSS", "eAB"};
        String[] B6 = new String[] {};
        String[] C6 = new String[] {"hABC"};
        String[] D6 = new String[] {"aABCD", "bABCDEF"};
        String[] E6 = new String[] {"aADEF", "bABC", "dSS", "eA"};
        String[] F6 = new String[] {};
        String[] G6 = new String[] {"hSB","a", "b", "d"};
        String[] H6 = new String[] {};
        String[] I6 = new String[] {"aADEF", "bABCD", "dSS", "eABCDEF"};
        String[] J6 = new String[] {"b", "fAB", "gABC"};
        String[] K6 = new String[] {};
        String[][] SPQR6 = new String[][] {S6, A6, B6, C6, D6, E6, F6, G6, H6, I6, J6, K6};
        ContextFreeGrammar G_6 = new ContextFreeGrammar(t6, nt6, SPQR6);
        System.out.println(G_6.toString());
        }
        catch (GrammarException e) {
            System.out.print("G6: " + e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G7:\n");
        String nt7 = "SABCDE";
        String t7 = "abdefgh";
        String[] S7 = new String[] {"aA", "b"};
        String[] A7 = new String[] {"aA", "bA", "dS", "eB"};
        String[] B7 = new String[] {"f"};
        String[] C7 = new String[] {"hA"};
        String[] D7 = new String[] {"aA", "bA"};
        String[] E7 = new String[] {"aA", "bA", "dS", "eA"};
        String[][] SPQR7 = new String[][] {S7, A7, B7, C7, D7, E7};
        ContextFreeGrammar G7 = new ContextFreeGrammar(t7, nt7, SPQR7);
        System.out.println(G7.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G8:\n");
        String nt8 = "SAB";
        String t8 = "abc";
        String[] S8 = new String[] {"aB","aA"};
        String[] A8 = new String[] {"bB"};
        String[] B8 = new String[] {"Ac"};
        String[][] SPQR8 = new String[][] {S8, A8, B8};
        ContextFreeGrammar G8 = new ContextFreeGrammar(t8, nt8, SPQR8);
        System.out.println(G8.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G9:\n");
        String nt9 = "SAB";
        String t9 = "abc";
        String[] S9 = new String[] {"aBd","aA"};
        String[] A9 = new String[] {"bB"};
        String[] B9 = new String[] {"Ac"};
        String[][] SPQR9 = new String[][] {S9, A9, B9};
        ContextFreeGrammar G9 = new ContextFreeGrammar(t9, nt9, SPQR9);
        System.out.println(G9.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G10:\n");
        String nt10 = "SAB";
        String t10 = "abc";
        String[] S10 = new String[] {"aBZ","aA"};
        String[] A10 = new String[] {"bB"};
        String[] B10 = new String[] {"Ac"};
        String[][] SPQR10 = new String[][] {S10, A10, B10};
        ContextFreeGrammar G10 = new ContextFreeGrammar(t10, nt10, SPQR10);
        System.out.println(G10.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G11:\n");
        String nt11 = "SAB";
        String t11 = "a";
        String[] S11 = new String[] {};
        String[] A11 = new String[] {};
        String[] B11 = new String[] {};
        String[][] SPQR11 = new String[][] {S11, A11, B11};
        ContextFreeGrammar G11 = new ContextFreeGrammar(t11, nt11, SPQR11);
        System.out.println(G11.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G12:\n");
        String nt12 = "";
        String t12 = "a";
        String[] S12 = new String[] {};
        String[] A12 = new String[] {};
        String[] B12 = new String[] {};
        String[][] SPQR12 = new String[][] {S12, A12, B12};
        ContextFreeGrammar G12 = new ContextFreeGrammar(t12, nt12, SPQR12);
        System.out.println(G12.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G13:\n");
        String nt13 = "SABCDEFGHIJKL";
        String t13 = "abcdefghijkl";
        String[] S13 = new String[] {"DA", "BC"};
        String[] A13 = new String[] {"AB", "AC", "d", "e"};
        String[] B13 = new String[] {"a","b","c","d"};
        String[] C13 = new String[] {"BC"};
        String[] D13 = new String[] {"CD", "EF"};
        String[] E13 = new String[] {"EF", "BC", "SS", "AK"};
        String[] F13 = new String[] {"a"};
        String[] G13 = new String[] {"SB","a", "b", "d"};
        String[] H13 = new String[] {"e"};
        String[] I13 = new String[] {"EG", "CD", "AS", "EF"};
        String[] J13 = new String[] {"b", "AB", "BC"};
        String[] K13 = new String[] {"AB","BC"};
        String[] L13 = new String[] {"DF","GF"};
        String[][] SPQR13 = new String[][] {S13, A13, B13, C13, D13, E13, F13, G13, H13, I13, J13, K13, L13};
        ContextFreeGrammar G_13 = new ContextFreeGrammar(t13, nt13, SPQR13);
        System.out.println(G_13.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G14:\n");
        String nt14 = "SABCD";
        String t14 = "abcd";
        String[] S14 = new String[] {"DA", "DA"};
        String[] A14 = new String[] {"AB", "AC", "d", "e"};
        String[] B14 = new String[] {"a","b","c","d"};
        String[] C14 = new String[] {"BC"};
        String[] D14 = new String[] {"CD", "EF"};
        String[][] SPQR14 = new String[][] {S14, A14, B14, C14, D14};
        ContextFreeGrammar G14 = new ContextFreeGrammar(t14, nt14, SPQR14);
        System.out.println(G14.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G15:\n");
        String nt15 = "SAACCDDDDDEF";
        String t15 = "abcd";
        String[] S15 = new String[] {"DA", "DA"};
        String[] A15 = new String[] {"AB", "AC", "d", "e"};
        String[] B15 = new String[] {"a","b","c","d"};
        String[] C15 = new String[] {"BC"};
        String[] D15 = new String[] {"CD", "EF"};
        String[][] SPQR15 = new String[][] {S15, A15, B15, C15, D15};
        ContextFreeGrammar G15 = new ContextFreeGrammar(t15, nt15, SPQR15);
        System.out.println(G15.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G16:\n");
        String nt16 = "SABCDEF";
        String t16 = "abcdc";
        String[] S16 = new String[] {"DA", "DA"};
        String[] A16 = new String[] {"AB", "AC", "d", "e"};
        String[] B16 = new String[] {"a","b","c","d"};
        String[] C16 = new String[] {"BC"};
        String[] D16 = new String[] {"CD", "EF"};
        String[][] SPQR16 = new String[][] {S16, A16, B16, C16, D16};
        ContextFreeGrammar G16 = new ContextFreeGrammar(t16, nt16, SPQR16);
        System.out.println(G16.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G17:\n");
        String nt17 = "SABCDEF";
        String t17 = "%";
        String[] S17 = new String[] {"DA", "DA"};
        String[] A17 = new String[] {"AB", "AC", "d", "e"};
        String[] B17 = new String[] {"a","b","c","d"};
        String[] C17 = new String[] {"BC"};
        String[] D17 = new String[] {"CD", "EF"};
        String[][] SPQR17 = new String[][] {S17, A17, B17, C17, D17};
        ContextFreeGrammar G17 = new ContextFreeGrammar(t17, nt17, SPQR17);
        System.out.println(G17.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G18:\n");
        String nt18 = "a";
        String t18 = "a";
        String[] S18 = new String[] {"DA", "DA"};
        String[] A18 = new String[] {"AB", "AC", "d", "e"};
        String[] B18 = new String[] {"a","b","c","d"};
        String[] C18 = new String[] {"BC"};
        String[] D18 = new String[] {"CD", "EF"};
        String[][] SPQR18 = new String[][] {S18, A18, B18, C18, D18};
        ContextFreeGrammar G18 = new ContextFreeGrammar(t18, nt18, SPQR18);
        System.out.println(G18.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G19:\n");
        String nt19 = "SABCD";
        String t19 = "a";
        String[] S19 = new String[] {"", "", ""};
        String[] A19 = new String[] {"AB", "AC", "d", "e"};
        String[] B19 = new String[] {"a","b","c","d"};
        String[] C19 = new String[] {"BC"};
        String[] D19 = new String[] {"CD", "EF"};
        String[][] SPQR19 = new String[][] {S19, A19, B19, C19, D19};
        ContextFreeGrammar G19 = new ContextFreeGrammar(t19, nt19, SPQR19);
        System.out.println(G19.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

        try {
        System.out.print("G20:\n");
        String nt20 = "SAB";
        String t20 = "a";
        String[] S20 = new String[] {"A", "S", "B"};
        String[] A20 = new String[] {"AB", "AC", "d", "e"};
        String[] B20 = new String[] {"a","b","c","d"};
        String[] C20 = new String[] {"BC"};
        String[] D20 = new String[] {"CD", "EF"};
        String[][] SPQR20 = new String[][] {S20, A20, B20, C20, D20};
        ContextFreeGrammar G20 = new ContextFreeGrammar(t20, nt20, SPQR20);
        System.out.println(G20.toString());
        }
        catch (GrammarException e) {
            System.out.print(e.getMessage() + "\n\n");
        }

    }
}
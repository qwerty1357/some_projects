package thevoice;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Objects;

public class ProcessorTop5 extends Processor{
    private final static int NUMBER_OF_TOP_SONGS = 5;
    private ArrayList<String> bannedWords = new ArrayList<>();
    
    ProcessorTop5(ArrayList<String> bannedWords) {
        super();
        this.bannedWords = bannedWords;
    }
    
    @Override
    void process(Artist a) {
        String Ar = "Top 5:\n";
        Ar += a.getName() + ": [";
        HashMap<String, Integer> words = a.getWordList();
        ArrayList<String> topWords = new ArrayList<>();
        Entry<String, Integer> maxEntry;
        int howManyWords = NUMBER_OF_TOP_SONGS;
        if (words.size() < howManyWords)
            howManyWords = words.size();
        for (int i = 0; i < howManyWords; i++) {
            maxEntry = null;
            for (Entry<String,Integer> entry : words.entrySet()) {
                if ((maxEntry == null || entry.getValue() >= maxEntry.getValue())) {
                    String s = entry.getKey();
                    if (!topWords.contains(s) && !this.bannedWords.contains(s))
                        if (maxEntry != null && Objects.equals(entry.getValue(), maxEntry.getValue())) {
                            int c = s.compareTo(maxEntry.getKey());
                            if (c < 0)
                                maxEntry = entry;  
                        }
                        else
                            maxEntry = entry;
                }
            }
            if (maxEntry != null) {
               topWords.add(maxEntry.getKey());
                Ar += maxEntry.getKey() + "=" + maxEntry.getValue();
                if (i != howManyWords-1)
                    Ar += ", ";
            }
        }
        Ar += "]";
        System.out.println(Ar);
    }
}

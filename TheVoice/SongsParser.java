package thevoice;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;

public abstract class SongsParser {
    ArrayList<String> bannedWords;
    
    SongsParser(ArrayList<String> bannedWordsPaths) throws FileNotFoundException {
        this.bannedWords = new ArrayList<>();
        for (String s : bannedWordsPaths)
            addToBannedWords(s);
    }
    
    final void addToBannedWords(String path) throws FileNotFoundException {
        File f = new File(path);
        Scanner scan = new Scanner(f);
        String word;
        while (scan.hasNext()) {
            word = scan.nextLine();
            word = word.toLowerCase();
            this.bannedWords.add(word);
        }
    }
    
    abstract Pair<HashMap<String, Integer>, ArrayList<Song>> getWordList(String name) throws FileNotFoundException;
    
    void addWord(String w, HashMap<String, Integer> words) {
        Integer i;
        i = words.get(w);
        if (i == null)
            i = 1;
        else 
            i++;
        words.put(w, i);
    }
}

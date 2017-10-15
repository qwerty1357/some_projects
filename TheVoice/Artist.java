package thevoice;

import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;

public final class Artist {
    private final String name;
    private final HashMap<String, Integer> words;
    private final ArrayList<Song> songList;
    int numberOfWords;
    
    Artist(SongsParser sp, String name) throws FileNotFoundException {
        this.name = name;
        Pair<HashMap<String, Integer>, ArrayList<Song>> pair = sp.getWordList(name);
        this.words = pair.getLeft();
        this.songList = pair.getRight();
        this.numberOfWords = words.size();
    }

    public HashMap<String, Integer> getWordList() {
        return this.words;
    }
    
    public String getName() {
        return this.name;
    }
    
    public int getNumberOfWords() {
        return numberOfWords;
    }  
}


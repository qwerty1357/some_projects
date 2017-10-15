package thevoice;

import org.jsoup.Jsoup;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

public class AZLyricsSongsParser extends SongsParser {
    private final String path;
    AZLyricsSongsParser(String path, ArrayList<String> bannedWordsPaths) throws FileNotFoundException{
        super(bannedWordsPaths);
        this.path = path;
    }
    
    @Override
    Pair<HashMap<String, Integer>, ArrayList<Song>> getWordList(String name) throws FileNotFoundException {
        HashMap<String, Integer> words = new HashMap<>();
        ArrayList<Song> songs = new ArrayList<>();
        Pair<HashMap<String, Integer>, ArrayList<Song>> pair = new Pair<>(words, songs);
        try {
            Document doc = Jsoup.connect(path+"/"+name.charAt(0)+"/"+name).get();
            for (Element e : doc.select("a[href^=\"../lyrics\"")) {
                String adr = e.attr("href").substring(2);
                String song = Jsoup.connect(path+adr).get().html();
                findWords(song, words);
                songs.add(new Song(adr.substring(9+name.length(), adr.length()-5)));
            }
        } catch (IOException ex) {
            Logger.getLogger(AZLyricsSongsParser.class.getName()).log(Level.SEVERE, null, ex);
        }
        return pair;
    }
    
    void findWords(String song, HashMap<String, Integer> words) {
        Scanner scanner = new Scanner(song);
        String line;
        while (scanner.hasNextLine()) {
            line = scanner.nextLine().trim();
            if (line.startsWith("<!-- Usage of az"))
                break;
        }
        while (scanner.hasNextLine()) {
            line = scanner.nextLine().trim();
            for (String in : line.split("[ \\s,.:;?!()-]+")) {
                if (!in.isEmpty()) {
                    if ((in.charAt(0) != '<') && (in.charAt(0) != '[')) {
                        in = in.toLowerCase();
                        addWord(in, words);
                    }
                }
            }
            if (line.startsWith("</div>"))
                break;
        }
    }
}

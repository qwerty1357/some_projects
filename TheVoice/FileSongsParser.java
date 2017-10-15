package thevoice;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.io.FilenameFilter;
import java.util.HashMap;
import java.util.Scanner;

public class FileSongsParser extends SongsParser {
    private String path;
    
    FileSongsParser(String path, ArrayList<String> bannedWordsPaths) throws FileNotFoundException{
        super(bannedWordsPaths);
        this.path = path;
    }
    
    @Override
    Pair<HashMap<String, Integer>, ArrayList<Song>> getWordList(String name) throws FileNotFoundException {
        HashMap<String, Integer> words = new HashMap<>();
        ArrayList<Song> songs = new ArrayList<>();
        Pair<HashMap<String, Integer>, ArrayList<Song>> pair = new Pair<>(words, songs);
        File f = new File(this.path);
        File[] fList = f.listFiles();
        String fileName;
        for (File file : fList) {
            if (file.isDirectory()) {
                fileName = file.getName();
                if (fileName.equals(name)) {
                    File[] list = this.finderTxt(file.getAbsolutePath());
                    for (File m : list) {
                        File songFile = new File(m.getAbsolutePath());
                        Scanner scan = new Scanner(songFile);
                        songs.add(new Song(m.getName().substring(0, f.getName().length() - 4)));
                        while (scan.hasNext()) {
                            String input = scan.nextLine();
                            for (String in : input.split("[ \\s,.:;?!()-]+")) {
                                in = in.toLowerCase();
                                if (!in.isEmpty())
                                    addWord(in, words);
                            }
                        }
                    } 
                }
            }
        }
        return pair;
    } 
        
    private File[] finderTxt(String dirName) {
        File dir;
    	dir = new File(dirName);

    	return dir.listFiles(new FilenameFilter() { 
                @Override
    	        public boolean accept(File dir, String filename)
    	            { return filename.endsWith(".txt"); }
    	} );
    }
}

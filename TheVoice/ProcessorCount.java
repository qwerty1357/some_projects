package thevoice;

public class ProcessorCount extends Processor {
    
    ProcessorCount() {
        super();
    }
    
    @Override
    void process(Artist a) {
        int number = a.getNumberOfWords();
        String Ar = "count:\n";
        Ar += a.getName() + ": " + number;
        System.out.println(Ar);
    }
    
}

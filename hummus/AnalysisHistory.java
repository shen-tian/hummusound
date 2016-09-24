import ddf.minim.analysis.*;
import java.util.LinkedList;

public class AnalysisHistory
{
    private LinkedList<AnalysisOutput> queue;
    private int capacity;
    
    private long lastOnset;
    
    private LinkedList<Integer> bpmQueue;
    
    public AnalysisHistory(int maxLength)
    {
        this.capacity = maxLength;
        queue = new LinkedList<AnalysisOutput>();
        
        bpmQueue = new LinkedList<Integer>();
        
    }
    
    public void addSample(AnalysisOutput analysis)
    {
        queue.add(analysis);
        
        if (analysis.isOnset()){
            long timeSince = analysis.getTimestamp() - lastOnset;
            if (timeSince > 150){
                addBeat((int)timeSince);
                lastOnset = analysis.getTimestamp();
            }
        }
        
        if (queue.size() > capacity)
            queue.removeFirst();
    }
    
    
    
    
    private void addBeat(int millis)
    {
        System.out.println(millis);
        bpmQueue.add(millis);
        if (bpmQueue.size() > 100)
            bpmQueue.removeFirst();
    }
    
    public int getBeatRange(int min, int max)
    {
        int k = 0;
        for (int i = 0; i < bpmQueue.size(); i++)
        {
            if ((min <= bpmQueue.get(i)) && (bpmQueue.get(i) < max))
                k++;
        }
        return k;
    }
    
    public int getSize()
    {
        return queue.size();
    }
    
    public AnalysisOutput getAnalysis(int pos)
    {
        return queue.get(pos);
    }
}

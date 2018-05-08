import ddf.minim.analysis.*;

public class AnalysisOutput
{
    private boolean onset;
    private boolean[] onsets;
    
    private long timestamp;
    
    public AnalysisOutput(long timestamp, BeatDetect energyBD, BeatDetect freqBD)
    {
        onset = freqBD.isKick();//energyBD.isOnset();
        onsets = new boolean[freqBD.dectectSize()];
        
        for (int i = 0; i < freqBD.dectectSize(); i++)
            onsets[i] = freqBD.isRange(i, i, 1);
            
        this.timestamp = timestamp;
        
    }
    
    public int getBeatDetectBands()
    {
        return onsets.length;
    }
    
    // energy mode
    public boolean isOnset()
    {
        return onset;
    }
    
    // frequency mode
    public boolean isOnset(int band)
    {
        return onsets[band];
    }
    
    public int onsetCount()
    {
        int count = 0;
        for (int i = 0; i < onsets.length; i++)
            if (onsets[i])
                count++;
        return count;
    }
    
    public long getTimestamp()
    {
        return timestamp;
    }
}
    

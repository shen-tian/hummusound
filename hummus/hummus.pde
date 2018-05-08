import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioSource in;
//AudioPlayer sound;
FFT fft;
float[] fftFilter;

BeatDetect beat;
BeatDetect energyBeat;

long lastOnset;

FullListener listener;

void setup()
{
    size(512, 600, P3D);

    minim = new Minim(this); 

    // Small buffer size!
    in = minim.getLineIn(); 
    
    fft = new FFT(in.bufferSize(), in.sampleRate());
    fft.logAverages( 60, 3);
    
    System.out.println(fft.avgSize());
    
    fftFilter = new float[fft.specSize()];
    
    System.out.println(in.bufferSize());
    System.out.println(in.sampleRate());
    System.out.println(fft.specSize());

    colorMode(HSB, 100);

    beat = new BeatDetect();
    energyBeat = new BeatDetect();

    history = new AnalysisHistory(300);

    beat.detectMode(BeatDetect.FREQ_ENERGY);
    bbands = beat.dectectSize();
    
    System.out.println(bbands);

    beat.setSensitivity(150);
    
    listener = new FullListener(beat, fft, in); 
    
    ((AudioInput)in).enableMonitoring();
}
float eRadius;
int bands = 30;

int bbands;

AnalysisHistory history;

long last_t;

void draw()
{
    long t = millis();
    long lapse = t - last_t; 
    last_t = t;

    color(50);

    background(0);
    float decay = 0.9;

    text(lapse, 10, 10);

    //fft.forward(in.mix);
    //beat.detect(in.mix);
    energyBeat.detect(in.mix);

    stroke(192);
    
    int n = fft.avgSize();
    
    int fftWidth = 15;
    int xStart = 50;
    int yStart = 200;
    
    for (int i = 0; i < n; i++)
    {
        fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getAvg(i)));
        fill(i * 100. / n, 80, 100);
        stroke(0);
        
        int x = xStart + i * fftWidth;
        int bandHeight = (int)(50 * fftFilter[i]);
        rect(x, yStart - bandHeight, fftWidth, bandHeight);
        if (i % 3 == 0) {
          int freq = (int)(fft.getAverageCenterFrequency(i) - fft.getAverageBandWidth(i) / 2);
          textAlign(CENTER);
          
          text(freq, x, yStart + 10);
        }
    }

    AnalysisOutput sample = new AnalysisOutput(t, energyBeat, beat);
    history.addSample(sample);

    for (int i = 0; i < history.getSize(); i++) {

        AnalysisOutput s = history.getAnalysis(i);
        int yPos = (int)(yStart + (t - s.getTimestamp())/10);
        for (int j = 0; j < bbands; j++)
        {
            stroke(0, 0);
            fill(j * 100. / bands, 80, 50);

            if (s.isOnset(j))
                rect(xStart + fftWidth * j, yPos, fftWidth, 3);
        }

        if (s.onsetCount() > 10)
            text(s.onsetCount(), xStart - 40, yPos);

        fill (50);
        if (s.isOnset())
            rect(xStart - 10, yPos, 10, 3);
    }
    
    int startH = 370;
    int barWidth = 7;
    
    int bucketWidth = 2;
    
    for (int bpm = 80; bpm < 180; bpm+= bucketWidth)
    {
        
        
        fill(75);
        color(75);
        stroke(0);
        
        int xDelta = (bpm - 80) * barWidth / bucketWidth;;
        
        int top = 60000/bpm;
        int bottom = 60000/(bpm + bucketWidth);
        
        int h = history.getBeatRange(bottom, top) * 2;
        
        rect(startH + xDelta, 100 - h, barWidth, h);
        
        textAlign(CENTER);
        textSize(10);
        if ((bpm % 20) == 0)
            text(bpm, startH + xDelta, 110);
    }
}

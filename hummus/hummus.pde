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

void setup()
{
    size(512, 600, P3D);

    minim = new Minim(this); 

    // Small buffer size!
    in = minim.getLineIn();
    //in = minim.loadFile("/Users/Shen/kafkaf.mp3", 512);
    //((AudioPlayer)in).loop();
    fft = new FFT(in.bufferSize(), in.sampleRate());
    fftFilter = new float[fft.specSize()];

    colorMode(HSB, 100);

    beat = new BeatDetect();
    energyBeat = new BeatDetect();
    //eRadius = 20;

    history = new AnalysisHistory(300);

    beat.detectMode(BeatDetect.FREQ_ENERGY);
    bbands = beat.dectectSize();

    beat.setSensitivity(30);
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

    fft.forward(in.mix);
    beat.detect(in.mix);
    energyBeat.detect(in.mix);

    stroke(192);

    for (int i = 0; i < fft.specSize (); i++) {
        fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
    }

    int specWidth = 300;

    for (int i = 0; i < bands; i ++)
    {
        int xstart = specWidth/bands * i; 
        fill(i * 100. / bands, 80, 100);
        stroke(0);
        int samples = fft.specSize() / bands;
        float total = 0;
        for (int j =0; j < samples; j++)
            total += fftFilter[fft.specSize() * i / bands + j];

        int bandHeight = (int)(total / samples * 50);

        rect(50 + xstart, 100 - bandHeight, specWidth/bands, bandHeight);
    }

    AnalysisOutput sample = new AnalysisOutput(t, energyBeat, beat);
    history.addSample(sample);

    int xStart = 50;
    int yStart = 100;

    for (int i = 0; i < history.getSize(); i++) {

        AnalysisOutput s = history.getAnalysis(i);
        int yPos = (int)(yStart + (t - s.getTimestamp())/10);
        for (int j = 0; j < bbands; j++)
        {
            stroke(0, 0);
            fill(j * 100. / bands, 80, 50);

            if (s.isOnset(j))
                rect(xStart + 10 * j, yPos, 10, 3);
        }

        if (s.onsetCount() > 10)
            text(s.onsetCount(), xStart - 40, yPos);

        fill (50);
        if (s.isOnset())
            rect(xStart - 10, yPos, 10, 3);
    }
    
    int startH = 370;
    int barWidth = 7;
    
    int bucketWidth = 5;
    
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


    //float eRadius = 20;


    float a = map(eRadius, 20, 80, 60, 255);
    fill(60, 60, 100);
    if ( beat.isOnset() ) eRadius = 80;
    //ellipse(width/2, height/2, eRadius, eRadius);
    eRadius *= 0.97;
    if ( eRadius < 20 ) eRadius = 20;
}

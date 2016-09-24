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
    
    samples = new AnalysisOutput[1000];

    beat.detectMode(BeatDetect.FREQ_ENERGY);
    bbands = beat.dectectSize();

    println(bbands);
    beat.setSensitivity(30);
}
float eRadius;
int bands = 30;

int bbands;

AnalysisOutput samples[];

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

    for (int i = 1000 - 1; i > 0; i--) {
        samples[i] = samples[i-1];
    }
    
    samples[0] = new AnalysisOutput(t, energyBeat, beat);

    for (int i = 0; i < 1000; i++) {
        
        if (samples[i] != null)
        {
            int xPos = (int)(100 + (t - samples[i].getTimestamp())/10);
            for (int j = 0; j < bbands; j++)
            {
                stroke(0, 0);
                fill(j * 100. / bands, 80, 50);
 
                if (samples[i].isOnset(j))
                {
                    rect(50 + 10 * j, xPos, 10, 3);
                }
            }
            
            if (samples[i].onsetCount() > 10)
                text(samples[i].onsetCount(), 10, xPos);

            fill (50);
            if (samples[i].isOnset())
                rect(40, xPos, 10, 3);
        }
    }


    //float eRadius = 20;


    float a = map(eRadius, 20, 80, 60, 255);
    fill(60, 60, 100);
    if ( beat.isOnset() ) eRadius = 80;
    //ellipse(width/2, height/2, eRadius, eRadius);
    eRadius *= 0.97;
    if ( eRadius < 20 ) eRadius = 20;
}
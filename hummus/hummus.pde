import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioSource in;
//AudioPlayer sound;
FFT fft;
float[] fftFilter;

BeatDetect beat;
BeatDetect energyBeat;

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
    
    historyTime = new long[1000];
    
    word = new String[1000];
    onset = new int[1000];
    
    for (int i = 0; i < 1000; i++){
        historyTime[i] = 0;
        word[i] = "                               ";
        onset[i] = 0;
    }
    
    beat.detectMode(BeatDetect.FREQ_ENERGY);
    bbands = beat.dectectSize();
    
    println(bbands);
    beat.setSensitivity(30);
}
float eRadius;
int bands = 30;

int bbands;

String word[];
int onset[];
long historyTime[];

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
    
    for (int i = 1000 - 1; i > 0; i--){
        historyTime[i] = historyTime[i-1];
        word[i] = word[i-1];
        onset[i] = onset[i-1];
    }
    
    historyTime[0] = t;
    
    word[0] = "";
    for (int i = 0; i < bbands; i ++)
        word[0] += (beat.isRange(i,i,1)) ? "X" : " ";
        
    onset[0] = (energyBeat.isOnset()) ? 2 : 0;
    
    
    for (int i = 0; i < 1000; i++){
        int k = 0;
        for (int j = 0; j < bbands; j++)
        {
            stroke(0,0);
            fill(j * 100. / bands, 80, 50);
            
            if (word[i].charAt(j) == 'X')
            {
                rect(50 + 10 * j, 100 + (t - historyTime[i])/10, 10, 3);
                k++;
            }
            
            
        }
        
        if (k > 10)
            text(k, 10, 100 + (t - historyTime[i])/10);
        
        fill (50);
        if (onset[i] > 0)
            rect(40, 100 + (t - historyTime[i])/10, 10, 3);
    }
        

    //float eRadius = 20;

    
    float a = map(eRadius, 20, 80, 60, 255);
    fill(60, 60, 100);
    if ( beat.isOnset() ) eRadius = 80;
    //ellipse(width/2, height/2, eRadius, eRadius);
    eRadius *= 0.97;
    if ( eRadius < 20 ) eRadius = 20;
}

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioSource in;
//AudioPlayer sound;
FFT fft;
float[] fftFilter;

BeatDetect beat;

void setup()
{
    size(512, 300, P3D);

    minim = new Minim(this); 

    // Small buffer size!
    //in = minim.getLineIn();
    in = minim.loadFile("/Users/Shen/kafkaf.mp3", 512);
    ((AudioPlayer)in).loop();
    fft = new FFT(in.bufferSize(), in.sampleRate());
    fftFilter = new float[fft.specSize()];

    colorMode(HSB, 100);
    
    beat = new BeatDetect();
    //eRadius = 20;
}
float eRadius;
int bands = 60;

void draw()
{
    background(0);
    float decay = 0.9;

    fft.forward(in.mix);

    stroke(192);

    //for (int i = 0; i < fft.specSize (); i++) {
    //    fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
    //    stroke(i * 100. / fft.specSize(), 80, 100);
    //    line(i, 300, i, 300 - (fftFilter[i] * 100));
    //}

    for (int i = 0; i < bands; i ++)
    {
        int xstart = width/bands * i; 
        fill(i * 100. / bands, 80, 100);
        stroke(0);
        int samples = fft.specSize() / bands;
        float total = 0;
        for (int j =0; j < samples; j++)
            total += fftFilter[fft.specSize() * i / bands + j];

        rect(xstart, 0, width/bands, total / samples * 100);
    }

    //float eRadius = 20;

    beat.detect(in.mix);
    float a = map(eRadius, 20, 80, 60, 255);
    fill(60, 60, 100);
    if ( beat.isOnset() ) eRadius = 80;
    ellipse(width/2, height/2, eRadius, eRadius);
    eRadius *= 0.97;
    if ( eRadius < 20 ) eRadius = 20;
}
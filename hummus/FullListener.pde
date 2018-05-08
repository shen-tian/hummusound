import ddf.minim.analysis.*;
import ddf.minim.*;

class FullListener implements AudioListener
{
  private BeatDetect beat;
  private AudioSource source;
  private FFT fft;
  
  FullListener(BeatDetect beat, FFT fft, AudioSource source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
    this.fft = fft;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
    fft.forward(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
    fft.forward(source.mix);
  }
}

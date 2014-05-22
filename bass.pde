import ddf.minim.analysis.*;
import toxi.geom.*;
import java.util.Random;

class Bass {
  FFT fft;

  Vec3D loVec;
  Vec3D miVec;
  Vec3D hiVec;

  float hiBoundary = 16.0/250;
  float miBoundary = 64.0/250;
  float loBoundary = 128.0/250;

  float hiLoudless;
  float miLoudless;
  float loLoudless;

  float origHiLoudless;
  float origMiLoudless;
  float origLoLoudless;

  PImage img = loadImage("bass.png");

  Bass(FFT _fft) {
    fft = _fft;

    Vec3D center = new Vec3D(width/2, height/2, 0);
    float jitter = min(width, height) / 4;

    loVec = center.copy().jitter(new Random(), jitter);
    miVec = center.copy().jitter(new Random(), jitter);
    hiVec = center.copy().jitter(new Random(), jitter);

    origHiLoudless = int(height * 0.8);
    origMiLoudless = int(height * 1);
    origLoLoudless = int(height * 1.4);

  }

  void run() {
    update();
    render();
  }

  void update() {
    updateBassLoudless();
  }

  void render() {
    pushMatrix();
    translate(0, 0, -100);
    fill(neptune, 100);
    noStroke();
    ellipse(loVec.x, loVec.y, loLoudless, loLoudless);
    ellipse(miVec.x, miVec.y, miLoudless, miLoudless);
    ellipse(hiVec.x, hiVec.y, hiLoudless, hiLoudless);
    popMatrix();
    //renderImage(img, loVec, loLoudless, gray, 100);
    //renderImage(img, miVec, miLoudless, gray, 100);
    //renderImage(img, hiVec, hiLoudless, gray, 100);
  }

  void updateBassLoudless() {
    hiLoudless = origHiLoudless;
    miLoudless = origMiLoudless;
    loLoudless = origLoLoudless;
    float rate = 10;

    int ilen = fft.avgSize();

    int hiLen = int(ilen * miBoundary);
    for(int i = int(ilen * hiBoundary); i < hiLen; i++) {
      hiLoudless += fft.getAvg(i) * rate;
    }


    int miLen = int(ilen * loBoundary);
    for(int i = int(ilen * miBoundary); i < miLen; i++) {
      miLoudless += fft.getAvg(i) * rate;
    }

    int loLen = ilen;
    for(int i = int(ilen * loBoundary); i < miLen; i++) {
      loLoudless += fft.getAvg(i) * rate;
    }
  }
}

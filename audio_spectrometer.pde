import ddf.minim.*;
import ddf.minim.analysis.*;

import java.util.ArrayList;

FFT fft;
VJ vj;
DJ dj;
DSP dsp;

Waveform wave;

final int bufferSize = 1024;
final int fps = 30;

Synchro sync;
int synchro;
Camera camera;

// global gain? on a quieter song, the waveforms are not too exciting

void setup() {
  fullScreen(P3D, 1);
  frameRate(fps);

  sync = new Synchro();
  
  Minim minim = new Minim(this);
  dj = new DJ(minim);

  if (!dj.hasSong()) {
    println(CODED);
    exit();
  } else {
    dj.play();
    fft = new FFT(bufferSize, dj.getSampleRate());
    fft.logAverages( 22, 3); // first octave is from 0-22 Hz, 3 bands per octave ??

    dsp = new DSP(sync, fft);

    wave = new Waveform(sync, dj);
    new Thread(wave).start();

    vj = new VJ(wave, dsp, dj);

    synchro = 0;
    camera = new Camera();

    new Thread(dsp).start();
  }
}

// allow concurrent reads??
class Synchro {
  private volatile int pulse;
  
  public Synchro () {
    pulse = 0;
  }

  public void beat () {
    synchronized (this) {
      pulse += 1;
      if (pulse == 3)
        pulse = 0;
    }
  }

  public int getPulse () {
    synchronized (this) {
      return pulse;
    }
  }
}

class Camera {
  float rotX;
  float rotY;
  float rotZ;
  
  Camera() {
    rotX = 0;
    rotY = 0;
    rotZ = 0;
  }
  
  void wander() {
    rotX = frameCount*PI/1533.0;
    rotY = frameCount*PI/1097.0;
    rotZ = frameCount*PI/1342.0;
  }
}

void mouseClicked() {
  // sometimes keyboard events are not registered, a mouse click fixes it
  print("mouse click ");
}

void keyReleased() {
  dj.handleKey();
  vj.handleKey();
}

// could actually move most of these into their owner classes
void draw() { 
  lights();
  background(0);
  stroke(0);
  fill(255,255,255,100);
  
  text("fps: " + int(frameRate), 20, 20);

  sync.beat();
  dj.continuePlay();
  //fft.forward(dj)
  fft.forward(dj.getMix());
  

  camera.wander();
 
  /*
  if (vj.colour_organ) {
    float gap = 10;
    float xdivisions = width/7;
    float ydivisions = xdivisions;
    if (height < ydivisions) {
      ydivisions = height;
    }
    fill(255*basslvl,0,0);
    rect( gap, gap, xdivisions-3*gap/2, ydivisions-2*gap);
    fill(0,255*midlvl[0],0);
    rect( xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*midlvl[1],0);
    rect( 2*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*midlvl[2],0);
    rect( 3*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*midlvl[3],0);
    rect( 4*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*midlvl[4],0);
    rect( 5*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,0,255*treblelvl);
    rect( 6*xdivisions+gap/2, gap, xdivisions-3*gap/2, ydivisions-2*gap);
  }
  */
 
  pushMatrix();
  translate(width/2,height/2,-100);
  rotateX(camera.rotX);
  rotateY(camera.rotY);
  rotateZ(camera.rotZ);

  vj.drawSpaceships();

  popMatrix();

  vj.drawPictures();

  synchro = (synchro+1)%2;
}
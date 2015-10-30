import ddf.minim.*;
import ddf.minim.analysis.*;
import java.io.File;

Minim minim;
AudioPlayer song;
FFT fft;
Spectro master;
DJ dj;
Waveform wfcontrol;
final int bufferSize = 1024;
final int fps = 30;
int synchro;
Planet planet;
Camera camera;

//global gain? on a quieter song, the waveforms are not too exciting

void setup() {
  //fullScreen(P3D, 1);
  size( 1400, 700, P3D);
  frameRate(fps);
  
  wfcontrol = new Waveform();
  
  minim = new Minim(this);
  
  dj = new DJ();
  
  song = minim.loadFile(dj.song_name(), bufferSize);
  song.play();
  
  fft = new FFT(song.bufferSize(), song.sampleRate());
  fft.logAverages( 22, 3); //
  
  master = new Spectro();
  
  synchro = 0;
  
  planet = new Planet();
  camera = new Camera();
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

class DJ {
  private int current_song = 0;
  private StringList song_list = new StringList();
  boolean colour_organ;
  boolean d3_omg;
  boolean asteroid_belt;
  
  DJ() {
    File folder = new File(sketchPath(""));
    String[] filenames = folder.list();
    for(int i = 0; i < filenames.length; i++) {
      if (filenames[i].endsWith(".mp3") || filenames[i].endsWith(".wav")) {
        song_list.append(filenames[i]);
      }
    }
    colour_organ = false;
    d3_omg = false;
    asteroid_belt = false;
  }
  
  String song_name() {
    return song_list.get( current_song );
  }
  
  void previous() {
    song.pause();
    current_song = (current_song - 1);
    if (current_song < 0) {
      current_song = song_list.size() - 1;
    }
    song = minim.loadFile(dj.song_name(), bufferSize);
    song.play();
  }
  
  void next() {
    song.pause();
    current_song = (current_song + 1) % song_list.size();
    song = minim.loadFile(dj.song_name(), bufferSize);
    song.play();
  }
  
  void rewind() {
    song.rewind();
  }
}

void mouseClicked() {
  // sometimes keyboard events are not registered, a mouse click fixes it
  print("mouse click ");
}

void keyReleased() {
  if (key == 'l') {
    dj.rewind();
  } else if (key =='o') {
    dj.colour_organ = !dj.colour_organ;
  } else if (key =='d') {
    wfcontrol.dandruff = !wfcontrol.dandruff;
  } else if (key =='3') {
    dj.d3_omg = !dj.d3_omg;
  } else if (key =='a') {
    dj.asteroid_belt = !dj.asteroid_belt;
  } else if (key == CODED) {
    if (keyCode == LEFT) {
      dj.previous();
    } else if (keyCode == RIGHT) {
      dj.next();
    }
  }
}

// could actually move most of these into their owner classes (see: icosahedron)
void draw() { 
  lights();
  background(0);
  stroke(0);
  fill(255,255,255,100);
  
  text("fps: "+int(frameRate),20,20);
  
  if(song.position() >= song.length() - 400) {
    dj.next();
  }
 
  fft.forward(song.mix);
  
  float basslvl = master.bassLevel();
  float[] midlvl = master.midLevel();
  float treblelvl = master.trebleLevel();
 
  if (dj.colour_organ) {
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
  if (dj.d3_omg || dj.asteroid_belt) {
    pushMatrix();
    camera.wander();
    translate(width/2,height/2,-100);
    rotateX(camera.rotX);
    rotateY(camera.rotY);
    rotateZ(camera.rotZ);
    if(dj.d3_omg) {
      planet.create( basslvl, midlvl, treblelvl); 
      planet.fill_space();
    }
    if(dj.asteroid_belt) {
      planet.orbit(wfcontrol.butterfly(synchro));
    }
    popMatrix();
  }
  if (wfcontrol.dandruff) {
    fill(255*basslvl,255*basslvl,255-127*basslvl);
    stroke(255*basslvl,255*basslvl,255-127*basslvl);
    ArrayList<float[]> flakes = wfcontrol.dandruff(synchro);
    float xbase = width/float(wfcontrol.butterfly_read().length);
    float ampScl = (height/2.0f)*0.7;
    float ampOffSet = 30 + (height/10.0f);
    float arrowHeight = xbase/4.0;
    float arrowTails = xbase;
    float[] tmp = new float[2];
    for (int i = 0; i < flakes.size(); i++) {
      tmp = flakes.get(i);
      if (tmp[1] < 0) {
        pushMatrix();
        translate( tmp[0]*xbase + xbase/2, height/2 + tmp[1]*ampScl - ampOffSet);
        beginShape();
        vertex( 0, 0);
        vertex( xbase/0.8, arrowTails);
        vertex( 0, -arrowHeight);
        vertex( -xbase/0.8, arrowTails); 
        endShape(CLOSE);
        popMatrix();
      } else {
        pushMatrix();
        translate( tmp[0]*xbase + xbase/2, height/2 + tmp[1]*ampScl + ampOffSet);
        beginShape();
        vertex( 0, 0);
        vertex( xbase/0.8, -arrowTails);
        vertex( 0, +arrowHeight);
        vertex( -xbase/0.8, -arrowTails); 
        endShape(CLOSE);
        popMatrix();
      }
    }
  }
  synchro = (synchro+1)%2;
}
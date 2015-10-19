import ddf.minim.*;
import ddf.minim.analysis.*;
import java.io.File;

Minim minim;
AudioPlayer song;
FFT fft;
Spectro master;
DJ musicSelector;
Vis_fx vcontrol;
final int bufferSize = 1024;
final int fps = 30;
int synchro;
Tessellated ico1;
Camera camera;

//global gain? on a quiter song, the waveforms are not too exciting

void setup() {
  fullScreen(P3D, 1);
  //size(1920, 1080, P3D);
  frameRate(fps);
  
  vcontrol = new Vis_fx();
  
  minim = new Minim(this);
  
  musicSelector = new DJ();
  
  song = minim.loadFile(musicSelector.song_name(), bufferSize);
  song.play();
  
  fft = new FFT(song.bufferSize(), song.sampleRate());
  fft.logAverages( 22, 3); //
  
  master = new Spectro();
  
  synchro = 0;
  
  ico1 = new Tessellated();
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
  
  void move() {
    rotX = frameCount*PI/1533.0;
    rotY = frameCount*PI/1097.0;
    rotZ = frameCount*PI/1342.0;
  }
}

class DJ {
  private int current_song = 0;
  private StringList song_list = new StringList();
  
  DJ() {
    File folder = new File(sketchPath(""));
    String[] filenames = folder.list();
    for(int i = 0; i < filenames.length; i++) {
      if (filenames[i].endsWith(".mp3") || filenames[i].endsWith(".wav")) {
        song_list.append(filenames[i]);
      }
    }
  }
  
  String song_name() {
    print(current_song);
    return song_list.get( current_song );
  }
  
  void previous() {
    song.pause();
    current_song = (current_song - 1);
    if (current_song < 0) {
      current_song = song_list.size() - 1;
    }
    song = minim.loadFile(musicSelector.song_name(), bufferSize);
    song.play();
  }
  
  void next() {
    song.pause();
    current_song = (current_song + 1) % song_list.size();
    song = minim.loadFile(musicSelector.song_name(), bufferSize);
    song.play();
    print("LENGTH: " + song.length() + " ");
  }
}

void mouseClicked() {
  // sometimes Processing will not register keyboard events, a mouse click fixes it
  print("mouse click ");
}

void keyReleased() {
  if (key == 'l') {
    song.rewind();
  } else if (key == 'b') {
    vcontrol.butterfly = !vcontrol.butterfly;
  } else if (key == 'r') {
    vcontrol.rough_cut = !vcontrol.rough_cut;
  } else if (key =='p') {
    vcontrol.low_pass = !vcontrol.low_pass;
  } else if (key =='s') {
    master.small_bars = !master.small_bars;
  } else if (key =='o') {
    master.colour_organ = !master.colour_organ;
  } else if (key == 'n') {
    vcontrol.butterfly_nest = !vcontrol.butterfly_nest;
  } else if (key == 'm') {
    vcontrol.mountain_range = !vcontrol.mountain_range;
  } else if (key =='d') {
    vcontrol.dandruff = !vcontrol.dandruff;
  } else if (key =='3') {
    master.d3_omg = !master.d3_omg;
  } else if (key =='a') {
    master.asteroid_belt = !master.asteroid_belt;
  } else if (key == CODED) {
    if (keyCode == LEFT) {
      musicSelector.previous();
    } else if (keyCode == RIGHT) {
      musicSelector.next();
    }
  }
}

// could actually move most of these into their owner classes (see: icosahedron)
void draw() { 
  lights();
  background(0);
  stroke(0);
  
  text("fps: "+int(frameRate),20,20);
  
  if(song.position() >= song.length() - 400) {
    musicSelector.next();
  }
 
  fft.forward(song.mix);
  
  int basslvl = master.bassLevel();
  int[] midlvl = master.midLevel();
  int treblelvl = master.trebleLevel();
 
  
  if (master.small_bars) {
    //bass
    fill(255,0,0,128);
    rect( 0, basslvl, 32, height);
    
    // around speaking range
    fill(0,255,0,128);
    rect( 32, midlvl[0], 32, height);
    rect( 64, midlvl[1], 32, height);
    rect( 96, midlvl[2], 32, height);
    rect( 128, midlvl[3], 32, height);
    rect( 160, midlvl[4], 32, height);
  
    // treble  
    fill(0,0,255,128);
    rect(192, treblelvl, 32, height);
  }
  if (master.colour_organ) {
    float gap = 10;
    float xdivisions = width/7;
    float ydivisions = xdivisions;
    if (height < ydivisions) {
      ydivisions = height;
    }
    fill(255*float(height-basslvl)/height,0,0);
    rect( gap, gap, xdivisions-3*gap/2, ydivisions-2*gap);
    fill(0,255*float(height-midlvl[0])/height,0);
    rect( xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*float(height-midlvl[1])/height,0);
    rect( 2*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*float(height-midlvl[2])/height,0);
    rect( 3*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*float(height-midlvl[3])/height,0);
    rect( 4*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,255*float(height-midlvl[4])/height,0);
    rect( 5*xdivisions+gap/2, gap, xdivisions-gap, ydivisions-2*gap);
    fill(0,0,255*float(height-treblelvl)/height);
    rect( 6*xdivisions+gap/2, gap, xdivisions-3*gap/2, ydivisions-2*gap);
  }
  if (master.d3_omg || master.asteroid_belt) {
    pushMatrix();
    camera.move();
    translate(width/2,height/2,-100);
    rotateX(camera.rotX);
    rotateY(camera.rotY);
    rotateZ(camera.rotZ);
    if(master.d3_omg) {
      
      float BASS = float(height-basslvl)/height;
      float[] MID = new float[midlvl.length];
      MID[0] = float(height-midlvl[0])/height;
      MID[1] = float(height-midlvl[1])/height;
      MID[2] = float(height-midlvl[2])/height;
      MID[3] = float(height-midlvl[3])/height;
      MID[4] = float(height-midlvl[4])/height;
      float TREBLE = float(height-treblelvl)/height;
    
      ico1.create( BASS, MID, TREBLE); 
      ico1.fill_space();
    }
    if(master.asteroid_belt) {
      ico1.orbit(vcontrol.butterfly(synchro));
      //ico1.ripple(vcontrol.dandruff(synchro), vcontrol.butterfly(synchro).length);
    }
    popMatrix();
  }
  if (vcontrol.low_pass) {
    stroke(255);
    float[] lp = vcontrol.lowPass(song.mix.toArray());
    float xscale = width/float(lp.length);
    float ampScl = 50;
    for(int i = 0; i < lp.length-1; i++) {
      line( i*xscale, height/2+lp[i]*ampScl, i*xscale+xscale, height/2+lp[i+1]*ampScl);
    }
  }
  if (vcontrol.rough_cut) {
    stroke(255,0,0);
    strokeWeight(5);
    float ampScl = 50;
    float[] combo = vcontrol.roughCut(song.mix);
    if (combo.length == 0) {
      line(0,height/2,width,height/2);
    } else {
      float xscale = width/float(bufferSize);
      line( 0, height/2, combo[0]*xscale, height/2 + combo[1]*ampScl);
      int reps = (combo.length-2)/2;
      for(int i = 0; i < reps; i++) {
        float x1 = combo[i*2] * xscale;
        float y1 = height/2 + combo[i*2+1] * ampScl;
        float x2 = combo[(i+1)*2] * xscale;
        float y2 = height/2 + combo[(i+1)*2+1] * ampScl;
        line(x1,y1,x2,y2);
      }
      line( combo[combo.length-2] * xscale, height/2 + combo[combo.length-1] * ampScl, width, height/2); 
    } 
    strokeWeight(1);
  }
  if (vcontrol.butterfly) {
    stroke(255);
    fill(255,100);
    float slant = 15;
    float yC = height/2; // centre on the y axis
    float ampScl = 60; // amplitudes are in the range of +- 1
    float[] amplitudes = vcontrol.butterfly(synchro);
    float xbase = width/float(amplitudes.length);
    for(int i = 0; i < amplitudes.length; i++) {
      beginShape();
      vertex(i*xbase,yC);
      vertex(i*xbase+xbase,yC);
      vertex(i*xbase+xbase+slant, yC+amplitudes[i] * ampScl);
      vertex(i*xbase+slant, yC+amplitudes[i] * ampScl / 1.3);
      endShape(CLOSE);
    }
  }
  if (vcontrol.butterfly_nest) {
    fill(0);
    stroke(0);
    float[] clouds = vcontrol.butterfly_nest(synchro);
    float xbase = width/float(clouds.length);
    float h = xbase/2;
    float ampScl = 70;
    
    for(int i = 0; i < clouds.length-2; i++) {
      float x1 = (i+2)*xbase-h/2;
      float y1 = height/2 + (3*clouds[i+1] + clouds[i+2])/4 * ampScl;
      float x2 = (i+1)*xbase+h/2;
      float y2 = height/2 + (3*clouds[i+1] + clouds[i])/4 * ampScl;
      stroke(0);
      beginShape();
      vertex( (i+1)*xbase, height/2);
      vertex( (i+2)*xbase, height/2);
      vertex( (i+2)*xbase, height/2 + ((clouds[i+1]+clouds[i+2])/2) * ampScl);
      bezierVertex( x1, y1, x2, y2, (i+1)*xbase, height/2 + ((clouds[i]+clouds[i+1])/2) * ampScl);
      endShape(CLOSE);
      
      stroke(255);
      bezier( (i+2)*xbase, height/2 + ((clouds[i+1]+clouds[i+2])/2) * ampScl, x1, y1, x2, y2, (i+1)*xbase, height/2 + ((clouds[i]+clouds[i+1])/2) * ampScl);
    }
  }
  if (vcontrol.mountain_range) {
    float BASS = float(height-basslvl)/height;
    fill(0,255,0,170);
    stroke(0,255,0,170);
    float[] clouds = vcontrol.butterfly_nest(synchro);
    float xbase = width/float(clouds.length);
    float h = xbase/2;
    float ampScl = 60+20*BASS;
    for(int i = 0; i < clouds.length-1; i++) {
        beginShape();
        vertex(i*xbase+h,height/2);
        vertex((i+1)*xbase+h,height/2);
        vertex((i+1)*xbase+h, height/2+clouds[i+1]*ampScl);
        vertex(i*xbase+h, height/2+clouds[i]*ampScl);
        endShape(CLOSE);
    }
  }
  if (vcontrol.dandruff) {
    float BASS = 255*float(height-basslvl)/height;
    fill(BASS,BASS,255-BASS/2);
    stroke(BASS,BASS,255-BASS/2);
    ArrayList<float[]> flakes = vcontrol.dandruff(synchro);
    float xbase = width/float(vcontrol.butterfly_read().length);
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

// rorschach? golden ratio?
// rorschach, in all four corners and along the left and right, more instrusive when volume is low, change colour, overlapping opacity
// somthing constant scrolling? -> need to fill the space
class Spectro {
  boolean small_bars;
  boolean colour_organ;
  boolean d3_omg;
  boolean asteroid_belt;
  private float treble_max = 0;
  private float treble_decayed_max = 0;
  private int treble_lag = 0;
  private float bass_max = 0;
  private float bass_decayed_max = 0;
  private float mid_max = 0;
  private float mid_decayed_max = 0;
  private int mid_cycles = 0;
  private int treble_cycles = 0;
  private int bass_cycles = 0;
  
  Spectro() {
    small_bars = false;
    colour_organ = false;
    d3_omg = false;
    asteroid_belt = false;
  }
  
  int[] midLevel() {
    int[] results = new int[5];
    float[] lvls = new float[5];
    lvls[0] = fft.calcAvg(120.0, 300.0);
    lvls[1] = fft.calcAvg(200.0, 450.0);
    lvls[2] = fft.calcAvg(450.0, 800.0);
    lvls[3] = fft.calcAvg(500.0, 1400.0);
    lvls[4] = fft.calcAvg(1000.0, 1500.0);
    
    float sum = lvls[0];
    float max = lvls[0];
    for(int i = 1; i < 5; i++) {
      if (lvls[i] > max) {
        max = lvls[i];
      }
      sum += lvls[i];
    }
    
    if (max > mid_decayed_max) {
      mid_decayed_max = max;
      mid_max = max;
      mid_cycles = 0;
      for(int i = 0; i < 5; i++) {
        results[i] = height - int(height * lvls[i]/max);
      }
      return results;
    } else {
      mid_cycles += 1;
      for(int i = 0; i < 5; i++) {
        results[i] = height - int(height * lvls[i]/mid_decayed_max);
      }
      mid_decayed_max = mid_max * (1 - mid_cycles/(fps*2));
      return results;
    }
  }
  
  int bassLevel() {
    float lvl = fft.calcAvg(20.0,120.0);
    // average is already decently smooth
    if (lvl > bass_decayed_max) {
      bass_decayed_max = lvl;
      bass_max = lvl;
      bass_cycles = 0;
      return 0;
    } else {
      return this.bassDecay(lvl);
    }
  }
  
  private int bassDecay(float max) {
    bass_cycles += 1;
    float arg = -bass_cycles/fps + 5;
    bass_decayed_max = bass_max * (atan(arg) + HALF_PI) / 2.9442;
    return height - int(height * max/bass_decayed_max);
  }
  
  int trebleLevel() {
    int lowerLim = fft.specSize() - fft.specSize()/2;
    float sum = 0;
    for(int i = lowerLim; i < fft.specSize(); i++) {
      sum += fft.getBand(i);
    }
    int current = this.trebleRaw(sum);
    
    // smooth
    if ( treble_lag < height/2 && current > height/2 ) {
      treble_lag = current;
      return current;
    } else if (abs(current-treble_lag) < height/3) {
      treble_lag = int(current*0.2+treble_lag*0.8);
      return treble_lag;
    } else {  // this case roughly corresponds to a snare hit
      treble_lag = current;
      return current;
    }
  }
    
  private int trebleRaw( float lvl ) {
    if (lvl > treble_decayed_max) {
      treble_max = lvl;
      treble_decayed_max = lvl;
      treble_cycles = 0;
      return 0; // max height, or top left corner has a y of 0
    } else {
      return this.trebleDecay(lvl);
    }
  }
  
  private int trebleDecay(float max) {
    treble_cycles += 1;
    float exp = treble_cycles/(fps*3); // six seconds until compare_max = 1/2 decay_max
    treble_decayed_max = treble_max * cos(HALF_PI - pow(2.7, -exp) * HALF_PI);
    return height - int(height * max/treble_decayed_max);
  }
}
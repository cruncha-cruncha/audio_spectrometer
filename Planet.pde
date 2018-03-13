class D3OmgLag {
  float treble = 0;
  float[] mid = new float[5];
  float bass = 0;
  float tAngle = 0;
  
  void noLag(float b, float[] m, float t, float tA) {
    treble = t;
    mid = m;
    bass = b;
    tAngle = tA; // treble angle
  }
}

public class Planet implements SpaceObject {
  D3OmgLag lag = new D3OmgLag();
  private volatile boolean visible;

  private final DSP dsp;
  private float[] mid;

  
  int[][] fMaps;       // each element is three indices describing the three vertices of a triangle
  float[][] vertices;                   
  float[][] vMods;    // used to scale vertex values

  Planet (DSP dsp) {
  	mid = new float[5];
  	visible = false;
  	this.dsp = dsp;
    loadShape();
  }
  
  private void loadShape () {
    Icosahedron hedron = new Icosahedron();
    fMaps = hedron.fMaps;
    vertices = hedron.vertices;
    vMods = new float[vertices.length][3];
  }
  
  // stretch "vertically"
  private void morph() {
    float y = sin(frameCount*PI/53)/2.2f;
    for (int i = 0; i < vertices.length; i++)                              
      vMods[i][1] += y;
  }
  
  // respond to mid range
  private void spike(int v, float s) {
    if (0.7 > random(1)) {
      vMods[v][0] = (0.9+(s/4.0f));
      vMods[v][1] = (0.9+(s/4.0f));
      vMods[v][2] = (0.9+(s/4.0f));
    } else {
      vMods[v][0] = (1.0-(s/4.0f));
      vMods[v][1] = (1.0-(s/4.0f));
      vMods[v][2] = (1.0-(s/4.0f));
    }
  }
  
  // reset vertex modifiers
  private void fillMods() {
    for(int i = 0; i < vertices.length; i++) {                                     
      vMods[i][0] = 1.0f;
      vMods[i][1] = 1.0f;
      vMods[i][2] = 1.0f;
    }
  }
  
  //void create(float bass, float[] mid, float treble) {
  public void draw () {
  	float bass = dsp.getBass();
  	float treble = dsp.getTreble();
  	dsp.getMids(mid);

    fillMods();
    
    if (bass <= lag.bass && lag.bass > 0.4) {
      bass = lag.bass - (lag.bass-bass)/10.0f;
    } else if (abs(bass-lag.bass) < 0.2) {
      bass += (lag.bass-bass)/3.0f;
    }
    float radius = 100 + 45*bass;
    
    for(int i  = 0; i < vertices.length; i++) {                                       
      spike(i, mid[i%5]);
    }
    
    morph();
    
    float tAngle = lag.tAngle;
    if (treble > 0.5) {
      if (lag.treble < 0.5) {
        tAngle += 0.1;
      }
      tAngle += treble/10.0;
      tAngle = tAngle%4; // becuase HALF_PI * 4 = TWO_PI = 0;
    }
    
    pushMatrix();
    rotateY(HALF_PI*tAngle);
    noStroke();
    fill(204,4,4);
    for(int i = 0; i < fMaps.length; i++) { // i < 80                                    
      beginShape();
      vertex( vertices[fMaps[i][0]][0]*radius*vMods[fMaps[i][0]][0], vertices[fMaps[i][0]][1]*radius*vMods[fMaps[i][0]][1], vertices[fMaps[i][0]][2]*radius*vMods[fMaps[i][0]][2]);
      vertex( vertices[fMaps[i][1]][0]*radius*vMods[fMaps[i][1]][0], vertices[fMaps[i][1]][1]*radius*vMods[fMaps[i][1]][1], vertices[fMaps[i][1]][2]*radius*vMods[fMaps[i][1]][2]);
      vertex( vertices[fMaps[i][2]][0]*radius*vMods[fMaps[i][2]][0], vertices[fMaps[i][2]][1]*radius*vMods[fMaps[i][2]][1], vertices[fMaps[i][2]][2]*radius*vMods[fMaps[i][2]][2]);
      endShape(CLOSE);
    }
    popMatrix();
    
    lag.noLag( bass, mid, treble, tAngle);
  }

	public void flipVisible () {
		visible = !visible;
	}

	public boolean isVisible () {
		return visible;
	}
}

class Icosahedron {
  // should also include scale and some sort of colour scheme
  
  // each element is three indices describing the three vertices of a triangle
  public final int[][] fMaps = { { 0, 1, 2}, { 3, 4, 1}, { 5, 2, 4}, { 1, 4, 2}, { 0, 6, 1}, { 7, 8, 6}, 
                    { 3, 1, 8}, { 6, 8, 1}, { 7, 9, 8}, { 10, 11, 9}, { 3, 8, 11}, { 9, 11, 8}, 
                    { 3, 11, 12}, { 10, 13, 11}, { 14, 12, 13}, { 11, 13, 12}, { 3, 12, 4}, { 14, 15, 12},
                    { 5, 4, 15}, { 12, 15, 4}, { 14, 16, 15}, { 17, 18, 16}, { 5, 15, 18}, { 16, 18, 15}, 
                    { 14, 19, 16}, { 20, 21, 19}, { 17, 16, 21}, { 19, 21, 16}, { 10, 22, 13}, { 20, 19, 22}, 
                    { 14, 13, 19}, { 22, 19, 13}, { 10, 23, 22}, { 24, 25, 23}, { 20, 22, 25}, { 23, 25, 22}, 
                    { 24, 26, 25}, { 27, 28, 26}, { 20, 25, 28}, { 26, 28, 25}, { 27, 29, 28}, { 17, 21, 29}, 
                    { 20, 28, 21}, { 29, 21, 28}, { 27, 30, 29}, { 31, 32, 30}, { 17, 29, 32}, { 30, 32, 29},
                    { 27, 33, 30}, { 34, 35, 33}, { 31, 30, 35}, { 33, 35, 30}, { 34, 36, 35}, { 0, 37, 36}, 
                    { 31, 35, 37}, { 36, 37, 35}, { 0, 2, 37}, { 5, 38, 2}, { 31, 37, 38}, { 2, 38, 37}, 
                    { 31, 38, 32}, { 5, 18, 38}, { 17, 32, 18}, { 38, 18, 32}, { 7, 6, 39}, { 0, 36, 6}, 
                    { 34, 39, 36}, { 6, 36, 39}, { 7, 39, 40}, { 34, 41, 39}, { 24, 40, 41}, { 39, 41, 40},
                    { 7, 40, 9}, { 24, 23, 40}, { 10, 9, 23}, { 40, 23, 9}, { 27, 26, 33}, { 24, 41, 26},
                    { 34, 33, 41}, { 26, 41, 33} };
           
  public final float[][] vertices = { { -0.5257311, 0.0, 0.8506508}, { -0.30901697, 0.5, 0.809017}, { 0.0, 0.0, 1.0}, 
                         { 0.0, 0.8506508, 0.5257311}, { 0.30901697, 0.5, 0.809017}, { 0.5257311, 0.0, 0.8506508},
                         { -0.809017, 0.30901697, 0.5}, { -0.8506508, 0.5257311, 0.0}, { -0.5, 0.809017, 0.30901697},
                         { -0.5, 0.809017, -0.30901697}, { 0.0, 0.8506508, -0.5257311}, { 0.0, 1.0, 0.0}, 
                         { 0.5, 0.809017, 0.30901697}, { 0.5, 0.809017, -0.30901697}, { 0.8506508, 0.5257311, 0.0}, 
                         { 0.809017, 0.30901697, 0.5}, { 1.0, 0.0, 0.0}, { 0.8506508, -0.5257311, 0.0}, 
                         { 0.809017, -0.30901697, 0.5}, { 0.809017, 0.30901697, -0.5}, { 0.5257311, 0.0, -0.8506508},
                         { 0.809017, -0.30901697, -0.5}, { 0.30901697, 0.5, -0.809017}, { -0.30901697, 0.5, -0.809017}, 
                         { -0.5257311, 0.0, -0.8506508}, { 0.0, 0.0, -1.0}, { -0.30901697, -0.5, -0.809017}, 
                         { 0.0, -0.8506508, -0.5257311}, { 0.30901697, -0.5, -0.809017}, { 0.5, -0.809017, -0.30901697}, 
                         { 0.0, -1.0, 0.0}, { 0.0, -0.8506508, 0.5257311}, { 0.5, -0.809017, 0.30901697}, 
                         { -0.5, -0.809017, -0.30901697}, { -0.8506508, -0.5257311, 0.0}, { -0.5, -0.809017, 0.30901697}, 
                         { -0.809017, -0.30901697, 0.5}, { -0.30901697, -0.5, 0.809017}, { 0.30901697, -0.5, 0.809017}, 
                         { -1.0, 0.0, 0.0}, { -0.809017, 0.30901697, -0.5}, { -0.809017, -0.30901697, -0.5} };
}
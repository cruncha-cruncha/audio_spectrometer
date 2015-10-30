import java.util.Arrays;
ToyBox tb = new ToyBox();

class D3OmgLag {
  float treble = 0;
  float[] mid = new float[5];
  float bass = 0;
  float tAngle = 0;
  
  void noLag(float b, float[] m, float t, float tA) {
    treble = t;
    mid = m;
    bass = b;
    tAngle = tA;
  }
}

class Planet {
  float radius;
  int faces;
  int verts;
  D3OmgLag lag = new D3OmgLag();
  float[][] stars;
  
  int[][] fMap;       // each element is three indices describing the three vertices of a triangle
  float[][] vertices; // vertices are stored only once, but referenced multiple times through fMap                      
  float[][] vMods;    // used to scale vertex values
  
  Planet() {
    load_shape("tardis");
    star_generator();
  }
  
  private void load_shape(String shape) {
    tb.select(shape);
    faces = tb.get_f();
    verts = tb.get_v();
    fMap = tb.get_map();
    vertices = tb.get_vertices();
    vMods = new float[verts][3];
    // possibility of race conditions?
  }
  
  private void morph() {
    float y = sin(frameCount*PI/53)/2.2f;
    for (int i = 0; i < verts; i++) {                                  
      vMods[i][1] += y;
    }
  }
  
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
  
  private void fillMods() {
    for(int i = 0; i < verts; i++) {                                     
      vMods[i][0] = 1.0f;
      vMods[i][1] = 1.0f;
      vMods[i][2] = 1.0f;
    }
  }
  
  void create(float bass, float[] mid, float treble) {
    fillMods();
    
    if (bass <= lag.bass && lag.bass > 0.4) {
      bass = lag.bass - (lag.bass-bass)/10.0f;
    } else if (abs(bass-lag.bass) < 0.2) {
      bass += (lag.bass-bass)/3.0f;
    }
    radius = 100 + 45*bass;
    
    for(int i  = 0; i < verts; i++) {                                       
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
    for(int i = 0; i < faces; i++) { // i < 80                                    
      beginShape();
      vertex( vertices[fMap[i][0]][0]*radius*vMods[fMap[i][0]][0], vertices[fMap[i][0]][1]*radius*vMods[fMap[i][0]][1], vertices[fMap[i][0]][2]*radius*vMods[fMap[i][0]][2]);
      vertex( vertices[fMap[i][1]][0]*radius*vMods[fMap[i][1]][0], vertices[fMap[i][1]][1]*radius*vMods[fMap[i][1]][1], vertices[fMap[i][1]][2]*radius*vMods[fMap[i][1]][2]);
      vertex( vertices[fMap[i][2]][0]*radius*vMods[fMap[i][2]][0], vertices[fMap[i][2]][1]*radius*vMods[fMap[i][2]][1], vertices[fMap[i][2]][2]*radius*vMods[fMap[i][2]][2]);
      endShape(CLOSE);
    }
    popMatrix();
    
    lag.noLag( bass, mid, treble, tAngle);
  }
  
  void orbit(float[] smooth) {
    float radiusA = 400;
    float ampScl = 20;
    float gap = TWO_PI/float(smooth.length);
    float x1, z1, x2, z2;
    pushMatrix();
    rotateY(-frameCount*PI/90);
    stroke(0,255,0);
    for(int i = 0; i < smooth.length-1; i++ ) {
      x1 = sin(i*gap) * (smooth[i]*ampScl + radiusA);
      z1 = cos(i*gap) * (smooth[i]*ampScl + radiusA);
      x2 = sin((i+1)*gap) * (smooth[i+1]*ampScl + radiusA);
      z2 = cos((i+1)*gap) * (smooth[i+1]*ampScl + radiusA);
      line( x1, 0, z1, x2, 0, z2);
      line( x1*1.05, 0, z1*1.05, x2*1.05, 0, z2*1.05);
    }
    popMatrix();
  }
  
  private void star_generator() {
    float lower = 1000.0;
    float upper = 5000.0;
    int num = 1000;
    stars = new float[num][3];
    for(int i = 0; i < num; i++) {
      stars[i][0] = (1-random(2))*(lower-upper)+lower;
      stars[i][1] = (1-random(2))*(lower-upper)+lower;
      stars[i][2] = (1-random(2))*(lower-upper)+lower;
    }  
  }
  
  void fill_space() {
    for(int i = 0; i < stars.length; i++) {
      pushMatrix();
      translate(stars[i][0], stars[i][1], stars[i][2]);
      tetrahedron(i);
      popMatrix();
    }
  }
  
  private void tetrahedron(int rot) {
    float r = 10.0; // radius
    float z = (1.0/sqrt(2.0)) * r;
    
    fill(255,255,255,140);
    noStroke();
    
    pushMatrix();
    rotateX(rot);
    rotateY(-rot);
    // A B C
    beginShape();
    vertex( r, 0, -z);
    vertex( -r, 0, -z);
    vertex( 0, r, z);
    endShape(CLOSE);
    
    // A B D
    beginShape();
    vertex( r, 0, -z);
    vertex( -r, 0, -z);
    vertex( 0, -r, z);
    endShape(CLOSE);
    
    // A C D
    beginShape();
    vertex( r, 0, -z);
    vertex( 0, r, z);
    vertex( 0, -r, z);
    endShape(CLOSE);
    
    // B C D
    beginShape();
    vertex( -r, 0, -z);
    vertex( 0, r, z);
    vertex( 0, -r, z);
    endShape(CLOSE);
    popMatrix();
  }
}

class ToyBox {
  // should also include scale and some sort of colour scheme
  int selector = 0;
  int[] faces = { 80, 14 };
  int[] verts = { 42, 9 };
  
  int[][][] fMaps = { { { 0, 1, 2}, { 3, 4, 1}, { 5, 2, 4}, { 1, 4, 2}, { 0, 6, 1}, { 7, 8, 6}, 
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
                        { 34, 33, 41}, { 26, 41, 33} },
                      { { 0, 1, 2}, { 0, 2, 3}, { 0, 1, 5}, { 0, 4, 5}, { 1, 2, 6}, { 1, 5, 6}, { 2, 3, 7},
                        { 2, 6, 7}, { 0, 3, 4}, { 3, 4, 7}, { 4, 5, 8}, { 5, 6, 8}, { 6, 7, 8}, { 4, 7, 8} } };
               
  // 42 vertices
  float[][][] vertices = { { { -0.5257311, 0.0, 0.8506508}, { -0.30901697, 0.5, 0.809017}, { 0.0, 0.0, 1.0}, 
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
                             { -1.0, 0.0, 0.0}, { -0.809017, 0.30901697, -0.5}, { -0.809017, -0.30901697, -0.5} },
                           { { 1.0, 1.5, -1.0}, { -1.0, 1.5, -1.0}, { -1.0, 1.5, 1.0}, { 1.0, 1.5, 1.0}, { 1.0, -1.5, -1.0}, 
                             { -1.0, -1.5, -1.0}, { -1.0, -1.5, 1.0}, { 1.0, -1.5, 1.0}, { 0, -2.0, 0} } };
                             
  void select(String choice) {
    if (choice == "icosahedron2") {
      selector = 0;
    } else if (choice == "tardis") {
      selector = 1;
    } else {
      selector = 0;
    }
  }
  
  int get_f() {
    return faces[selector];
  }
  
  int get_v() {
    return verts[selector];
  }
  
  int[][] get_map() {
    return fMaps[selector];
  }
  
  float[][] get_vertices() {
    return vertices[selector];
  }
}
public class Stars implements SpaceObject {
	float[][] stars;
	private volatile boolean visible;

	public Stars () {
		visible = false;
		generate();
	}

	public void flipVisible () {
		visible = !visible;
	}

	public boolean isVisible () {
		return visible;
	}
	
  // stars
  private void generate() {
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
  
   // stars
  public void draw() {
    for(int i = 0; i < stars.length; i++) {
      pushMatrix();
      translate(stars[i][0], stars[i][1], stars[i][2]);
      tetrahedron(i);
      popMatrix();
    }
  }
  
  // stars
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
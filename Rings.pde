public class Rings implements SpaceObject {
	private volatile boolean visible;
	private Waveform wave;

	public Rings (Waveform wave) {
		this.wave = wave;
		visible = false;
	}

    public void flipVisible () {
   		visible = !visible;
	}

	public boolean isVisible () {
		return visible;
    }

	public void draw () {
		float[] smooth = new float[wave.numOfButterflies];
		wave.kissTheGirl(smooth);
		//float[] smooth = wave.getButterfly();//wave.butterfly(synchro);
		//float[] smooth = wave.kissTheGirl();
		//float[] smooth = wave.butterfly();
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

}
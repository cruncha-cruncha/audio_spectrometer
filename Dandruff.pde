public class Dandruff implements FlatObject {
	private final ArrayList<float[]> head_of_hair;
  	private final float[] flake_lag;
  	private final float[] flakes;
  	private volatile boolean visible;
  	private final Waveform wave;
  	private final DSP dsp;

	public void flipVisible() {
		visible = !visible;
	}

	public boolean isVisible() {
		return visible;
	}

	public Dandruff (Waveform wave, DSP dsp) {
		this.wave = wave;
		this.dsp = dsp;
		visible = false;

		head_of_hair = new ArrayList<float[]>(width);
		flakes = new float[wave.numOfButterflies];
    	flake_lag = new float[wave.numOfButterflies];
	}

	public void draw () {
		float basslvl = dsp.getBass();

		fill(255*basslvl,255*basslvl,255-127*basslvl);
	    stroke(255*basslvl,255*basslvl,255-127*basslvl);

	    calcFlakes();

	    //ArrayList<float[]> flakes = wave.dandruff(synchro);
	    float xbase = width / float(wave.numOfButterflies);
	    float ampScl = (height/2.0f)*0.7;
	    float ampOffSet = 30 + (height/10.0f);
	    float arrowHeight = xbase/4.0;
	    float arrowTails = xbase;
	    float[] tmp = new float[2];


	    for (int i = 0; i < head_of_hair.size(); i++) {
	      tmp = head_of_hair.get(i);
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

	//ArrayList<float[]> dandruff(int cycle) {
	private void calcFlakes () {
    	wave.kissTheGirl(flakes);
    	float step = 5.0; // higher = slower
    
	    // ArrayList<Integer> doesn't seem to work???
	    IntList removal = new IntList();
	    for(int i = 0; i < head_of_hair.size(); i++ ) {
	      float[] tmp = head_of_hair.get(i);
	      if (abs(tmp[1]) >= 1) {
	        removal.append(i);
	      } else if (tmp[1] > 0) {
	        tmp[1] += (1.1 - tmp[1]) / step;
	      } else {
	        tmp[1] -= (1.1 + tmp[1]) / step;
	      }
	    }
	    
	    for(int i = removal.size()-1; i >= 0; i--)
	      head_of_hair.remove(removal.get(i));

	    int count = 0;
	    for (int i = 0; i < flakes.length; i++)
	      if ((flakes[i] > 0.5 && flake_lag[i] < 0.5) || (flakes[i] < -0.5 && flake_lag[i] > -0.5))
	        count += 1;

	    if (count <= 4) {
	      for (int i = 0; i < flakes.length; i++) {
	        if (flakes[i] > 0.5 && flake_lag[i] < 0.5) {
	          float[] tmp = {i, 0.01};
	          head_of_hair.add(tmp);
	          flake_lag[i] = flakes[i];
	        } else if (flakes[i] < -0.5 && flake_lag[i] > -0.5) {
	          float[] tmp = {i, -0.01};
	          head_of_hair.add(tmp);
	          flake_lag[i] = flakes[i];
	        }
	      }
	    } else {
	      // I like the look of this threshold, don't know why
	      float threshold = (20-count)/float(20);
	      for(int i  = 0; i < flakes.length; i++ ) {
	          if (flakes[i] > 0.5 && flake_lag[i] < 0.5 && 0.3 > random(1)) {
	            float[] tmp = {i, 0.01};
	            head_of_hair.add(tmp);
	            flake_lag[i] = flakes[i];
	          } else if (flakes[i] < -0.5 && flake_lag[i] > -0.5 && 0.3 > random(1)) {
	            float[] tmp = {i, -0.01};
	            head_of_hair.add(tmp);
	            flake_lag[i] = flakes[i];
	          }
	      }
	    }

	    //return head_of_hair;
	}
}
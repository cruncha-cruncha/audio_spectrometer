public class PlainJane implements FlatObject {
	private volatile boolean visible;
	private final Waveform wave;
	//private ArrayList<float[]> points;
	private final float[] blank;

	public PlainJane (Waveform wave) {
		this.wave = wave;
		visible = false;

		blank = new float[wave.numOfPeppers];
	}

	public void flipVisible() {
		visible = !visible;
	}

	public boolean isVisible() {
		return visible;
	}

	public void draw () {
		//wave.kissTheGirl(blank);
		wave.jump(blank);

		int scaler = blank.length;

		pushMatrix();
		translate(0,height/2);
		stroke(204,102,0);
		for (int i = 0; i < blank.length-1; i++) {
			float x1 = width * (i/float(scaler));
			float y1 = blank[i] * 100;
			float x2 = width * ((i+1)/float(scaler));
			float y2 = blank[i+1] * 100;
			line(x1, y1, x2, y2);
		}

		wave.limbo(blank);
		stroke(0,102,204);
		for (int i = 0; i < blank.length-1; i++) {
			float x1 = width * (i/float(scaler));
			float y1 = blank[i] * 100;
			float x2 = width * ((i+1)/float(scaler));
			float y2 = blank[i+1] * 100;
			line(x1, y1, x2, y2);
		}

		popMatrix();
	}
}
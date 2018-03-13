class DSP implements Runnable {
  private final Integer TREBLE = 0;
  private final Integer MID = 1;
  private final Integer BASS = 2;

  private final float[] max;
  private final float[] decayedMax;
  private final float[] cycles;

  private final float[] scratchLevels;
  private volatile float mid0, mid1, mid2, mid3, mid4;
  private volatile float trebleLevel, bassLevel;

  private float trebleLag;// = 0;
  private final int lowerTrebleLim;
  private final int specSize;

  private final Thread env;
  private final FFT fft;
  private final Synchro sync;
  private int syncLag;

  public DSP (Synchro sync, FFT fft) {
  	this.fft = fft;
  	this.sync = sync;

  	env = Thread.currentThread();

  	syncLag = -1;

  	max = new float[3];
  	decayedMax = new float[3];
  	cycles = new float[3];

  	scratchLevels = new float[5];

  	trebleLag = 0;
  	specSize = fft.specSize();
  	lowerTrebleLim = specSize - specSize/2;
  }

  public void run () {
  	while (!env.isInterrupted()) {
	  	if (syncLag != sync.getPulse()) {
	  		calcBass();
	  		calcMids();
	  		calcTreble();
	  		syncLag = sync.getPulse();
	  	} else {
	  		Thread.yield();
	   	}
	}
  }

  public float getTreble () {
  	synchronized (TREBLE) {
  		return trebleLevel;
  	}
  }

  public float getBass () {
  	synchronized (BASS) {
  		return bassLevel;
  	}
  }

  public void getMids (float[] out) {
  	synchronized (MID) {
  		out[0] = mid0;
  		out[1] = mid1;
  		out[2] = mid2;
  		out[3] = mid3;
  		out[4] = mid4;
  	}
  }
  
  public void calcMids () {
   	scratchLevels[0] = fft.calcAvg(120.0, 300.0);
   	scratchLevels[1] = fft.calcAvg(200.0, 450.0);
    scratchLevels[2] = fft.calcAvg(450.0, 800.0);
    scratchLevels[3] = fft.calcAvg(500.0, 1400.0);
    scratchLevels[4] = fft.calcAvg(1000.0, 1500.0);
    
    float tmpMax = scratchLevels[0];
    for (int i = 1; i < 5; i++)
      if (scratchLevels[i] > tmpMax)
        tmpMax = scratchLevels[i];

    if (tmpMax > decayedMax[MID]) {
      decayedMax[MID] = tmpMax;
      max[MID] = tmpMax;
      cycles[MID] = 0;

      synchronized (MID) {
          mid0 = scratchLevels[0] / tmpMax;
          mid1 = scratchLevels[1] / tmpMax;
          mid2 = scratchLevels[2] / tmpMax;
          mid3 = scratchLevels[3] / tmpMax;
          mid4 = scratchLevels[4] / tmpMax;
      }
    } else {
      cycles[MID] = cycles[MID] + 1;
      synchronized (MID) {
        mid0 = scratchLevels[0] / decayedMax[MID];
        mid1 = scratchLevels[1] / decayedMax[MID];
        mid2 = scratchLevels[2] / decayedMax[MID];
        mid3 = scratchLevels[3] / decayedMax[MID];
        mid4 = scratchLevels[4] / decayedMax[MID];
      }
      decayedMax[MID] = max[MID] * (1 - cycles[MID]/(fps*2));
    }
  }
  
  public void calcBass () {
    float lvl = fft.calcAvg(20.0,120.0);
    // average is already decently smooth
     if (lvl > decayedMax[BASS]) {
      decayedMax[BASS] = lvl;
      max[BASS] = lvl;
      cycles[BASS] = 0;
      synchronized (BASS) {
      	bassLevel = 0;
      }
    } else {
      // ???
      cycles[BASS] = cycles[BASS] + 1;
  	  float arg = 5 - cycles[BASS]/fps;
  	  decayedMax[BASS] = max[BASS] * (atan(arg) + HALF_PI) / 2.9442;
  	  synchronized (BASS) {
  		bassLevel = lvl/decayedMax[BASS];
  	  }
    }
  }
  
  public void calcTreble () {
    float sum = 0;
    for(int i = lowerTrebleLim; i < specSize; i++)
      sum += fft.getBand(i);

    float current = trebleRaw(sum);
    
    // smooth
    // ???
    if ( trebleLag < 0.5 && current > 0.5 ) {
      trebleLag = current;
      synchronized (TREBLE) {
      	trebleLevel = current;
      }
    } else if (abs(current-trebleLag) < 1.0f/3.0f) {
      trebleLag = current*0.2 + trebleLag*0.8;
      synchronized (TREBLE) {
      	trebleLevel = trebleLag;
      }
    } else {  // this case roughly corresponds to a snare hit (???)
      trebleLag = current;
      synchronized (TREBLE) {
      	trebleLevel = current;
      }
    }
  }
    
  private float trebleRaw (float lvl) {
  	if (lvl > decayedMax[TREBLE]) {
  		max[TREBLE] = lvl;
  		decayedMax[TREBLE] = lvl;
  		cycles[TREBLE] = 0;
  		return 1;
  	} else {
  		// ???
  		cycles[TREBLE] = cycles[TREBLE] + 1;
    	float exp = cycles[TREBLE] / (fps*3); // 3 seconds to decay??
    	decayedMax[TREBLE] = max[TREBLE] * cos(HALF_PI - pow(2.7, -exp) * HALF_PI);
    	return lvl/decayedMax[TREBLE];
  	}
  }
}
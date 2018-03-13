class Waveform implements Runnable {
  private DJ dj;
  private final float[] wingDecay; // wingHistory
  private final float[] wingBuffer;
  private final float[] wings;
  public final int numOfButterflies;
  private final Synchro sync;
  private int syncLag;
  private final Thread env;
  private final int window = 8; // must be a power of 2

  private final int sample = 4;

  private final float[] lowStore;
  private final float[] lowBuff;
  private final float[] highStore;
  private final float[] highBuff;
  private final int numOfPeppers;

  private float[] mix;
  
  Waveform (Synchro sync, DJ dj) {
    this.sync = sync;
    this.dj = dj;

    syncLag = -1;

    env = Thread.currentThread();

    numOfButterflies = bufferSize/window;
    wingDecay = new float[numOfButterflies];
    wingBuffer = new float[numOfButterflies];
    wings = new float[numOfButterflies];

    numOfPeppers = bufferSize/sample;
    lowStore = new float[bufferSize/sample];
    lowBuff = new float[bufferSize/sample];
    highStore = new float[bufferSize/sample];
    highBuff = new float[bufferSize/sample];
  }

  public void run () {
    while (!env.isInterrupted()) {
      if (syncLag != sync.getPulse()) {
        mix = dj.getMix();
        jollyOlPepper();
        calcWings();
        syncLag = sync.getPulse();
      } else {
        Thread.yield();
      }
    }
  }

  // change inputs to arrays, so effects can be chained
  
  private void jollyOlPepper () {
    float sum;
    for (int i = 0; i < lowStore.length; i++) {
      sum = 0;
      for (int j = 0; j < sample; j++)
        sum += mix[i*sample+j];
      lowStore[i] = sum;
    }

    float alpha = 0.5;
    highStore[0] = lowStore[0];
    for (int i = 1; i < highStore.length; i++) {
      highStore[i] = alpha * highStore[i-1] + alpha * (lowStore[i]-lowStore[i-1]);
    }

    for (int i = 2; i >= 0; i--) {
      highStore[i] = alpha * highStore[i+1] + alpha * (lowStore[i]-lowStore[i+1]);
    }

    float tmp = 0;
    float smoothing = 30;
    for (int i = 0; i < lowStore.length; i++) {
      float x = lowStore[i];
      tmp += (x-tmp)/smoothing;
      lowStore[i] = tmp;
    }

    synchronized (highStore) {
      for (int i = 0; i < highStore.length; i++) {
        highBuff[i] = highStore[i];
      }
    }

    synchronized (lowStore) {
      for (int i = 0; i < lowStore.length; i++)
        lowBuff[i] = lowStore[i];
    }
  }

  public void jump (float[] out) {
    synchronized (highStore) {
      for (int i = 0; i < highBuff.length; i++) {
        out[i] = highBuff[i];
      }
    }
  }

  public void limbo (float[] out) {
    synchronized (lowStore) {
      for (int i = 0; i < lowBuff.length; i++) {
        out[i] = lowBuff[i];
      }
    }
  }
  
  private void calcWings () {
      //float[] mix = dj.getMix();

      // calc average of window
      for (int i = 0; i < wings.length; i++) {
        float avg = 0;
        for (int j = i*window; j < i*window + window; j++)
          avg += mix[j];
        avg = avg/window;

        // ???
        if (avg < 0) {
          avg = (-1) * (atan(24*(avg*(-1))-8)+HALF_PI)/PI;
        } else {
          avg = (atan(24*avg-8)+HALF_PI)/PI;
        }

        wingBuffer[i] = avg; 
        // ???
        /*
        if (abs(avg) < abs(wingDecay[i])) {
          if (wingDecay[i] < 0) {
            wingDecay[i] += (1+wingDecay[i])/6;
          } else {
            wingDecay[i] -= (1-wingDecay[i])/6;
          }
        } else {
          wingDecay[i] = wingDecay[i]*0.6+avg*0.4;
        }
        */
      }
      
      synchronized (wings) {
        for (int i = 0; i < wings.length; i++)
          wings[i] = wingBuffer[i];
      }
  }

  public void kissTheGirl (float[] out) {
    synchronized (wings) {
      for (int i = 0; i < wings.length; i++)
        out[i] = wings[i];
    }
  }
}
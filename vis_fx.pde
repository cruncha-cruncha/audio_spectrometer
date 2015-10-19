class Vis_fx {
  boolean butterfly;
  boolean rough_cut;
  boolean low_pass;
  boolean butterfly_nest;
  boolean mountain_range;
  boolean dandruff;
  private float[] wingHistory = new float[0];
  private int butterfly_lag;
  private float[] butterfly_storage = new float[0];
  private ArrayList<float[]> head_of_hair; // could alternatively use two FloatLists
  private float[] flake_lag = new float[0];
  
  Vis_fx() {
    butterfly = false;
    rough_cut = false;
    low_pass = false;
    butterfly_nest = false;
    mountain_range = false;
    dandruff = false;
    butterfly_lag = -1;
    head_of_hair = new ArrayList<float[]>(width);
  }
  
  // change inputs to arrays, so effects can be chained
  float[] lowPass(float[] buff) {
    int sample = 4;
    float[] results = new float[buff.length/sample];
    float sum;
    for(int i = 0; i < results.length; i++) {
      sum = 0;
      for(int j = 0; j < sample; j++) {
        sum += buff[i*sample+j];
      }
      results[i] = sum;
    }
    float tmp = 0;
    float smoothing = 30;
    for(int i = 0; i < results.length; i++) {
      float x = results[i];
      tmp += (x-tmp)/smoothing;
      results[i] = tmp;
    }
    return results;
  }
  
  // change inout to an array so effects can be chained
  float[] roughCut(AudioBuffer buff) {
    float max = 0;
    float cutoff = 0.3; // must be postive
    FloatList composite = new FloatList();
    boolean high = false;
    for(int i = 0; i < buff.size(); i++) {
      float x = buff.get(i);
      if (x < 0 && high) {
        composite.append(i);
        composite.append(0); // use x for a little more scratchiness (and the one below)
        high = false;
      } else if (x > 0 && !high) {
        composite.append(i);
        composite.append(0);
        high = true;
      }
      if (x > cutoff) {
        if (x > max) {
          max = x;
        }
      } else if (x < -cutoff) {
        if (x < max) {
          max = x;
        }
      } else if (max != 0) {
        composite.append(i);
        composite.append(max);
        max = 0;
      }
    }
    return composite.array();
  }
  
  // do something where if amplitude > threshold, a piece goes flying off either up or down
  // maybe incorporate into the butterfly draw?
  
  float[] butterfly_nest(int cycle) {
    butterfly(cycle);
    int scaler = 1;
    if (scaler == 1) {
      return wingHistory;
    } else {
      int len = wingHistory.length/scaler;
      float[] condensed = new float[len];
      for(int i = 0; i < len; i++ ) {
        for(int j = 0; j < scaler; j++ ) {
          condensed[i] += wingHistory[i*scaler+j] / scaler;
        }
      }
      return condensed;
    }
  }
  
  float[] butterfly(int cycle) {
    int window = 8; // must be a power of two
    float[] wings;
    if (wingHistory.length == 0) {
      wingHistory = new float[bufferSize/window];
    }
    if (butterfly_lag != cycle) {
      wings = new float[bufferSize/window];
      for(int i = 0; i < bufferSize/window; i++) {
        float avg = 0;
        for(int j = i*window; j < i*window + window; j++) {
          avg += song.mix.get(j);
        }
        avg = avg/window;
        if (avg < 0) {
          avg = (-1) * (atan(24*(avg*(-1))-8)+HALF_PI)/PI;
        } else {
          avg = (atan(24*avg-8)+HALF_PI)/PI;
        }
        wings[i] = avg; 
        if (abs(avg) < abs(wingHistory[i])) {
          if (wingHistory[i] < 0) {
            wingHistory[i] += (1+wingHistory[i])/6;
          } else {
            wingHistory[i] -= (1-wingHistory[i])/6;
          }
        } else {
          wingHistory[i] = wingHistory[i]*0.6+avg*0.4;
        }
      }
      butterfly_lag = cycle;
      butterfly_write( wings );
      return wings;
    } else {
      return butterfly_read();
    }
  }
  
  private void butterfly_write(float[] wings) {
    butterfly_storage = wings; 
  }
  
  private float[] butterfly_read() {
    return butterfly_storage; // length = 128
  }
  
  ArrayList<float[]> dandruff(int cycle) {
    float[] flakes = butterfly(cycle); // length = 128
    float step = 5.0; // higher = slower
    
    if (flake_lag.length != flakes.length) {
      flake_lag = flakes;
    }
    
    IntList removal = new IntList();
    for(int i = 0; i < head_of_hair.size(); i++ ) {
      float[] tmp = new float[2];
      tmp = head_of_hair.get(i);
      if (abs(tmp[1]) >= 1) {
        removal.append(i);
      } else if (tmp[1] > 0) {
        tmp[1] += (1.1 - tmp[1]) / step;
        head_of_hair.set(i, tmp);
      } else {
        tmp[1] -= (1.1 + tmp[1]) / step;
        head_of_hair.set(i, tmp);
      }
    }
    
    for(int i = removal.size()-1; i >= 0; i--) {
      head_of_hair.remove(removal.get(i));
    }
    
    int testing = 0;
    for(int i  = 0; i < flakes.length; i++ ) {
      float[] tmp = new float[2];
      if (0.3 > random(1)) {   // sparser, and more variation is cooler looking
        if (flakes[i] > 0.5 && flake_lag[i] < 0.5) {
          tmp[0] = i;
          tmp[1] = 0.01;
          head_of_hair.add(tmp);
          flake_lag[i] = flakes[i];
        } else if (flakes[i] < -0.5 && flake_lag[i] > -0.5) {
          tmp[0] = i;
          tmp[1] = -0.01;
          head_of_hair.add(tmp);
          flake_lag[i] = flakes[i];
        }
      }
    }

    return head_of_hair;
  }
}
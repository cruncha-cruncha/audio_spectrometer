class Waveform {
  boolean butterfly;
  boolean dandruff;
  
  private float[] wingHistory = new float[0];
  private int butterfly_lag;
  private float[] butterfly_storage = new float[0];
  private ArrayList<float[]> head_of_hair; // could alternatively use two FloatLists
  private float[] flake_lag = new float[0];
  
  Waveform() {
    butterfly = false;
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

class Spectro { 
  private float treble_max = 0;
  private float treble_decayed_max = 0;
  private float treble_lag = 0;
  private float bass_max = 0;
  private float bass_decayed_max = 0;
  private float mid_max = 0;
  private float mid_decayed_max = 0;
  private int mid_cycles = 0;
  private int treble_cycles = 0;
  private int bass_cycles = 0;
  
  float[] midLevel() {
    float[] results = new float[5];
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
        results[i] = lvls[i]/max;
      }
      return results;
    } else {
      mid_cycles += 1;
      for(int i = 0; i < 5; i++) {
        results[i] = lvls[i]/mid_decayed_max;
      }
      mid_decayed_max = mid_max * (1 - mid_cycles/(fps*2));
      return results;
    }
  }
  
  float bassLevel() {
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
  
  private float bassDecay(float max) {
    bass_cycles += 1;
    float arg = -bass_cycles/fps + 5;
    bass_decayed_max = bass_max * (atan(arg) + HALF_PI) / 2.9442;
    return max/bass_decayed_max;
  }
  
  float trebleLevel() {
    int lowerLim = fft.specSize() - fft.specSize()/2;
    float sum = 0;
    for(int i = lowerLim; i < fft.specSize(); i++) {
      sum += fft.getBand(i);
    }
    float current = this.trebleRaw(sum);
    
    // smooth
    if ( treble_lag < 0.5 && current > 0.5 ) {
      treble_lag = current;
      return current;
    } else if (abs(current-treble_lag) < 1.0f/3.0f) {
      treble_lag = current*0.2+treble_lag*0.8;
      return treble_lag;
    } else {  // this case roughly corresponds to a snare hit
      treble_lag = current;
      return current;
    }
  }
    
  private float trebleRaw( float lvl ) {
    if (lvl > treble_decayed_max) {
      treble_max = lvl;
      treble_decayed_max = lvl;
      treble_cycles = 0;
      return 1;
    } else {
      return this.trebleDecay(lvl);
    }
  }
  
  private float trebleDecay(float max) {
    treble_cycles += 1;
    float exp = treble_cycles/(fps*3); // six seconds until compare_max = 1/2 decay_max
    treble_decayed_max = treble_max * cos(HALF_PI - pow(2.7, -exp) * HALF_PI);
    return max/treble_decayed_max;
  }
}
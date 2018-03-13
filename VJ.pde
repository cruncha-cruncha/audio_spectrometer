import java.util.HashMap;
import java.util.Collection;

class VJ {
  private final HashMap<String,SpaceObject> spaceObjects;
  private final Collection<SpaceObject> spaceCollection;
  //private final ArrayList<FlatObject> flatObjects; 
  //
  //public volatile boolean dandruff;
  private final HashMap<String,FlatObject> flatObjects;
  private final Collection<FlatObject> flatCollection;

  public VJ (Waveform wave, DSP dsp, DJ dj) {
    spaceObjects = new HashMap<String,SpaceObject>();
    //flatObjects = new ArrayList<FlatObject>();

    spaceObjects.put("planet", new Planet(dsp));
    spaceObjects.put("rings", new Rings(wave));
    spaceObjects.put("stars", new Stars());

    spaceCollection = spaceObjects.values();

    flatObjects = new HashMap<String,FlatObject>();

    flatObjects.put("dandruff", new Dandruff(wave, dsp));
    flatObjects.put("plainjane", new PlainJane(wave));
    flatCollection = flatObjects.values();
  }

  public void handleKey () {
    if (key == 's') {
      spaceObjects.get("stars").flipVisible();
    } else if (key == 'p') {
      spaceObjects.get("planet").flipVisible();
    } else if (key == 'r') {
      spaceObjects.get("rings").flipVisible();
    } else if (key == 'd') {
      flatObjects.get("dandruff").flipVisible();
    } else if (key == 'j') {
      flatObjects.get("plainjane").flipVisible();
    }
  }

  public void drawSpaceships () {
    for (SpaceObject so : spaceCollection)
      if (so.isVisible())
        so.draw();
  }

  public void drawPictures () {
    for (FlatObject fo : flatCollection)
      if (fo.isVisible())
        fo.draw();
  }
}
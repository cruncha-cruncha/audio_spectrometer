import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;

class DJ {
  private ArrayList<String> songList;
  private final Minim minim;
  private AudioPlayer song;
  private int songIndex;
  
  DJ (Minim minim) {
    this.minim = minim;

    songList = new ArrayList<String>();
    songIndex = 0;
    song = null;

    File folder = new File(sketchPath(""));
    String[] filenames = folder.list(new FilenameFilter() {
      boolean accept (File dir, String name) {
        if (name.endsWith(".mp3") || name.endsWith(".wav"))
          return true;
        return false;
      }
    });

    for(String name : filenames)
      songList.add(name);

    if (songList.size() > 0) {
      loadSong(songName());
    } else {
      try {
        println("DJ could not find any songs in " + folder.getCanonicalPath());
      } catch (IOException e) {
        println("DJ died");
      }
    }
  }

  public void handleKey () {
    if (key == 'l') {
      rewind();
    } else if (key == CODED) {
      if (keyCode == LEFT) {
        previous();
      } else if (keyCode == RIGHT) {
        next();
      }
    }
  }

  public boolean hasSong () {
    synchronized (this) {
      return (song != null);
    }
  }

  public float getSampleRate () {
    synchronized (this) {
      return song.sampleRate();
    }
  }

  public void play () {
    synchronized (this) {
      song.play();
    }
  }

  public void pause () {
    synchronized (this) {
      song.pause();
    }
  }

  public void continuePlay () {
    synchronized (this) {
      if (song.position() >= (song.length()-400)) // milliseconds
        next();
    }
  }

  public float[] getMix () {
    synchronized (this) {
      return song.mix.toArray();
    }
  }

  public void loadSong (String name) {
    synchronized (this) {
      if (song != null)
        song.pause();
      song = minim.loadFile(name, bufferSize);
    }
  }

  public AudioPlayer getSong () {
    synchronized (this) {
      return song;
    }
  }
  
  public String songName () {
    synchronized (this) {
      return songList.get(songIndex);
    }
  }
  
  public void previous() {
    synchronized (this) {
      songIndex = (songIndex - 1);
      if (songIndex < 0)
        songIndex = songList.size() - 1;

      loadSong(songName());
      song.play();
    }
  }
  
  public void next() {
    synchronized (this) {
      songIndex = (songIndex + 1);
      if (songIndex >= songList.size())
        songIndex = 0;

      loadSong(songName());
      song.play();
    }
  }
  
  public void rewind() {
    synchronized (this) {
      song.rewind();
    }
  }
}
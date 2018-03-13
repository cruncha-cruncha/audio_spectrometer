public interface DrawableInterface {
	public void flipVisible();
	public boolean isVisible();
	public void draw();
}

public interface SpaceObject extends DrawableInterface {

}

public interface FlatObject extends DrawableInterface {

}
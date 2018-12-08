import java.awt.Rectangle;
import java.awt.Graphics;
import java.awt.image.ImageObserver;

/** De abstracte klasse voor een item op een Slide
 * <P>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: SlideItem.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: SlideItem.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: SlideItem.java,v 1.3 2004/08/17 Sylvia Stuurman
 */

public abstract class SlideItem {
  private int level = 0; // het level van het slideitem

  public SlideItem(int lev) {
    level = lev;
  }

  public SlideItem() {
    this(0);
  }

// Geef het level
  public int getLevel() {
    return level;
  }

// Geef de bounding box
  public abstract Rectangle getBoundingBox(Graphics g, ImageObserver observer, float scale, Style style);

// teken het item
  public abstract void draw(int x, int y, float scale, Graphics g, Style style, ImageObserver observer);
}

import java.awt.Rectangle;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.awt.image.ImageObserver;
import java.io.File;
import javax.imageio.ImageIO;
import java.io.IOException;


/** De klasse voor een Bitmap item
 * <P>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: BitmapItem.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: BitmapItem.java,v 1.2 2003/12/17 Sylvia Stuurman
 * @version $Id: BitmapItem.java,v 1.3 2004/08/17 Sylvia Stuurman
 * @version $Id: BitmapItem.java,v 1.4 2007/07/16 Sylvia Stuurman
 */

public class BitmapItem extends SlideItem {
  private BufferedImage bufferedImage;
  private String imageName;

// level staat voor het item-level; name voor de naam van het bestand met het plaatje
  public BitmapItem(int level, String name) {
    super(level);
    imageName = name;
    try {
      bufferedImage = ImageIO.read(new File(imageName));
    }
    catch (IOException e) {
      System.err.println("Bestand " + imageName + " niet gevonden") ;
    }
  }

// Een leeg bitmap-item
  public BitmapItem() {
    this(0, null);
  }

// geef de bestandsnaam van het plaatje
  public String getName() {
    return imageName;
  }

// geef de bounding box van het plaatje
  public Rectangle getBoundingBox(Graphics g, ImageObserver observer, float scale, Style myStyle) {
    return new Rectangle((int) (myStyle.indent * scale), 0,
	(int) (bufferedImage.getWidth(observer) * scale),
	((int) (myStyle.leading * scale)) + (int) (bufferedImage.getHeight(observer) * scale));
  }

// teken het plaatje
  public void draw(int x, int y, float scale, Graphics g, Style myStyle, ImageObserver observer) {
    int width = x + (int) (myStyle.indent * scale);
    int height = y + (int) (myStyle.leading * scale);
    g.drawImage(bufferedImage, width, height,(int) (bufferedImage.getWidth(observer)*scale),
                (int) (bufferedImage.getHeight(observer)*scale), observer);
  }

  public String toString() {
    return "BitmapItem[" + getLevel() + "," + imageName + "]";
  }
}

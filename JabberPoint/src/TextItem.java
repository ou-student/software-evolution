import java.awt.Rectangle;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.font.TextLayout;
import java.awt.font.TextAttribute;
import java.awt.font.LineBreakMeasurer;
import java.awt.font.FontRenderContext;
import java.awt.geom.Rectangle2D;
import java.awt.image.ImageObserver;
import java.text.AttributedString;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

/** Een tekst item
 * <P>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: TextItem.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: TextItem.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: TextItem.java,v 1.2 2004/08/17 Sylvia Stuurman
 */

public class TextItem extends SlideItem {
  private String text;

// een textitem van level level, met als tekst string
  public TextItem(int level, String string) {
    super(level);
    text = string;
  }

// een leeg textitem
  public TextItem() {
    this(0, "NO TEXT GIVEN");
  }

// Geef de tekst
  public String getText() {
    return text == null ? "" : text;
  }

// geef de AttributedString voor het item
  public AttributedString getAttributedString(Style style, float scale) {
    AttributedString attrStr = new AttributedString(getText());
    attrStr.addAttribute(TextAttribute.FONT, style.getFont(scale), 0, text.length());
    return attrStr;
  }

// geef de bounding box van het item
public Rectangle getBoundingBox(Graphics g, ImageObserver observer, float scale, Style myStyle) {
    List layouts = getLayouts(g, myStyle, scale);
    int xsize = 0, ysize = (int) (myStyle.leading * scale);
    Iterator iterator = layouts.iterator();
    while (iterator.hasNext()) {
      TextLayout layout = (TextLayout) iterator.next();
      Rectangle2D bounds = layout.getBounds();
      if (bounds.getWidth() > xsize) {
        xsize = (int) bounds.getWidth();
      }
      if (bounds.getHeight() > 0) {
        ysize += bounds.getHeight();
      }
      ysize += layout.getLeading() + layout.getDescent();
    }
    return new Rectangle((int) (myStyle.indent*scale), 0, xsize, ysize );
  }

// teken het item
  public void draw(int x, int y, float scale, Graphics g, Style myStyle, ImageObserver o) {
    if (text == null || text.length() == 0) {
      return;
    }
    List layouts = getLayouts(g, myStyle, scale);
    Point pen = new Point(x + (int)(myStyle.indent * scale), y + (int) (myStyle.leading * scale));
    Graphics2D g2d = (Graphics2D)g;
    g2d.setColor(myStyle.color);
    Iterator it = layouts.iterator();
    while (it.hasNext()) {
      TextLayout layout = (TextLayout) it.next();
      pen.y += layout.getAscent();
      layout.draw(g2d, pen.x, pen.y);
      pen.y += layout.getDescent();
    }
  }

  private List getLayouts(Graphics g, Style s, float scale) {
    List<TextLayout> layouts = new ArrayList<TextLayout>();
    AttributedString attrStr = getAttributedString(s, scale);
    Graphics2D g2d = (Graphics2D) g;
    FontRenderContext frc = g2d.getFontRenderContext();
    LineBreakMeasurer measurer = new LineBreakMeasurer(attrStr.getIterator(), frc);
    float wrappingWidth = (Slide.referenceWidth - s.indent) * scale;
    while (measurer.getPosition() < getText().length()) {
      TextLayout layout = measurer.nextLayout(wrappingWidth);
      layouts.add(layout);
    }
    return layouts;
  }

  public String toString() {
    return "TextItem[" + getLevel()+","+getText()+"]";
  }
}

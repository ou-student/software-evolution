import java.awt.Color;
import java.awt.Font;

/** Style staat voor Indent, Color, Font and Leading.
 * De koppeling tussen style-nummer en item-level is nu direct:
 * in Slide wordt de style opgehaald voor een item
 * met als style-nummer het item-level.
 * <P>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: Style.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: Style.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: Style.java,v 1.3 2004/08/17 Sylvia Stuurman
 */

public class Style {
  private static Style[] styles; // de styles
  int indent;
  Color color;
  Font font;
  int fontSize;
  int leading;

  public static void createStyles() {
    styles = new Style[5];     // Deze kunnen ooit uit een bestand worden gehaald
    styles[0] = new Style(0, Color.red,   48, 20);	// style voor item-level 0
    styles[1] = new Style(20, Color.blue,  40, 10);	// style voor item-level 1
    styles[2] = new Style(50, Color.black, 36, 10);	// style voor item-level 2
    styles[3] = new Style(70, Color.black, 30, 10);	// style voor item-level 3
    styles[4] = new Style(90, Color.black, 24, 10);	// style voor item-level 4
  }

  public static Style getStyle(int level) {
    if (level >= styles.length) {
      level = styles.length - 1;
    }
    return styles[level];
  }

  public Style(int indent, Color color, int points, int leading) {
    this.indent = indent;
    this.color = color;
    font = new Font("Helvetica", Font.BOLD, fontSize=points);
    this.leading = leading;
  }

  public String toString() {
    return "["+indent+","+color+"; "+fontSize+" on "+leading+"]";
  }

  public Font getFont(float scale) {
    return font.deriveFont(fontSize * scale);
  }
}

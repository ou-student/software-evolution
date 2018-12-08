import javax.swing.JOptionPane;
import java.io.IOException;

/** JabberPoint Main Programma
 * <P>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: JabberPoint.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: JabberPoint.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: JabberPoint.java,v 1.3 2004/08/17 Sylvia Stuurman
 * @version $Id: JabberPoint.java,v 1.4 2007/07/16 Sylvia Stuurman
 */

public class JabberPoint {

  /** Het Main Programma */
  public static void main(String argv[]) {
    Style.createStyles();
    Presentation presentation = new Presentation();
    new SlideViewerFrame("JabberPoint 1.4 - OU version", presentation);
    try {
      if (argv.length == 0) { // een demo presentatie
        Accessor.getDemoAccessor().loadFile(presentation, "");
      } else {
        new XMLAccessor().loadFile(presentation, argv[0]);
      }
      presentation.setSlideNumber(0);
    } catch (IOException ex) {
	JOptionPane.showMessageDialog(null,
		"IO Error: " + ex, "JabberPoint Error",
		JOptionPane.ERROR_MESSAGE);
    }
  }
}

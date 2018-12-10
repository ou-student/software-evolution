import java.awt.Frame;
import javax.swing.JOptionPane;

/**De About-box voor JabberPoint.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: AboutBox.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: AboutBox.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: AboutBox.java,v 1.3 2004/08/17 Sylvia Stuurman
 * @version $Id: AboutBox.java,v 1.4 2007/07/16 Sylvia Stuurman
 */

public class AboutBox {
	
  /**
   * Dit is ook commentaar
   */
  private int test /* TEST */ /* TEST */ ;
	
  public static void show(Frame parent) {
    JOptionPane.showMessageDialog(parent,
	"JabberPoint is a primitive slide-show program in Java(tm). It\n" +
	"is freely copyable as long as you keep this notice and\n" +
	"the splash screen intact.\n" +
	"Copyright (c) 1995-1997 by Ian F. Darwin, ian@darwinsys.com.\n" +
	"Adapted by Gert Florijn (version 1.1) and " +
	"Sylvia Stuurman (version 1.2 and 1.3) for the Open" +
	"University of the Netherlands, 2002 -- 2007." +
	"Author's version available from http://www.darwinsys.com/",
	"About JabberPoint",
	JOptionPane.INFORMATION_MESSAGE
	/* new ImageIcon(myImage) */
	); /** Wat is dit voor 
	raar commentaar */ int hoi;
  }
}

import java.awt.MenuBar;
import java.awt.Frame;
import java.awt.Menu;
import java.awt.MenuItem;
import java.awt.MenuShortcut;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.io.IOException;
import javax.swing.JOptionPane;

/** De controller voor het menu
 * <P>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: MenuController.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: MenuController.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: MenuController.java,v 1.3 2004/08/17 Sylvia Stuurman
 * @version $Id: MenuController.java,v 1.4 2007/07/16 Sylvia Stuurman
 */
public class MenuController extends MenuBar {
	private static final long serialVersionUID = 227L;
  private Frame parent; // het frame, alleen gebruikt als ouder voor de Dialogs
  private Presentation presentation; // wat gecontrolled wordt is de presentatie

  public MenuController(Frame frame, Presentation pres) {
    parent = frame;
    presentation = pres;
    MenuItem menuItem;
    Menu fileMenu = new Menu("File");
    fileMenu.add(menuItem = mkMenuItem("Open"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent actionEvent) {
        presentation.clear();
        Accessor xmlAccessor = new XMLAccessor();
        try {
          xmlAccessor.loadFile(presentation, "test.xml");
          presentation.setSlideNumber(0);
        } catch (IOException exc) {
          JOptionPane.showMessageDialog(parent, "IOException: " + exc, "Load Error", JOptionPane.ERROR_MESSAGE);
	}
	parent.repaint();
      }
    } );
    fileMenu.add(menuItem = mkMenuItem("New"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent actionEvent) {
        presentation.clear();
	parent.repaint();
      }
    });
    fileMenu.add(menuItem = mkMenuItem("Save"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
	Accessor xmlAccessor = new XMLAccessor();
	try {
          xmlAccessor.saveFile(presentation, "dump.xml");
	} catch (IOException exc) {
          JOptionPane.showMessageDialog(parent, "IOException: " + exc, "Save Error", JOptionPane.ERROR_MESSAGE);
	}
      }
    });
    fileMenu.addSeparator();
    fileMenu.add(menuItem = mkMenuItem("Exit"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent actionEvent) {
	presentation.exit(0);
      }
    });
    add(fileMenu);
    Menu viewMenu = new Menu("View");
    viewMenu.add(menuItem = mkMenuItem("Next"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent actionEvent) {
	presentation.nextSlide();
      }
    });
    viewMenu.add(menuItem = mkMenuItem("Prev"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent actionEvent) {
	presentation.prevSlide();
      }
    });
    viewMenu.add(menuItem = mkMenuItem("Goto"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent actionEvent) {
	String pageNumberStr = JOptionPane.showInputDialog((Object)"Page number?");
	int pageNumber = Integer.parseInt(pageNumberStr);
	presentation.setSlideNumber(pageNumber - 1);
      }
    });
    add(viewMenu);
    Menu helpMenu = new Menu("Help");
    helpMenu.add(menuItem = mkMenuItem("About"));
    menuItem.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent actionEvent) {
	AboutBox.show(parent);
      }
    });
    setHelpMenu(helpMenu);		// nodig for portability (Motif, etc.).
  }

// een menu-item aanmaken
  public MenuItem mkMenuItem(String name) {
    return new MenuItem(name, new MenuShortcut(name.charAt(0)));
  }
}

import java.awt.Color;
import java.awt.Font;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Rectangle;
import javax.swing.JComponent;

/** SlideViewerComponent is een grafische component die Slides kan laten zien.
 * <P>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: SlideViewerComponent.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: SlideViewerComponent.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: SlideViewerComponent.java,v 1.3 2004/08/17 Sylvia Stuurman
 * @version $Id: SlideViewerComponent.java,v 1.4 2007/07/16 Sylvia Stuurman
 */

public class SlideViewerComponent extends JComponent {
	private static final long serialVersionUID = 227L;
  private Slide slide; // de huidige slide
  private Font labelFont = null; // het font voor labels
  private Presentation presentation = null; // de presentatie

  public SlideViewerComponent(Presentation pres) {
    setBackground(Color.white); // dit zou ooit van Style afkomstig kunnen zijn
    presentation = pres;
    labelFont = new Font("Dialog", Font.BOLD, 10);
  }

  public Dimension getPreferredSize() {
    return new Dimension(Slide.referenceWidth, Slide.referenceHeight);
  }

  public void update(Presentation presentation, Slide data) {
    if (data == null) {
      repaint();
      return;
    }
    this.presentation = presentation;
    this.slide = data;
    repaint();
  }

// teken de slide
  public void paintComponent(Graphics g) {
    g.setColor(Color.white);
    g.fillRect(0, 0, getSize().width, getSize().height);
    if (presentation.getSlideNumber() < 0 || slide == null) {
      return;
    }
    g.setFont(labelFont);
    g.setColor(Color.black);
    g.drawString("Slide " + (1+presentation.getSlideNumber()) + " of " +
                 presentation.getSize(), 600, 30);
    Rectangle area = new Rectangle(0, 20, getWidth(), (getHeight()-20));
    slide.draw(g, area, this);
  }

}

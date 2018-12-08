import java.util.ArrayList;

/**
 * Presentation houdt de slides in de presentatie bij.
 * <p>
 * In the Presentation's world, page numbers go from 0 to n-1 * <p>
 * This program is distributed under the terms of the accompanying
 * COPYRIGHT.txt file (which is NOT the GNU General Public License).
 * Please read it. Your use of the software constitutes acceptance
 * of the terms in the COPYRIGHT.txt file.
 * @author Ian F. Darwin, ian@darwinsys.com
 * @version $Id: Presentation.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: Presentation.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: Presentation.java,v 1.3 2004/08/17 Sylvia Stuurman
 * @version $Id: Presentation.java,v 1.4 2007/07/16 Sylvia Stuurman
 */

public class Presentation {
  private String showTitle; // de titel van de presentatie
  private ArrayList<Slide> showList = null; // een ArrayList met de Slides
  private int currentSlideNumber = 0; // het slidenummer van de huidige Slide
  private SlideViewerComponent slideViewComponent = null; // de viewcomponent voor de Slides

  public Presentation() {
    slideViewComponent = null;
    clear();
  }

  public Presentation(SlideViewerComponent slideViewerComponent) {
    this.slideViewComponent = slideViewerComponent;
    clear();
  }

// Methode die wordt gebruikt door de Controller
// om te bepalen wat er getoond wordt.
  public int getSize() {
    return showList.size();
  }

  public String getTitle() {
    return showTitle;
  }

  public void setTitle(String nt) {
    showTitle = nt;
  }

  public void setShowView(SlideViewerComponent slideViewerComponent) {
    this.slideViewComponent = slideViewerComponent;
  }

// geef het nummer van de huidige slide
  public int getSlideNumber() {
    return currentSlideNumber;
  }

// verander het huidige-slide-nummer en laat het aan het window weten.
  public void setSlideNumber(int number) {
    currentSlideNumber = number;
    if (slideViewComponent != null) {
      slideViewComponent.update(this, getCurrentSlide());
    }
  }

// ga naar de vorige slide tenzij je aan het begin van de presentatie bent
  public void prevSlide() {
    if (currentSlideNumber > 0) {
      setSlideNumber(currentSlideNumber - 1);
    }
  }

// Ga naar de volgende slide tenzij je aan het einde van de presentatie bent.
  public void nextSlide() {
    if (currentSlideNumber < (showList.size()-1)) {
      setSlideNumber(currentSlideNumber + 1);
    }
  }

// Verwijder de presentatie, om klaar te zijn voor de volgende
  void clear() {
    showList = new ArrayList<Slide>();
    setTitle("New presentation");
    setSlideNumber(-1);
  }

// Voeg een slide toe aan de presentatie
  public void append(Slide slide) {
    showList.add(slide);
  }

// Geef een slide met een bepaald slidenummer
  public Slide getSlide(int number) {
    if (number < 0 || number >= getSize()){
        return null;
    }
    return (Slide)showList.get(number);
  }

// Geef de huidige Slide
  public Slide getCurrentSlide() {
    return getSlide(currentSlideNumber);
  }

  public void exit(int n) {
    System.exit(n);
  }
}

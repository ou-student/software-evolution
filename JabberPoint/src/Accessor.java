import java.io.IOException;

/**
 * Een Accessor maakt het mogelijk om gegevens voor een presentatie
 * te lezen of te schrijven.
 * <p>
 * Niet-abstracte subklassen moeten de load en de save methode implementeren.
 *
 * @author Ian Darwin, ian@darwinsys.co
 * @version $Id: Accessor.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: Accessor.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: Accessor.java,v 1.3 2004/08/17 Sylvia Stuurman
 */

public abstract class Accessor {
  public static final String DEMO_NAME = "Demonstratie presentatie";
  public static final String DEFAULT_EXTENSION = ".xml";

  public static Accessor getDemoAccessor() {
    return new DemoPresentation();
  }

  public Accessor() {
  }

  abstract public void loadFile(Presentation p, String fn) throws IOException;

  abstract public void saveFile(Presentation p, String fn) throws IOException;

}

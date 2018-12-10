import java.util.List;
import java.util.Vector;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.FileWriter;


/**
 * Een accessor die XML bestanden kan lezen en schrijven
 *
 * @version $Id: XMLAccessor.java,v 1.1 2002/12/17 Gert Florijn
 * @version $Id: XMLAccessor.java,v 1.2 2003/11/19 Sylvia Stuurman
 * @version $Id: XMLAccessor.java,v 1.2 2004/08/17 Sylvia Stuurman
 * @version $Id: XMLAccessor.java,v 1.2 2004/08/17 Sylvia Stuurman
 */

public class XMLAccessor extends Accessor {

  public void loadFile(Presentation presentation, String filename) throws IOException {
    try {
      SAXBuilder builder = new SAXBuilder(true);    // true -> validate
      Document document = builder.build(new File(filename)); // maak een JDOM document
      Element element = document.getRootElement();
      String title = element.getChild("head").getChild("title").getText();
      presentation.setTitle(title);
      List slides = element.getChildren("slide");
      for (int slideNumber = 0; slideNumber < slides.size(); slideNumber++) {
	Element xmlSlide = (Element)slides.get(slideNumber);
	Slide slide = new Slide();
	slide.setTitle(xmlSlide.getChild("title").getText());
	presentation.append(slide);
	Element items = xmlSlide.getChild("items");
	List slideItems = items.getChildren();
	for (int itemNumber = 0; itemNumber < slideItems.size(); itemNumber++) {
          Element item = (Element)slideItems.get(itemNumber);
          loadSlideItem(slide, item);
	}
      }
    } catch (JDOMException jdx) {
      System.err.println(jdx.toString());
      throw new IOException("Parse Exception");
    }
  }

  protected void loadSlideItem(Slide slide, Element item) {
    String type = item.getName();
    int level = 1; // default
    String leveltext = item.getAttributeValue("level");
    if (leveltext != null) {
      try {
	level = Integer.parseInt(leveltext);
      }
      catch(NumberFormatException x) {
      }
    }
    if ("text".equals(type)) {
      slide.append(new TextItem(level, item.getText()));
    }
    else {
      if ("image".equals(type)) {
        slide.append(new BitmapItem(level, item.getText()));
      }
      else {
        System.err.println("Unknown element type");
      }
    }
  }

  public void saveFile(Presentation presentation, String filename) throws IOException {
    PrintWriter out = new PrintWriter(new FileWriter(filename));
    out.println("<?xml version=\"1.0\"?>");
    out.println("<!DOCTYPE slideshow SYSTEM \"jabberpoint.dtd\">");
    out.println("<presentation>");
    out.print("<head><title>");
    out.print(presentation.getTitle());
    out.println("</title></head>");
    for (int slideNumber=0; slideNumber<presentation.getSize(); slideNumber++) {
      Slide slide = presentation.getSlide(slideNumber);
      out.println("<slide>");
      out.println("<title>" + slide.getTitle() + "</title>");
      out.println("<items>");
      Vector slideItems = slide.getSlideItems();
      for (int itemNumber = 0; itemNumber<slideItems.size(); itemNumber++) {
        SlideItem slideItem = (SlideItem) slideItems.elementAt(itemNumber);
        if (slideItem instanceof TextItem) {
          out.print("<text level=\"" + slideItem.getLevel() + "\">");
          out.print( ( (TextItem) slideItem).getText());
          out.println("</text>");
        }
        else {
          if (slideItem instanceof BitmapItem) {
            out.print("<image level=\"" + slideItem.getLevel() + "\">");
            out.print( ( (BitmapItem) slideItem).getName());
            out.println("</image>");
          }
          else {
            System.out.println("Ignoring " + slideItem);
          }
        }
      }
      out.println("</items>");
      out.println("</slide>");
    }
    out.println("</slideshow>");
    out.close();
  }
}

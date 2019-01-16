module Visualisation::Controls

import vis::Figure;
import vis::KeySym;
import String;

/************************************/
/* Button Control                   */
/************************************/
public Figure myButton(str caption, void() action) {
	bool hovered = false;

	return overlay(
			[box(lineWidth(0), fillColor(rgb(129,156,169)),
				onMouseEnter(void(){hovered = true;}),
				onMouseExit(void(){hovered = false;}),
				onMouseDown(btnClickHandler(action))
				),
			text(toUpperCase(caption), fontColor("white"), fontBold(true)),
			box(lineWidth(0),fillColor(Color () {return color("white", (hovered ? 1.0 : 0.0) );}),vresizable(false),vsize(3), bottom())], 
			resizable(false), height(60), width(140));
}

private bool(int, map[KeyModifier, bool]) btnClickHandler(void() action) = bool(int btn, map[KeyModifier, bool] m) {
	if(btn == 1){
		action();
		return true;
	}
	return false;
};

/************************************/
/* Label Control                    */
/************************************/
public Figure label(str caption) {

	if(caption != "") {
		return box(
			text(caption, fontColor("white"), fontBold(true)),
			vresizable(false), height(40), lineWidth(0), fillColor(rgb(84,110,122))
		);
	}
	return space(size(0), resizable(false));
}

/************************************/
/* Header Control                   */
/************************************/
public Figure header(str caption) {	
	if(title != "") {
		return box(
			text("  " + caption, fontSize(30), fontColor("white"), left()),
			vresizable(false), height(80), lineWidth(0), fillColor(rgb(41,67,78))
		);
	}
	return space(size(0), resizable(false));
}

/************************************/
/* Footer Control                   */
/************************************/
public Figure footer(str caption) {	
	if(title != "") {
		return box(
			text("  " + caption, fontColor("white"), right()),
			vresizable(false), height(60), lineWidth(0), fillColor(rgb(41,67,78))
		);
	}
	return space(size(0), resizable(false));
}

/************************************/
/* Panel Control                    */
/************************************/
public Figure panel(Figure content) {
	return panel(content, "");
}

public Figure panel(Figure content, str title) {
	return panel(content, title, 24);
}

public Figure panel(Figure content, str title, int margin) {
	return box(
			  vcat(
			  	[
			  	label(title),
			  	space(content,gap(margin))
			  	]
			  ),
			  lineWidth(0), shadow(true)
	);
}

/************************************/
/* MenuBar Control                  */
/************************************/
public Figure menuBar(Figure menuItems...) {
	return box(
		// Content
		hcat(menuItems, resizable(false), left()),
		
		// Styling
		vresizable(false), shadow(true), height(60), left(), fillColor(rgb(129,156,169)), lineWidth(0)
		);
}

/************************************/
/* Page Control                     */
/************************************/
public Figure page(str title, Figure menu, Figure main, Figure footer) {
	return box(
	  vcat([header(title),
		  	menu,
		  	main,
		  	footer
	       ]),
	  fillColor(rgb(225,226,225)), lineWidth(0), std(font("Dialog"))
      );
}

/************************************/
/* ListItem Control                 */
/************************************/
public Figure listItem(str label) {
	return box(text(label), vresizable(false), height(20), left());
}

public Figure listItem(str label, bool(int, map[KeyModifier, bool]) callback) {
	return box(text(label), vresizable(false), height(20), left(), onMouseDown(callback));
}
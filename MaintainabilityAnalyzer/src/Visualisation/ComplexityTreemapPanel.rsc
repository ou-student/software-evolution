module Visualisation::ComplexityTreemapPanel

import Prelude;
import DataTypes;

import vis::Figure;
import vis::KeySym;
import util::Math;

import util::Editors;

import Visualisation::Controls;
import Utils::MetricsInformation;

private Color _firstColor = color("red");
private Color _secondColor = color("green");

private str title = "Complexity Treemap Panel (Nothing selected)";
private set[UnitInfo] unitinfos = {};

/*****************************/
/* Initializer				 */
/*****************************/
private bool _isInitialized = false;

/**
 * Initializes the complexity treemap panel.
 */
public void ctp_initialize() {
	if(!_isInitialized) {		
		
		_isInitialized = true;
	}
}

/*****************************/
/* Redraw panel				 */
/*****************************/
private bool _redraw = false;
private void redraw() { _redraw = true; }
private bool shouldRedraw() { bool temp = _redraw; _redraw = false; return temp; }

/*****************************/
/* New Method Selected event */
/*****************************/
private list[void(loc method)] methodSelectedEventListeners = [];

/**
 * Adds an event listener for the new method selected event.
 */
public void ctp_addMethodSelectedEventListener(void(loc method) listener) {
	if(indexOf(methodSelectedEventListeners, listener) == -1) {
		methodSelectedEventListeners += [listener];
	}
}

/**
 * Trigger the new method selected event listener.
 */
private void methodSelected(loc method) {
	for(l <- methodSelectedEventListeners) l(method);
}

/**
 * Sets the methods to display in the treemap.
 * @param label The label for the treemap.
 * @param The set of type location containing the methods locations.
 */
public void ctp_setMethods(str label, set[loc] methods) {
	title = label;
	unitinfos = { mi_getUnitInfo(m) | m <- methods };
	redraw();
}

public void ctp_setColorscheme(Color first, Color second) {
	_firstColor = first;
	_secondColor = second;
	redraw();
}

/**
 * Returns a computeFigure delegate to draw the complexity treemap panel.
 */
public Figure complexityTreemapPanel() {
	return computeFigure(
		shouldRedraw,
		Figure() {
			nodes = [];
			if(size(unitinfos) >0) {
				cscale = colorScale([0..25], _secondColor, _firstColor);
				nodes = [createTreemapBox(s, cscale(min(s.complexity, 25))) | s <- unitinfos ];
			}
			
			return panel(treemap(nodes), title, 0);
		}
	);
}

/**
 * Returns an FProperty representing a mouse over popup for the specified UnitInfo.
 * @param s The UnitInfo to return the FProperty for.
 * @returns An FProperty representing the popup.
 */
public FProperty popup(UnitInfo s) {
	return mouseOver(box(vcat([
						text(s.unit.file, fontBold(true), left()), 
						text("Complexity:\t<s.complexity>", fontItalic(true), left()), 
						text("Lines of code:\t<s.size>", fontItalic(true), left()),
						text(""),
						text("ctrl+click to view source...", left())
						], vgap(5)),
					 fillColor(ColorPopupBackground),
					 gap(5), startGap(true), endGap(true),
					 resizable(false)));
}

/**
 * Creates a Figure representing the treemap box.
 * @param s The UnitInfo to create the box for.
 * @param c The box fill color.
 * @returns A Figure representing the box for the UnitInfo.
 */
private Figure createTreemapBox(UnitInfo s, Color c) {
	return box(
			   area(s.size),
			   fillColor(c),
			   shrink(1.0,1.0),
			   popup(s),
			   onMouseDown(treemapBoxClickHandler(s.unit))
			);
}

/**
 * Gets a label for the specified method.
 * @param method The location of the method to get the label for.
 */
private str getLabel(loc method) = ((/^<n:.*>\(.*$/ := method.file) ? n : method.file) + "()";

/**
 * Mouse click handler for treemap boxes.
 */
private bool(int, map[KeyModifier, bool]) treemapBoxClickHandler(loc location) = bool(int btn, map[KeyModifier, bool] mdf) {
	if(btn == 1 && mdf[\modCtrl()] == true){
		edit(mi_getDeclaration(location));
		return true;
	}
	if(btn == 1) {
		methodSelected(location);
	}
	return false;
};
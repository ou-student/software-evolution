module Visualisation::ComplexityTreemapPanel

import Prelude;
import DataTypes;

import vis::Figure;
import vis::KeySym;
import util::Math;

import util::Editors;

import Visualisation::Controls;
import Utils::MetricsInformation;

private str title = "Complexity Treemap Panel (Nothing selected)";
private set[UnitInfo] unitinfos = {};

/*****************************/
/* Initializer				 */
/*****************************/
private bool _isInitialized = false;

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


public void ctp_setMethods(str label, set[loc] methods) {
	title = label;
	unitinfos = { mi_getUnitInfo(m) | m <- methods };
	redraw();
}

public Figure complexityTreemapPanel() {
	return computeFigure(
		shouldRedraw,
		Figure() {
			nodes = [];
			if(size(unitinfos) >0) {
				cscale = colorScale([0..50], color("green"),color("red"));
				nodes = [createTreemapBox(s, cscale(min(s.complexity, 50))) | s <- unitinfos ];
			}
			
			return panel(treemap(nodes), title, 0);
		}
	);
}

public FProperty popup(UnitInfo s) {
	return mouseOver(box(vcat([text(s.unit.file, fontBold(true), left()), text("Complexity:\t<s.complexity>", fontItalic(true), left()), text("Lines of code:\t<s.size>", fontItalic(true), left())], vgap(5)),
					 fillColor(ColorPopupBackground),
					 gap(5), startGap(true), endGap(true),
					 resizable(false)));
}

private Figure createTreemapBox(UnitInfo s, Color c) {
	return box(
			   area(s.size),
			   fillColor(c),
			   shrink(1.0,1.0),
			   popup(s),
			   onMouseDown(treemapBoxClickHandler(s.unit))
			);
}

private str getLabel(loc method) = ((/^<n:.*>\(.*$/ := method.file) ? n : method.file) + "()";

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
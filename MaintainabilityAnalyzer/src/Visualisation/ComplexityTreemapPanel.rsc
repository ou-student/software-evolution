module Visualisation::ComplexityTreemapPanel

import Prelude;
import DataTypes;

import vis::Figure;
import vis::KeySym;

import Visualisation::Controls;

private map[loc, UnitInfos] complexityData = ();

/*****************************/
/* Redraw panel				 */
/*****************************/
private bool _redraw = false;
private void redraw() { _redraw = true; }
private bool shouldRedraw() { bool temp = _redraw; _redraw = false; return temp; }



public void ctp_updateUnitInfos(loc project, UnitInfos uis) {
	complexityData[project] = uis;
	redraw();
}

public void ctp_setCurrentLocation(loc location) {
	
}

public Figure complexityTreemapPanel() {
	return computeFigure(
		shouldRedraw,
		Figure() {
			nodes = [];
			
			return panel(treemap(nodes), "CTP");
		}
	);
}

public FProperty popup(UnitInfo s) {
	return mouseOver(box(vcat([text(s.unit.path), text(toString(s.complexity))]),
					 fillColor("lightYellow"),
					 grow(1.2),
					 resizable(false)));
}

private Figure createTreemapBox(UnitInfo s, Color c) {
	return box(area(s.size),
			   fillColor(c),
			   popup(s),
			   onMouseDown(treemapBoxClickHandler(s.unit))
			   );
}

private bool(int, map[KeyModifier, bool]) treemapBoxClickHandler(loc location) = bool(int btn, map[KeyModifier, bool] mdf) {
	if(btn == 1 && mdf[\modCtrl()] == true){
		edit(location);
		return true;
	}
	return false;
};
module Visualisation::ComplexityTreemapPanel

import Prelude;
import DataTypes;

import vis::Figure;
import vis::KeySym;

import Visualisation::Controls;

private map[loc, UnitInfos] complexityData = ();

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

//private Figure getTreemapPanel() {
//	return computeFigure(bool() { bool temp = complexityData.changed; complexityData.changed = false; return temp; }, Figure() {
//		Figures boxes = [];
//		if(size(complexityData.ui) > 0) {
//			cscale = colorScale([s.complexity | s <- complexityData.ui], color("green"),color("red"));
//			boxes = [createTreemapBox(s, cscale(s.complexity)) | s <- complexityData.ui ];
//		}
//		
//		return panel(treemap(boxes, lineWidth(0)), complexityData.label, 0);
//	});
//}

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
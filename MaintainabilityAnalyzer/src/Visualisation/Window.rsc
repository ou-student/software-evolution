module Visualisation::Window

import Prelude;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Math;
import util::Editors;

import DataTypes;
import Main;

import Visualisation::ProjectBrowser;
import Visualisation::Controls;

//UnitInfos r = {};
loc selectedProject = |project://JabberPoint/|;

data DataSet = complexitySet(bool changed, UnitInfos ui, str label);
DataSet complexityData = complexitySet(false, {}, "");


void begin() {
	
	menu = menuBar([myButton("Load", loadProject),myButton("Clear", clear)]);
	
	render(
		page("Maintainance Analyzer",
			 menu,
			 createMain(panel(renderBrowser()), getTreemapPanel()),
			 footer("Copyright by A. Walgreen & E. Postma ©2019\t")
		)
	);

}

private Figure getTreemapPanel() {
	return computeFigure(bool() { bool temp = complexityData.changed; complexityData.changed = false; return temp; }, Figure() {
		Figures boxes = [];
		if(size(complexityData.ui) > 0) {
			cscale = colorScale([s.complexity | s <- complexityData.ui], color("green"),color("red"));
			boxes = [createTreemapBox(s, cscale(s.complexity)) | s <- complexityData.ui ];
		}
		
		return panel(treemap(boxes, lineWidth(0)), complexityData.label, 0);
	});
}

private void redraw() {
	_redraw = true;
}

private void clear() {
	complexityData = complexitySet(true, {}, "");
}

private void loadProject() {
	proj = getCurrentProject();
	r = run(proj.location);
	complexityData = complexitySet(true, r, proj.label);
}







public Figure createMain(Figure left, Figure right) {
	return box(
		hcat(
		[
			space(left, hshrink(0.3)),
			space(right)
		],
		gap(48), startGap(true), endGap(true)),
		fillColor(color("white", 0.0)), lineWidth(0)
	);
}


public FProperty popup(UnitInfo s) {
	return mouseOver(box(vcat([text(s.unit.path), text(toString(s.complexity))]),
					 fillColor("lightYellow"),
					 grow(1.2),
					 resizable(false)));
}

public Figure createTreemapBox(UnitInfo s, Color c) {
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




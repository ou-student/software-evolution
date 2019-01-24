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
import Visualisation::MethodInformationPanel;
import Visualisation::ComplexityTreemapPanel;
import Visualisation::Controls;

import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

private loc currentSelectedMethod;
private int currentIndex = 0;

void onPBNewLocationSelected(M3 model, loc location) {
	if(isMethod(location)){
		mip_setCurrentMethod(model, location);
		currentIndex = 1;
	} else {
		currentIndex = 2;
	}
}

/**
 * Event listener for MethodInformationPanel new selected method.
 */
void onMIPNewMethodSelected(loc method) {
	println("Selected new method <method>");
	pb_setLocation(method);
}


void begin() {

	pb_initialize();

	pb_addNewLocationSelectedEventListener(onPBNewLocationSelected);
	mip_addNewMethodSelectedEventListener(onMIPNewMethodSelected);
	
	menu = menuBar([myButton("Load", loadProject),myButton("Clear", clear)]);
	
	//browseTree = createBrowseTree({createM3FromEclipseProject(|project://smallsql/|)});
	
	render(
		page("Maintainance Analyzer",
			 menu,
			 createMain(
			 	panel(projectBrowser(), "", 0),
				 	fswitch(int(){return currentIndex;},[
				 		panel(text("Select a project in the browser on the left to start", center()), "Welcome to the Maintainability Analyzer"),
				 		methodInformationPanel(),
				 		complexityTreemapPanel()
				 	])
				 ),
			 footer("Copyright by A. Walgreen & E. Postma ©2019\t")
		)
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
			space(left, hsize(400), hresizable(false)),
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




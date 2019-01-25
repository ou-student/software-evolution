module Visualisation::MethodInformationPanel

import Prelude;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import util::Editors;

import Utils::MetricsInformation;

import Visualisation::Controls;

private loc currentMethod = |unknown:///|;

/*****************************/
/* Initializer				 */
/*****************************/
private bool _isInitialized = false;

public void mip_initialize() {
	if(!_isInitialized) {
		mip_addNewMethodSelectedEventListener(onNewMethodSelected);		
		
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
private list[void(loc method)] newMethodSelectedEventListeners = [];

/**
 * Adds an event listener for the new method selected event.
 */
public void mip_addNewMethodSelectedEventListener(void(loc method) listener) {
	if(indexOf(newMethodSelectedEventListeners, listener) == -1) {
		newMethodSelectedEventListeners += [listener];
	}
}

/**
 * Trigger the new method selected event listener.
 */
private void newMethodSelected(loc method) {
	for(l <- newMethodSelectedEventListeners) l(method);
}

/**
 * Local event handler for selecting new method.
 */
private void onNewMethodSelected(loc method) {
	mip_setCurrentMethod(method);
}

public void mip_setCurrentMethod(loc method) {

	currentMethod = method;
	redraw();
}

public void mip_clearMethodInformationPanel() {
	currentMethod = |unknown:///|;
	redraw();
}

public Figure methodInformationPanel() {
	mip_initialize();

	return computeFigure(
			shouldRedraw,
			Figure() { 			
				return panel(
					vcat([
						label("Unit Maintainability Ranking:"),
						box(hscrollable(getGraph())),
						hcat([
							text("Complexity: <mi_getUnitComplexity(currentMethod)>", left()),
							text("LOC: ...", left()),
							text("Unitsize: <mi_getUnitLOC(currentMethod)>", left()),
							myButton("View source", void(){edit(mi_getDeclaration(currentMethod));})
						], vsize(60), vresizable(false), justify(true))
						
					]),
					getName(currentMethod)
				); 
			}
		);
}

private loc getDeclaration(loc location) {
	declarations = currentModel.declarations[location];
	if(size(declarations) > 0)
		return getOneFrom(currentModel.declarations[location]);
	return location;
}

Figure getGraph(){
	//pred = predecessors(currentModel.methodInvocation, currentMethod);
	//succ = successors(currentModel.methodInvocation, currentMethod);
	pred = mi_getPredecessors(currentMethod);
	succ = mi_getSuccessors(currentMethod);
	
	nodes = [ graphNode(pr) | pr <- (pred + succ +{currentMethod}) ];
	
	edges = [ edge(method.path, currentMethod.path) | method <- pred ];
	edges += [ edge(currentMethod.path, method.path) | method <- succ ];
	
	return graph(nodes, edges, hint("layered"),gap(50));
}

Figure graphNode(loc l) = box(
							text(getName(l)), 
							id(l.path),
							hgap(10),
							hsize(100), vsize(50), resizable(false), fillColor(getNodeColor(l)),
							top(), left(),
							popup("Filename: <l.file>\nFilepath: <l.path>"),
							onMouseDown(graphNodeClickHandler(l))
						  );
						  
Color getNodeColor(loc l) {
	if(l == currentMethod) return color("red");
	//if(l notin methods(currentModel)) return color("grey");
	return color("blue");
}

private bool(int, map[KeyModifier, bool]) graphNodeClickHandler(loc location) = bool(int btn, map[KeyModifier, bool] mdf) {
	if(btn == 1){
		newMethodSelected(location);
		return true;
	}
	return false;
};

private str getName(loc l) {
	return /^<n:.*>\(.*$/ := l.file ? n + "()" : l.file;	
}

public void testModule() {
	model = createM3FromEclipseProject(|project://smallsql|);
	met = |java+method:///smallsql/database/Columns/copy()|;
	
	//for(m <- sort(domain(model.containment))) {
	//	println(m);
	//}
	//
	//setCurrentMethod(model, met);
	
	
	//render(methodInformationPanel());
	
	//for(meth <- currentModel.methodInvocation) {
	//	println(meth);
	//}
	//
	//m = predecessors(currentModel.methodInvocation, currentMethod);
	//s = successors(currentModel.methodInvocation, currentMethod);
	//
	//nodes = [ graphNode(pr) | pr <- (m+s+{currentMethod}) ];
	//println(nodes);
	//
	//edges = [ edge(pr.path, currentMethod.path) | pr <- m ];
	//edges += [ edge(currentMethod.path, pr.path) | pr <- s ];
	//println(edges);
	
		
	//println("Is used in: ");
	//for(pr <- m) {
	//	println(pr);
	//}
	//
	//println();
	//println("Uses: ");
	//for(suc <- s) {
	//	println(suc);
	//}
	
	//println(currentMethod);
}
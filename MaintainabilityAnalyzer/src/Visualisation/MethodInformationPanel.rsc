module Visualisation::MethodInformationPanel

import Prelude;
import DataTypes;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import util::Editors;

import util::Math;

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
							text("LineCount:", left()),
							getLineCountsFigure(currentMethod),
							text("Unitsize: <mi_getUnitLOC(currentMethod)>", left()),
							myButton("View source", void(){edit(mi_getDeclaration(currentMethod));})
						],hgap(20), vsize(60), vresizable(false), justify(true))
						
					]),
					getName(currentMethod)
				); 
			}
		);
}

Figure getLineCountsFigure(loc location) {
	LineCounts lc = mi_getLineCountsForMethod(location);
	
	comments = (0.00 + lc.comment) / (0.001 + lc.total);
	blank = (0.00 + lc.blank) / (0.001 + lc.total);
	code = (0.00 + lc.code) / (0.001 + lc.total);
	
	println("Comments <comments>, Blank <blank>, Code <code>");
	
	return box(
		hcat([
			box(fillColor("black"), lineWidth(0), hshrink(comments)),
			box(fillColor("green"), lineWidth(0), hshrink(code)),
			box(fillColor("white"), lineWidth(0), hshrink(blank))
		],std(vsize(40))), popup("Comments:\t <lc.comment>\nBlank:\t\t <lc.blank>\nCode:\t\t <lc.code>"),
		std(vresizable(false))
	);
	
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
	if(mi_getDeclaration(l) == |unknown:///|) return color("grey");
	return color("green");
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

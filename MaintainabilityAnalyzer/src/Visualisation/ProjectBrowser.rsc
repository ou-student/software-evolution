module Visualisation::ProjectBrowser

import Visualisation::Controls;

import Prelude;
import util::Resources;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import Set;
import Map;
import IO;
import String;
import Main;
import DataTypes;

import util::Editors;

import List;
import Map;
import Set;
import String;

public loc RootLocation = |browse://root|;
public loc BrowserLocation = RootLocation;
private loc SelectedLocation = BrowserLocation;
public str PathNormlizationPrefix = "/src";

private M3 _currentModel = createM3FromEclipseProject(|project://smallsql|);

alias BrowseTree = map[loc location, loc parent];

private list[void()] actionListeners = [];

public BrowseTree browseTree = ();

/*****************************/
/* Redraw panel				 */
/*****************************/
private bool _redraw = false;
private void redraw() { _redraw = true; }

/*****************************/
/* New Location Selected event */
/*****************************/
private list[void(M3, loc)] newLocationSelectedEventListeners = [];

/**
 * Adds an event listener for the new location selected event.
 */
public void pb_addNewLocationSelectedEventListener(void(M3, loc) listener) {
	if(indexOf(newLocationSelectedEventListeners, listener) == -1) {
		newLocationSelectedEventListeners += [listener];
	}
}

/**
 * Trigger the new method selected event listener.
 */
private void newLocationSelected(M3 model, loc location) {
	for(l <- newLocationSelectedEventListeners) l(model, location);
}

/**
 * Local event handler for selecting new location.
 */
private void onNewLocationSelected(M3 model, loc location) {
	pb_setLocation(location);
}

//private void projectBrowserUpdate() {
//	redraw();
//	for(l <- actionListeners) l();
//}

public M3 getCurrentModel() {
	return _currentModel;
}

public loc getSelectedLocation() {
	return SelectedLocation;
}

public void pb_setLocation(loc location) {
	if(location in browseTree){
		SelectedLocation = location;
		if(isMethod(location)) {
			BrowserLocation = browseTree[location];
		} else {
			BrowserLocation = location;
		}
		redraw();
	}
}

public BrowseTree createBrowseTree(set[M3] projectModels) {
	BrowseTree tree = ();
	
	for (model <- projectModels) {
		tree += createBrowseTree(model);	
	}

	return tree;
}

public Figure projectBrowser() {
	browseTree = createBrowseTree({_currentModel});
	
	pb_addNewLocationSelectedEventListener(onNewLocationSelected);
	
	return computeFigure(bool() { bool temp = _redraw; _redraw = false; return temp; }, Figure() {
	
		println("Current: " + BrowserLocation.path);
		println("Selected: " + SelectedLocation.path);
	
	    return box(vcat([
		box(createHeader(), vsize(20), vresizable(false)),
		box(vscrollable(createItems(), top()), std(fontSize(9)), lineWidth(0), top())		
	]), std(font("Dialog")), lineWidth(0));
	});
}

private Figure createHeader() {
	if (BrowserLocation == RootLocation) {
		int projectCount = size({ p | p <- invert(browseTree)[RootLocation], p != RootLocation });
		
		return box(
			text("<projectCount> project<projectCount == 1 ? "" : "s">", fontColor("white"), fontBold(true)),
			vresizable(false), height(40), lineWidth(0), fillColor(rgb(84,110,122))
		);
	}
	else {
		str label = getLabel(BrowserLocation);
		
		return box(hcat([
			backbutton(),	
			box(width(10), resizable(false)),		
			box(
				text(label, left(), size(20, 20), resizable(false), fontColor("white"), fontBold(true)),
				vresizable(false), height(40), lineWidth(0), fillColor(rgb(84,110,122))
			)
		]), left(), std(fillColor(rgb(84,110,122))), std(fontColor("White")));
	}
}

private Figure createItems() = vcat([ createItem(c) | c <- sort(invert(browseTree)[BrowserLocation]) ], vresizable(false), top());

private str getLabel(loc location) {
	str label = location.path;
	
	if (location.scheme == "java+package") {
		label = packageName(location.path);
	}
	else if (location.scheme == "java+compilationUnit") {
		label = location.file;
	}
	else if (location.scheme == "project" && location.path == "/") {
		label = location.authority;
	}
	else if (isMethod(location)) {
		label = /^<n:.*>\(.*$/ := location.file ? n : location.file;
		label += "()";
	}
	
	return label;
}

private Figure createItem(loc location) {

	str label = getLabel(location);
	
	return listItem(label, itemClickHandler(location));
	
	//return hcat(
	//[
	//	box(width(10), lineWidth(0), resizable(false)), 
	//	box(
	//		text(label, left(), fontSize(12)),		
	//		vresizable(false), 
	//		height(24), 
	//		onMouseDown(bool (int btn, map[KeyModifier,bool] modifiers) {
	//			loc child = location;
	//			if(isMethod(child)) {
	//				println(child);
	//				edit(child);
	//			}
	//			else {
	//				
	//				BrowserLocation = child;        	
	//				redraw();
	//			}
	//	    	
	//	    	return true;
	//		})
	//	,lineWidth(0))
	//], vsize(24), vresizable(false));
}

private bool(int, map[KeyModifier,bool]) itemClickHandler(loc location) = bool(int btn, map[KeyModifier,bool] mdf) {
	if(btn == 1) {
		newLocationSelected(_currentModel, location);
		//if(isMethod(location)){
		//	pb_setLocation(location);
		//	SelectedLocation = location;
		//} else {
		//	BrowserLocation = location;
		//}
		//projectBrowserUpdate();		
	}

	return true;
}; 

private Figure backbutton() {
	return box(
		text("", font("Segoe MDL2 Assets"), resizable(false), size(20, 20), left()),
		lineWidth(0),
		left(),
		resizable(false),
		onMouseDown(bool (int btn, map[KeyModifier,bool] modifiers) {
			newLocationSelected(_currentModel, browseTree[BrowserLocation]);
        	
       		return true;
    	})
	);
}

private map[loc location, loc parent] createBrowseTree(M3 model) {
	map[loc, loc] locationMap = (RootLocation:RootLocation);	
	loc project = cast(#loc, model[0]);
	set[loc] packages = packages(model);
	set[loc] units = files(model);
	set[loc] methods = methods(model);
	
	locationMap += (project:RootLocation);	
	locationMap += (package:project | package <- packages);
	locationMap += (unit:package | package <- packages, unit <- units, unit.path == PathNormlizationPrefix + package.path + "/" + unit.file);
	locationMap += (m:unit | unit <- units, m <- methods, normalizeUnitPath(unit) == normalizeMethodPath(m)); 
	
	return locationMap;
}

private str packageName(str path) = substring(replaceAll(path, "/", "."), 1);

private str normalizeUnitPath(loc location) {
	str path = location.path;
	str file = location.file;
	
	return substring(path, 0, findLast(path, "/")) + "/" + substring(file, 0, findLast(file, "."));
}

private str normalizeMethodPath(loc location) {
	str path = location.path;
	
	return PathNormlizationPrefix + substring(path, 0, findLast(path, "/"));
}

private &T cast(type[&T] t, value x) {
  	if (&T e := x) { 
    	return e;
 	}
 
  	throw "Invalid cast exception: <x> can not be matched to <t>.";
}
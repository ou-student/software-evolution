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
import DateTime;
import Set;
import String;
import Utils::CoreExtension;
import Utils::MetricsInformation;

private loc RootLocation = |browse://root|;
private loc CurrentProject = RootLocation;
private loc CurrentLocation = RootLocation;
private loc SelectedLocation = RootLocation;

public str PathNormlizationPrefix = "/src";

alias BrowseTree = map[loc location, loc parent];
private BrowseTree browseTree = ();



/*****************************/
/* Initializer				 */
/*****************************/
private bool _isInitialized = false;

public bool pb_initialize(bool force) {
	if(!_isInitialized || force) {
		browseTree = createBrowseTree();
		pb_addNewLocationSelectedEventListener(onNewLocationSelected);
		pb_addProjectRefreshRequestEventListener(onProjectRefreshRequest);
	
		pb_setLocation(RootLocation);
		
		_isInitialized = true;
		return true;
	}
	return false;
}

/*****************************/
/* Redraw panel				 */
/*****************************/
private bool _redraw = false;
private void redraw() { _redraw = true; }
private bool shouldRedraw() { bool temp = _redraw; _redraw = false; return temp; }

/*******************************/
/* New Location Selected event */
/*******************************/
private list[void(loc)] newLocationSelectedEventListeners = [];

/**
 * Adds an event listener for the new location selected event.
 */
public void pb_addNewLocationSelectedEventListener(void(loc) listener) {
	if(indexOf(newLocationSelectedEventListeners, listener) == -1) {
		newLocationSelectedEventListeners += [listener];
	}
}

/**
 * Trigger the new method selected event listener.
 */
private void newLocationSelected(loc location) {
	for(l <- newLocationSelectedEventListeners) l(location);
}

/**
 * Local event handler for selecting new location.
 */
private void onNewLocationSelected(loc location) {
	pb_setLocation(location);
}

/*********************************/
/* Project Refresh request event */
/*********************************/
private list[void(loc)] projectRefreshRequestEventListeners = [];

/**
 * Adds an event listener for the project refresh request event.
 */
public void pb_addProjectRefreshRequestEventListener(void(loc) listener) {	
	if(indexOf(projectRefreshRequestEventListeners, listener) == -1) {
		projectRefreshRequestEventListeners += [listener];
	}
}

/**
 * Trigger the project refresh request event listener.
 */
private void projectRefreshRequest(loc project) {
	for(l <- projectRefreshRequestEventListeners) l(project);
}

private void onProjectRefreshRequest(loc project) {
	println("Refreshing <project>");
}


/*********************************/
/* Module interface methods      */
/*********************************/
public void pb_setLocation(loc location) {
	if(location != SelectedLocation){
		if(location in browseTree){
			SelectedLocation = location;
			pb_navigateTo(browseTree[location]);

			redraw();
		}
	}
}

public void pb_navigateTo(loc location) {
	if(location != CurrentLocation){
		if(location in browseTree){
			CurrentLocation = location;
			CurrentProject = getProjectOfLocation(location);
			
			redraw();
		}
	}
}


/**
 * Constructs a projectBrowser panel
 */
public Figure projectBrowser() {
	pb_initialize(false);

	return computeFigure(shouldRedraw, Figure() {
		return grid([
			[createHeader()],
			[vscrollable(box(
				grid(createItems(), [top()]),
				std(fontColor(rgb(55,71,79))),
				top(),
				left(),
				resizable(false),
				lineWidth(0)			
			))]
		]);
	});	
}


/*********************************/
/* Private methods               */
/*********************************/
private Figure createHeader() {
	if (CurrentLocation == RootLocation) {
		int projectCount = size({ p | p <- invert(browseTree)[RootLocation], p != RootLocation });
		
		return box(
			text("<projectCount> project<projectCount == 1 ? "" : "s">", fontColor("white"), fontBold(true)),
			vresizable(false), height(40), lineWidth(0), fillColor(rgb(84,110,122))
		);
	}
	else {
		str label = getLabel(CurrentLocation);
		
		return box(hcat([
			backbutton(),	
			box(width(10), resizable(false), lineWidth(0)),		
			box(
				text(label, left(), size(20, 20), resizable(false), fontColor("white"), fontBold(true)),
				vresizable(false), height(40), lineWidth(0), fillColor(rgb(84,110,122))
			)
		]), left(), vresizable(false), lineWidth(0), height(40), std(fillColor(rgb(84,110,122))), std(fontColor("White")));
	}
}

private list[list[Figure]] createItems() = [ createItem(c) | c <- sort(invert(browseTree)[CurrentLocation]), c != RootLocation ];

private str getLabel(loc location) {
	str label = location.path;
	
	if (isPackage(location)) {		
		if (location.authority == "(default package)") {
			label = "(default package)";
		}
		else {
			label = packageName(location.path);
		}
	}
	else if (isCompilationUnit(location)) {
		label = location.file;
	}
	else if (isProject(location) && location.path == "/") {
		label = location.authority;
	}
	else if (isMethod(location) || isConstructor(location)) {
		//label = /^<n:.*>\(.*$/ := location.file ? n : location.file;
		//label += "()";
		label = location.file;
	}
	
	return label;
}


private list[FProperty] iconStyle = [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24) ];

private Figure constructorIcon = text("", iconStyle);
private Figure methodIcon = text("", iconStyle);
private Figure fileIcon = text("", iconStyle);
private Figure packageIcon = text("", iconStyle);
private Figure projectIcon = text("", iconStyle);
private Figure homeIcon = text("", iconStyle);
private Figure forwardIcon = text("", [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24), fontColor(rgb(38,50,56)), right()]);
private Figure refreshIcon = text("", [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24), fontColor(rgb(38,50,56)), right()]);

private map[str scheme, Figure icon] icons = (
	"java+compilationUnit":fileIcon,
	"java+package":packageIcon,
	"java+method":methodIcon,
	"java+constructor":constructorIcon,
	"project":projectIcon,
	"browse":homeIcon
);


private list[Figure] createItem(loc location) {
	str label = getLabel(location);
	
	//return listItem(label, itemClickHandler(location));
	FProperty fillColor = (SelectedLocation == location) ? fillColor(rgb(176,190,197)) : fillColor(rgb(250,250,250));
	FProperty fontColor = (SelectedLocation == location) ? fontColor("Black") : fontColor(rgb(55,71,79)); 
	Figure icon = isProject(location) ? refreshIcon : box(size(24, 24), resizable(false), fillColor, lineWidth(0));
	
	return [	
		box(	
	 		icons[location.scheme],
	 		lineWidth(0),
	 		resizable(false),	 		
	 		width(24),
	 		fillColor,
	 		onMouseDown(itemNavigateHandler(location))
	 	),
		box(
			text(label, left(), fontSize(12), fontColor),		
			vresizable(false),
			hresizable(true), 
			height(24), 
			onMouseDown(itemSelectHandler(location)), 
			lineWidth(0),	
			width(450),		
			top(),			
			fillColor
		),
		box(
			icon,
			fillColor,
	 		lineWidth(0),
	 		resizable(false),
	 		width(48),
	 		onMouseDown(itemRefreshClickHandler(location))		
		)	
	];
}

private bool(int, map[KeyModifier,bool]) itemSelectHandler(loc location) = bool(int btn, map[KeyModifier,bool] mdf) {
	if(btn == 1) {
		newLocationSelected(location);
	}

	return true;
}; 

private bool(int, map[KeyModifier,bool]) itemNavigateHandler(loc location) = bool(int btn, map[KeyModifier,bool] mdf) {
	if(btn == 1) {
		pb_navigateTo(location);
	}

	return true;
}; 

private bool(int, map[KeyModifier,bool]) itemRefreshClickHandler(loc location) = bool(int btn, map[KeyModifier,bool] mdf) {
	if(btn == 1) {
		if(isProject(location)) {
			projectRefreshRequest(location);
		}
	}
	return true;
};


private Figure backbutton() {
	return box(
		text("", font("Segoe MDL2 Assets"), resizable(false), size(20, 20), left()),
		lineWidth(0),
		left(),
		resizable(false),
		onMouseDown(backButtonClickHandler())
	);
}

private bool(int, map[KeyModifier,bool]) backButtonClickHandler() = bool(int btn, map[KeyModifier,bool] mdf) {
	if(btn == 1) {
		pb_navigateTo(browseTree[CurrentLocation]);
		redraw();
	}

	return true;
}; 

private BrowseTree createBrowseTree() {
	BrowseTree tree = ();
	
	for (m <- mi_getModels()) {
		tree += createBrowseTree(m);	
	}	
	
	return tree;
}

private map[loc location, loc parent] createBrowseTree(M3 model) {
	map[loc, loc] locationMap = (RootLocation:RootLocation);	
	loc project = cast(#loc, model[0]);
	
	print("Creating tree for <project>... ");
	
	set[loc] packages = packages(model);
	set[loc] units = files(model);
	set[loc] methods = methods(model);
	bool useDefaultPackage = false;
	
	// Create a default package if there are no packages.
	if (size(packages) == 0) {
		loc defaultPackage = |java+package://(default%20package)| + project.authority;		
		packages += { defaultPackage };
		useDefaultPackage = true;
	}
	
	locationMap += (project:RootLocation);	
	locationMap += (package:project | package <- packages);
	locationMap += (unit:package | package <- packages, unit <- units, useDefaultPackage ? true : unit.path == PathNormlizationPrefix + package.path + "/" + unit.file);	
	locationMap += (m:unit | unit <- units, m <- methods, normalizeUnitPath(unit) == normalizeMethodPath(m)); 
	
	println("Done");
	
	return locationMap;
}

private loc getProjectOfLocation(loc location){
	if(isProject(location) || location == RootLocation) return location;
	
	return getProjectOfLocation(browseTree[location]);
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
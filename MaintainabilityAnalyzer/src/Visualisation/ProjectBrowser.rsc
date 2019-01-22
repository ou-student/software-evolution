module Visualisation::ProjectBrowser

import Prelude;
import util::Resources;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import lang::java::jdt::m3::Core;
import Set;
import Map;
import IO;
import String;
import Main;
import DataTypes;

import List;
import Map;
import DateTime;
import Set;
import String;
import lang::java::jdt::m3::Core;

public loc RootLocation = |browse://root|;
public loc CurrentLocation = RootLocation;
public loc SelectedLocation = RootLocation;

public str PathNormlizationPrefix = "/src";

alias BrowseTree = map[loc location, loc parent];

private datetime clicked;
private bool firstClick = true;

public BrowseTree createBrowseTree(set[M3] projectModels) {
	
	
	BrowseTree tree = ();
	
	for (model <- projectModels) {
		tree += createBrowseTree(model);	
	}	
	
	return tree;
}

public Figure createBrowser(BrowseTree browseTree) {
	return computeFigure(bool() { return true; }, Figure() {
		return grid([
			[createHeader(browseTree)],
			[vscrollable(box(
				grid(createItems(browseTree), [top()]),
				std(fontColor(rgb(55,71,79))),
				top(),
				left(),
				resizable(false),
				lineWidth(0)			
			)
			)]
		]);
	});	
}

private Figure createHeader(BrowseTree browseTree) {
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
			backbutton(browseTree),	
			box(width(10), resizable(false)),		
			box(
				text(label, left(), size(20, 20), resizable(false), fontColor("white"), fontBold(true)),
				vresizable(false), height(40), lineWidth(0), fillColor(rgb(84,110,122))
			)
		]), left(), vresizable(false), height(40), std(fillColor(rgb(84,110,122))), std(fontColor("White")));
	}
}

private list[list[Figure]] createItems(BrowseTree browseTree) = [ createItem(c, browseTree) | c <- sort(invert(browseTree)[CurrentLocation]), c != RootLocation ];

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
	else if (location.scheme == "java+method" || location.scheme == "java+constructor") {
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

private map[str scheme, Figure icon] icons = (
	"java+compilationUnit":fileIcon,
	"java+package":packageIcon,
	"java+method":methodIcon,
	"java+constructor":constructorIcon,
	"project":projectIcon,
	"browse":homeIcon
);


private list[Figure] createItem(loc location, BrowseTree browseTree) {
	str label = getLabel(location);
	
	FProperty fillColor = (SelectedLocation == location) ? fillColor(rgb(176,190,197)) : fillColor(rgb(250,250,250));
	FProperty fontColor = (SelectedLocation == location) ? fontColor("Black") : fontColor(rgb(55,71,79)); 
	Figure icon = (location.scheme == "java+method" || location.scheme == "java+constructor") ? box(size(24, 24), resizable(false), fillColor, lineWidth(0)) : forwardIcon;
	
	return [	
		box(	
	 		icons[location.scheme],
	 		lineWidth(0),
	 		resizable(false),	 		
	 		width(24),
	 		fillColor
	 	),
		box(
			text(label, left(), fontSize(12), fontColor),		
			vresizable(false),
			hresizable(true), 
			height(24), 
			onMouseDown(bool (int btn, map[KeyModifier,bool] modifiers) {
				loc child = location;				
				SelectedLocation = child;
					
				return true;
			}), 
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
	 		onMouseDown(bool (int btn, map[KeyModifier,bool] modifiers) {
				loc child = location;				
				CurrentLocation = child;
					
				return true;
			})
		)	
	];
}


private Figure backbutton(BrowseTree browseTree) {
	return box(
		text("", font("Segoe MDL2 Assets"), resizable(false), size(20, 20), left()),
		lineWidth(0),
		left(),
		resizable(false),
		onMouseDown(bool (int btn, map[KeyModifier,bool] modifiers) {
       		CurrentLocation = browseTree[CurrentLocation];        	
       		
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
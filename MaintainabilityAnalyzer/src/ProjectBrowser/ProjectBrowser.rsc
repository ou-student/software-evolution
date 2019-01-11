module ProjectBrowser::ProjectBrowser

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

alias BrowserItem = tuple[str label, loc location];

alias ItemNode = tuple[str label, loc location];

private ItemNode currentItem;
private ItemNode rootItem;  
private ItemNode parentItem;

private M3 currentModel;

private set[loc] projectLocations;

public void renderBrowser() {
	projectLocations = projects();	
	
	ItemNode root = <"Overall maintainability (<size(projectLocations)> projects)", |browse://root|>;
	
	rootItem = root;
	currentItem = root;
	
	renderBrowser(rootItem);
}

private bool handleClick(ItemNode item) {
	println("click: <item>");	
	
	if (item.location.scheme == "java+compilationUnit") {
		return false;
	}
	else {	
		parentItem = currentItem;
		currentItem = item;
		renderBrowser(item);	
		
		return true;
	}
}

private str packageName(str path) = replaceFirst(replaceAll(path, "/", "."), ".", "");


public void renderBrowser(ItemNode parent) {
	list[Figure] items = [listItem(currentItem.label, bool(int btn, map[KeyModifier,bool] modifiers) {
		println(currentItem); 
		return true; 
	})];
	
	if (currentItem != rootItem) {
		ItemNode root = parentItem;
		
		items = [listItem(root.label, bool(int btn, map[KeyModifier,bool] modifiers) {			
			return handleClick(root); 
		})] + items;
	}
	
	for(ItemNode child <- children(currentItem)) {
		ItemNode current = child;
		items += box(text(child.label), resizable(false), width(200), onMouseDown( bool(int btn, map[KeyModifier,bool] modifiers) {
			return handleClick(current); 			
		}));	
	}
	
	render(hcat([vcat(items)], [height(100), resizable(false), left()]));	
}

private void initialize() {	
	projectLocations = projects();	
	
	
}

private list[ItemNode] children(ItemNode parent) {
	list[ItemNode] children = [];
	
	if (parent == rootItem) {
		children = [<p.authority, p> | p <- projectLocations];
	}
	else if (parent.location.scheme == "project") {
		currentModel = createM3FromEclipseProject(parent.location);		
		children = sort([ <packageName(p.path), p> | p <- packages(currentModel) ]);
	}
	else if (parent.location.scheme == "java+package") {
		children = [ <f.file, f> | f <- files(currentModel), path := f.path, path == ("/src" + parent.location.path + "/" + f.file) ];
	}
	
	return children;
}

private Figure createBrowserItem(loc project) {
	return listItem(project.authority, bool (int btn, map[KeyModifier,bool] x) { 
		currentItem = <project.authority, project>;
		return true;
	});
}

private Figure header(set[loc] projects) {	
	return listItem("Overall maintainability (<size(projects)> projects)");
}

private Figure listItem(str label) {
	return box(text(label), resizable(false), width(200), height(20), left());
}

private Figure listItem(str label, bool(int, map[KeyModifier, bool]) callback) {
	return box(text(label), resizable(false), width(200), height(20), left(), onMouseDown(callback));
}
module ProjectBrowser::ProjectBrowser

import Prelude;
import util::Resources;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import Set;
import Map;

alias BrowserItem = tuple[str label, loc location];

alias ItemNode = tuple[str label, loc location];

private ItemNode currentItem;

private set[loc] projectLocations;

private bool isInitialized = false;

public loc RootNode = |browse://root|;

public void reset() {
	isInitialized = false;
}


public void renderBrowser(ItemNode parent) {
	if (!isInitialized) {
		initialize();
	}
	
	list[Figure] items = [listItem(currentItem.label, bool(int btn, map[KeyModifier,bool] modifiers) {
		println(currentItem); 
		return true; 
	})];
	
	if (currentItem.location != RootNode) {
		ItemNode root = <"..", RootNode>;
		
		items = [listItem(root.label, bool(int btn, map[KeyModifier,bool] modifiers) {
			currentItem = root;
			println(currentItem);
			
			renderBrowser(currentItem);
			return true; 
		})] + items;
	}
	
	for(ItemNode child <- children(currentItem)) {
		ItemNode current = child;
		items += box(text(child.label), resizable(false), width(200), onMouseDown( bool(int btn, map[KeyModifier,bool] modifiers) {
			
			currentItem = current;
			println(currentItem);
			
			renderBrowser(currentItem);
			return true;
		}));	
	}
	
	render(hcat([vcat(items)], [height(100), resizable(false), left()]));	
}

private void initialize() {	
	projectLocations = projects();	
	
	ItemNode root = <"Overall maintainability (<size(projectLocations)> projects)", RootNode>;
	
	currentItem = root;
	
	isInitialized = true;
}

private list[ItemNode] children(ItemNode parent) {
	list[ItemNode] children = [];
	
	if (parent.location == RootNode) {
		children = [<p.authority, p> | p <- projectLocations];
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
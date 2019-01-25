module Tests::Visualisation::ProjectBrowserTests

import IO;
import Map;
import Visualisation::ProjectBrowser;
import lang::java::jdt::m3::Core;

test bool createBrowseTree_Adds_RootLocation() {
	M3 model = createM3FromEclipseProject(|project://HelloWorld|);
	
	map[loc, loc] actual = createBrowseTree({ model });

	return RootLocation in actual;
}

test bool createBrowseTree_Adds_Project_Location_With_RootLocation_As_Parent() {
	loc project = |project://HelloWorld|;
	M3 model = createM3FromEclipseProject(project);	
	
	map[loc, loc] actual = createBrowseTree({ model });
	
	return project in actual && actual[project] == RootLocation;
}

test bool createBrowseTree_Adds_Package_Locations_With_Project_Location_As_Parent() {
	loc project = |project://HelloWorld|;
	M3 model = createM3FromEclipseProject(project);	
	
	map[loc, loc] actual = createBrowseTree({ model });
	
	return
		|java+package:///| in actual && actual[|java+package:///|] == project && 
		|java+package:///com| in actual && actual[|java+package:///com|] == project &&
		|java+package:///com/srccodes| in actual && actual[|java+package:///com/srccodes|] == project &&
		|java+package:///com/srccodes/example| in actual && actual[|java+package:///com/srccodes/example|] == project;
}

// Add tests for units and methods.
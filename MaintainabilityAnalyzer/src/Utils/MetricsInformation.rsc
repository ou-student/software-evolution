module Utils::MetricsInformation

import Prelude;
import DataTypes;

import util::Resources;
import Utils::CoreExtension;

import analysis::graphs::Graph;
import lang::java::jdt::m3::Core;

import Extractors::LinesOfCodeExtractor;
import Extractors::DuplicationExtractor;
import Extractors::UnitSizeExtractor;
import Extractors::ComplexityExtractor;
import Analyzers::VolumeAnalyzer;
import Analyzers::UnitSizeAnalyzer;
import Analyzers::DuplicationAnalyzer;
import Analyzers::ComplexityAnalyzer;
import Analyzers::MaintainabilityScoreAnalyzer;

alias ProjectData = tuple[M3 model, UnitInfos unitInfos, set[LineCounts] lineCounts, Duplications duplications, Results results];
alias ProjectInformation = map[loc project, ProjectData information];
private ProjectInformation database = ();

private M3 global = m3(|browse://root|);
private UnitInfos globalUnitInfos = ();

private bool _isInitialized = false;

/**
 * Initializes the metrics information module.
 * @param force True to force a (re)initialization, false otherwise.
 * @return True if the module is initialized, false otherwise. 
 */
public bool mi_initialize(bool force) {
	if(!_isInitialized || force) {
		set[loc] projects = projects();
		
		for(p <- projects) {
	 
			if(checkCacheFile(p)) continue;
			
			createM3ModelAndAddToDatabase(p);
		}
		
		// Create a global M3 model for all projects
		global = composeJavaM3(|browse://root|,database.information.model);
		
		_isInitialized = true;
		return true;
	}
	return false;
}

/**
 * Checks whether a cache file exists for the specified project location.
 * @param project The location of the project.
 * @return True if a cache file exists, false otherwise.
 */
private bool checkCacheFile(loc project) {
	print("Check for existing metrics file...");
	
	try {
		loc temp = |tmp:///|;
		temp += project.authority;
		print(temp);
		ProjectData projectData = readBinaryValueFile(#ProjectData, temp);
		database[project] = projectData;
		
		// Add unitinfo to global map of unitinfos.
		globalUnitInfos += projectData.unitInfos;
		println(" FOUND");
	}
	catch: {
		println(" Not found");
		return false;
	}
	
	return true;
}

/**
 * Creates an M3 model instance adding it to project information database map.\
 * @param location The location of the project to create the M3 for.
 */
private void createM3ModelAndAddToDatabase(loc project) {
	print("Creating M3 for <project>...");
				
	try {
		if(project == |project://MaintainabilityAnalyzer|) throw "This project"; 
		M3 model = createM3FromEclipseProject(project);				
		database[project] = <model, (), {}, (), EmptyResults>;
		println(" Done");
	}
	catch: {
		println(" Skipped");
	}
}

/**
 * Refreshes the project metrics data for the specified project.
 * @param location The location of the project to refresh the metrics data for.
 */
public void mi_refreshProjectMetrics(loc project) {
	ProjectData projectData = database[project];
	Duplications duplications = ();
	
	set[LineCounts] lineCounts = {};
	
	for(decl <- projectData.model.declarations) {
		//if(contains(decl.src.path, "junit")) continue;
		//if(contains(decl.src.path, "/test/")) continue;
		
		if(isCompilationUnit(decl.name)) {
			lineCounts += extractLinesOfCode(decl.src);
		}
		
		if(isClass(decl.name)) {
			duplications = extractDuplications(decl.src, duplications, 6);
		}
		
		if(isMethod(decl.name) && !isAnonymous(decl.name)) {
			complexity = extractComplexity(decl.src);
			unitSize   = extractUnitSize(decl.src);
			
			projectData.unitInfos[decl.name] = <decl.name, unitSize, complexity>;
		}
	}
	
	VolumeAnalysisResult volumeAnalysisResult     	    = analyzeVolume(lineCounts);
	UnitSizeAnalysisResult unitSizeAnalysisResult 	    = analyzeUnitSize(projectData.unitInfos.info); 
	ComplexityAnalysisResult complexityAnalysisResult   = analyzeComplexity(projectData.unitInfos.info); 
	DuplicationAnalysisResult duplicationAnalysisResult = analyzeDuplications(duplications, volumeAnalysisResult.totalLinesOfCode);
	MaintainabilityScore maintainabilityScore 			= analyzeMaintainability(<volumeAnalysisResult.ranking, complexityAnalysisResult.ranking, duplicationAnalysisResult.ranking, unitSizeAnalysisResult.ranking, RankingUnknown>); 
	
	projectData.results = <volumeAnalysisResult,unitSizeAnalysisResult,complexityAnalysisResult,duplicationAnalysisResult,maintainabilityScore>;
	
	// Copy results over to database.
	projectData.lineCounts = lineCounts;
	projectData.duplications = duplications;
	
	database[project] = projectData;
	
	// Write to file
	loc temp = |tmp:///|;
	temp += project.authority;
	writeBinaryValueFile(temp ,projectData);
	
	// Add unitinfo to global map of unitinfos.
	globalUnitInfos += projectData.unitInfos;
}

/**
 * Returns all models in the information database.
 */
public set[M3] mi_getModels() = database.information.model;

/**
 * Gets the Results for the specified project.
 * @param project The location of the project to get the results for.
 * @returns A Results instance containing the project results.
 */
public Results mi_getResultsOfProject(loc project) {
	println(project);
	if(isProject(project)) return database[project].results;
	return EmptyResults;
}

/**
 * Returns a set of the successors of the given method.
 */
public set[loc] mi_getSuccessors(loc from) {
	return successors(global.methodInvocation, from);
}

/**
 * Returns a set of the predecessors of the given method.
 */
public set[loc] mi_getPredecessors(loc from) {
	return predecessors(global.methodInvocation, from);
}

/**
 * Gets the declaration associated with the specified location.
 * @param src The location to get the declaration for.
 * @returns The declaration location.
 */
public loc mi_getDeclaration(loc src) {
	try {
		return toMapUnique(global.declarations)[src];
	}
	catch: {
		return NotFound;
	}
}

/**
 * Gets the line counts for the specified method location.
 * @param method The location of the method.
 * @returns The LineCounts for the method.
 */
public LineCounts mi_getLineCountsForMethod(loc method) {
	if(isMethod(method)) {
		return extractLinesOfCode(method);
	}
	return <NotFound,0,0,0,0>;
}

/**
 * Gets the unit complexity for the specified location.
 * @param location The location to get the complexity for.
 * @returns An integer representing the complexity, or -1 if the complexity is not available.
 */
public int mi_getUnitComplexity(loc location) {
	int complexity = -1;

	if(isMethod(location)) {		
		try{
			complexity = globalUnitInfos[location].complexity;
		}
		catch: {
			println("Method <location> not found, might not have been initalized..");
		}	
	}
	
	return complexity;
}

/**
 * Gets the number of lines of code for the specified location.
 * @param location The location to get the lines of code for.
 * @returns An integer representing the number of lines of code, or -1 if loc is not available.
 */
public int mi_getUnitLOC(loc location) {
	int LOC = -1;

	if(isMethod(location)) {		
		try{
			LOC = globalUnitInfos[location].size;
		}
		catch: {
			println("Method <location> not found, might not have been initalized..");
		}	
	}
	
	return LOC;
}

/**
 * Gets the UnitInfo for the specified location.
 * @param location The location to get the UnitInfo for.
 * @returns The unit info for the specified location.
 */
public UnitInfo mi_getUnitInfo(loc location) {	
	UnitInfo retval = <NotFound, 0, 0>;

	if(isMethod(location)) {		
		try{
			retval = globalUnitInfos[location];
		}
		catch: {
			println("Method <location> not found, might not have been initalized..");
		}	
	}
	
	return retval;	
}


public void testModule() {
	mi_initializeProjects();
	
	mi_refreshProjectMetrics(|project://JabberPoint|);
	
}

private &T cast(type[&T] t, value x) {
  	if (&T e := x) { 
    	return e;
 	}
 
  	throw "Invalid cast exception: <x> can not be matched to <t>.";
}
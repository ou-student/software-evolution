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

alias ProjectData = tuple[M3 model, UnitInfos unitInfos, set[LineCounts] lineCounts, Results results];
alias ProjectInformation = map[loc project, ProjectData information];
private ProjectInformation database = ();

private M3 global = m3(|browse://root|);
private UnitInfos globalUnitInfos = ();

private bool _isInitialized = false;

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

private void createM3ModelAndAddToDatabase(loc project) {
	print("Creating M3 for <project>...");
				
	try {
		if(project == |project://MaintainabilityAnalyzer|) throw "This project"; 
		M3 model = createM3FromEclipseProject(project);				
		database[project] = <model, (), {}, EmptyResults>;
		println(" Done");
	}
	catch: {
		println(" Skipped");
	}
}

public void mi_refreshProjectMetrics(loc project) {

	ProjectData projectData = database[project];
	
	set[LineCounts] lineCounts = {};
	
	for(decl <- projectData.model.declarations) {
		
		if(isCompilationUnit(decl.name)) {
			lineCounts += extractLinesOfCode(decl.src);
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
	DuplicationAnalysisResult duplicationAnalysisResult = analyzeDuplications((), volumeAnalysisResult.totalLinesOfCode);
	MaintainabilityScore maintainabilityScore 			= analyzeMaintainability(<volumeAnalysisResult.ranking, complexityAnalysisResult.ranking, duplicationAnalysisResult.ranking, unitSizeAnalysisResult.ranking, RankingUnknown>); 
	
	projectData.results = <volumeAnalysisResult,unitSizeAnalysisResult,complexityAnalysisResult,duplicationAnalysisResult,maintainabilityScore>;
	
	// Copy results over to database.
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
 * Returs a set of the successors of the given method.
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

public loc mi_getDeclaration(loc src) {
	try {
		return toMapUnique(global.declarations)[src];
	}
	catch: {
		return |unknown:///|;
	}
}

public LineCounts mi_getLineCountsForMethod(loc method) {
	if(isMethod(method)) {
		return extractLinesOfCode(method);
	}
	return <|unknown:///|,0,0,0,0>;
}

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

public UnitInfo mi_getUnitInfo(loc location) {
	
	UnitInfo retval = <|unknown:///|, 0, 0>;

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
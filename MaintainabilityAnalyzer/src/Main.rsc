module Main

import DataTypes;
import IO;
import Map;
import Set;
import Extractors::LinesOfCodeExtractor;
import Extractors::DuplicationExtractor;
import Extractors::UnitSizeExtractor;
import Extractors::ComplexityExtractor;
import Analyzers::VolumeAnalyzer;
import Analyzers::UnitSizeAnalyzer;
import Analyzers::DuplicationAnalyzer;
import Analyzers::ComplexityAnalyzer;
import lang::java::jdt::m3::Core;
import String;
import List;
import DateTime;
import Utils::Normalizer;
import Utils::CoreExtension;
import Utils::ResultPrinter;

public void run(loc project) {
	// Create new model from project file.
	M3 model = createM3FromEclipseProject(project);
	
	// Instantiate required objects
	Duplications duplicates = ();
	UnitInfos unitInfos = {};
	set[LineCounts] lineCounts = {};

	// run metrics on compilation units and methods.
	for(x <- model.declarations) {
		// skip if code is part of unittests.
		if(contains(x.src.path, "junit")) continue;
	
		// If file:
		if(isCompilationUnit(x.name)) {
			lineCounts += extractLinesOfCode(x.src);			
		}
		
		// If class:
		if(isClass(x.name)) {
			// Extract duplicates
			duplicates = extractDuplications(x.src, duplicates, 6);
		}
		
		// If method:
		if(isMethod(x.name) && !isAnonymous(x.name)) {			
			complexity = extractComplexity(x.src);
			unitSize   = extractUnitSize(x.src);
			
			unitInfos += <x.src, unitSize, complexity>;
		}
	}
	
	VolumeAnalysisResult volumeAnalysisResult     	    = analyzeVolume(lineCounts);
	UnitSizeAnalysisResult unitSizeAnalysisResult 	    = analyzeUnitSize(unitInfos); 
	ComplexityAnalysisResult complexityAnalysisResult   = analyzeComplexity(unitInfos); 
	DuplicationAnalysisResult duplicationAnalysisResult = analyzeDuplications(duplicates, volumeAnalysisResult.totalLinesOfCode);
	
	Results results = <volumeAnalysisResult,unitSizeAnalysisResult,complexityAnalysisResult,duplicationAnalysisResult>;
	
	printResults(results, project.uri);
	
}

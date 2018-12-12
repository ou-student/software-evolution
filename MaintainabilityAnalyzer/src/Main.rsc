module Main

import DataTypes;
import IO;
import Map;
import Set;
import Extractors::LinesOfCodeExtractor;
import Extractors::DuplicationExtractor;
import Analyzers::VolumeAnalyzer;
import Analyzers::UnitSizeAnalyzer;
import lang::java::jdt::m3::Core;
import String;
import List;
import DateTime;
import Utils::Normalizer;
import Utils::CoreExtension;

public void run(loc project) {
	// Create new model from project file.
	M3 model = createM3FromEclipseProject(project);
	
	// Instantiate required objects
	Duplications duplicates = ();
	set[LineCounts] lineCounts = {};

	// run metrics on compilation units and methods.
	for(x <- model.declarations) {
		// If file:
		if(isCompilationUnit(x.name)) {
			lineCounts += extractLinesOfCode(x.src);
		}
		
		// If method:
		if(isMethod(x.name) && !isAnonymous(x.name)) {
			// Normalize file
			linesOfCode = normalizeFile(x.src);
			
			// Extract duplicates
			duplicates = extractDuplications(linesOfCode, duplicates, 6);
		}
	}
	
	VolumeAnalysisResult volumeAnalysisResult = analyzeVolume(lineCounts);
	
	println("VOLUME RANKING");
	println();
	println("Total <volumeAnalysisResult.totalLinesOfCode> lines of which:");
	println("<volumeAnalysisResult.codeLines> lines of code");
	println("<volumeAnalysisResult.commentLines> comment lines");
	println("<volumeAnalysisResult.blankLines> blank lines");
	println();
	println("Calculated volume ranking: <volumeAnalysisResult.ranking.rank> (<volumeAnalysisResult.ranking.label>)");
	
	
}

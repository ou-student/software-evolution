module Main

import DataTypes;
import IO;
import Map;
import Set;
import Extractors::LinesOfCodeExtractor;
import Extractors::DuplicationExtractor;
import Analyzers::VolumeAnalyzer;
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
	totalLoc = 0;
	totalLoc2 = 0;

	// run metrics on compilation units and methods.
	for(x <- model.declarations) {
		// If file:
		if(isCompilationUnit(x.name)) {
			linesOfCode = normalizeFile(x.src);
			unitLoc = size(linesOfCode);
			totalLoc += unitLoc;
			println(x.src);
		}
		
		// If method:
		if(isMethod(x.name) && !isAnonymous(x.name)) {
			// Normalize file
			linesOfCode = normalizeFile(x.src);
			totalLoc2 += size(linesOfCode);
			
			// Extract duplicates
			duplicates = extractDuplications(linesOfCode, duplicates, 6);
		}
	}
	
	
	//totalLOC = sum(LOCPerFile.LOC);
	//print(totalLOC);
	
	set[LineCounts] lineCounts2 = { extractLinesOfCode(f) | f <- files(model) };
	
	//for (x <- lineCounts) {
	//	println("<x.location>:");
	//	println("- Code: \t<x.code>");
	//	println("- Comment:\t<x.comment>");
	//	println("- Blank:\t<x.blank>");
	//	println("- Total:\t<x.total>");
	//	println();
	//}
	
	println("Total LOC(cu): <totalLoc>");
	println("Total LOC(m) : <totalLoc2>");
	println("Calculated volume ranking: <analyzeVolume(lineCounts)>");
	println("Calculated volume ranking: <analyzeVolume(lineCounts2)>");
}

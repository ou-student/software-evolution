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
import Utils::Normalizer;

public void run(loc project) {
	M3 model = createM3FromEclipseProject(project);
	
	Duplications duplicates = ();
	
	for(x <- model.declarations) {
		// If file:
		//if(isCompilationUnit(x.name)) println(readFile(x.src));
		
		// If method:
		if(isMethod(x.name)) {
			//duplicates = extractDuplications(x.src, duplicates);
			
			linesOfCode = normalizeFile(x.src);
			duplicates = extractDuplications(linesOfCode, duplicates);
		}
	}
	
	
	//totalLOC = sum(LOCPerFile.LOC);
	//print(totalLOC);
	
	//set[LineCounts] lineCounts = { extractLinesOfCode(f) | f <- files(model) };
	//
	//for (x <- lineCounts) {
	//	println("<x.location>:");
	//	println("- Code: \t<x.code>");
	//	println("- Comment:\t<x.comment>");
	//	println("- Blank:\t<x.blank>");
	//	println("- Total:\t<x.total>");
	//	println();
	//}
	//
	//println("Calculated volume ranking: <analyzeVolume(lineCounts)>");
}

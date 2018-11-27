module Main

import DataTypes;
import IO;
import Set;
import Extractors::LinesOfCodeExtractor;
import Analyzers::VolumeAnalyzer;
import lang::java::jdt::m3::Core;

public void run(loc project) {
	M3 model = createM3FromEclipseProject(project);
	
	set[LineCounts] volume = extractLinesOfCode(model);
	
	for (x <- volume) {
		println("<x.location>:");
		println("- Code: \t<x.code>");
		println("- Comment:\t<x.comment>");
		println("- Blank:\t<x.blank>");
		println("- Total:\t<x.total>");
		println();
	}
	
	println("Calculated volume ranking: <analyzeVolume(volume)>");
}

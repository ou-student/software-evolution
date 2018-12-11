module Main

import DataTypes;
import IO;
import Map;
import Set;
import Extractors::LinesOfCodeExtractor;
import Extractors::DuplicationExtractor;
import Extractors::UnitSizeExtractor;
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
	println(left("", 80, "-"));
	UnitSizes unitSizes = extractUnitSizes(methods(model));
	UnitSizeAnalysisResult unitSizeAnalysisResult = analyzeUnitSize(unitSizes); 
	RiskEvaluation unitSizeRisk = unitSizeAnalysisResult.risk;
	
	println("UNIT SIZE RANKING");
	println();
	println("Total <unitSizeAnalysisResult.unitsCount> units of which:");
	printRiskCategory(RiskCategories.veryHigh, unitSizeRisk);
	printRiskCategory(RiskCategories.high, unitSizeRisk);
	printRiskCategory(RiskCategories.moderate, unitSizeRisk);
	printRiskCategory(RiskCategories.low, unitSizeRisk);	
	println();
	println("Calculated unit size ranking: <unitSizeAnalysisResult.ranking.rank> (<unitSizeAnalysisResult.ranking.label>)");
	println(left("", 80, "-"));
	
}

private void printRiskCategory(RiskCategory riskCategory, RiskEvaluation evaluation) {
	if (riskCategory in evaluation) {
		RiskValues values = evaluation[riskCategory];
		
		println("<left(riskCategory.risk + "(" + riskCategory.category + ")", 30)>\t <values.percentage> % (totalling <values.linesOfCode> lines of code)");
	}
}

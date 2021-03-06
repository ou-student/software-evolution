module Utils::ResultPrinter

import Prelude;
import DataTypes;

public void printResults(Results results, str projectName) {
	separator("=");
	println(left("=== Results for project: <projectName> ", 80, "="));
	separator("=");
	
	heading("VOLUME RANKING");	
	println("Total <results.volume.totalLinesOfCode> lines of which:");
	println("<results.volume.codeLines> lines of code");
	println("<results.volume.commentLines> comment lines");
	println("<results.volume.blankLines> blank lines");
	println();
	println("Calculated volume ranking: <results.volume.ranking.rank> (<results.volume.ranking.label>)");
	separator("-");
	
	heading("UNIT SIZE RANKING");	
	println("Total <results.unitSize.unitsCount> units of which:");
	printRiskCategory(RiskCategories.veryHigh,  results.unitSize.risk, false);
	printRiskCategory(RiskCategories.high,  	results.unitSize.risk, false);
	printRiskCategory(RiskCategories.moderate,  results.unitSize.risk, false);
	printRiskCategory(RiskCategories.low,  		results.unitSize.risk, false);	
	println();
	println("Calculated unit size ranking: <results.unitSize.ranking.rank> (<results.unitSize.ranking.label>)");
	separator("-");
		
	heading("COMPLEXITY RANKING");	
	println("Total <results.complexity.unitsCount> units of which:");
	printRiskCategory(RiskCategories.veryHigh, 	results.complexity.risk, false);
	printRiskCategory(RiskCategories.high, 		results.complexity.risk, false);
	printRiskCategory(RiskCategories.moderate, 	results.complexity.risk, false);
	printRiskCategory(RiskCategories.low, 		results.complexity.risk, false);	
	println();
	println("Calculated complexity ranking: <results.complexity.ranking.rank> (<results.complexity.ranking.label>)");
	separator("-");
	
	heading("DUPLICATIONS RANKING");	
	println("<results.duplicates.duplicateLines> of <results.duplicates.totalLinesOfCode> lines are duplicate: <results.duplicates.percentage>%");
	println("Calculated duplications ranking: <results.duplicates.ranking.rank> (<results.duplicates.ranking.label>)");
	separator("-");
	
	heading("SYSTEM MAINTAINABILITY RANKING");
	printAspect(MaintainabilityAspects.analyzability, results.score);
	printAspect(MaintainabilityAspects.changeability, results.score);
	printAspect(MaintainabilityAspects.stability, results.score);
	printAspect(MaintainabilityAspects.testability, results.score);
	println();
	println("Overall maintainability ranking: <results.score.overall.rank> (<results.score.overall.label>)");	
}

private void heading(str heading) {
	println();
	println(heading);
	println();
}

private void separator(str repeat) { 
	println(left("", 80, repeat));
}

private void printRiskCategory(RiskCategory riskCategory, RiskEvaluation evaluation, bool showFilesForCategory) {
	if (riskCategory in evaluation) {
		RiskValues values = evaluation[riskCategory];
		
		println("<left(riskCategory.risk + " (" + riskCategory.category + ")", 30)> <values.percentage> % (totalling <values.linesOfCode> lines of code in <size(values.units)> units)");
		
		if(showFilesForCategory) {
			for(unit <- values.units) println("\t - <unit.unit>");
			println();
		}
	}
}

private void printAspect(str aspect, MaintainabilityScore score) = println("<left(aspect, 20)><score.aspects[aspect].rank> (<score.aspects[aspect].label>)");
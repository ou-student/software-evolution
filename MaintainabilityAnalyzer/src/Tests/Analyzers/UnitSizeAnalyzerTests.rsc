module Tests::Analyzers::UnitSizeAnalyzerTests

import Analyzers::UnitSizeAnalyzer;
import DataTypes;
import Set;
import Relation;

test bool analyzeUnitSize_Correctly_Determines_Calculates_LinesOfCode() {
	UnitSizes counts = {
		<|project://test/small1.java|, 10>,
		<|project://test/small2.java|, 15>,			
		<|project://test/medium1.java|, 25>,		
		<|project://test/large.java|, 50>,
		<|project://test/verylarge.java|, 100>				
	};	
	
	UnitSizeAnalysisResult actual = analyzeUnitSize(counts);
	
	return actual.risk[RiskCategories.low].linesOfCode == 25 &&
		actual.risk[RiskCategories.moderate].linesOfCode == 25 &&
		actual.risk[RiskCategories.high].linesOfCode == 50 &&
		actual.risk[RiskCategories.veryHigh].linesOfCode == 100;
}

test bool analyzeUnitSize_Correctly_Calculates_UnitCounts() {
	UnitSizes counts = {
		<|project://test/small1.java|, 10>,
		<|project://test/small2.java|, 15>,
		<|project://test/small3.java|, 10>,
		<|project://test/small4.java|, 15>,
		<|project://test/small5.java|, 10>,
		<|project://test/small6.java|, 15>,
		<|project://test/small7.java|, 10>,
		<|project://test/small8.java|, 15>,					
		<|project://test/medium1.java|, 25>,
		<|project://test/medium2.java|, 25>,
		<|project://test/medium3.java|, 25>,
		<|project://test/medium4.java|, 25>,		
		<|project://test/large.java|, 50>,
		<|project://test/large2.java|, 50>,
		<|project://test/verylarge.java|, 100>				
	};
		
	UnitSizeAnalysisResult actual = analyzeUnitSize(counts);
	
	return actual.risk[RiskCategories.low].unitCount == 8 &&
		actual.risk[RiskCategories.moderate].unitCount == 4 && 
		actual.risk[RiskCategories.high].unitCount == 2 &&
		actual.risk[RiskCategories.veryHigh].unitCount == 1;
}


test bool analyzeUnitSize_Correctly_Calculates_Percentages() {
	UnitSizes counts = {
		<|project://test/small1.java|, 10>,
		<|project://test/small2.java|, 15>,
		<|project://test/small3.java|, 10>,
		<|project://test/small4.java|, 15>,
		<|project://test/small5.java|, 10>,
		<|project://test/small6.java|, 15>,
		<|project://test/small7.java|, 10>,
		<|project://test/small8.java|, 15>,					
		<|project://test/medium1.java|, 25>,
		<|project://test/medium2.java|, 25>,
		<|project://test/medium3.java|, 25>,
		<|project://test/medium4.java|, 25>,		
		<|project://test/large.java|, 50>,
		<|project://test/large2.java|, 50>,
		<|project://test/verylarge.java|, 100>				
	};
	
	UnitSizeAnalysisResult result = analyzeUnitSize(counts);
	RiskEvaluation actual = result.risk;	
		
	return actual[RiskCategories.low].percentage == 25 &&
		actual[RiskCategories.moderate].percentage == 25 && 
		actual[RiskCategories.high].percentage == 25 &&
		actual[RiskCategories.veryHigh].percentage == 25;
}

test bool analyzeUnitSize_Correctly_Calculates_VeryHigh_Rank() {
	// Test line counts with 0% very high risk, 0% high risk, 25% moderate risk.
	UnitSizes counts = {
		<|project://test/small1.java|, 10>,
		<|project://test/small2.java|, 15>,
		<|project://test/small3.java|, 10>,
		<|project://test/small4.java|, 15>,
		<|project://test/small5.java|, 10>,
		<|project://test/small6.java|, 15>,					
		<|project://test/medium1.java|, 25>
	};
	
	UnitSizeAnalysisResult actual = analyzeUnitSize(counts);
	
	return actual.ranking == Rankings.veryHigh;
}

test bool analyzeUnitSize_Correctly_Calculates_High_Rank() {
	loc baseLoc = |project://test|;
	// Generate test line counts with 0% very high risk, 5% high risk, 30% low risk.
	UnitSizes counts = { <(baseLoc + "small<x>.java"), 10> | x <- [0..65] };
	counts += { <(baseLoc + "medium<x>.java"), 25> | x <- [0..12] };
	counts += { <(baseLoc + "large<x>.java"), 50> | x <- [0..1] };
	
	UnitSizeAnalysisResult actual = analyzeUnitSize(counts);
	
	return actual.ranking == Rankings.high;
}

test bool analyzeUnitSize_Correctly_Calculates_Moderate_Rank() {
	loc baseLoc = |project://test|;
	// Generate test line counts with 0% very high risk, 10% high risk, 40% moderate risk.
	UnitSizes counts = { <(baseLoc + "small<x>.java"), 10> | x <- [0..50] };
	counts += { <(baseLoc + "medium<x>.java"), 25> | x <- [0..16] };
	counts += { <(baseLoc + "large<x>.java"), 50> | x <- [0..2] };
	
	UnitSizeAnalysisResult actual = analyzeUnitSize(counts);
	
	return actual.ranking == Rankings.moderate;
}

test bool analyzeUnitSize_Correctly_Calculates_Low_Rank() {
	loc baseLoc = |project://test|;
	// Generate test line counts with 5% very high risk, 15% high risk, 50% moderate risk.
	UnitSizes counts = { <(baseLoc + "small<x>.java"), 10> | x <- [0..60] };
	counts += { <(baseLoc + "medium<x>.java"), 25> | x <- [0..40] };
	counts += { <(baseLoc + "large<x>.java"), 50> | x <- [0..6] };	
	counts += { <|project://test/verylarge.java|, 100>	};
	
	UnitSizeAnalysisResult actual = analyzeUnitSize(counts);
	
	return actual.ranking == Rankings.low;
}

test bool analyzeUnitSize_Correctly_Calculates_VeryLow_Rank() {
	loc baseLoc = |project://test|;
	// Generate test line counts with > 5% very high risk, 15% high risk, 50% moderate risk.
	UnitSizes counts = { <(baseLoc + "small<x>.java"), 10> | x <- [0..60] };
	counts += { <(baseLoc + "medium<x>.java"), 25> | x <- [0..40] };
	counts += { <(baseLoc + "large<x>.java"), 50> | x <- [0..7] };	
	counts += { <|project://test/verylarge.java|, 100>	};
	
	UnitSizeAnalysisResult actual = analyzeUnitSize(counts);
	
	return actual.ranking == Rankings.veryLow;
}
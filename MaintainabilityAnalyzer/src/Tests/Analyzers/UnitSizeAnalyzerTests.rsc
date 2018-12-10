module Tests::Analyzers::UnitSizeAnalyzerTests

import Analyzers::UnitSizeAnalyzer;
import DataTypes;
import Set;
import Relation;

test bool analuzeUnitSize_Correctly_Determines_Risk_Categories() {
	set[LineCounts] counts = {
		<|project://test/small1.java|, 10, 0, 0, 0>,
		<|project://test/small2.java|, 15, 0, 0, 0>,			
		<|project://test/medium1.java|, 25, 0, 0, 0>,		
		<|project://test/large.java|, 50, 0, 0, 0>,
		<|project://test/verylarge.java|, 100, 0, 0, 0>				
	};	
	
	tuple[Rank ranking, RiskEvaluation risk] actual = analyzeUnitSize(counts);
	
	return actual.risk[RiskCategories.low].linesOfCode == 25 &&
		actual.risk[RiskCategories.moderate].linesOfCode == 25 &&
		actual.risk[RiskCategories.high].linesOfCode == 50 &&
		actual.risk[RiskCategories.veryHigh].linesOfCode == 100;
}

test bool determineRiskClassifications_Correctly() {
	set[LineCounts] counts = {
		<|project://test/small1.java|, 10, 0, 0, 0>,
		<|project://test/small2.java|, 15, 0, 0, 0>,
		<|project://test/small3.java|, 10, 0, 0, 0>,
		<|project://test/small4.java|, 15, 0, 0, 0>,
		<|project://test/small5.java|, 10, 0, 0, 0>,
		<|project://test/small6.java|, 15, 0, 0, 0>,
		<|project://test/small7.java|, 10, 0, 0, 0>,
		<|project://test/small8.java|, 15, 0, 0, 0>,					
		<|project://test/medium1.java|, 25, 0, 0, 0>,
		<|project://test/medium2.java|, 25, 0, 0, 0>,
		<|project://test/medium3.java|, 25, 0, 0, 0>,
		<|project://test/medium4.java|, 25, 0, 0, 0>,		
		<|project://test/large.java|, 50, 0, 0, 0>,
		<|project://test/large2.java|, 50, 0, 0, 0>,
		<|project://test/verylarge.java|, 100, 0, 0, 0>				
	};
		
	tuple[Rank ranking, RiskEvaluation risk] actual = analyzeUnitSize(counts);
	
	return actual.risk[RiskCategories.low].unitCount == 8 &&
		actual.risk[RiskCategories.moderate].unitCount == 4 && 
		actual.risk[RiskCategories.high].unitCount == 2 &&
		actual.risk[RiskCategories.veryHigh].unitCount == 1;
}

test bool analyzeUnitSize_Correctly_Calculates_UnitCounts() {
set[LineCounts] counts = {
		<|project://test/small1.java|, 10, 0, 0, 0>,
		<|project://test/small2.java|, 15, 0, 0, 0>,
		<|project://test/small3.java|, 10, 0, 0, 0>,
		<|project://test/small4.java|, 15, 0, 0, 0>,
		<|project://test/small5.java|, 10, 0, 0, 0>,
		<|project://test/small6.java|, 15, 0, 0, 0>,
		<|project://test/small7.java|, 10, 0, 0, 0>,
		<|project://test/small8.java|, 15, 0, 0, 0>,					
		<|project://test/medium1.java|, 25, 0, 0, 0>,
		<|project://test/medium2.java|, 25, 0, 0, 0>,
		<|project://test/medium3.java|, 25, 0, 0, 0>,
		<|project://test/medium4.java|, 25, 0, 0, 0>,		
		<|project://test/large.java|, 50, 0, 0, 0>,
		<|project://test/large2.java|, 50, 0, 0, 0>,
		<|project://test/verylarge.java|, 100, 0, 0, 0>				
	};
	
	tuple[Rank ranking, RiskEvaluation risk] actual = analyzeUnitSize(counts);
	
	return actual.risk[RiskCategories.low].unitCount == 8 &&
		actual.risk[RiskCategories.moderate].unitCount == 4 && 
		actual.risk[RiskCategories.high].unitCount == 2 &&
		actual.risk[RiskCategories.veryHigh].unitCount == 1;
}

test bool analyzeUnitSize_Correctly_Calculates_Percentages() {
set[LineCounts] counts = {
		<|project://test/small1.java|, 10, 0, 0, 0>,
		<|project://test/small2.java|, 15, 0, 0, 0>,
		<|project://test/small3.java|, 10, 0, 0, 0>,
		<|project://test/small4.java|, 15, 0, 0, 0>,
		<|project://test/small5.java|, 10, 0, 0, 0>,
		<|project://test/small6.java|, 15, 0, 0, 0>,
		<|project://test/small7.java|, 10, 0, 0, 0>,
		<|project://test/small8.java|, 15, 0, 0, 0>,					
		<|project://test/medium1.java|, 25, 0, 0, 0>,
		<|project://test/medium2.java|, 25, 0, 0, 0>,
		<|project://test/medium3.java|, 25, 0, 0, 0>,
		<|project://test/medium4.java|, 25, 0, 0, 0>,		
		<|project://test/large.java|, 50, 0, 0, 0>,
		<|project://test/large2.java|, 50, 0, 0, 0>,
		<|project://test/verylarge.java|, 100, 0, 0, 0>				
	};
	
	tuple[Rank ranking, RiskEvaluation risk] result = analyzeUnitSize(counts);
	RiskEvaluation actual = result.risk;	
		
	return actual[RiskCategories.low].percentage == 25 &&
		actual[RiskCategories.moderate].percentage == 25 && 
		actual[RiskCategories.high].percentage == 25 &&
		actual[RiskCategories.veryHigh].percentage == 25;
}
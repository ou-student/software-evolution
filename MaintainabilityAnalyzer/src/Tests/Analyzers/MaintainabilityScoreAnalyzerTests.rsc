module Tests::Analyzers::MaintainabilityScoreAnalyzerTests

import Analyzers::MaintainabilityScoreAnalyzer;
import DataTypes;

test bool analyzeMaintainability_Correctly_Calculates_Analyzability_Ranking() {
	MetricRankings rankings = <Rankings.veryHigh, Rankings.veryLow, Rankings.low, Rankings.low, Rankings.moderate>;	
	MaintainabilityScore actual = analyzeMaintainability(rankings);
	
	return
		actual.overall == Rankings.low && 
		actual.aspects[MaintainabilityAspects.analyzability] == Rankings.moderate &&
		actual.aspects[MaintainabilityAspects.changeability] == Rankings.low &&
		actual.aspects[MaintainabilityAspects.stability] == RankingUnknown && // We don't take this one into account, it has no use as we don't have unit test coverage data. 
		actual.aspects[MaintainabilityAspects.testability] == Rankings.low;	
}
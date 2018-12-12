module Analyzers::MaintainabilityScoreAnalyzer

import DataTypes;
import List;

/**
 * Analyzes the overall system maintainability ranking including mapping the system level scores for maintainability aspects to averaged rankings.
 * @param rankings The MetricRankings to analyze maintainability scores for.
 **/
public MaintainabilityScore analyzeMaintainability(MetricRankings rankings) {
	Rank analyzability = calculateAspectRanking(MaintainabilityAspects.analyzability, rankings);
	Rank changeability = calculateAspectRanking(MaintainabilityAspects.changeability, rankings);
	Rank stability = calculateAspectRanking(MaintainabilityAspects.stability, rankings);	
	Rank testability = calculateAspectRanking(MaintainabilityAspects.testability, rankings);
	Rank overall = calculateOverallRanking([analyzability, changeability, stability, testability]);
	
	return <overall, (
		MaintainabilityAspects.analyzability:analyzability,
		MaintainabilityAspects.changeability:changeability,
		MaintainabilityAspects.stability:stability,
		MaintainabilityAspects.testability:testability)>;
}

private Rank calculateOverallRanking(list[Rank] rankings) {
	int sum = sum([x | x <- rankings.weight]);
	int count = size(rankings);
	num ranking = (0.00 + sum) / (0.00 + count);
	
	return calculateRank(ranking);	
}

private Rank calculateAspectRanking(str aspect, MetricRankings rankings) {
	int count = 1;
	int sum = 0;
	
	if (aspect == MaintainabilityAspects.analyzability) {
		sum = rankings.volume.weight + rankings.duplication.weight + rankings.unitSize.weight;
		count = 3;
	}
	else if (aspect == MaintainabilityAspects.changeability) {
		sum = rankings.complexity.weight + rankings.duplication.weight;
		count = 2;
	}	
	else if (aspect == MaintainabilityAspects.stability) {
		// This concers unit testing, we haven't implemented that metric yet.
		return RankingUnknown;
	}
	else if (aspect == MaintainabilityAspects.testability) {
		// This depends on unit testing, but we don't include it as we don't have it yet.
		sum = rankings.complexity.weight + rankings.unitSize.weight;
		count = 2;
	}
	
	return calculateRank((0.00 + sum) / (0.00 + count));	
}

private Rank calculateRank(num average) {
	if (average <= 1) {
		return Rankings.veryLow;
	}
	else if (average <= 2) {
		return Rankings.low;
	}
	else if (average <= 3) {
		return Rankings.moderate;
	}
	else if (average <= 4) {
		return Rankings.high;
	}
	else {
		return Rankings.veryHigh;
	}
}
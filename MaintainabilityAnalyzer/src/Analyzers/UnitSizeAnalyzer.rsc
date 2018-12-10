module Analyzers::UnitSizeAnalyzer

import DataTypes;
import IO;
import Map;
import List;
import Relation;
import Set;

/**
 * Map that contains the metric tresholds associated to a specified rank.
 **/
private map[Rank rank, MetricTresholds tresholds] tresholds = (
	Rankings.veryHigh:<25,0,0>,
	Rankings.high:<30,5,0>,
	Rankings.moderate:<40,10,0>,
	Rankings.low:<50,15,5>
);

/**
 * Analyzes the unit size metric for the specified set of facts.
 * @param facts The set of LineCounts to analyze.
 * @return A tuple of type Rank and RiskEvaluation containing the analysis results.
 **/
public tuple[Rank ranking, RiskEvaluation risk] analyzeUnitSize(set[LineCounts] facts) {
	RiskEvaluation riskEvaluation = evaluateRisk(facts);
	Rank rank = Rankings.veryLow;
	
	if (withinTresholds(Rankings.veryHigh, riskEvaluation)) {
		rank = Rankings.veryHigh;
	}
	else if (withinTresholds(Rankings.high, riskEvaluation)) {
		rank = Rankings.high;
	}
	else if (withinTresholds(Rankings.moderate, riskEvaluation)) {
		rank = Rankings.moderate;
	}
	else if (withinTresholds(Rankings.low, riskEvaluation)) {
		rank = Rankings.low;
	}
	
	return <rank, riskEvaluation>;
}

/**
 * Sums the number of lines of code in the specified set.
 * @param counts The set that contains the LineCounts to sum the number of lines of code for.
 * @return An int representing the sum of the number of lines of code.
 **/
private int sumCode(set[LineCounts] counts) = sum([ c.code | c <- toList(counts) ]);

/**
 * Calculates the percentage of the total for the specified values.
 * @param linesOfCode The number of lines of code.
 * @param total The total number of lines of code.
 * @return A num representing the percentage.
 **/
private num calculatePercentage(num linesOfCode, num total) = (0.00 + linesOfCode / total) * 100;

/**
 * Evaluates the risk for the specified set of line counts.
 * @param facts The set of LineCounts to evaluate the risk for.
 * @return A RiskEvaluation representing the risk evaluation results.
 **/
private RiskEvaluation evaluateRisk(set[LineCounts] facts) {
	num totalLinesOfCode = sumCode(facts);
	rel[RiskCategory category, LineCounts counts] unitSizes = { <determineRisk(x.code), x> | x <- facts };
	
	return ( x:<size(y), z, calculatePercentage(z, totalLinesOfCode)> | x <- domain(unitSizes), y := unitSizes[x], z := sumCode(y) );
}


/**
 * Determines whether the specified risk evaluation contains values that fall within the treshold associated with the specified rank.
 * @param rank The rank to assess the treshold values for.
 * @param evaluation The risk evaluation data.
 * @return True if it falls within the tresholds, false otherwise.
 **/
private bool withinTresholds(Rank rank, RiskEvaluation evaluation) {
	MetricTresholds treshold = tresholds[rank];
	
	return 
		evaluation[RiskCategories.veryHigh].percentage <= treshold.veryHigh &&
		evaluation[RiskCategories.high].percentage <= treshold.high &&
		evaluation[RiskCategories.moderate].percentage <= treshold.moderate;
}

/**
 * Determines the risk for the specified number of lines of code.
 * @param linesOfCode The number of lines of code.
 * @return A RiskCategory representing the determined risk.
 **/
private RiskCategory determineRisk(int linesOfCode) {
	/* Tresholds obtained from SIG e-book Building Maintainable Software (2015).
	 * <= 15 lines		Simple, without much risk
	 * > 15 && <= 30 	More complext, moderate risk
	 * > 30 && <= 60	Complex, high risk
	 * > 60				Untestable, very high risk
	 */
	 	 
	if (linesOfCode > 60) {
		return RiskCategories.veryHigh;
	}
	else if (linesOfCode > 30) {
		return RiskCategories.high;
	}
	else if (linesOfCode > 15) {
		return RiskCategories.moderate;
	}
	else {
		return RiskCategories.low;
	}
}
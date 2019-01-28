module Analyzers::ComplexityAnalyzer

import Prelude;
import DataTypes;

/**
 * Map that contains the metric tresholds associated to a specified rank. 
 * Tresholds are obtained from 'A Practical Model for Measuring Maintainability'
 **/
private map[Rank rank, MetricTresholds tresholds] tresholds = (
	Rankings.veryHigh:<25,0,0>,
	Rankings.high:<30,5,0>,
	Rankings.moderate:<40,10,0>,
	Rankings.low:<50,15,5>
);

/**
 * Analyzes the complexity metric for the specified set of facts.
 * @param facts The set of UnitInfo to analyze.
 * @return A tuple of type Rank and RiskEvaluation containing the analysis results.
 **/
public ComplexityAnalysisResult analyzeComplexity(set[UnitInfo] facts) {
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
	
	return <rank, riskEvaluation, size(facts)>;
}

/**
 * Sums the number of lines of code in the specified set.
 * @param counts The set that contains the LineCounts to sum the number of lines of code for.
 * @return An int representing the sum of the number of lines of code.
 **/
private int sumCode(set[UnitInfo] units) = sum([ u.size | u <- units]);

/**
 * Calculates the percentage of the total for the specified values.
 * @param linesOfCode The number of lines of code.
 * @param total The total number of lines of code.
 * @return A num representing the percentage.
 **/
private num calculatePercentage(num linesOfCode, num total) = (0.00 + linesOfCode / total) * 100;

/**
 * Evaluates the risk for the specified set of unit complexity.
 * @param facts The set of UnitInfo to evaluate the risk for.
 * @return A RiskEvaluation representing the risk evaluation results.
 **/
private RiskEvaluation evaluateRisk(set[UnitInfo] facts) {
	num totalLinesOfCode = sumCode(facts);
	rel[RiskCategory category, UnitInfo unitinfo] unitsInCategory = { <determineRisk(u.complexity), u> | u <- facts };
	
	return ( cat:<ui, z, calculatePercentage(z, totalLinesOfCode)> | cat <- domain(unitsInCategory), ui := unitsInCategory[cat], z := sumCode(ui) );
}

/**
 * Evaluates the specified treshold value for the specified risk category in the specified risk evaluation.
 * @param category The RiskCategory to evaluate the treshold for.
 * @param evaluation The RiskEvaluation that contains the risk evaluation data.
 * @param treshold The treshold value to evaluate.
 * @return True if the specified treshold value is met within the risk evaluation for the specified category, false otherwise.
 **/
private bool evaluateTreshold(RiskCategory category, RiskEvaluation evaluation, num treshold) = (category notin evaluation) || (category in evaluation && evaluation[category].percentage <= treshold);


/**
 * Determines whether the specified risk evaluation contains values that fall within the treshold associated with the specified rank.
 * @param rank The rank to assess the treshold values for.
 * @param evaluation The risk evaluation data.
 * @return True if it falls within the tresholds, false otherwise.
 **/
private bool withinTresholds(Rank rank, RiskEvaluation evaluation) {
	MetricTresholds treshold = tresholds[rank];
	
	return 
		evaluateTreshold(RiskCategories.veryHigh, evaluation, treshold.veryHigh) &&
		evaluateTreshold(RiskCategories.high, evaluation, treshold.high) &&
		evaluateTreshold(RiskCategories.moderate, evaluation, treshold.moderate);
}

/**
 * Determines the risk for the specified complexity value.
 * @param complexity The complexity value.
 * @return A RiskCategory representing the determined risk.
 **/
private RiskCategory determineRisk(int complexity) {
	/* Tresholds obtained from 'A Practical Model for Measuring Maintainability'
	 * 0-10 	Simple, without much risk
	 * 11-20   	More complext, moderate risk
	 * 21-50	Complex, high risk
	 * > 50		Untestable, very high risk
	 */
	 	 
	if (complexity > 50) {
		return RiskCategories.veryHigh;
	}
	else if (complexity > 20) {
		return RiskCategories.high;
	}
	else if (complexity > 10) {
		return RiskCategories.moderate;
	}
	else {
		return RiskCategories.low;
	}
}

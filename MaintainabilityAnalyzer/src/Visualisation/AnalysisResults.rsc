module Visualisation::AnalysisResults

import Visualisation::Controls;
import vis::Figure;
import DataTypes;

public Figure createTable(Results results) {
	return panel(grid([
		[ box(text("Maintainability Ranking:")), box(text(results.score.overall.rank))],
		[ box(text("Volume")), box(text(results.volume.ranking.rank))],
		[ box(text("Unit Size")), box(text(results.unitSize.ranking.rank))],
		[ box(text("Unit Complexity")), box(text(results.complexity.ranking.rank))],
		[ box(text("Duplication")), box(text(results.duplicates.ranking.rank))]
	])); 
}
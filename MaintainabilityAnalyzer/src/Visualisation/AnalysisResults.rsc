module Visualisation::AnalysisResults

import Visualisation::Controls;
import vis::Figure;
import DataTypes;
import Set;
import Map;
import String;

private Figure veryLowIcon = box(text("", [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24), fontColor("Red")]), right(), height(22));
private Figure lowIcon = text("", [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24), fontColor("Orange"), right(), height(22)]);
private Figure moderateIcon = text("", [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24), fontColor("Yellow"), right(), height(22)]);
private Figure highIcon = box(text("", [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24), fontColor("LightGreen"), right(), height(22)]));
private Figure veryHighIcon = box(text("", [ font("Segoe MDL2 Assets"), resizable(false), size(24, 24), fontColor("Green"), right(), height(22)]));

private map[Rank, Figure] icons = (
	Rankings.veryLow:veryLowIcon,
	Rankings.low:lowIcon,
	Rankings.moderate:moderateIcon,
	Rankings.high:highIcon,
	Rankings.veryHigh:veryHighIcon
);

private map[Rank, FProperty] rankColors = (
	Rankings.veryLow:fillColor("Red"),
	Rankings.low:fillColor("Orange"),
	Rankings.moderate:fillColor("Yellow"),
	Rankings.high:fillColor("Green"),
	Rankings.veryHigh:fillColor("DarkGreen"),
	RankingUnknown:fillColor("White")
);

private map[Rank, FProperty] rankFontColors = (
	Rankings.veryLow:fontColor("White"),
	Rankings.low:fontColor("Black"),
	Rankings.moderate:fontColor("Black"),
	Rankings.high:fontColor("White"),
	Rankings.veryHigh:fontColor("White"),
	RankingUnknown:fontColor("Black")
);

private list[FProperty] fontStyle = [ fontSize(11), left(), vresizable(false), height(22) ];

private int labelWidth = 350;

private Figure label(Rank rank) = box(text(rank.label), left(), width(labelWidth));

private Figure label(str label) = box(text(label, fontStyle), left(), width(labelWidth));

private Figure label(str label, list[FProperty] styles) = box(text(label, fontStyle + styles), left(), width(labelWidth));

private Figure rank(Rank rank) = box(text(rank.rank), left(), width(labelWidth));

private Figure icon(Rank rank) {
	FProperty fontColor = (rank == Rankings.low || rank == Rankings.moderate || rank == RankingUnknown) ? fontColor("Black") : fontColor("White");
	
	return box(text(rank.rank, fontBold(true), fontColor), rankColors[rank], width(30));
}


private Figure riskCategory(RiskCategory riskCategory, RiskEvaluation evaluation) {
	Figure figure;
	
	if (riskCategory in evaluation) {
		RiskValues values = evaluation[riskCategory];
		str text = "<left(riskCategory.risk + " (" + riskCategory.category + ")", 30)> <values.percentage> % (totalling <values.linesOfCode> lines of code in <size(values.units)> units)";
		
		figure = label(text, [font("Consolas"), fontSize(10)]);
	}
	else {
		figure = label("<riskCategory.category> N/A");
	}
	
	return figure;	
}

private Figure icon(VolumeAnalysisResult result) {
	Rank rank = result.ranking;	
	
	Figure content = vcat([
		label("VOLUME RANKING", [fontBold(true)]),
		label(""),
		label("Total <result.totalLinesOfCode> lines of which:"),
		label("<result.codeLines> lines of code"),
		label("<result.commentLines> comment lines"),
		label("<result.blankLines> blank lines"),
		label(""),
		label("Calculated volume ranking: <rank.rank> (<rank.label>)")
	], [std(fillColor(ColorPopupBackground))]);
	
	return box(text(rank.rank, fontBold(true), rankFontColors[rank]), rankColors[rank], width(30), popup(content));
}

private Figure icon(UnitSizeAnalysisResult result) {
	Rank rank = result.ranking;
	
	Figure content = vcat([
		label("UNIT SIZE", [fontBold(true), height(20), resizable(false)]),
		label(""),
		label("Total <result.unitsCount> units of which:"),		
		riskCategory(RiskCategories.veryHigh,  result.risk),
		riskCategory(RiskCategories.high,  result.risk),
		riskCategory(RiskCategories.moderate,  result.risk),
		riskCategory(RiskCategories.low,  result.risk),
		label(""),
		label("Calculated unit size ranking: <rank.rank> (<rank.label>)")
	], [std(fillColor(ColorPopupBackground))]);
	
	return box(text(rank.rank, fontBold(true), rankFontColors[rank]), rankColors[rank], width(30), popup(content));
}

private Figure icon(ComplexityAnalysisResult result) {
	Rank rank = result.ranking;	
	
	Figure content = vcat([
		label("COMPLEXITY", [fontBold(true), height(20), resizable(false)]),
		label(""),
		label("Total <result.unitsCount> units of which:"),		
		riskCategory(RiskCategories.veryHigh,  result.risk),
		riskCategory(RiskCategories.high,  result.risk),
		riskCategory(RiskCategories.moderate,  result.risk),
		riskCategory(RiskCategories.low,  result.risk),
		label(""),
		label("Calculated complexity ranking: <rank.rank> (<rank.label>)")
	], [std(fillColor(ColorPopupBackground))]);
	
	return box(text(rank.rank, fontBold(true), rankFontColors[rank]), rankColors[rank], width(30), popup(content));
}

private Figure icon(DuplicationAnalysisResult result) {
	Rank rank = result.ranking;
	
	Figure content = vcat([
		label("DUPLICATIONS RANKING", [fontBold(true)]),
		label(""),
		label("<result.duplicateLines> of <result.totalLinesOfCode> lines are duplicate: <result.percentage>%"),
		label(""),
		label("Calculated duplications ranking: <result.ranking.rank> (<result.ranking.label>)")
	], [std(fillColor(ColorPopupBackground))]);
	
	return box(text(rank.rank, fontBold(true), rankFontColors[rank]), rankColors[rank], width(30), popup(content));
}

public Results CurrentResults = EmptyResults;

public Figure createTable(Results results) {
	return panel(grid([
		[ label("Metrics:", [fontBold(true)]) ],
		[ label("Volume"), icon(results.volume)],
		[ label("Unit Size"), icon(results.unitSize)],
		[ label("Complexity"), icon(results.complexity)],
		[ label("Duplication"), icon(results.duplicates)],
		[ box() ],		
		[ label("Quality Aspects:", [fontBold(true)]) ],
		[ label(MaintainabilityAspects.analyzability), icon(results.score.aspects[MaintainabilityAspects.analyzability])],		
		[ label(MaintainabilityAspects.changeability), icon(results.score.aspects[MaintainabilityAspects.changeability])],
		[ label(MaintainabilityAspects.stability), icon(results.score.aspects[MaintainabilityAspects.stability])],
		[ label(MaintainabilityAspects.testability), icon(results.score.aspects[MaintainabilityAspects.testability])],
		[ box() ],
		[ label("Overall Maintainability Ranking:", [fontBold(true)]), icon(results.score.overall)]			
	], [top(), resizable(false), height(120), std(lineWidth(0)), std(fontSize(11)), std(hresizable(false))]),
		"System Maintainability Ranking", 5
	); 
}
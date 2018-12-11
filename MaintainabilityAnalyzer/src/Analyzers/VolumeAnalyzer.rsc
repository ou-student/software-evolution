module Analyzers::VolumeAnalyzer

import IO;
import DataTypes;
import List;
import Set;

public VolumeAnalysisResult analyzeVolume(set[LineCounts] facts)
{
	if(size(facts) == 0) return <Rankings.veryHigh,0,0,0,0,facts>;
	
	int codeLines = sum([ x.code | x <- facts ]);
	num totalKLoc = codeLines / 1000;
	int commentLines = sum([ x.comment | x <- facts ]);
	int blankLines = sum([ x.blank | x <- facts ]);
	int totalLines = sum([ x.total | x <- facts ]);
	Rank ranking = Rankings.veryLow; // Pessimistic default.
	
	if (totalKLoc < 66) 
	{
		ranking = Rankings.veryHigh;
	}
	else if (totalKLoc < 246)
	{
		ranking = Rankings.high;
	}
	else if (totalKLoc < 665)
	{
		ranking = Rankings.moderate;
	}
	else if (totalKLoc < 1310)
	{
		ranking = Rankings.low;
	}
	
	return <ranking, totalLines, codeLines, blankLines, commentLines, facts>;	
}
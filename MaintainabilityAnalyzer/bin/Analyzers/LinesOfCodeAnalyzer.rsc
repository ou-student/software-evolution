module Analyzers::LinesOfCodeAnalyzer

import IO;
import DataTypes;
import List;

public Ranking analyzeLinesOfCode(list[tuple[loc, LineCounts]] facts)
{
	int totalCount = sum([x.counts.code | tuple[loc file, LineCounts counts] x <- facts]);
	num totalKLoc = totalCount / 1000;
	
	return if (totalKLoc < 66) 
	{
		VeryHigh(totalCount);
	}
	else if (totalKLoc < 246)
	{
		return High(totalCount);
	}
	else if (totalKLoc < 665)
	{
		return Moderate(totalCount);
	}
	else if (totalKLoc < 1310)
	{
		return Low(totalCount);
	}
	else
	{
		return VeryLow(totalCount);
	}	
}
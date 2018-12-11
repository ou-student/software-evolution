module Analyzers::VolumeAnalyzer

import IO;
import DataTypes;
import List;
import Set;

public Ranking analyzeVolume(set[LineCounts] facts)
{
	if(size(facts) == 0) return VeryHigh(0);
	
	int totalCount = sum({ x.code | x <- facts });
	num totalKLoc = totalCount / 1000;
	
	if (totalKLoc < 66) 
	{
		return VeryHigh(totalCount);
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
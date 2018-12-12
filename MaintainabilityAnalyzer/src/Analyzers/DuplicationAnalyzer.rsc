module Analyzers::DuplicationAnalyzer

import Prelude;
import List;
import DataTypes;
import Extractors::DuplicationExtractor;

public DuplicationAnalysisResult analyzeDuplications(Duplications duplications, int totalLOC) {

	// y:=size(x) returns the number of occurences of 6 lines of code.
	// y>1 filters duplicated occurences of 6 lines of code.
	// y-1 removes the nonredundant duplicate, so only the reduntant number of duplicates remain.
    int nrOfDuplications = sum([0]+[ y-1 | x <- duplications.clones, y:=size(x), y > 1]) * 6;
    
    num percentage = ((0.0+nrOfDuplications) / (0.0+totalLOC)) * 100.0;
    
    Rank ranking = Rankings.veryLow;
    
    if (percentage < 3.0) 	    ranking = Rankings.veryHigh;
	else if (percentage < 5.0)  ranking = Rankings.high;
	else if (percentage < 10.0) ranking = Rankings.moderate;
	else if (percentage < 20.0) ranking = Rankings.low;

    
	return <ranking, totalLOC, nrOfDuplications, percentage>;
}


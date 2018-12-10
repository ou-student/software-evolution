module Extractors::DuplicationExtractor

import Prelude;
import DataTypes;

public alias Duplications = map[str piece, list[LineOfCode] clones];

/**
 * Creates a single LineOfCode element from a LinesOFCode list.
 * The code is concatened with a \n to form a single line of code.
 * The location represents LOC of the first LineOfCode in LinesOfCode.
 */
private LineOfCode flatten(LinesOfCode locs) {
	loc newLocation = head(locs.location);

	return <intercalate("\n", locs.line), newLocation>;
}

/**
 * Extracts a given number of lines of code from the given source, concatenates the LOCs and sees if it exists 
 * in the given Duplications object. If it does, it adds the LineOfCode element to the duplicates.
 */
Duplications extractDuplications(LinesOfCode source, Duplications duplicates, int nrOfLinesToMatch) {
	// As long as there are enough lines of code, check for duplicates.
	while(size(source) >= nrOfLinesToMatch) {
	
		// Take 6 lines from the given source.
		LinesOfCode pieces = take(nrOfLinesToMatch, source);
		// Create a concatenated LineOfCode from the lines.
		LineOfCode piece = flatten(pieces);
		
		if(piece.line in duplicates) {
			// If concatenated line is seen before, add LineOfCode to Duplications.
			duplicates[piece.line] += [piece];
		}
		else {
			// If concatenated line is not seen before, create new entry.
			duplicates[piece.line] = [piece];
		}
		
		// Drop first LOC from source so next line will be evaluated.
		source = drop(1, source);
	}
	
	return duplicates;
}

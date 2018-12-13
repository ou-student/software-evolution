module Extractors::DuplicationExtractor

import Prelude;
import DataTypes;
import Utils::Normalizer;

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
Duplications extractDuplications(loc source, Duplications duplicates, int nrOfLinesToMatch) {
	// Normalize the file.
	linesOfCode = normalizeFile(source);
	
	// As long as there are enough lines of code, check for duplicates.
	while(size(linesOfCode) >= nrOfLinesToMatch) {
	
		// Take 6 lines from the given source.
		LinesOfCode pieces = take(nrOfLinesToMatch, linesOfCode);
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
		linesOfCode = drop(1, linesOfCode);
	}
	
	return duplicates;
}

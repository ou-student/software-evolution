module Extractors::DuplicationExtractor

import Prelude;
import DataTypes;

public alias Duplications = map[str piece, list[LineOfCode] clones];

private LineOfCode flatten(LinesOfCode locs) {
	loc newLocation = head(locs.location);

	return <intercalate("\n", locs.line), newLocation>;
}


Duplications extractDuplications(LinesOfCode source, Duplications duplicates) {
	while(size(source) >= 6) {
		LinesOfCode pieces = take(6, source);
		LineOfCode piece = flatten(pieces);
		
		if(piece.line in duplicates) {
			duplicates[piece.line] += [piece];
		}
		else {
			duplicates[piece.line] = [piece];
		}
		
		source = drop(1, source);
	}
	
	return duplicates;
}

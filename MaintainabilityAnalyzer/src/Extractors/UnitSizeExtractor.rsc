module Extractors::UnitSizeExtractor

import DataTypes;
import List;
import String;
import Utils::Normalizer;
import Utils::CoreExtension;
import lang::java::jdt::m3::Core;

/**
 * Extracts all the relevant unit sizes from the specified unit locations.
 * @param units The set of type loc that contains the method locations.
 * @return UnitSizes representing the result of the extraction.
 **/ 
public UnitSizes extractUnitSizes(set[loc] units) {
	return { <x, size(source)> | x <- units, !contains(x.path, "$anonymous"), source := normalizeFile(x) };
}
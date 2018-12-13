module Extractors::UnitSizeExtractor

import DataTypes;
import List;
import String;
import Utils::Normalizer;
import Utils::CoreExtension;
import lang::java::jdt::m3::Core;

/**
 * Extracts all the relevant unit sizes from the specified unit locations.
 * @param unit The unit from which the size must be determined.
 * @return UnitSizes representing the result of the extraction.
 **/ 
public int extractUnitSize(loc unit) {
	return size(normalizeFile(unit));
}
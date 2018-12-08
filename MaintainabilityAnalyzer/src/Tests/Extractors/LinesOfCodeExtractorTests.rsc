module Tests::Extractors::LinesOfCodeExtractorTests

import Extractors::LinesOfCodeExtractor;
import lang::java::jdt::m3::Core;
import DataTypes;
import IO;
import Set;

test bool extractLinesOfCode_Correctly_Sets_Location() {
	loc source = |project://JabberPoint/src/AboutBox.java|; 
	LineCounts actual = extractLinesOfCode(source);

	return actual.location == source;
}

test bool extractLinesOfCode_Correctly_Calculates_Blank_Lines() {
	loc source = |project://JabberPoint/src/AboutBox.java|; 
	LineCounts actual = extractLinesOfCode(source);

	return actual.blank == 2;
}

test bool extractLinesOfCode_Correctly_Calculates_Comment_Lines() {
	loc source = |project://JabberPoint/src/AboutBox.java|; 
	LineCounts actual = extractLinesOfCode(source);

	return actual.comment == 8;
}

test bool extractLinesOfCode_Correctly_Calculates_Code_Lines() {
	loc source = |project://JabberPoint/src/AboutBox.java|; 
	LineCounts actual = extractLinesOfCode(source);

	return actual.code == 19;
}

test bool extractLinesOfCode_Correctly_Calculates_Total_Lines() {
	loc source = |project://JabberPoint/src/AboutBox.java|; 
	LineCounts actual = extractLinesOfCode(source);

	return actual.total == 28;
}


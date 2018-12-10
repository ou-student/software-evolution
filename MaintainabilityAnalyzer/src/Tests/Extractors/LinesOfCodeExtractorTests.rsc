module Tests::Extractors::LinesOfCodeExtractorTests

import Extractors::LinesOfCodeExtractor;
import lang::java::jdt::m3::Core;
import DataTypes;
import IO;
import Set;

private loc fileSource = |project://JabberPoint/src/AboutBox.java|;
private loc methodSource = |java+method:///Slide/draw(java.awt.Graphics,java.awt.Rectangle,java.awt.image.ImageObserver)|;

test bool extractLinesOfCode_Correctly_Sets_Location() {	 
	LineCounts actual = extractLinesOfCode(fileSource);

	return actual.location == fileSource;
}

test bool extractLinesOfCode_Correctly_Calculates_Blank_Lines() {	
	LineCounts actual = extractLinesOfCode(fileSource);

	return actual.blank == 2;
}

test bool extractLinesOfCode_Correctly_Calculates_Comment_Lines() {	
	LineCounts actual = extractLinesOfCode(fileSource);

	return actual.comment == 8;
}

test bool extractLinesOfCode_Correctly_Calculates_Code_Lines() {	
	LineCounts actual = extractLinesOfCode(fileSource);

	return actual.code == 18;
}

test bool extractLinesOfCode_Correctly_Calculates_Total_Lines() {	 
	LineCounts actual = extractLinesOfCode(fileSource);

	return actual.total == 28;
}

test bool extractLinesOfCode_Correctly_Calculates_Blank_Lines_For_Method() {
	LineCounts actual = extractLinesOfCode(methodSource);
	
	return actual.blank == 0;
}

test bool extractLinesOfCode_Correctly_Calculates_Comment_Lines_For_Method() {	
	LineCounts actual = extractLinesOfCode(methodSource);

	return actual.comment == 2;
}

test bool extractLinesOfCode_Correctly_Calculates_Code_Lines_For_Method() {	
	LineCounts actual = extractLinesOfCode(methodSource);

	return actual.code == 14;
}


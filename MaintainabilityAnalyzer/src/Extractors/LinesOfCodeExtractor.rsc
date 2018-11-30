module Extractors::LinesOfCodeExtractor

import util::FileSystem;
import lang::java::jdt::m3::Core;
import IO;
import List;
import Set;
import String;
import DataTypes;

/**
 * Extracts the lines of code represented as LineCounts from the specified source location.
 * @param source The location of the file to extract the LineCounts for.
 * @return LineCounts A LineCounts instance representing the LineCounts for the source.
 */
public LineCounts extractLinesOfCode(loc source) {
	return calculateLineCounts(source);
}

/**
 * Counts the number of blank lins in the specified list.
 * @param lines The list of type str that contains the source code lines.
 * @return An int representing the number of blank lines.
 */
private int countBlankLines(list[str] lines) = size([x | x <- lines, trim(x) == ""]);

/**
 * Calculates the line counts for the specified file.
 * @param file The location of the file to calculate the LineCounts for.
 * @return A LineCounts instance containing the result of the calculation.
 */
private LineCounts calculateLineCounts(loc file) {
	M3 model = createM3FromFile(file);
	str source = readFile(file);
	list[str] lines = split("\n", source);	
	int total = size(lines);
	int blank = countBlankLines(lines);
	int code = 0;
	int comment = 0;
	
	// Straight forward calculation when there are no comments.
	if (size(model.documentation) == 0) {
		code = total - blank;
	}
	else {
		code = calculateLinesOfCode(source, model);
		comment = total - code - blank;		
	}
			
	return <file, code, comment, blank, total>;	
}

/**
 * Calculates the number of lines of code.
 * @param source The source code to count the lines of code for.
 * @param The model that contains the source code meta data.
 * @return An int representing the number of lines of code.
 */
private int calculateLinesOfCode(str source, M3 model) {
	list[str] lines = removeComments(source, model);
	int total = size(lines);
	int blank = countBlankLines(lines);
	
	return total - blank;
}

/**
 * Removes all comments from the specified source.
 * @param source The source code to remove the comments from.
 * @param model The model that contains the documentation comments.
 * @return A list of type str that represents all code lines from the cleaned up source. 
 */
private list[str] removeComments(str source, M3 model) {
	str code = source;
	
	for (d <- model.documentation) {
		int offset = d.comments.offset;
		str comment = substring(source, offset, offset + d.comments.length);
		code = replaceFirst(code, comment, "");
	}
	
	return split("\n", code);
}


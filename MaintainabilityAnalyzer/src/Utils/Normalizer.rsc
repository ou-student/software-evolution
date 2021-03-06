module Utils::Normalizer

import Prelude;
import DataTypes;

/**
 * Normalizes the given file.
 * Normalization removes (multiline) comments, blank lines and leading/trailing whitespaces.
 * @param file The file that needs to be normalized.
 * @return A LinesOfCode object that contains a list of LineOfCode objects, each representing a line of code and its location.
 */
LinesOfCode normalizeFile(loc file) {
	LinesOfCode result = [];
	str code = readFile(file);
	list[str] lines = split("\n", code);
	
	int lineNumber = 0;
	int offset = 0;
	
	isMultiline = false;
	
	for(line <- lines){
		str tempLine = line;
		
		// If there is an active multiline comment, try finding the end.
		if(isMultiline) {
			<tempLine, isMultiline> = removeMultiLineCommentEnd(tempLine);
		}
		// If there is no active multiline comment, find one or just a single line.
		else {
			tempLine = removeSingleLineComment(tempLine);
			<tempLine, isMultiline> = removeMultiLineCommentStart(tempLine);
		}
		
		// remove trailing and leading spaces.
		tempLine = trim(tempLine);
		
		// find remaining line in original line.
		int index = findFirst(line, tempLine);
		
		// Comment was probably inline, no problem, just take original line.
		if (index == -1) {
			tempLine = trim(line);
			index = 0;
		}
		
		// Create a source reference that points to the line of code.
		loc src = file;
		
		try {
			src = createSourceReference(file, lineNumber, offset, index, size(tempLine));
		}
		catch: {
			src = file;
		}
		
		// If the line is not a blank line, add it to the result.
		// TODO: maybe do store blank line, but mark it as blank, so we can count them too...
		if(tempLine != "") result += <tempLine,src>;
		
		// Increase linenumber and offset for next line.
		lineNumber += 1;
		offset += size(line) + 1;
	}

	return result;
}

/**
 * Create a location based on the 'parent' location, current line number, total offset, indent colunm, and length.
 * @param original The 'parent' location on which the new location is based.
 * @param lineNumber The line number, relative to the parent location.
 * @param offset The character offset, relative to the parent location.
 * @param column The number of whitespaces before a line.
 * @param length The length of the line of code.
 * @return The create location object.
 */
private loc createSourceReference(loc original, int lineNumber, int offset, int column, int length) {
	loc src = original;
	src.begin.column = 0;
	src.end.column = 0;
	src.begin.line = 0;
	lineNumber += original.begin.line;
	
	src.offset += offset + column;
	src.length = length;
	
	src.end.line = lineNumber;
	src.begin.line = src.end.line;
	src.end.column = column + length;
	src.begin.column = column;
	
	return src;	
}

/**
 * Removes comments that look like //, whether they are single line or inline.
 * @param input The input str from which single line comment will be removed.
 * @return The cleaned up line of code.
 */
private str removeSingleLineComment(str input) {
	if(/<comment:\/\/.*>/ := input) input = replaceFirst(input, comment, "");
	return input;
}

/**
 * Tries to find the start of a multiline comment.
 * If the multiline comment start is found, it replaces everything from the comment start with "".
 *     the method checks if the comment part also contains a multiline comment end tag.
 *     when the multiline comment has not ended in this line, it sets the isMultiline to 'true' so
 *     the parser knows that the next line is part of a multiline comment.
 * If the multiline comment start is not found, it returns the input string.
 * @param input The input str from which multiline comment will be removed.
 * @return A tuple which consists of the cleaned up line of code and a boolean that is true when the comment did not end yet.
 */
private tuple[str line, bool isMultiline] removeMultiLineCommentStart(str input) {
	isMultiline = false;
	
	// An inline comment was found, replace it with "".
	if( /<comment:\/\*[\s\S]*\*\/>/ := input) {
		input = replaceFirst(input, comment, "");
	}
	// If only the start of a multiline comment is found, replace it with "" and set isMulitline to 'true'.
	else if( /<comment:\/\*[\s\S]*>/ := input) {
		input = replaceFirst(input, comment, "");
		isMultiline = true;
	}
	
	return <input, isMultiline>;
}

/**
 * Tries to find the end of a multiline comment.
 * If the multiline comment end is found, it replaces everything up and until the comment end with "".
 * If the multiline comment end is not found, it assumes the line is comment and replaces it with "".
 * @param input The input str from which multiline comment end will be removed.
 * @return A tuple which consists of the cleaned up line of code and a boolean that is true when the comment did not end yet.
 */
private tuple[str line, bool isMultiline] removeMultiLineCommentEnd(str input) {
	isMultiline = true;
	
	if(	/<comment:^.*\*\/>/ := input ) {
		input = replaceFirst(input, comment, "");
		isMultiline = false;
	}
	else {
		input = "";
	}
	
	return <input, isMultiline>;
}




///////////////////////////////////////////
// TRYOUT CODE ////////////////////////////
///////////////////////////////////////////


/**
 * Using visit method... works but slower, because match is expected once.
 */
//private str removeSingleLineComment(str input) {
//	res = visit(input) {
//		case /<comment:\/\/.*>/ => ""
//		};
//	return res;
//}

/**
 * Using visit method... works but slower, because match is expected once.
 */
//private tuple[str line, bool isMultiline] removeMultiLineCommentStart(str input) {
//	isMultiline = false;
//	
//	res = visit(input) {
//		case /<comment:\/\*[\s\S]*\*\/>/: {
//			input = replaceFirst(input, comment, "");
//			isMultiline = false;
//		}
//		case /<comment:\/\*[\s\S]*>/: {
//			input = replaceFirst(input, comment, "");
//			isMultiline = true;
//		}
//	};
//	
//	return <input, isMultiline>;
//}


//alias NormalizeResult = tuple[str normalized, num blankLines, num commentlines];
//
//public NormalizeResult normalize(str input) {
//	comments = 0;
//	
//	result = removeSingleLineComments(input);
//	//println("Removed <result.lines> lines of single line comments {<result.removed>}");
//	result = removeInlineComments(result.result);
//	//println("Removed <result.lines> inline comments {<result.removed>}");
//	result = removeMultiLineComments(result.result);
//	//println("Removed <result.lines> lines of multi line comments {<result.removed>}");
//	result = removeBlankLines(result.result);
//	//println("Removed <result.lines> blank lines");
//	result = removeWhitespaces(result.result);
//	//println("Removed <result.lines> whitespaces");
//	
//	return <result.result,0,comments>;
//}
//
//private tuple[str result, num lines, list[str] removed] removeWhitespaces(str input) {
//	aantal = 0;
//
//	//// Remove whitespaces at end of line.
//	//for( /<whitespace:^\S[\s]+>\n/ := input ) {
//	//	input = replaceFirst(input, whitespace, "");
//	//	aantal += 1;
//	//}
//	
//	//// Remove whitespaces at start of line.
//	for( /(^|\n)<whitespace:[\s]+>[^\s\n]/ := input ) {
//		input = replaceFirst(input, whitespace, "");
//		aantal += 1;
//	}
//
//	return <input, aantal, []>;
//}
//
//private tuple[str result, num lines, list[str] removed] removeBlankLines(str input) {
//	nrOfBlankLines = 0;
//	
//	// Remove blank spaces between two existing lines.
//	for( /<blank:\n[\s]*\n>/ := input ) {
//		input = replaceFirst(input, blank, "\n");
//		nrOfBlankLines += 1;
//	}
//	
//	// Remove blank line if it's first line of file.
//	if( /<blank:^[\s]*\n>/ := input ) {
//		input = replaceFirst(input, blank, "");
//		nrOfBlankLines += 1;
//	}
//	
//	return <input, nrOfBlankLines, []>;
//}
//
//private tuple[str result, num lines, list[str] removed] removeSingleLineComments(str input) {
//	nrOfCommentLines = 0;
//	removed = [];
//	
//	for( /(^|\n)<comment:[\s]*\/\/.*>/ := input ) {
//		input = replaceFirst(input, comment, "");
//		nrOfCommentLines += 1;
//		removed += comment;
//	}
//	
//	return <input, nrOfCommentLines, removed>;
//}
//
//private tuple[str result, num lines, list[str] removed] removeInlineComments(str input) {
//	nrOfComments = 0;
//	removed = [];
//	
//	for( /[^\n]<comment:\/\/[^"\n]*>\n/ := input ) {
//		input = replaceFirst(input, comment, "");
//		nrOfComments += 1;
//		removed += comment;
//	}
//	
//	return <input, nrOfComments, removed>;
//}
//
//private tuple[str result, num lines, list[str] removed] removeMultiLineComments(str input) {
//	nrOfCommentLines = 0;
//	removed = [];
//	
//	for( /<comment:\/\*[\s\S]*?\*\/>/ := input ) {
//		input = replaceFirst(input, comment, "");
//		nrOfCommentLines += size(split("\n", comment));
//		removed += comment;
//	}
//	
//	return <input, nrOfCommentLines, removed>;
//}


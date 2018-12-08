module Extractors::LinesOfCodeExtractor

import util::FileSystem;
import lang::java::jdt::m3::Core;
import IO;
import List;
import Set;
import String;
import DataTypes;
import analysis::m3::AST;

public set[LineCounts] extractLinesOfCode(M3 model) {
	return { calculate(f) | f <- files(model) };
}

private LineCounts calculate(loc file) {
	\AST(file);
	list[str] lines = readFileLines(file);
	set[int] blankLines = countBlankLines(lines);
	tuple[set[int] comment, set[int] blank] commentLines = countCommentLines(file, lines, toList(blankLines));
	
	blankLineCount2 = size([ a | a <- lines, trim(a)=="" ]);
	commentLineCount2 = size([ a | a <- lines, /^\/\/.*$|^[\s]*\/\*.*$|^[\s]*\*.*$/ := a ]);
	
	int totalCount = size(lines);
	int blankLineCount = size(blankLines);
	int commentLineCount = size(commentLines.comment);
	int codeLineCount = totalCount - blankLineCount - commentLineCount;
	
	return <file, codeLineCount, commentLineCount2, blankLineCount2, totalCount>;
}

private set[int] countBlankLines(list[str] lines) {
	set[int] blankLineIndices = {};
	int index = 0;
	int count = size(lines);
	
	while (index < count) {
		str trimmed = trim(lines[index]);
		
		if (size(trimmed) == 0) {
			blankLineIndices += {index};
		}
		
		index += 1;
	}
	
	return blankLineIndices;
}

private tuple[set[int], set[int]] countCommentLines(loc location, list[str] lines, list[int] blankLines)
{
	M3 model = createM3FromFile(location);
	set[int] commentLineIndices = {};	
	set[int] blankCommentLineIndices = {};
	
	if (size(model.documentation) == 0) 
	{
		return <commentLineIndices, blankCommentLineIndices>;
	}
		
	for(f <- model.documentation, unit := f.comments) 
	{
		list[str] commentLines = readFileLines(unit);
				
		int index = unit.begin.line - 1; // -1 for 0 based index.
		int end = unit.end.line;
		int commentIndex = 0;
	
		while(index < end)
		{	
			str commentLine = trim(commentLines[commentIndex]);
			str codeLine = trim(lines[index]);
			
			if (commentLine == codeLine)
			{			
				commentLineIndices += { index };
				
				if (size(commentLine) == 0)
				{
					blankCommentLineIndices += { index };
				}
			}
			
			index += 1;	
			commentIndex += 1;		
		}				
	}
	
	return <commentLineIndices, blankCommentLineIndices>;
}
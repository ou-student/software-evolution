module Extractors::LinesOfCodeExtractor


import util::FileSystem;
import DataTypes;
import IO;
import List;
import Set;
import String;
import lang::java::jdt::m3::Core;

public list[tuple[loc, LineCounts]] calculateLinesOfCode(M3 model)
{	
	list[tuple[loc, LineCounts]] results = [];	
	set[loc] files = files(model);
	
	for(f <- files)
	{	
		LineCounts result = calculate(f);	
		results += <f, result>;
	}
	
	return results;
}

public list[tuple[loc, LineCounts]] calculateUnitSizes(M3 model)
{	
	list[tuple[loc, LineCounts]] results = [];	
	set[loc] files = methods(model);
	
	for(f <- files)
	{	
		LineCounts result = calculate(f);	
		results += <f, result>;
	}
	
	return results;
}

private LineCounts calculate(loc file)
{
	println("LinesOfCodeExtractor::calculate");
	println(file);
	println();
	
		
	list[str] lines = readFileLines(file);
	set[int] blankLines = countBlankLines(lines);
	tuple[set[int] comment, set[int] blank] commentLines = countCommentLines(file, lines, toList(blankLines));
	int totalCount = size(lines);
	int blankLineCount = size(blankLines);
	int commentLineCount = size(commentLines.comment);
	int codeLineCount = totalCount - blankLineCount - commentLineCount + size(commentLines.blank); 
	
	// total, code, blank, comment
	return LineCounts(totalCount, codeLineCount, blankLineCount, commentLineCount);	
}

private set[int] countBlankLines(list[str] lines)
{	
	set[int] blankLineIndices = {};	
	int index = 0;
	int count = size(lines);
	
	while(index < count)
	{
		str trimmed = trim(lines[index]);
		
		if (size(trimmed) == 0)
		{			
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
	
		println(readFile(unit)); 
	
		//println("UNIT!");
		//println(unit);
		
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
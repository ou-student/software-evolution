module Test

import IO;
import lang::java::jdt::m3::Core;
import Extractors::LinesOfCodeExtractor;
import DataTypes;

public int testRun()
{
	M3 model = createM3FromEclipseProject(|project://HelloWorld|);
		
	println("Extracted facts ---------------------------------------------------------");
	println();
	println("Lines of code:");
	println();
	println(calculateLinesOfCode(model));
	println();
	
	println("Unit sizes:");
	println();
	print(calculateUnitSizes(model));
	println("");
	
	return 0;
}
module DataTypes

data Ranking = 
	VeryLow(num size) 
	| Low (num size)
	| Moderate (num size)
	| High (num size)
	| VeryHigh (num size);

/**
 * The LineCount data structure represents a location, it's total number of lines
 * and it's number of lines of code, ommiting comments and blank lines.
 */
data LineCount =
	LineCount(loc location, int count, int locCount); 


/**
 * The LineCounts data structure contains the line counts, distinghuised as
 * total (total lines count), code (code lines count), blank (blank lines count)
 * and comment (comment lines count).
 */
data LineCounts = 
	LineCounts(int total, int code, int blank, int comment); 
	
data FileInfo = 
	FileInfo(LineCount lineCount);
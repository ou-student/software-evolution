module DataTypes

data Ranking =
	VeryLow (num size)
	| Low (num size)
	| Moderate (num size)
	| High (num size)
	| VeryHigh (num size);
	
alias LineCounts = tuple[loc location, int code, int comment, int blank, int total];


alias LineOfCode = tuple[str line, loc location];
alias LinesOfCode = list[LineOfCode];

alias Position = tuple[int line, int column];
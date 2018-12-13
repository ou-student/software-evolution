module Extractors::ComplexityExtractor

import lang::java::m3::AST;
import Prelude;
import DataTypes;

/**
 * Extracts the complexity number for the given src.
 * The method needs the whole file to create an AST of it.
 * It then parses the whole file looking for methods.
 * If a method is at the location that is given, the complexity will be determined.
 * @param src The location of the source.
 * @return the complexity value of the source.
 */
public int extractComplexity(loc src) {
	
	ast = createAstFromFile(toLocation(src.uri), false);
	
	int complexity = 0;
	
	visit(ast) {
		case m:\method(_,_,_,_,imp): {
			if(m.src == src) { 
				complexity = determineComplexity(imp);
			}
		}
		case c:\constructor(_,_,_,imp): {
			if(c.src == src) {
				complexity = determineComplexity(imp);
			}
		}
	}
	
	return complexity;
}

/**
 * Determins the complexity of a method block.
 * @param implementation The block part of a method.
 * @return The complexity of the method.
 */
private int determineComplexity(Statement implementation) {
	int complexity = 1;
	
	visit(implementation) {
	 	case \if(c,_): 	 			complexity += 1 + nrOfOperators(c);
	 	case \if(c,_,_): 			complexity += 1 + nrOfOperators(c);
	 	case \conditional(c,_,_):   complexity += 1 + nrOfOperators(c);
	 	case \while(c,_):			complexity += 1 + nrOfOperators(c);
	 	case \do(_,c):				complexity += 1 + nrOfOperators(c);
	 	case \for(_,c,_,_):			complexity += 1 + nrOfOperators(c);
	 	case \for(_,_,_):			complexity += 1;
	 	case \foreach(_,_,_):		complexity += 1;
	 	case \case(_):				complexity += 1;
	 	case \catch(_,_):			complexity += 1;
	};
	
	return complexity;
}

/**
 * Returns the number of 'or' and 'and' operators in an expression.
 * The complexity of i.e. an if statement depends on the number of 'or' and 'and' operators.
 * @param exp The expression to test.
 * @return The number of operators found.
 */
private int nrOfOperators(Expression exp) {
	nrOfOps = 0;
	
	visit(exp) {
		case \infix(_,op,_): {
			if(op == "||") nrOfOps += 1;
			if(op == "&&") nrOfOps += 1;
		}
	}
	
	return nrOfOps;
}
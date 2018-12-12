module Tests::Extractors::UnitSizeExtractorTests

import DataTypes;
import Extractors::UnitSizeExtractor;
import Set;

test bool extractUnitSizes_Correctly_Extracts_Sizes() {
 	loc unit1 = |java+method:///MenuController/MenuController(java/awt/Frame,Presentation)/$anonymous1/actionPerformed(java.awt.event.ActionEvent)|;
 	loc unit2 = |java+constructor:///MenuController/MenuController(java.awt.Frame,Presentation)|;
	loc unit3 = |java+method:///TextItem/getAttributedString(Style,float)|;
		
	UnitSizes actual = extractUnitSizes({ unit1, unit2, unit3 });
	
	// Unit1 should not be included, its an anonymous method.
	return unit1 notin actual && actual[unit2] == {76} && actual[unit3] == {5};
}
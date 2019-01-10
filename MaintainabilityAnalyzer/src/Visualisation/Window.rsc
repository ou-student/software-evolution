module Visualisation::Window

import Prelude;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Math;
import util::Editors;

import DataTypes;
import Main;



void begin() {
	bool redraw = false;
	
	
	UnitInfos r = {};
	
	btnLoad = button("Start", void(){ 
			r = run(|project://JabberPoint/|); 
			redraw = true;
		});
	menu = [ btnLoad, btnLoad ];
	
	Figure getTreemap() {
		return computeFigure(bool() {bool temp = redraw; redraw = false; return temp; }, Figure() {
		
			Figures boxes = [];
			if(size(r) > 0) {
				cscale = colorScale([s.complexity | s <- r], color("green"),color("red"));
				boxes = [mkBox(s, cscale(s.complexity)) | s <- r ];
			}
			
			return treemap(boxes);
		});
	}
	
	
	
	
	render(vcat([hcat(menu, std(resizable(false)), std(height(48)), std(width(200)), left()), 
				 hcat([getTreemap()]),
				 hcat([box(height(48),width(100),resizable(false))])
			    ]));
}

public FProperty popup(UnitInfo s) {
	return mouseOver(box(vcat([text(s.unit.path), text(toString(s.complexity))]),
					 fillColor("lightYellow"),
					 grow(1.2),
					 resizable(false)));
}

public Figure mkBox(UnitInfo s, Color c) {
	return box(area(s.size),
			   fillColor(c),
			   popup(s),
			   onMouseDown(bool (int btn, map[KeyModifier, bool] m) {
			   		edit(s.unit); return true;
			   }));
}

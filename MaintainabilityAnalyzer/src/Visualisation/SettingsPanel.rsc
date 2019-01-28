module Visualisation::SettingsPanel

import Prelude;

import vis::Figure;
import Visualisation::Controls;

private str colorscheme = "Red-Green";

alias Colorset = tuple[Color first, Color second];
alias ColorMap = map[str name, Colorset colors];
private ColorMap colors = (
	"Red-Green"   : <color("red"), 			color("green")  >,
	"Red-Blue"	  :	<color("red"),			color("lightblue")   >,
	"Blue-Yellow" : <color("DeepSkyBlue"),  color("yellow") >, 
	"Purple-Pink" : <rgb(12,0,46), 			rgb(244,210,255)>, 
	"Purple-Green": <rgb(114,22,95),		rgb(146,157,39) >
	);

private Color _firstExample = color("red");
private Color _secondExample = color("green");

/*****************************/
/* Initializer				 */
/*****************************/
private bool _isInitialized = false;

/**
 * Initializes the settings panel.
 */
public void sp_initialize() {
	if(!_isInitialized) {	
		sp_addColorschemeChangedEventListener(onColorSchemeChanged);
		
		_isInitialized = true;
	}
}

/*****************************/
/* Redraw panel				 */
/*****************************/
private bool _redraw = false;
private void redraw() { _redraw = true; }
private bool shouldRedraw() { bool temp = _redraw; _redraw = false; return temp; }

/*****************************/
/* Color changed eventhandler*/
/*****************************/
private list[void(Color first, Color second)] colorschemeChangedEventListeners = [];

/**
 * Adds an event listener for the colorscheme changed event.
 */
public void sp_addColorschemeChangedEventListener(void(Color first, Color second) listener) {
	if(indexOf(colorschemeChangedEventListeners, listener) == -1) {
		colorschemeChangedEventListeners += [listener];
	}
}

/**
 * Trigger the colorscheme changed event listener.
 */
private void colorschemeChanged(Color first, Color second) {
	for(l <- colorschemeChangedEventListeners) l(first, second);
}

/**
 * Local event handler for selecting new colorscheme.
 */
 private void onColorSchemeChanged(Color first, Color second) {
 	_firstExample = first;
 	_secondExample = second;
 	redraw();
 }

/******************************/
/* Settings saved eventhandler*/
/******************************/
private list[void()] settingsSavedEventListeners = [];

/**
 * Adds an event listener for the settings saved event.
 */
public void sp_addSettingsSavedEventListener(void() listener) {
	if(indexOf(settingsSavedEventListeners, listener) == -1) {
		settingsSavedEventListeners += [listener];
	}
}

/**
 * Trigger the settings saved event listener.
 */
private void settingsSaved() {
	for(l <- settingsSavedEventListeners) l();
}

/**
 * Returns a Figure that allows the user to change settings.
 */
public Figure settingsPanel() {
	
	return computeFigure(
		shouldRedraw,
		Figure() {
			return panel(
				vcat([
					label("Choose color scheme"),
					choice(["\<leave unchanged\>"] + sort(toList(domain(colors))), colorChoiceChangedHandler, height(200), vresizable(false)),
					exampleColorLabel(),
					space(),
					myButton("Save settings...", saveButtonClickHandler, vresizable(false), height(44))
				]),
				"Settings"
			);
		}
	);
}

private Figure exampleColorLabel() {
	cscale = colorScale([0..10],_firstExample, _secondExample);

	return hcat([
		box(fillColor(cscale(i)), lineWidth(0)) | i <- [0..10]
		], height(40), vresizable(false));
}

/**
 * Color choice changed handler, executed when choice figure changed item.
 */
private void colorChoiceChangedHandler(str s) {
	if(s in colors) {
		colorschemeChanged(colors[s].first, colors[s].second);
	}	
}

/**
 * Click handler when save button is clicked.
 */
private void saveButtonClickHandler() {
	settingsSaved();
}


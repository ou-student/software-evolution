module Visualisation::Window

import Prelude;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Math;

import DataTypes;
import Main;

import Utils::MetricsInformation;

import Visualisation::ProjectBrowser;
import Visualisation::MethodInformationPanel;
import Visualisation::ComplexityTreemapPanel;
import Visualisation::AnalysisResults;
import Visualisation::Controls;

import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

private int currentIndex = 0;

/**
 * Event listener for project browser new location selected.
 */
void onPBNewLocationSelected(loc location) {
	if(isMethod(location)){
		mip_setCurrentMethod(location);
		currentIndex = 1;
	} else {
		ctp_setMethods(location.path, pb_getMethodsOfSelectedLocation());
		currentIndex = 2;
	}
	updateMaintainabilityRankingPanel();
}

/**
 * Event listener for MethodInformationPanel new selected method.
 */
void onMIPNewMethodSelected(loc method) {
	pb_setLocation(method);
	updateMaintainabilityRankingPanel();
}

/**
 * Event listener for complexity tree panel new selected method.
 */
void onCTPMethodSelected(loc method) {
	pb_setLocation(method);
	mip_setCurrentMethod(method);
	currentIndex = 1;
	updateMaintainabilityRankingPanel();
}

/**
 * Updates the maintainability ranking panel.
 */
void updateMaintainabilityRankingPanel(){
	currentProject = pb_getCurrentProject();
	results = mi_getResultsOfProject(currentProject);
	mrp_setResults(results);
}

/**
 * Module entry point method.
 */
void begin() {
	currentIndex = 0;

	bool miReInit = mi_initialize(false);
	pb_initialize(miReInit);
	
	pb_addNewLocationSelectedEventListener(onPBNewLocationSelected);
	pb_addProjectRefreshRequestEventListener(mi_refreshProjectMetrics);
	mip_addNewMethodSelectedEventListener(onMIPNewMethodSelected);
	
	ctp_addMethodSelectedEventListener(onCTPMethodSelected);
	
	render(
		page("Maintainance Analyzer",
			 menuBar([]),
			 createMain(
			 	panel(projectBrowser(), "", 0),
			 	maintainabilityRankingPanel(),
			 	fswitch(int(){return currentIndex;},[
			 		welcomePanel(),
			 		methodInformationPanel(),
			 		complexityTreemapPanel()
			 	])
				 ),
			 footer("Copyright by A. Walgreen & E. Postma ©2019\t")
		)
	);
}

/**
 * Creates a figure representing the main window.
 * @param leftTop The figure to put in the left top.
 * @param leftBottom The figure to put in the left bottom.
 * @param right The figure for the right side area.
 * @returns A Figure representing the composed main window.
 */
public Figure createMain(Figure leftTop, Figure leftBottom, Figure right) {
	return box(
		hcat(
		[
			vcat(
			[
				space(leftTop),
				space(leftBottom, resizable(false), height(120))
			], hsize(350), hresizable(false), vgap(48)),
			space(right)
		],
		gap(48), startGap(true), endGap(true)),
		fillColor(color("white", 0.0)), lineWidth(0)
	);
}

/**
 * Creates the welcome pannel.
 * @returns A Figure representing the welcome panel.
 */
private Figure welcomePanel() {
	return panel(
				text(
					"Select a project in the browser on the left to start", 
					center()
				), 
				"Welcome to the Maintainability Analyzer"
			);
}
module Tests::Utils::CoreExtensionTests

import Utils::CoreExtension;

test bool isAnonymous_Non_Anonymous_Method() {
	loc source = |java+method:///SlideViewerFrame/setupWindow(SlideViewerComponent,Presentation)|;
	result = isAnonymous(source);
	expectedResult = false;
	
	return result == expectedResult;
}

test bool isAnonymous_Anonymous_Method() {
	loc source = |java+method:///SlideViewerFrame/setupWindow(SlideViewerComponent,Presentation)/$anonymous1/windowClosing(java.awt.event.WindowEvent)|;
	result = isAnonymous(source);
	expectedResult = true;
	
	return result == expectedResult;
}
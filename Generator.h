/*
 * Commented Methods in Implementation.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <appkit/appkit.h>
#import "LifeView.h"

#define VERSION_STRING "Version 1.0a"

@interface Generator:Object
{
    id		generationField;
    id		lifeView;
    id		runButton;			//we need to change the icon
    id		runMenuButton;		//we need to change title
	id		filenameField;
	id		prefController;		//handles on prefcontroller
	id		infoGenerator;		//  and info controller
	id		randomGenerator;	//  and random generator
	id		samplesMenu;		//The samples submenu
	BOOL	running;			//Are we animating?
	char	*filename;			//The file loaded...
	DPSTimedEntry	runningTE;	//For animation
	int 	generation;
	double	speed;
	BOOL	menuLoaded;			//We need to contoll the number of times
								//we load the Sample Menu. Otherwise when
								//InfoPanle awakesFromNib, it will get reloaded
}

// initialize
- init;
- awakeFromNib;

// Action methods...
- clear:sender;
- runStop:sender;
- step:sender;

// File handling
- setFilename:(const char *)aFilename;
- saveAs:sender;
- save:sender;
- load:sender;
- loadFile:(const char *)aFilename;
- loadSample:sender;
- revertToSaved:sender;

// for animation
- go;
- removeTE;


// other nibs dynamically loaded...
- showInfo:sender;
- showLegal:sender;
- showPrefs:sender;
- startRandomTool:sender;

// the dynamic load of the Samples Menu.
- loadSamplesMenuFromDirectory:(const char *)aDirectory;
- addSampleMenuCell:(char *)aTitle;

//Various variable access
- setSpeed:sender;
- resetSizeTo:(IntNXSize)aSize;
- lifeView;
- setGeneration:(int)aGeneration;
- (int)generation;

// Mail Speaker...
- suggestion:sender;

// termination
- appWillTerminate:sender;
- free;

@end

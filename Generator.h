/*
 * Commented Methods in Implementation.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <AppKit/AppKit.h>
#import "LifeView.h"

@class InfoGenerator;
@class RandomGenerator;

#define VERSION_STRING "Version 1.0b"

@interface Generator: NSObject
{
	IBOutlet NSTextField   	*generationField;
	IBOutlet LifeView      	*lifeView;
	IBOutlet NSButton      	*runButton;			//we need to change the icon
	IBOutlet id		runMenuButton;		//we need to change title
	IBOutlet NSTextField   	*filenameField;
	IBOutlet id		prefController;		//handles on prefcontroller
	IBOutlet InfoGenerator 	*infoGenerator;		//  and info controller
	IBOutlet RandomGenerator *randomGenerator;	//  and random generator
	IBOutlet id		samplesMenu;		//The samples submenu
	BOOL	running;			//Are we animating?
	NSString	*filename;			//The file loaded...
	NSTimer	*runningTE;	//For animation
	int 	generation;
	double	speed;
	BOOL	menuLoaded;			//We need to contoll the number of times
								//we load the Sample Menu. Otherwise when
								//InfoPanle awakesFromNib, it will get reloaded
}

// initialize
- (id)init;
- (void)awakeFromNib;

// Action methods...
- (IBAction)clear:sender;
- (IBAction)runStop:sender;
- (IBAction)step:sender;

// File handling
- (void)setFilename:(NSString *)aFilename;
- (IBAction)saveAs:sender;
- (IBAction)save:sender;
- (IBAction)load:sender;
- (void)loadFile:(NSString *)aFilename;
- (IBAction)loadSample:sender;
- (IBAction)revertToSaved:sender;

// for animation
- (void)go;
- (void)removeTE;


// other nibs dynamically loaded...
- (IBAction)showInfo:sender;
- (IBAction)showLegal:sender;
- (IBAction)showPrefs:sender;
- (IBAction)startRandomTool:sender;

// the dynamic load of the Samples Menu.
- (void)loadSamplesMenuFromDirectory:(NSString *)aDirectory;
- (void)addSampleMenuCell:(NSString *)aTitle;

//Various variable access
- (IBAction)setSpeed:sender;
- (void)resetSizeTo:(IntNXSize)aSize;
- (LifeView*)lifeView;
- (void)setGeneration:(int)aGeneration;
- (int)generation;

// Mail Speaker...
- (IBAction)suggestion:sender;

// termination
- (void)appWillTerminate:sender;

@end

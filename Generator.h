/*
 * Commented Methods in Implementation.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <Cocoa/Cocoa.h>
#import "LifeView.h"
@class InfoGenerator;
@class PrefController;
@class RandomGenerator;

#define VERSION_STRING "Version 1.0a"

@interface Generator: NSObject <NSApplicationDelegate>
{
    IBOutlet NSTextField	*generationField;
    IBOutlet NSButton		*runButton;			//we need to change the icon
    IBOutlet NSMenuItem		*runMenuButton;		//we need to change title
	IBOutlet NSTextField	*filenameField;
	IBOutlet PrefController	*prefController;		//handles on prefcontroller
	IBOutlet InfoGenerator		*infoGenerator;		//  and info controller
	IBOutlet RandomGenerator	*randomGenerator;	//  and random generator
	IBOutlet NSMenu			*samplesMenu;		//The samples submenu
	BOOL	running;			//Are we animating?
	NSString	*filename;			//The file loaded...
	NSTimer	*runningTE;	//For animation
	int 	generation;
	NSTimeInterval	speed;
	BOOL	menuLoaded;			//We need to contoll the number of times
								//we load the Sample Menu. Otherwise when
								//InfoPanle awakesFromNib, it will get reloaded
}
@property (weak) IBOutlet LifeView *lifeView;

// initialize
- (instancetype)init;

// Action methods...
- (IBAction)clear:(id)sender;
- (IBAction)runStop:(id)sender;
- (IBAction)step:(id)sender;

// File handling
@property (nonatomic, copy) NSString *filename;
- (IBAction)saveAs:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)load:(id)sender;
- (BOOL)loadFile:(NSString *)aFilename;
- (IBAction)loadSample:(id)sender;
- (IBAction)revertToSaved:(id)sender;

// for animation
- (void)go;
- (void)removeTE;


// other nibs dynamically loaded...
- (IBAction)showInfo:(id)sender;
- (IBAction)showLegal:(id)sender;
- (IBAction)showPrefs:(id)sender;
- (IBAction)startRandomTool:(id)sender;

// the dynamic load of the Samples Menu.
- (void)loadSamplesMenuFromDirectory:(NSString *)aDirectory;
- (void)addSampleMenuCell:(NSString*)aTitle;

//Various variable access
- (IBAction)setSpeed:(id)sender;
- (void)resetSizeTo:(IntNXSize)aSize;
@property (nonatomic) int generation;

// Mail Speaker...
- (IBAction)suggestion:(id)sender;

// termination
//- appWillTerminate:(id)sender;

@end

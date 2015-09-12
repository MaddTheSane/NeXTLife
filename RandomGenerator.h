/*
 * Commented methods are in the implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */
#import <AppKit/AppKit.h>
#import "Generator.h"
@class LifeView;

#define	ISOTROPIC	0	// fotr the whichApply... 
#define	GAUSSIAN	1
#define	STEP		2


@interface RandomGenerator: NSObject
{
	IBOutlet NSTextField	*isoPercentField;	//Isotropic view density TextField
	IBOutlet NSTextField	*gaussPercentField;	//Gaussian view density TextField
	IBOutlet NSTextField	*gaussWidthField;	//Gaussian View width TextField
	IBOutlet id	stepDensityField;	//Step Distribution view density TextField
	IBOutlet id	stepWidthField;		//Step Dist. width TextField
	IBOutlet NSWindow *window;				//The window that get displayed
	IBOutlet Generator	*theGenerator;		//A pointer the the main generator so we can apply
	IBOutlet LifeView	*lifeView;			//The lifeView in the main generator
	IBOutlet NSBox	*isotropicView;		//the isotropic view (in the holding place)
	IBOutlet NSBox	*gaussianView;		//gaussian
	IBOutlet NSBox	*stepView;			//step
	IBOutlet NSBox	*multiView;			//the view that gets displayed in window
	char	*population;	//a population matrix
	int	popSize;			//it's size
	IntNXSize	theUniverse;//an integer NXSize (for the universe)
	int	whichApply;			//A flag to set which drawing we need to do.
}

- (void)awakeFromNib;
- (NSWindow*)window;
- (IBAction)setDistribution:sender;
- (IBAction)setDistToView:theView;
- (IBAction)apply:sender;

/* Different random draws */
- (void)isotropicDraw;
- (void)gaussianDraw;
- (void)stepDraw;

@end

/*
 * Commented methods are in the implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */
#import <Cocoa/Cocoa.h>
#import "Generator.h"
@class LifeView;

/// for the whichApply...
typedef NS_ENUM(NSInteger, WhichDraw) {
	RandomDrawIsotropic = 0,
	RandomDrawGaussian = 1,
	RandomDrawStep = 2
};
#define	ISOTROPIC	RandomDrawIsotropic
#define	GAUSSIAN	RandomDrawGaussian
#define	STEP		RandomDrawStep


@interface RandomGenerator: NSObject
{
    IBOutlet NSTextField	*isoPercentField;	//Isotropic view density TextField
	IBOutlet NSTextField	*gaussPercentField;	//Gaussian view density TextField
	IBOutlet NSTextField	*gaussWidthField;	//Gaussian View width TextField
	IBOutlet NSTextField	*stepDensityField;	//Step Distribution view density TextField
	IBOutlet NSTextField	*stepWidthField;		//Step Dist. width TextField
	IBOutlet Generator		*theGenerator;		//A pointer the the main generator so we can apply
	IBOutlet LifeView		*lifeView;			//The lifeView in the main generator
	IBOutlet NSBox	*isotropicView;		//the isotropic view (in the holding place)
	IBOutlet NSBox	*gaussianView;		//gaussian
	IBOutlet NSBox	*stepView;			//step
	IBOutlet NSBox	*multiView;			//the view that gets displayed in window
	char	*population;	//a population matrix
	int	popSize;			//its size
	IntNXSize	theUniverse;//an integer NXSize (for the universe)
	WhichDraw	whichApply;			//A flag to set which drawing we need to do.
}
////The window that get displayed
@property (weak) IBOutlet NSWindow *window;

- (IBAction)setDistribution:(id)sender;
- (void)setDistToView:(NSView*)theView;
- (IBAction)apply:(id)sender;

/* Different random draws */
- (void)isotropicDraw;
- (void)gaussianDraw;
- (void)stepDraw;

@end

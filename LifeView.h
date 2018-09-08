/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */

#import <Cocoa/Cocoa.h>
#import "LifeChar.h"

#define FONT_SIZE 4.0

//! An integer NSSize (for universe size)
typedef struct _IntNXSize {
	int	width, height;
} IntNXSize;


@interface LifeView: NSView
{
    IBOutlet id		zoomField;					//!< text field for zoom value
	CGFloat	zoomSize;
	IBOutlet NSMenuItem		*gridButton;	//!< the 'Show Grid' menu button
											//!< we need to change it's title
	char 	*population;    			// draw this population.
	int		popSize;					// how many?
	BOOL	gridOn;						// decide if grid is shown.	
	char	theLifeChar;				// the special char used 
	IBOutlet NSTextField	*popSizeField;
	IBOutlet id		cursor;
	IntNXSize	universe;				// the play field size 
}

+ (void)initialize;
- (instancetype)initWithFrame:(NSRect)frameRect;
- (void)resetFrame;
- (IBAction)showGrid:(id)sender;
/*! display this population (gets called by generators...) */
- (void)showPopulation:(char *)aPopulation ofSize:(int)aSize andUniverse:(IntNXSize)aUniverse;

/*! same as above with current universe */
- (void)showPopulation:(char *)aPopulation ofSize:(int)aSize;

/*!
 * This gets the population from LiveView. Note that only LifeView keeps the
 * uptodate population. This gets called by save methods...
 */
- (void)takePopulation:(char **)aPopulation andSize:(int *)sSize;

@property (nonatomic) IntNXSize universe;
@property (readonly,getter=popSize) int populationSize;
@property (nonatomic, setter=setLifeCharTo:) char lifeChar;
@property (nonatomic) CGFloat zoom;
- (IBAction)takeFloatSize:(id)sender;
- (void)setScrollersTo:(CGFloat)aFloat;
- (void)calculate:(char *)aPopulation;
- (void)calculate;

@end

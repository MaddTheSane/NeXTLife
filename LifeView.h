/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */

#import <Cocoa/Cocoa.h>
//#import "LifeChar.h"
@class LifeChar;

#define FONT_SIZE 4.0

typedef struct _IntNXSize {		//An integer NSSize (for universe size)
	int	width, height;
} IntNXSize;


@interface LifeView: NSView
{
    IBOutlet id		zoomField;					// text field for zoom value
	CGFloat	zoomSize;
	IBOutlet id		gridButton;					// the 'Show Grid' menu button
										// we need to change it's title 
	char 	*population;    			// draw this population.
	int		popSize;					// how many?
	BOOL	gridOn;						// decide if grid is shown.	
	char	theLifeChar;				// the special char used 
	IBOutlet id		popSizeField;
	IBOutlet id		cursor;
	IntNXSize	universe;				// the play field size 
}

+ (void)initialize;
- (instancetype)initWithFrame:(NSRect)frameRect;
- (void)resetFrame;
- (IBAction)showGrid:(id)sender;
- (void)showPopulation:(char *)aPopulation ofSize:(int)aSize andUniverse:(IntNXSize)aUniverse;
- (void)showPopulation:(char *)aPopulation ofSize:(int)aSize;
- (void)takePopulation:(char **)aPopulation andSize:(int *)sSize;
@property (nonatomic) IntNXSize universe;
@property (readonly,getter=popSize) int populationSize;
- (int)popSize;
@property (nonatomic, setter=setLifeCharTo:) char lifeChar;
@property (nonatomic) CGFloat zoom;
- (IBAction)takeFloatSize:(id)sender;
- (void)setScrollersTo:(CGFloat)aFloat;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)calculate:(char *)aPopulation;
- (void)calculate;

@end

/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */

#import <AppKit/AppKit.h>
#import "LifeChar.h"

#define FONT_SIZE 4.0

typedef struct _IntNXSize {		//An integer NXSize (for universe size)
	int	width, height;
} IntNXSize;


@interface LifeView: NSView
{
	IBOutlet NSSlider   	*zoomField;					// text field for zoom value 
	float	zoomSize;
	IBOutlet NSMenuItem	*gridButton;					// the 'Show Grid' menu button  
										// we need to change it's title 
	char 	*population;    			// draw this population.
	int		popSize;					// how many?
	BOOL	gridOn;						// decide if grid is shown.	
	char	theLifeChar;				// the special char used 
	IBOutlet NSTextField   	*popSizeField;
	//IBOutlet id		cursor;
	IntNXSize	universe;				// the play field size 
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)resetFrame;
- (IBAction)showGrid:sender;
- (void)showPopulation:(char *)aPopulation ofSize:(int)aSize andUniverse:(IntNXSize)aUniverse;
- (void)showPopulation:(char *)aPopulation ofSize:(int)aSize;
- (void)takePopulation:(char **)aPopulation andSize:(int *)sSize;
- (IntNXSize)universe;
- (int)popSize;
- (void)setUniverse:(IntNXSize)aUniverse;
- (void)setLifeChar:(char)aChar;
- (char)lifeChar;
- (void)setZoom:(float)zoomSize;
- (IBAction)takeFloatSize:sender;
- (void)setScrollersTo:(float)aFloat;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)calculate:(char *)aPopulation;
- (void)calculate;

@end

/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */

#import <appkit/appkit.h>
#import "LifeChar.h"

#define FONT_SIZE 4.0

typedef struct _IntNXSize {		//An integer NXSize (for universe size)
	int	width, height;
} IntNXSize;


@interface LifeView:View
{
    id		zoomField;					// text field for zoom value 
	float	zoomSize;
	id		gridButton;					// the 'Show Grid' menu button  
										// we need to change it's title 
	char 	*population;    			// draw this population.
	int		popSize;					// how many?
	BOOL	gridOn;						// decide if grid is shown.	
	char	theLifeChar;				// the special char used 
	id		popSizeField;
	id		cursor;
	IntNXSize	universe;				// the play field size 
}

+ initialize;
- initFrame:(NXRect *)frameRect;
- resetFrame;
- showGrid:sender;
- drawSelf:(const NXRect *)rects :(int)rectCount;
- showPopulation:(char *)aPopulation ofSize:(int)aSize andUniverse:(IntNXSize)aUniverse;
- showPopulation:(char *)aPopulation ofSize:(int)aSize;
- takePopulation:(char **)aPopulation andSize:(int *)sSize;
- (IntNXSize)universe;
- (int)popSize;
- setUniverse:(IntNXSize)aUniverse;
- setLifeCharTo:(char)aChar;
- (char)lifeChar;
- setZoom:(float)zoomSize;
- takeFloatSize:sender;
- setScrollersTo:(float)aFloat;
- mouseDown:(NXEvent *)theEvent;
- (void)calculate:(char *)aPopulation;
- calculate;
- free;

@end

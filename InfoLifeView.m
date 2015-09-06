/*
 * InfoLifeView is a life view with some texts for the Titles and stuff. 
 * It is used for a nifty InfoPanel. Some people (see Help) clued me in on
 * the way to dislpay stuff in the background...
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import "InfoLifeView.h"

@implementation InfoLifeView

- initFrame:(NXRect *)frameRect
{
	int i;
	[super initFrame:frameRect];
	if(population) free(population);
	zoomSize = 1.5;		/* init zoom Size */
	
	universe.height = 60;
	universe.width  = 60;
	population = malloc(sizeof(char)*universe.height*universe.width);
	for (i = 0; i<universe.width*universe.height; i++) {
		population[i] = 0;
	}
	[super initFrame:frameRect];
	[self sizeTo:(float)(FONT_SIZE*universe.width) 	
							:(float)(FONT_SIZE*universe.height) ];
	[self setDrawSize:(float)universe.width :(float)universe.height];
	[self setDrawOrigin:-0.5 :-0.5];
	[self setOpaque:NO];
	return [self display];
}

/* overwrite drawself. We don't need grid, and we want to draw in gray. 
 * Also we need to draw the text each time on top.
 */
- drawSelf:(const NXRect *)rects :(int)rectCount
{
	float	oldX = 0.0, oldY = 0.0;			/* Hold the last full one */
	float 	*xyPositions;					/* pairs of positions...	  */
	char	*charString;					/* put enough 'special' chars */
	float	firstX = 0.0, firstY = 0.0;			/* hold the first for xyshow */
	int		i, j;

	PSWDefineFont("LifeFont",1.0);			/* Get the special font */ 	
	
	/* Allocate the correct memory size */
	xyPositions = calloc( 2*popSize - 1, sizeof(float) );
	charString  = calloc( popSize + 1, sizeof(char) );
	
	/* Fill in the character */
	for(j=0; j< popSize; j++) {
		charString[j] = 'a';
	}
	charString[popSize] = 0;
	
	/* skip begining of population array */	
	i=0;
	while( (population[i++] == 0) && (i<universe.width*universe.height) );
	j = i - 1;
	if(population[j]==10) {
		firstX = (float)(j % universe.width) - oldX;
		firstY = (float)(j / universe.width) - oldY;
		oldY = (float)( j / universe.width );
		oldX = (float)( j % universe.width );
	}
	
	/* continue the array. Now we need relative distances				*/
	j = 0;
	for(; i < universe.width*universe.height; i++) {
		if(population[i] == 10) {
			xyPositions[2*j]     = (float)( i % universe.width ) - oldX;
			xyPositions[2*j + 1] = (float)( i / universe.width ) - oldY;
			oldY = (float)( i / universe.width );
			oldX = (float)( i % universe.width );
			j++;
		}
	}
	/* Now we draw, at last */
 	PSsetgray(NX_LTGRAY);	
	NXRectFill(&bounds);			/* for the background */
	PSsetgray(NX_DKGRAY);
	PSWXYShow( firstX, firstY, charString, xyPositions, 2*popSize);
	[popSizeField setIntValue:popSize];
	/* free old stuff */
	cfree(xyPositions);
	cfree(charString);
	
	/* Now for text drawing. We disable flush window, so that we can 
	 * flush all at once. Otherwise it flickers a lot. 
	 */
	[[self window] disableFlushWindow];
	[copyrightText display];
	[versionText display];
	[authorText display];
	[theAppButton display];
	[theBox display];
	[theTitle display]; 
	[[[self window] reenableFlushWindow] flushWindow];
	return self;
}

/* disable mouse down drawing */
- mouseDown:(NXEvent *)theEvent
{
	return self;
}

- window
{
	return window;
}

- free
{
	free(population);
	[super free];
	return self;
}

@end

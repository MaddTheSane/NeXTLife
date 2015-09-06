/*
 * LifeView. Displays a Life Universe. Knows how too display a population.
 * Also can compute the next generation.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import "LifeView.h"

@implementation LifeView

+ initialize
{
	static NXDefaultsVector LifeDefaults = { //Default Defaults...
		{"UniverseHeight", "120"},
		{"UniverseWidth", "120"},
		{"Mail", "Warn"},
		{"LifeSymbol", "0"},
		{ NULL, NULL }
	};
	NXRegisterDefaults("LifeByGR",LifeDefaults);
	return self;
}

- initFrame:(NXRect *)frameRect
{
	int i;
		
	zoomSize = 1.5;		/* init zoom Size */
	
	if(population) free(population);
	universe.height = atoi(NXGetDefaultValue("LifeByGR","UniverseHeight"));
	universe.width  = atoi(NXGetDefaultValue("LifeByGR","UniverseWidth"));
	population = malloc(sizeof(char)*universe.height*universe.width);
	for (i = 0; i<universe.width*universe.height; i++) {
		population[i] = 0;
	}
	
	/* set the life form symbol. */
	theLifeChar = 'a' + atoi(NXGetDefaultValue("LifeByGR","LifeSymbol"));
	[super initFrame:frameRect];
	[self sizeTo:(float)(FONT_SIZE*universe.width) 	
							:(float)(FONT_SIZE*universe.height) ];
	[self setDrawSize:(float)universe.width :(float)universe.height];
	[self setDrawOrigin:-0.5 :-0.5];
	[self setOpaque:YES];	
	return [self display];
}

/* we need this method when we zoom, or change shape... */
- resetFrame
{
	NXRect	obounds = bounds;
	
	[self convertRectToSuperview:&obounds];
	[self sizeTo:(float)(zoomSize*universe.width*FONT_SIZE)
							:(float)(zoomSize*universe.height*FONT_SIZE)];
	[self setDrawSize:(float)universe.width :(float)universe.height];
	[self setDrawOrigin:-0.5 :-0.5];
	[self convertRectFromSuperview:&obounds];
	return [self display];
}

/* doesn't work and not used..., yet */
- setScrollersTo:(float)aFloat
{
	id theScrollview = [[self superview] superview];
	
	[ [ theScrollview horizScroller] setFloatValue:aFloat ];
	[ [ theScrollview  vertScroller] setFloatValue:aFloat ];
	
	return self;
}


- showGrid:sender
{
	if(!gridOn) {
		gridOn = YES;
		[gridButton setTitle:"Hide Grid"];
	}
	else {
		gridOn = NO;
		[gridButton setTitle:"Show Grid"];
	}
	return [self display];
}

/* the drawing method. Note the fancy zyshow! */
- drawSelf:(const NXRect *)rects :(int)rectCount
{
	float	oldX = 0.0, oldY = 0.0;			/* Hold the last full one */
	float 	*xyPositions;					/* pairs of positions...	  */
	char	*charString;					/* put enough 'special' chars */
	float	firstX = 0.0, firstY = 0.0;			/* hold the first for xyshow */
	int		i, j;

	PSWDefineFont("LifeFont",1.0);			/* Get the special font */

 	PSsetgray(NX_WHITE);	
	NXRectFill(&bounds);			/* for the white background */
 	
	/* draw the Grid, if gridOn */
	if (gridOn) {
		float tmp = -0.5;
		float shftHeight = (float)universe.height - 0.5;
		float shftWidth = (float)universe.width - 0.5;
		
		PSWDefs();
		while(tmp < shftWidth) {
			PSWMakeLineBind(tmp,-0.5,tmp,shftHeight);
			tmp += 1.0;
		}
		tmp = -0.5;
		while(tmp < shftHeight) {
			PSWMakeLineBind(-0.5,tmp,shftWidth,tmp);
			tmp += 1.0;
		}
		PSWStrokeLineBind(0.15,NX_LTGRAY);
	}
	/* Allocate the correct memory size */
	xyPositions = calloc( 2*popSize - 1, sizeof(float) );
	charString  = calloc( popSize + 1, sizeof(char) );
	
	/* Fill in the character */
	for(j=0; j< popSize; j++) {
		charString[j] = theLifeChar;
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
	/* debugging printf... 
	printf("drawSelf::\n");
	printf("popSize = %d\n",popSize);
	printf("charStrings = %s\n",charString);
	for(j=universe.height-1;j>=0;j--) {
		for(i=0;i<universe.width;i++) {
			printf("%3d",population[j*universe.width+i]);
		}
		printf("\n");
	}
	printf("\n");
	*/
	/* Now we draw, at last */
	PSsetgray(NX_BLACK);
	PSWXYShow( firstX, firstY, charString, xyPositions, 2*popSize);
	[popSizeField setIntValue:popSize];
	/* free old stuff */
	cfree(xyPositions);
	cfree(charString);
	
	return self;
}

/* display this population (gets called by generators...) */
- showPopulation:(char *)aPopulation 
						ofSize:(int)aSize 
						andUniverse:(IntNXSize)aUniverse
{
	int i;
	
	if(population) {
		free(population);
	}
	
	universe.width = aUniverse.width;
	universe.height = aUniverse.height;
	
	population = malloc(sizeof(char)*universe.width*universe.height);
	
	for(i=0; i< universe.width*universe.height; i++) {
		population[i] = aPopulation[i];
	}
	popSize = aSize;
	return [self resetFrame];
}

/* save as above with current universe */
- showPopulation:(char *)aPopulation ofSize:(int)aSize
{
	[self showPopulation:aPopulation ofSize:aSize andUniverse:universe];
	return self;
}

/* this get the population from LiveView. Note that only LifeView keeps the
 * uptodate population. This gets called by save methods...
 */
- takePopulation:(char **)aPopulation andSize:(int *)aSize
{
	*aPopulation = population;
	*aSize = popSize;
	return self;
}

/* access to variables */
- (IntNXSize)universe
{
	return universe;
}

- (int)popSize
{
	return popSize;
}

/* set new size */
- setUniverse:(IntNXSize)aUniverse
{
	universe.width  = aUniverse.width;
	universe.height = aUniverse.height;

	[self sizeTo:(float)(FONT_SIZE*universe.width) 	
								:(float)(FONT_SIZE*universe.height) ];
	[self setDrawSize:(float)universe.width :(float)universe.height];
	[self setDrawOrigin:-0.5 :-0.5];

	return self;
}

- setLifeCharTo:(char)aChar;
{
	theLifeChar = aChar;
	return self;
}

- (char)lifeChar
{
	return theLifeChar;
}

- setZoom:(float)aSize
{
	zoomSize = aSize;
	return [self resetFrame];
}

- takeFloatSize:sender
{
	[self setZoom:[sender floatValue] ];
	return self;
}

/* draws a new cell, or deletes old cell. this should get highly modified */
- mouseDown:(NXEvent *)theEvent
{
	int tmp;
	NXPoint center = theEvent->location;		/* get mouse location 		*/

	[self convertPoint:&center fromView:nil];	/* convert to view coords 	*/
	tmp = ((int)(center.y+0.5)) * universe.height + ((int) (center.x+0.5));
	if(population[tmp] == 10) {
		population[tmp] = 0;
		popSize--;
	}
	else {
		population[tmp] = 10;
		popSize++;
	}	
	return [self display];
}

/* calculate new population. This algorithm was lifted from another Life 
 * program by Peter ?,  peter_oleski@hh.maus.de.
 */
- (void)calculate:(char *)aPopulation
{
	register int i,j;
	int 	newPopSize=0;
	register char *rp = aPopulation+universe.width+1,*ws;
	
	for(j=1; j< universe.height-1; j++) {
	    for(i=1; i< universe.width-1; i++) {
			if(*rp > 9) {
				ws=rp-universe.width-1;
				*ws+=1; ws++;
				*ws+=1; ws++;
				*ws+=1; ws+=universe.width-2;
				*ws+=1; ws+=2;
				*ws+=1; ws+=universe.width-2;
				*ws+=1; ws++;
				*ws+=1; ws++;
				*ws+=1;
			}
		rp++;
	    }
	rp+=2;
	}
	
	rp = aPopulation;
		
	for(i=0; i<universe.width*universe.height; i++) {
		if(*rp) {
			if((*rp==12) || (*rp==13) || (*rp==3)) {
		    	*rp=10;
				newPopSize++;
			}
			else {
		  		*rp=0;
			}
		}
		rp++;
	}
	popSize = newPopSize;
}

- calculate
{
	[self calculate:population];
	return self;
}

- free
{
	free(population);
	[super free];
	return self;
}

@end

/*
 * A random distribution generator tool. knows how to get different views
 * from a holding place and display them in another view. There is a 
 * pop-down menu in the nib file (Random.nib), that chooses which one.
 *
 * Copyright (c) 1993 Gil Rivlis
 */
#import "RandomGenerator.h"

/* just a short cut */
double distance(double x, double y, double centerX, double centerY)
{
	return (x-centerX)*(x-centerX)+ (y-centerY)*(y-centerY);
}

@implementation RandomGenerator

/* When we awakeFromNib we set the initial choice for a view. */
- (void)awakeFromNib
{
	whichApply = ISOTROPIC;
	[self setDistToView:[isotropicView contentView] ];
}

/* Returns the window, so we can orderFront when initializing */ 
- window
{
	return window;
}

/* Gets called by the pop-up menu and sets the distribution view we want */
- (IBAction)setDistribution:sender
{
	id newView = nil;
	
	whichApply = [[sender selectedCell] tag]; //tagged as in the header file
	
	switch (whichApply) {
		case ISOTROPIC: 
				newView = [isotropicView contentView];
				break;
		case GAUSSIAN: 
				newView = [gaussianView	contentView];
				break;
		case STEP: 
				newView = [stepView contentView];
				break;
	}
	[self setDistToView:newView];
}

/* Sets the wanted view in multiView (which is the only view we actually see */
- (void)setDistToView:(NSBox*)theView
{
	NSRect	boxRect, viewRect;
	boxRect = [multiView frame];
	viewRect = [theView frame];
	
	[multiView setContentView:theView];
	viewRect.origin.x = (boxRect.size.width - viewRect.size.width) / 2.0;
        viewRect.origin.y = (boxRect.size.height - viewRect.size.height) / 2.0;
	
	[theView setFrame:viewRect];
	[multiView display];
}

/* obvious */
- (IBAction)apply:sender
{
	switch (whichApply) {
		case ISOTROPIC: [self isotropicDraw];
						break;
		case GAUSSIAN:	[self gaussianDraw];
						break;
		case STEP:		[self stepDraw];
						break;
	}
}

/* constant distribution draw */
- (void)isotropicDraw
{
	int i;
	float	density	= [isoPercentField floatValue]; // How dense ?

	lifeView = [theGenerator lifeView];
	theUniverse = [lifeView universe];
	popSize = 0;						// reset popSize locally
	
	// Allocate enough memory
	population = malloc(sizeof(char)*theUniverse.width*theUniverse.height);
	srand( (unsigned) time(NULL) % UINT_MAX );
	
	for (i=0; i<theUniverse.width*theUniverse.height; i++) {
		if ( (rand() % 100) < density ) { //rand modulo 100...
			population[i] = 10;
			popSize++;
		}
		else {
			population[i] = 0;
		}
	}
	[theGenerator clear:nil];
	[lifeView showPopulation:population ofSize:popSize]; // display
	free(population);
}

- (void)gaussianDraw
{
	int x,y;
	float	density	= [gaussPercentField floatValue];	  // the density
	float	width	= [gaussWidthField   floatValue]/2.0;  // make it radius
	double	centerX,centerY,radsq;
	
	lifeView = [theGenerator lifeView];
	theUniverse = [lifeView universe];
	
	/* don't compute too much... */
	radsq =(width*(double)(theUniverse.width)/100.0)*
						(width*(double)(theUniverse.width)/100.0);							
	centerX = theUniverse.width/2;
	centerY = theUniverse.height/2;
	
	popSize = 0;
	
	population = malloc(sizeof(char)*theUniverse.width*theUniverse.height);
	
	srand( (unsigned) time(NULL) % UINT_MAX );
	
	for (y=0; y<theUniverse.height;y++) {
		for(x=0; x<theUniverse.width;x++) {
			if ( ((int)density % 100)*exp(((-1)*distance((double)x, (double)y, centerX, centerY) )/radsq ) > (rand() % 100)) {
				population[y*theUniverse.width + x] = 10;
				popSize++;
			}
			else {
				population[y*theUniverse.width + x] = 0;
			}
		}
	}
			
	[theGenerator clear:nil];
	[lifeView showPopulation:population ofSize:popSize];
	free(population);
}

/* fixed density at the center with some width */
- (void)stepDraw
{
	int x,y;
	float	density	= [stepDensityField floatValue];	  // the density
	float	width	= [stepWidthField   floatValue]/2.0;  // make it radius
	double	centerX,centerY,radsq;
	
	lifeView = [theGenerator lifeView];
	theUniverse = [lifeView universe];
	
	/* don't compute too much... */
	radsq =(width*(double)(theUniverse.width)/100.0)*
						(width*(double)(theUniverse.width)/100.0);							
	centerX = theUniverse.width/2;
	centerY = theUniverse.height/2;
	
	popSize = 0;
	
	population = malloc(sizeof(char)*theUniverse.width*theUniverse.height);
	
	srand( (unsigned) time(NULL) % UINT_MAX );
	
	for (y=0; y<theUniverse.height;y++) {
		for(x=0; x<theUniverse.width;x++) {
			if ( ((rand() % 100) < density) && 
			( distance((double)x, (double)y, centerX, centerY) < radsq) ) {
				population[y*theUniverse.width + x] = 10;
				popSize++;
			}
			else {
				population[y*theUniverse.width + x] = 0;
			}
		}
	}
			
	[theGenerator clear:nil];
	[lifeView showPopulation:population ofSize:popSize];
	free(population);
}

@end

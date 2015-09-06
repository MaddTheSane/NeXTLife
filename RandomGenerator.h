/*
 * Commented methods are in the implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */
#import <appkit/appkit.h>
#import "Generator.h"

#define	ISOTROPIC	0	// fotr the whichApply... 
#define	GAUSSIAN	1
#define	STEP		2


@interface RandomGenerator:Object
{
    id	isoPercentField;	//Isotropic view density TextField
	id	gaussPercentField;	//Gaussian view density TextField
	id	gaussWidthField;	//Gaussian View width TextField
	id	stepDensityField;	//Step Distribution view density TextField
	id	stepWidthField;		//Step Dist. width TextField
    id	window;				//The window that get displayed
	id	theGenerator;		//A pointer the the main generator so we can apply
	id	lifeView;			//The lifeView in the main generator
	id	isotropicView;		//the isotropic view (in the holding place)
	id	gaussianView;		//gaussian
	id	stepView;			//step
	id	multiView;			//the view that gets displayed in window
	char	*population;	//a population matrix
	int	popSize;			//it's size
	IntNXSize	theUniverse;//an integer NXSize (for the universe)
	int	whichApply;			//A flag to set which drawing we need to do.
}

- awakeFromNib;
- window;
- setDistribution:sender;
- setDistToView:theView;
- apply:sender;

/* Different random draws */
- isotropicDraw;
- gaussianDraw;
- stepDraw;

@end

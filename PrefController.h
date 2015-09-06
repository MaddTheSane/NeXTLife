/*
 * Commented methods are in the implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */
#import <appkit/appkit.h>

@interface PrefController:Object
{
    id	universeHeightField;	
    id	universeWidthField;
	id	shapeMatrix;			//Life form shapes radio button matrix
	id	window;					//See RandomGenerator...
	id	theGenerator;			
	id	sizeView;
	id	shapeView;
	id	multiView;
	int	whichOne;				//which preference are we doing now?
}

- awakeFromNib;
- window;
- setToView:theView;
- setPrefView:sender;

- save:sender;
- useNow:sender;

@end

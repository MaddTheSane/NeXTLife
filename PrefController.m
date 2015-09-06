/*
 * Preference Controller. Similar to RandomGenerator it displays views 
 * view from a holding place in a view according to a pop-up menu.
 *
 * Copyright (c) 1993 Gil Rivlis
 */ 
 
#import "PrefController.h"
#import "Generator.h"

#define SIZE_PREF 	0	//whichOne?
#define SHAPE_PREF 	1

@implementation PrefController

- awakeFromNib
{
	whichOne = SIZE_PREF;
	
	/* get the default universe size and display in the appropriate fields */
	[universeHeightField
		setIntValue:(atoi(NXGetDefaultValue("LifeByGR","UniverseHeight")))];
	[universeWidthField
		setIntValue:(atoi(NXGetDefaultValue("LifeByGR","UniverseWidth")))];
	
	/* get the default shape and selcted the appropriate button */
	[shapeMatrix selectCellWithTag:((int)([[theGenerator lifeView] lifeChar]) 
					- (int)('a'))];
	
	[self setToView:[sizeView contentView] ];
	return self;
}

- window
{
	return window;
}

/* see RandomGenerator */
- setToView:theView
{
	NXRect	boxRect, viewRect;
	
	[multiView getFrame:&boxRect];
	[theView getFrame:&viewRect];
	
	[multiView setContentView:theView];
	NX_X(&viewRect) = (NX_WIDTH(&boxRect)-NX_WIDTH(&viewRect)) / 2.0;
	NX_Y(&viewRect) = (NX_HEIGHT(&boxRect)-NX_HEIGHT(&viewRect)) / 2.0;
	
	[theView setFrame:&viewRect];
	[multiView display];
	return self;
}

/* see Random Generator */
- setPrefView:sender
{
	id newView = nil;
	whichOne = [[sender selectedCell] tag];
	switch (whichOne) {
		case SIZE_PREF: 
				newView = [sizeView contentView];
				break;
		case SHAPE_PREF: 
				newView = [shapeView contentView];
				break;
	}
	[self setToView:newView];
	return self;
}

/* saves the new preferences in the default database */
- save:sender
{
	char 	buf[256];
	static NXDefaultsVector newDefaults = {
		{"UniverseHeight",""},		/* 0 */
		{"UniverseWidth", ""},		/* 1 */
		{"Mail", ""},				/* 2 */
		{"LifeSymbol", ""},			/* 3 */
		{NULL, NULL}
	};
	
	sprintf(buf,"%d",[universeHeightField intValue]);
	newDefaults[0].value = alloca(256);
	strcpy(newDefaults[0].value,buf);
	
	sprintf(buf,"%d",[universeWidthField intValue]);
	newDefaults[1].value = alloca(256);
	strcpy(newDefaults[1].value,buf);
	
	sprintf(buf,"%s", NXGetDefaultValue("LifeByGR","Mail"));
	newDefaults[2].value = alloca(256);
	strcpy(newDefaults[2].value,buf);
	
	sprintf(buf,"%d", [[shapeMatrix selectedCell] tag]);
	newDefaults[3].value = alloca(256);
	strcpy(newDefaults[3].value,buf);

	
	NXWriteDefaults("LifeByGR", newDefaults);

    return self;
}

/* if we want to actually use it in the current game */
- useNow:sender
{
	IntNXSize newSize;
	id theLifeView = [theGenerator lifeView];
	
	switch (whichOne) {
		case SIZE_PREF:
				newSize.width = [universeWidthField intValue];
				newSize.height = [universeHeightField intValue];
				[theGenerator resetSizeTo:newSize];
				break;
		case SHAPE_PREF:
				[ theLifeView setLifeCharTo:'a'
							+[[shapeMatrix selectedCell] tag] ];
				[ theLifeView display];
				break;
	}
	
	return self;
}

@end

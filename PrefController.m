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

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	whichOne = SIZE_PREF;
	
	/* get the default universe size and display in the appropriate fields */
	[universeHeightField
                setIntValue:[defaults integerForKey:@"UniverseHeight"]];
	[universeWidthField
                setIntValue:[defaults integerForKey:@"UniverseWidth"]];
	
	/* get the default shape and selcted the appropriate button */
	[shapeMatrix selectCellWithTag:((int)([[theGenerator lifeView] lifeChar]) 
					- (int)('a'))];
	
	[self setToView:[sizeView contentView] ];
}

- window
{
	return window;
}

/* see RandomGenerator */
- (void)setToView:(NSBox*)theView
{
	NSRect	boxRect, viewRect;
	boxRect = [multiView frame];
	viewRect = [theView frame];
		
	[multiView setContentView:theView];
	viewRect.origin.x = (boxRect.size.width - viewRect.size.width) / 2.0;
	viewRect.origin.y = (boxRect.size.height - viewRect.size.height) / 2.0;

	[theView setFrame:viewRect];
	[multiView setNeedsDisplay:YES];
}

/* see Random Generator */
- (IBAction)setPrefView:sender
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
}

/* saves the new preferences in the default database */
- (IBAction)save:sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setInteger: [universeHeightField intValue] forKey: @"UniverseHeight"];
	[defaults setInteger: [universeWidthField intValue] forKey: @"UniverseWidth"];
	[defaults setInteger: [[shapeMatrix selectedCell] tag] forKey: @"LifeSymbol"];
	[defaults synchronize];
}

/* if we want to actually use it in the current game */
- (IBAction)useNow:sender
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
				[ theLifeView setLifeChar:'a'
							+[[shapeMatrix selectedCell] tag] ];
				[ theLifeView display];
				break;
	}
}

@end

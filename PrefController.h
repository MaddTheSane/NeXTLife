/*
 * Commented methods are in the implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */
#import <AppKit/AppKit.h>
@class Generator;

@interface PrefController: NSObject
{
	IBOutlet NSTextField	*universeHeightField;	
	IBOutlet NSTextField	*universeWidthField;
	IBOutlet NSMatrix	*shapeMatrix;			//Life form shapes radio button matrix
	IBOutlet NSWindow	*window;    			//See RandomGenerator...
	IBOutlet Generator	*theGenerator;			
	IBOutlet NSBox	*sizeView;
	IBOutlet NSBox	*shapeView;
	IBOutlet NSBox	*multiView;
	int	whichOne;				//which preference are we doing now?
}

- (void)awakeFromNib;
- (NSWindow*)window;
- (IBAction)setToView:theView;
- (IBAction)setPrefView:sender;

- (IBAction)save:sender;
- (IBAction)useNow:sender;

@end

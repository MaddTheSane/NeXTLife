/*
 * Commented methods are in the implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis 
 */
#import <Cocoa/Cocoa.h>

@class Generator;

@interface PrefController: NSObject
{
    IBOutlet NSTextField	*universeHeightField;
    IBOutlet NSTextField	*universeWidthField;
	IBOutlet NSMatrix		*shapeMatrix;			//Life form shapes radio button matrix
	IBOutlet Generator		*theGenerator;
	IBOutlet NSBox		*sizeView;
	IBOutlet NSBox		*shapeView;
	IBOutlet NSBox		*multiView;
	NSInteger	whichOne;				//which preference are we doing now?
}

@property (readonly, weak) IBOutlet NSWindow *window;//See RandomGenerator...

- (void)awakeFromNib;
- (void)setToView:(NSView*)theView;
- (IBAction)setPrefView:(id)sender;

- (IBAction)save:(id)sender;
- (IBAction)useNow:(id)sender;

@end

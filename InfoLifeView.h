/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <Cocoa/Cocoa.h>

#import "LifeView.h"

@interface InfoLifeView: LifeView
{
	IBOutlet NSTextField	*versionText;		//Additional variables for the info view.
	IBOutlet NSTextField	*copyrightText;
	IBOutlet NSTextField	*authorText;
	IBOutlet NSButton	*theAppButton;
	IBOutlet NSBox		*theBox;
	IBOutlet id	theTitle;
}

//new implementaions needed... and a new method 
- (instancetype)initWithFrame:(NSRect)frameRect;
//- drawSelf:(const NSRect *)rects :(int)rectCount;
- (void)mouseDown:(NSEvent *)theEvent;

@end

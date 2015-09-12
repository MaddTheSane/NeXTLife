/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <AppKit/AppKit.h>

#import "LifeView.h"

@interface InfoLifeView: LifeView
{
	IBOutlet NSTextField	*versionText;		//Additional variables for the info view.
	IBOutlet NSTextField	*copyrightText;
	IBOutlet NSTextField	*authorText;
	IBOutlet NSButton	*theAppButton;
	IBOutlet NSBox 	*theBox;
	IBOutlet NSTextField	*theTitle;
}

//new implementaions needed... and a new method 
- (id)initWithFrame:(NSRect)frameRect;
- (void)mouseDown:(NSEvent *)theEvent;

@end

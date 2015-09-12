/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <AppKit/AppKit.h>

#import "LifeView.h"

@interface InfoLifeView: LifeView
{
	IBOutlet id	versionText;		//Additional variables for the info view.
	IBOutlet id	copyrightText;
	IBOutlet id	authorText;
	IBOutlet id	theAppButton;
	IBOutlet id  	theBox;
	IBOutlet id	theTitle;
}

//new implementaions needed... and a new method 
- (id)initWithFrame:(NSRect)frameRect;
- (void)mouseDown:(NSEvent *)theEvent;
- (NSWindow*)window;

@end

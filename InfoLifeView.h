/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <appkit/appkit.h>

#import "LifeView.h"

@interface InfoLifeView:LifeView
{
	id	versionText;		//Additional variables for the info view.
	id	copyrightText;
	id	authorText;
	id	theAppButton;
	id  theBox;
	id	theTitle;
}

//new implementaions needed... and a new method 
- initFrame:(NXRect *)frameRect;
- drawSelf:(const NXRect *)rects :(int)rectCount;
- mouseDown:(NXEvent *)theEvent;
- window;
- free;

@end

/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <AppKit/AppKit.h>

#import "Generator.h"
@class InfoLifeView;

@interface InfoGenerator: Generator
{
	IBOutlet InfoLifeView	*infoLifeView;
	IBOutlet id	panel;
	IBOutlet NSWindow *window;
}

- (NSWindow*)window;
- (id)panel;
- (void)resetSpeed:(float)aSpeed;

@end

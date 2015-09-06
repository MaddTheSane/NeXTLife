/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <Cocoa/Cocoa.h>

#import "Generator.h"

@interface InfoGenerator: Generator
{
    IBOutlet id	infoLifeView;
    IBOutlet id	panel;
    IBOutlet id	window;
}

- window;
- panel;
- resetSpeed:(float)aSpeed;

@end

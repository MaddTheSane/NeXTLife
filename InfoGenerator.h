/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <Cocoa/Cocoa.h>

#import "Generator.h"

@class InfoLifeView;

@interface InfoGenerator: Generator
{
    IBOutlet InfoLifeView	*infoLifeView;
}

@property (weak) IBOutlet NSPanel *panel;
@property (weak) IBOutlet NSWindow *window;

- (void)resetSpeed:(float)aSpeed;

@end

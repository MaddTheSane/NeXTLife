/*
 * commented methods in implementation file.
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import <appkit/appkit.h>

#import "Generator.h"

@interface InfoGenerator:Generator
{
    id	infoLifeView;
    id	panel;
    id	window;
}

- window;
- panel;
- resetSpeed:(float)aSpeed;

@end

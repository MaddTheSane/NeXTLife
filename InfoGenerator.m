/*
 * InfoGenerator is a generator so we can run the Life evolution. 
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import "InfoGenerator.h"
#import "InfoLifeView.h"

@implementation InfoGenerator
@synthesize panel;
@synthesize window;

- (void)resetSpeed:(float)aSpeed
{
	speed = aSpeed;
}

@end

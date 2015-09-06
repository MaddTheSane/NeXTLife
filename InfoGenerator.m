/*
 * InfoGenerator is a generator so we can run the Life evolution. 
 *
 * Copyright (c) 1993 Gil Rivlis
 */

#import "InfoGenerator.h"

@implementation InfoGenerator

- window
{
	return window;
}

- panel
{
	return panel;
}

- resetSpeed:(float)aSpeed
{
	speed = aSpeed;
	return self;
}

@end

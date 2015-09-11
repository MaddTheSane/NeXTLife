//
//  LifeChar.m
//  NeXTLife
//
//  Created by C.W. Betts on 9/5/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LifeChar.h"

void XYShow(NSPoint firstXY, NSString *charString, const NSPoint positions[], NSInteger count)
{
	
}

void MakeLineBind(NSPoint p1, NSPoint p2)
{
	
}

void StrokeLineBind(CGFloat LineWidth, NSColor *lineColor)
{
	
}

void DefineFont(NSString *fontname, CGFloat size)
{
	[[NSFont fontWithName:fontname size:size] set];
}

#pragma mark - wrappers over old functions

void PSWMakeLineBind(float x, float y, float x1, float y1)
{
	MakeLineBind(NSMakePoint(x, y), NSMakePoint(x1, y1));
}

void PSWXYShow(float X, float Y, const char *charString, const float XYCoords[], int j)
{
	j &= ~1; //Make sure we have an even number!
	NSPoint *positions = calloc(sizeof(NSPoint), j);
	for (NSInteger i = 0; i <= j; j += 2) {
		positions[i / 2] = NSMakePoint(XYCoords[i], XYCoords[i + 1]);
	}
	
	XYShow(NSMakePoint(X, Y), @(charString), positions, j / 2);
	
	free(positions);
}

void PSWStrokeLineBind(float LineWidth, float LineColor)
{
	StrokeLineBind(LineWidth, [NSColor colorWithCalibratedWhite:LineColor alpha:1.0]);
}

void PSWDefineFont(const char *fontname, int size)
{
	DefineFont(@(fontname), size);
}

void PSWDefs()
{
	
}

//
//  LifeChar.h
//  NeXTLife
//
//  Created by C.W. Betts on 9/5/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>


void XYShow(NSPoint firstXY, NSString *charString, const NSPoint positions[], NSInteger count);
void DefineFont(NSString *fontname, CGFloat size);
void MakeLineBind(NSPoint p1, NSPoint p2);
void StrokeLineBind(CGFloat LineWidth, NSColor *lineColor);

#pragma mark old function names
void PSWXYShow(float X, float Y, const char *charString, const float XYCoords[], int j) DEPRECATED_ATTRIBUTE;
void PSWDefineFont(const char *fontname, int size) DEPRECATED_ATTRIBUTE;
void PSWMakeLineBind(float x, float y, float x1, float y1) DEPRECATED_ATTRIBUTE;
void PSWStrokeLineBind(float LineWidth, float LineColor) DEPRECATED_ATTRIBUTE;
void PSWDefs(void) DEPRECATED_ATTRIBUTE;

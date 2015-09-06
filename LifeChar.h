//
//  LifeChar.h
//  NeXTLife
//
//  Created by C.W. Betts on 9/5/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 defineps PSWXYShow(float X, Y; char *charString;
 float numstring XYCoords[j]; int j)
*/

#define PSWDefs()

void XYShow(NSPoint firstXY, NSString *charString, const NSPoint positions[], NSInteger count );


#pragma mark old function names
void PSWXYShow(float X, float Y, char *charString, float XYCoords[], int j) DEPRECATED_ATTRIBUTE;
void PSWDefineFont(char *fontname, int size) DEPRECATED_ATTRIBUTE;
void PSWMakeLineBind(float x, float y, float x1, float y1) DEPRECATED_ATTRIBUTE;
void PSWStrokeLineBind(float LineWidth, float LineColor) DEPRECATED_ATTRIBUTE;

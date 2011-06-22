//
//  MathUtils.m
//  Slate
//
//  Created by Jigish Patel on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MathUtils.h"


@implementation MathUtils

+ (BOOL)isRect:(NSRect)rect1 biggerThan:(NSRect)rect2 {
  return rect1.size.width*rect1.size.height > rect2.size.width*rect2.size.height;
}

// I understand that the following method is stupidly written. Apple apparently enjoys keeping
// multiple types of coordinate spaces. NSScreen.origin returns bottom-left while we need
// top-left for window moving. Go figure.
+ (NSRect)flipYCoordinateOfRect:(NSRect)original withReference:(NSRect)reference {
  return NSMakeRect(original.origin.x,
                    reference.size.height - (reference.origin.y + original.origin.y + original.size.height),
                    original.size.width,
                    original.size.height);
}

+ (NSRect)scaleRect:(NSRect)rect factor:(double)factor {
  return NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width*factor, rect.size.height*factor);
}

+ (NSRect)weightedIntersectionOf:(NSRect)rect1 and:(NSRect)rect2 weight:(double)weight {
  NSRect intersection = NSIntersectionRect(rect1, rect2);
  if (NSEqualRects(intersection, NSZeroRect)) return NSZeroRect;
  return [MathUtils scaleRect:intersection factor:weight];
}

@end

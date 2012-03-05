//
//  MathUtils.m
//  Slate
//
//  Created by Jigish Patel on 6/22/11.
//  Copyright 2011 Jigish Patel. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see http://www.gnu.org/licenses

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

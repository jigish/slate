//
//  NSColor+Conversions.h
//  Slate
//
//  Created by Jigish Patel on 3/3/12.
//  Copyright 2012 Jigish Patel. All rights reserved.
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

#import "NSColor+Conversions.h"

@implementation NSColor (Conversions)

- (CGColorRef)cgColor {
  NSColor *colorRGB = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
  CGFloat components[4];
  [colorRGB getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
  CGColorSpaceRef theColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
  CGColorRef theColor = CGColorCreate(theColorSpace, components);
  CGColorSpaceRelease(theColorSpace);
  return theColor;
}

+ (NSColor *)colorWithCGColor:(CGColorRef)aColor {
  const CGFloat *components = CGColorGetComponents(aColor);
  CGFloat red = components[0];
  CGFloat green = components[1];
  CGFloat blue = components[2];
  CGFloat alpha = components[3];
  return [self colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}

@end

//
//  ResizeOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
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

#import "Constants.h"
#import "ResizeOperation.h"


@implementation ResizeOperation

@synthesize anchor;
@synthesize xResize;
@synthesize yResize;

- (id)init {
  self = [super init];
  
  if (self) {
    [self setMoveFirst:NO];
  }
  
  return self;
}

- (id)initWithAnchor:(NSString *)a xResize:(NSString *)x yResize:(NSString *)y {
  self = [self init];
  if (self) {
    if ([a isEqualToString:TOP_LEFT] || [a isEqualToString:TOP_RIGHT] || [a isEqualToString:BOTTOM_LEFT] || [a isEqualToString:BOTTOM_RIGHT]) {
      [self setAnchor:a];
    } else {
      NSLog(@"ERROR: Unrecognized anchor '%s'", [a cStringUsingEncoding:NSASCIIStringEncoding]);
      return nil;
    }
    [self setXResize:x];
    [self setYResize:y];
  }
  return self;
}

- (NSPoint) getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
  if ([anchor isEqualToString:TOP_LEFT]) {
    return cTopLeft;
  } else if ([anchor isEqualToString:TOP_RIGHT]) {
    NSInteger x = cTopLeft.x + cSize.width - nSize.width;
    NSInteger y = cTopLeft.y;
    return NSMakePoint(x,y);
  } else if ([anchor isEqualToString:BOTTOM_LEFT]) {
    NSInteger x = cTopLeft.x;
    NSInteger y = cTopLeft.y + cSize.height - nSize.height;
    return NSMakePoint(x,y);
  } else if ([anchor isEqualToString:BOTTOM_RIGHT]) {
    NSInteger x = cTopLeft.x + cSize.width - nSize.width;
    NSInteger y = cTopLeft.y + cSize.height - nSize.height;
    return NSMakePoint(x,y);
  }
  return NSMakePoint(0,0);
}

// Assumes well-formed resize +100 or -10%
- (NSInteger) resizeStringToInt:(NSString *)resize withValue:(NSInteger) val {
  NSInteger sign = [resize hasPrefix:MINUS] ? -1 : 1;
  NSString *magnitude = [resize stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:EMPTY];
  
  if ([magnitude hasSuffix:PERCENT]) {
    magnitude = [magnitude stringByReplacingOccurrencesOfString:PERCENT withString:EMPTY];
    return (sign * val * [magnitude integerValue] / 100);
  } else {
    return (sign * [magnitude integerValue]);
  }
}

- (NSSize) getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize {
  NSInteger dimX = cSize.width + [self resizeStringToInt:xResize withValue:cSize.width];
  NSInteger dimY = cSize.height + [self resizeStringToInt:yResize withValue:cSize.height];
  return NSMakeSize(dimX,dimY);
}

- (void)dealloc {
  [self setAnchor:nil];
  [self setXResize:nil];
  [self setYResize:nil];
  [super dealloc];
}

@end

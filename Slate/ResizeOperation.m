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

#import "AccessibilityWrapper.h"
#import "Constants.h"
#import "ResizeOperation.h"
#import "SlateConfig.h"


@implementation ResizeOperation

@synthesize anchor;
@synthesize xResize;
@synthesize yResize;

- (id)init {
  self = [super init];
  
  if (self) {
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

- (BOOL)doOperation:(AccessibilityWrapper *)aw {
  BOOL success = NO;
  NSPoint cTopLeft = [aw getCurrentTopLeft];
  NSSize cSize = [aw getCurrentSize];
  NSSize nSize = [self getDimensionsWithCurrentTopLeft:cTopLeft currentSize:cSize];
  if (!NSEqualSizes(cSize, nSize)) {
    success = [aw resizeWindow:nSize];
    NSSize realNewSize = [aw getCurrentSize];
    NSPoint nTopLeft = [self getTopLeftWithCurrentTopLeft:cTopLeft currentSize:cSize newSize:realNewSize];
    success = [aw moveWindow:nTopLeft] && success;
  }
  return success;
}

- (BOOL)doOperation {
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) {
    success = [self doOperation:aw];
  }
  [aw release];
  return success;
}

- (BOOL)testOperation {
  BOOL success = YES;
  NSPoint cTopLeft = NSMakePoint(0, 0);
  NSSize cSize = NSMakeSize(1000, 1000);
  NSSize nSize = [self getDimensionsWithCurrentTopLeft:cTopLeft currentSize:cSize];
  [self getTopLeftWithCurrentTopLeft:cTopLeft currentSize:cSize newSize:nSize];
  return success;
}

- (NSPoint)getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
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
- (NSInteger)resizeStringToInt:(NSString *)resize withValue:(NSInteger) val {
  NSInteger sign = [resize hasPrefix:MINUS] ? -1 : 1;
  NSString *magnitude = [resize stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:EMPTY];
  
  if ([magnitude hasSuffix:PERCENT]) {
    magnitude = [magnitude stringByReplacingOccurrencesOfString:PERCENT withString:EMPTY];
    return (sign * val * [magnitude integerValue] / 100);
  } else {
    return (sign * [magnitude integerValue]);
  }
}

- (NSSize)getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize {
  NSInteger sizeX = 0;
  NSInteger sizeY = 0;
  NSArray *screens = [NSScreen screens];
  NSScreen *screen = [screens objectAtIndex:0];
  NSPoint topLeftZeroed = NSMakePoint(cTopLeft.x, 0);
  if (!NSPointInRect(topLeftZeroed, [screen frame])) {
    for (NSUInteger i = 1; i < [screens count]; i++) {
      topLeftZeroed = NSMakePoint(cTopLeft.x, 0);
      screen = [screens objectAtIndex:i];
      if (NSPointInRect(topLeftZeroed, [screen frame])) {
        break;
      }
    }
  }
  sizeX = cSize.width;
  sizeY = cSize.height;
  NSString *resizePercentOf = [[SlateConfig getInstance] getConfig:RESIZE_PERCENT_OF] != nil ? [[SlateConfig getInstance] getConfig:RESIZE_PERCENT_OF] : @"windowSize";
  if ([resizePercentOf isEqualToString:@"screenSize"]) {
    sizeX = [screen visibleFrame].size.width;
    sizeY = [screen visibleFrame].size.height;
  }
  NSInteger dimX = cSize.width + [self resizeStringToInt:xResize withValue:sizeX];
  NSInteger dimY = cSize.height + [self resizeStringToInt:yResize withValue:sizeY];
  return NSMakeSize(dimX,dimY);
}

- (void)dealloc {
  [self setAnchor:nil];
  [self setXResize:nil];
  [self setYResize:nil];
  [super dealloc];
}

@end

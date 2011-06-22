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
#import "ScreenWrapper.h"
#import "SlateConfig.h"


@implementation ResizeOperation

@synthesize anchor;
@synthesize xResize;
@synthesize yResize;

- (id)init {
  self = [super init];
  return self;
}

- (id)initWithAnchor:(NSString *)a xResize:(NSString *)x yResize:(NSString *)y {
  self = [self init];
  if (self) {
    if ([a isEqualToString:TOP_LEFT]) {
      [self setAnchor:ANCHOR_TOP_LEFT];
    } else if ([a isEqualToString:TOP_RIGHT]) {
      [self setAnchor:ANCHOR_TOP_RIGHT];
    } else if ([a isEqualToString:BOTTOM_LEFT]) {
      [self setAnchor:ANCHOR_BOTTOM_LEFT];
    } else if ([a isEqualToString:BOTTOM_RIGHT]) {
      [self setAnchor:ANCHOR_BOTTOM_RIGHT];
    } else {
      NSLog(@"ERROR: Unrecognized anchor '%@'", a);
      return nil;
    }
    [self setXResize:x];
    [self setYResize:y];
  }
  return self;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = NO;
  NSPoint cTopLeft = [aw getCurrentTopLeft];
  NSSize cSize = [aw getCurrentSize];
  NSRect cWindowRect = NSMakeRect(cTopLeft.x, cTopLeft.y, cSize.width, cSize.height);
  NSSize nSize = [self getDimensionsWithCurrentWindow:cWindowRect screenWrapper:sw];
  if (!NSEqualSizes(cSize, nSize)) {
    success = [aw resizeWindow:nSize];
    NSSize realNewSize = [aw getCurrentSize];
    NSPoint nTopLeft = [self getTopLeftWithCurrentWindow:cWindowRect newSize:realNewSize];
    success = [aw moveWindow:nTopLeft] && success;
  }
  return success;
}

- (BOOL)doOperation {
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) success = [self doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
  [sw release];
  [aw release];
  return success;
}

- (BOOL)testOperation {
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  NSRect cWindowRect = NSMakeRect(0, 0, 1000, 1000);
  NSSize nSize = [self getDimensionsWithCurrentWindow:cWindowRect screenWrapper:sw];
  [self getTopLeftWithCurrentWindow:cWindowRect newSize:nSize];
  [sw release];
  return YES;
}

- (NSPoint)getTopLeftWithCurrentWindow:(NSRect)cWindowRect newSize:(NSSize)nSize {
  NSPoint cTopLeft = cWindowRect.origin;
  NSSize cSize = cWindowRect.size;
  if (anchor == ANCHOR_TOP_LEFT) {
    return cTopLeft;
  } else if (anchor == ANCHOR_TOP_RIGHT) {
    NSInteger x = cTopLeft.x + cSize.width - nSize.width;
    NSInteger y = cTopLeft.y;
    return NSMakePoint(x,y);
  } else if (anchor == ANCHOR_BOTTOM_LEFT) {
    NSInteger x = cTopLeft.x;
    NSInteger y = cTopLeft.y + cSize.height - nSize.height;
    return NSMakePoint(x,y);
  } else if (anchor == ANCHOR_BOTTOM_RIGHT) {
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

- (NSSize)getDimensionsWithCurrentWindow:(NSRect)cWindowRect screenWrapper:(ScreenWrapper *)sw {
  NSSize cSize = cWindowRect.size;
  NSInteger sizeX = cSize.width;
  NSInteger sizeY = cSize.height;
  NSString *resizePercentOf = [[SlateConfig getInstance] getConfig:RESIZE_PERCENT_OF defaultValue:RESIZE_PERCENT_OF_DEFAULT];
  if ([resizePercentOf isEqualToString:SCREEN_SIZE]) {
    NSInteger screenId = [sw getScreenId:REF_CURRENT_SCREEN windowRect:cWindowRect];
    if (![sw screenExists:screenId]) {
      return cSize;
    }
    NSSize screenSize = [sw convertScreenVisibleRectToWindowCoords:screenId].size;
    sizeX = screenSize.width;
    sizeY = screenSize.height;
  }
  NSInteger dimX = cSize.width + [self resizeStringToInt:xResize withValue:sizeX];
  NSInteger dimY = cSize.height + [self resizeStringToInt:yResize withValue:sizeY];
  return NSMakeSize(dimX,dimY);
}

- (void)dealloc {
  [self setXResize:nil];
  [self setYResize:nil];
  [super dealloc];
}

@end

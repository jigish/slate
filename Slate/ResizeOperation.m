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
#import "StringTokenizer.h"
#import "SlateLogger.h"

@implementation ResizeOperation

@synthesize anchor;
@synthesize xResize;
@synthesize yResize;

- (id)init {
  self = [super init];
  if (self) {
    [self setAnchor:ANCHOR_TOP_LEFT];
    [self setXResize:@"+0"];
    [self setYResize:@"+0"];
  }
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
      SlateLogger(@"ERROR: Unrecognized anchor '%@'", a);
      return nil;
    }
    [self setXResize:x];
    [self setYResize:y];
  }
  return self;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = NO;
  [self evalOptionsWithAccessibilityWrapper:aw screenWrapper:sw];
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
  SlateLogger(@"----------------- Begin Resize Operation -----------------");
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) success = [self doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
  SlateLogger(@"-----------------  End Resize Operation  -----------------");
  return success;
}

- (BOOL)testOperation {
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  NSRect cWindowRect = NSMakeRect(0, 0, 1000, 1000);
  NSSize nSize = [self getDimensionsWithCurrentWindow:cWindowRect screenWrapper:sw];
  [self getTopLeftWithCurrentWindow:cWindowRect newSize:nSize];
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
  NSString *resizePercentOf = [[SlateConfig getInstance] getConfig:RESIZE_PERCENT_OF];
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

- (void)parseOption:(NSString *)name value:(NSString *)value {
  // all options should be strings
  if (value == nil) { return; }
  if (![value isKindOfClass:[NSString class]]) {
    @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", name, value] userInfo:nil]);
  }
  if ([name isEqualToString:OPT_WIDTH]) {
    [self setXResize:value];
  } else if ([name isEqualToString:OPT_HEIGHT]) {
    [self setYResize:value];
  } else if ([name isEqualToString:OPT_ANCHOR]) {
    if ([value isEqualToString:TOP_LEFT]) {
      [self setAnchor:ANCHOR_TOP_LEFT];
    } else if ([value isEqualToString:TOP_RIGHT]) {
      [self setAnchor:ANCHOR_TOP_RIGHT];
    } else if ([value isEqualToString:BOTTOM_LEFT]) {
      [self setAnchor:ANCHOR_BOTTOM_LEFT];
    } else if ([value isEqualToString:BOTTOM_RIGHT]) {
      [self setAnchor:ANCHOR_BOTTOM_RIGHT];
    } else {
      SlateLogger(@"ERROR: Unrecognized anchor '%@'", value);
      @throw([NSException exceptionWithName:@"Unrecognized Anchor" reason:[NSString stringWithFormat:@"ERROR: Unrecognized anchor '%@'", value] userInfo:nil]);
    }
  }
}

+ (id)resizeOperation {
  return [[ResizeOperation alloc] init];
}

+ (id)resizeOperationFromString:(NSString *)resizeOperation {
  // resize <x> <y> <optional:anchor>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:resizeOperation into:tokens];

  if ([tokens count] < 3) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", resizeOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Resize operations require the following format: 'resize resizeX resizeY [optional:anchor]'", resizeOperation] userInfo:nil]);
  }

  NSString *anchor = TOP_LEFT;
  if ([tokens count] >= 4) {
    anchor = [tokens objectAtIndex:3];
  }
  Operation *op = [[ResizeOperation alloc] initWithAnchor:anchor xResize:[tokens objectAtIndex:1] yResize:[tokens objectAtIndex:2]];
  return op;
}

@end

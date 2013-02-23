//
//  MoveOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
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
#import "MoveOperation.h"
#import "ScreenWrapper.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"

@implementation MoveOperation

@synthesize topLeft;
@synthesize dimensions;
@synthesize monitor;
@synthesize screenId;

- (id)init {
  self = [super init];
  if (self) {
    [self setTopLeft:[[ExpressionPoint alloc] initWithX:@"" y:@""]];
    [self setDimensions:[[ExpressionPoint alloc] initWithX:@"" y:@""]];
    [self setMonitor:REF_CURRENT_SCREEN];
    [self setScreenId:-1];
  }
  return self;
}

- (id)initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(NSString *)mon {
  self = [self init];
  if (self) {
    NSArray *tlTokens = [tl componentsSeparatedByString:SEMICOLON];
    if ([tlTokens count] == 2) {
      [self setTopLeft:[[ExpressionPoint alloc] initWithX:[tlTokens objectAtIndex:0] y:[tlTokens objectAtIndex:1]]];
    } else {
      tlTokens = [tl componentsSeparatedByString:COMMA];
      if ([tlTokens count] == 2) {
        [self setTopLeft:[[ExpressionPoint alloc] initWithX:[tlTokens objectAtIndex:0] y:[tlTokens objectAtIndex:1]]];
      } else {
        return nil;
      }
    }
    NSArray *dimTokens = [dim componentsSeparatedByString:SEMICOLON];
    if ([dimTokens count] == 2) {
      [self setDimensions:[[ExpressionPoint alloc] initWithX:[dimTokens objectAtIndex:0] y:[dimTokens objectAtIndex:1]]];
    } else {
      dimTokens = [dim componentsSeparatedByString:COMMA];
      if ([dimTokens count] == 2) {
        [self setDimensions:[[ExpressionPoint alloc] initWithX:[dimTokens objectAtIndex:0] y:[dimTokens objectAtIndex:1]] ];
      } else {
        return nil;
      }
    }
    [self setMonitor:mon];
    [self setScreenId:-1];
  }

  return self;
}

- (id)initWithTopLeftEP:(ExpressionPoint *)tl dimensionsEP:(ExpressionPoint *)dim screenId:(NSInteger)myScreenId {
  self = [self init];
  if (self) {
    [self setTopLeft:tl];
    [self setDimensions:dim];
    [self setScreenId:myScreenId];
    [self setMonitor:nil];
  }

  return self;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = NO;
  [self evalOptionsWithAccessibilityWrapper:aw screenWrapper:sw];
  NSPoint cTopLeft = [aw getCurrentTopLeft];
  NSSize cSize = [aw getCurrentSize];
  NSRect cWindowRect = NSMakeRect(cTopLeft.x, cTopLeft.y, cSize.width, cSize.height);
  NSSize nSize = [self getDimensionsWithCurrentWindowRect:cWindowRect screenWrapper:sw];
  success = [aw resizeWindow:nSize];
  NSSize realNewSize = [aw getCurrentSize];
  NSPoint nTopLeft = [self getTopLeftWithCurrentWindowRect:cWindowRect newSize:realNewSize screenWrapper:sw];
  success = [aw moveWindow:nTopLeft] && success;
  success = [aw resizeWindow:nSize] && success;
  return success;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Move Operation -----------------");
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) success = [self doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
  SlateLogger(@"-----------------  End Move Operation  -----------------");
  return success;
}

- (BOOL)testOperation {
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  NSPoint cTopLeft = NSMakePoint(0, 0);
  NSSize cSize = NSMakeSize(1000, 1000);
  NSRect cWindowRect = NSMakeRect(cTopLeft.x, cTopLeft.y, cSize.width, cSize.height);
  NSSize nSize = [self getDimensionsWithCurrentWindowRect:cWindowRect screenWrapper:sw];
  [self getTopLeftWithCurrentWindowRect:cWindowRect newSize:nSize screenWrapper:sw];
  return YES;
}

- (NSPoint)getTopLeftWithCurrentWindowRect:(NSRect)cWindowRect newSize:(NSSize)nSize screenWrapper:(ScreenWrapper *)sw {
  // If monitor does not exist send back the same origin
  if (monitor != nil) {
    [self setScreenId:[sw getScreenId:monitor windowRect:cWindowRect]];
  }
  if (![sw screenExists:[self screenId]]) return cWindowRect.origin;
  NSDictionary *values = [sw getScreenAndWindowValues:screenId window:cWindowRect newSize:nSize];
  return [topLeft getPointWithDict:values];
}

- (NSSize)getDimensionsWithCurrentWindowRect:(NSRect)cWindowRect screenWrapper:(ScreenWrapper *)sw {
  // If monitor does not exist send back the same size
  if (monitor != nil) {
    [self setScreenId:[sw getScreenId:monitor windowRect:cWindowRect]];
  }
  if (![sw screenExists:[self screenId]]) return cWindowRect.size;
  NSDictionary *values = [sw getScreenAndWindowValues:screenId window:cWindowRect newSize:cWindowRect.size];
  return [dimensions getSizeWithDict:values];
}

- (NSArray *)requiredOptions {
  return [NSArray arrayWithObjects:OPT_X, OPT_Y, OPT_WIDTH, OPT_HEIGHT, nil];
}

- (void)parseOption:(NSString *)name value:(id)val {
  // all options should be strings
  if (val == nil) { return; }
  NSString *value = nil;
  if ([val isKindOfClass:[NSString class]]) {
    value = val;
  } else if ([val isKindOfClass:[NSNumber class]]) {
    value = [val stringValue];
  } else {
    @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", name, val] userInfo:nil]);
    return;
  }
  [[self options] setValue:value forKey:name];
  if ([name isEqualToString:OPT_X]) {
    [[self topLeft] setX:value];
  } else if ([name isEqualToString:OPT_Y]) {
    [[self topLeft] setY:value];
  } else if ([name isEqualToString:OPT_SCREEN]) {
    [self setMonitor:value];
  } else if ([name isEqualToString:OPT_WIDTH]) {
    [[self dimensions] setX:value];
  } else if ([name isEqualToString:OPT_HEIGHT]) {
    [[self dimensions] setY:value];
  }
}

+ (id)moveOperation {
  return [[MoveOperation alloc] init];
}

+ (id)moveOperationFromString:(NSString *)moveOperation {
  // move <topLeft> <dimensions> <optional:monitor>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:moveOperation into:tokens];

  if ([tokens count] < 3) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", moveOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Move operations require the following format: 'move topLeftX;topLeftY width;height [optional:screemNumber]'", moveOperation] userInfo:nil]);
  }

  Operation *op = nil;
  op = [[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:1] dimensions:[tokens objectAtIndex:2] monitor:([tokens count] >=4 ? [tokens objectAtIndex:3] : REF_CURRENT_SCREEN)];
  return op;
}

@end

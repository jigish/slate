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


@implementation MoveOperation

@synthesize topLeft;
@synthesize dimensions;
@synthesize monitor;
@synthesize moveFirst;

- (id)init {
  self = [super init];
  [self setMoveFirst:YES];
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
  }

  return self;
}

- (id)initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(NSString *)mon moveFirst:(BOOL)mf {
  self = [self initWithTopLeft:tl dimensions:dim monitor:mon];
  if (self) {
    [self setMoveFirst:mf];
  }
  
  return self;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = NO;
  NSPoint cTopLeft = [aw getCurrentTopLeft];
  NSSize cSize = [aw getCurrentSize];
  NSRect cWindowRect = NSMakeRect(cTopLeft.x, cTopLeft.y, cSize.width, cSize.height);
  NSSize nSize = [self getDimensionsWithCurrentWindowRect:cWindowRect screenWrapper:sw];
  if (moveFirst) {
    NSPoint nTopLeft = [self getTopLeftWithCurrentWindowRect:cWindowRect newSize:nSize screenWrapper:sw];
    success = [aw moveWindow:nTopLeft];
    success = [aw resizeWindow:nSize] && success;
  } else {
    success = [aw resizeWindow:nSize];
    NSSize realNewSize = [aw getCurrentSize];
    NSPoint nTopLeft = [self getTopLeftWithCurrentWindowRect:cWindowRect newSize:realNewSize screenWrapper:sw];
    success = [aw moveWindow:nTopLeft] && success;
  }
  return success;
}

- (BOOL)doOperation {
  NSLog(@"----------------- Begin Move Operation -----------------");
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) success = [self doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
  [sw release];
  [aw release];
  NSLog(@"-----------------  End Move Operation  -----------------");
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
  NSInteger screenId = [sw getScreenId:monitor windowRect:cWindowRect];
  if (![sw screenExists:screenId]) return cWindowRect.origin;
  NSDictionary *values = [sw getScreenAndWindowValues:screenId window:cWindowRect newSize:nSize];
  return [topLeft getPointWithDict:values];
}

- (NSSize)getDimensionsWithCurrentWindowRect:(NSRect)cWindowRect screenWrapper:(ScreenWrapper *)sw {
  // If monitor does not exist send back the same size
  NSInteger screenId = [sw getScreenId:monitor windowRect:cWindowRect];
  if (![sw screenExists:screenId]) return cWindowRect.size;
  NSDictionary *values = [sw getScreenAndWindowValues:screenId window:cWindowRect newSize:cWindowRect.size];
  return [dimensions getSizeWithDict:values];
}

- (void)dealloc {
  [self setTopLeft:nil];
  [self setDimensions:nil];
  [super dealloc];
}

@end

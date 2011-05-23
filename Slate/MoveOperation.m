//
//  MoveOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoveOperation.h"


@implementation MoveOperation

@synthesize topLeft;
@synthesize dimensions;
@synthesize monitor;

- (id)init {
  self = [super init];
  if (self) {
    // Initialization code here.
  }

  return self;
}

- (id) initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(int)mon {
  self = [super init];
  if (self) {
    NSArray *tlTokens = [tl componentsSeparatedByString:@","];
    if ([tlTokens count] >=2) {
      topLeft = [[ExpressionPoint alloc] initWithX:[tlTokens objectAtIndex:0] y:[tlTokens objectAtIndex:1]];
    } else {
      topLeft = [[ExpressionPoint alloc] init];
    }
    NSArray *dimTokens = [dim componentsSeparatedByString:@","];
    if ([dimTokens count] >=2) {
      dimensions = [[ExpressionPoint alloc] initWithX:[dimTokens objectAtIndex:0] y:[dimTokens objectAtIndex:1]];
    } else {
      dimensions = [[ExpressionPoint alloc] init];
    }
    monitor = mon;
  }

  return self;
}

- (NSPoint) getTopLeftWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  NSScreen *screen = nil;
  if (monitor == -1) {
    NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
    while ((screen = [screenEnum nextObject]) && !NSPointInRect(cTopLeft, [screen frame]));
  } else {
    NSArray *screens = [NSScreen screens];
    screen = [screens objectAtIndex:monitor];
  }
  NSRect screenRect = [screen visibleFrame];
  NSPoint screenOrigin = screenRect.origin;
  NSSize screenSize = screenRect.size;
  NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:screenOrigin.x], @"screenOriginX", 
                          [NSNumber numberWithInteger:screenOrigin.y], @"screenOriginY", 
                          [NSNumber numberWithInteger:screenSize.width], @"screenSizeX", 
                          [NSNumber numberWithInteger:screenSize.height], @"screenSizeY", 
                          [NSNumber numberWithInteger:cSize.width], @"windowSizeX", 
                          [NSNumber numberWithInteger:cSize.height], @"windowSizeY", 
                          [NSNumber numberWithInteger:cTopLeft.x], @"windowTopLeftX", 
                          [NSNumber numberWithInteger:cTopLeft.y], @"windowTopLeftY", nil];
  return [topLeft getPointWithDict:values];
}

- (NSSize) getDimensionsWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  NSScreen *screen = nil;
  if (monitor == -1) {
    NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
    while ((screen = [screenEnum nextObject]) && !NSPointInRect(cTopLeft, [screen frame]));
  } else {
    NSArray *screens = [NSScreen screens];
    screen = [screens objectAtIndex:monitor];
  }
  NSRect screenRect = [screen visibleFrame];
  NSPoint screenOrigin = screenRect.origin;
  NSSize screenSize = screenRect.size;
  NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:screenOrigin.x], @"screenOriginX", 
                          [NSNumber numberWithInteger:screenOrigin.y], @"screenOriginY", 
                          [NSNumber numberWithInteger:screenSize.width], @"screenSizeX", 
                          [NSNumber numberWithInteger:screenSize.height], @"screenSizeY", 
                          [NSNumber numberWithInteger:cSize.width], @"windowSizeX", 
                          [NSNumber numberWithInteger:cSize.height], @"windowSizeY", 
                          [NSNumber numberWithInteger:cTopLeft.x], @"windowTopLeftX", 
                          [NSNumber numberWithInteger:cTopLeft.y], @"windowTopLeftY", nil];
  return [dimensions getSizeWithDict:values];
}

- (void)dealloc {
  [super dealloc];
}

@end

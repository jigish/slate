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

// I understand that the following method is stupidly written. Apple apparently enjoys keeping
// multiple types of coordinate spaces. NSScreen.origin returns bottom-left while we need
// top-left for window moving. Go figure.
- (NSDictionary *) getScreenAndWindowValues: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  int originX = 0;
  int originY = 0;
  int sizeX = 0;
  int sizeY = 0;
  if (monitor == -1) {
    NSUInteger i = 0;
    NSArray *screens = [NSScreen screens];
    NSScreen *screen = [screens objectAtIndex:0];
    int prevHeight = [screen visibleFrame].size.height;
    int prevOriginY = [screen visibleFrame].origin.y;
    while (i < [screens count] && !NSPointInRect(cTopLeft, [screen frame])) {
      screen = [screens objectAtIndex:i];
      originX = [screen visibleFrame].origin.x;
      originY = originY + (prevOriginY - [screen visibleFrame].origin.y) - (prevHeight - [screen visibleFrame].size.height);
      i++;
    }
    sizeX = [screen visibleFrame].size.width;
    sizeY = [screen visibleFrame].size.height;
  } else {
    NSArray *screens = [NSScreen screens];
    NSScreen *screen = [screens objectAtIndex:0];
    int prevHeight = [screen visibleFrame].size.height;
    int prevOriginY = [screen visibleFrame].origin.y;
    for (NSUInteger i = 1; i <= monitor; i++) {
      screen = [screens objectAtIndex:i];
      originX = [screen visibleFrame].origin.x;
      originY = originY + (prevOriginY - [screen visibleFrame].origin.y) - (prevHeight - [screen visibleFrame].size.height);
    }
    sizeX = [screen visibleFrame].size.width;
    sizeY = [screen visibleFrame].size.height;
  }
  return [NSDictionary dictionaryWithObjectsAndKeys:
           [NSNumber numberWithInteger:originX], @"screenOriginX", 
           [NSNumber numberWithInteger:originY], @"screenOriginY", 
           [NSNumber numberWithInteger:sizeX], @"screenSizeX", 
           [NSNumber numberWithInteger:sizeY], @"screenSizeY", 
           [NSNumber numberWithInteger:cSize.width], @"windowSizeX", 
           [NSNumber numberWithInteger:cSize.height], @"windowSizeY", 
           [NSNumber numberWithInteger:cTopLeft.x], @"windowTopLeftX", 
           [NSNumber numberWithInteger:cTopLeft.y], @"windowTopLeftY", nil];
}

- (NSPoint) getTopLeftWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  NSDictionary *values = [self getScreenAndWindowValues:cTopLeft currentSize: cSize];
  return [topLeft getPointWithDict:values];
}

- (NSSize) getDimensionsWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize {
  NSDictionary *values = [self getScreenAndWindowValues:cTopLeft currentSize: cSize];
  return [dimensions getSizeWithDict:values];
}

- (void)dealloc {
  [super dealloc];
}

@end

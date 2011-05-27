//
//  MoveOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "MoveOperation.h"
#import "SlateConfig.h"


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

- (id) initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(NSInteger)mon {
  self = [super init];
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

- (BOOL) monitorExists {
  return (monitor < ((NSInteger)[[NSScreen screens] count]) ? YES : NO);
}

// I understand that the following method is stupidly written. Apple apparently enjoys keeping
// multiple types of coordinate spaces. NSScreen.origin returns bottom-left while we need
// top-left for window moving. Go figure.
- (NSDictionary *) getScreenAndWindowValues:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
  NSInteger originX = 0;
  NSInteger originY = 0;
  NSInteger sizeX = 0;
  NSInteger sizeY = 0;
  if (monitor < 0 || (![self monitorExists] && [[SlateConfig getInstance] getBoolConfig:DEFAULT_TO_CURRENT_SCREEN])) {
    NSArray *screens = [NSScreen screens];
    NSScreen *screen = [screens objectAtIndex:0];
    NSInteger mainHeight = [screen frame].size.height;
    NSInteger mainOriginY = [screen frame].origin.y;
    NSPoint topLeftZeroed = NSMakePoint(cTopLeft.x, 0);
    if (!NSPointInRect(topLeftZeroed, [screen frame])) {
      for (NSUInteger i = 1; i < [screens count]; i++) {
        topLeftZeroed = NSMakePoint(cTopLeft.x, 0);
        screen = [screens objectAtIndex:i];
        if (NSPointInRect(topLeftZeroed, [screen frame])) {
          originX = [screen visibleFrame].origin.x;
          originY = mainOriginY - [screen frame].origin.y - ([screen frame].size.height - mainHeight);
          break;
        }
      }
    } else {
      originX = [screen visibleFrame].origin.x;
      originY = [screen frame].size.height - ([screen visibleFrame].origin.y + [screen visibleFrame].size.height);
    }
    sizeX = [screen visibleFrame].size.width;
    sizeY = [screen visibleFrame].size.height;
  } else {
    NSArray *screens = [NSScreen screens];
    NSScreen *screen = [screens objectAtIndex:0];
    NSInteger mainHeight = [screen frame].size.height;
    NSInteger mainOriginY = [screen frame].origin.y;
    screen = [screens objectAtIndex:monitor];
    if (monitor == 0) { // special handling for menu bar and dock
      originX = [screen visibleFrame].origin.x;
      originY = [screen frame].size.height - ([screen visibleFrame].origin.y + [screen visibleFrame].size.height);
    } else {
      originX = [screen visibleFrame].origin.x;
      originY = mainOriginY - [screen frame].origin.y - ([screen frame].size.height - mainHeight);
    }
    sizeX = [screen visibleFrame].size.width;
    sizeY = [screen visibleFrame].size.height;
  }
  NSLog(@"screenOrigin:(%ld,%ld), screenSize:(%ld,%ld), windowSize:(%f,%f), windowTopLeft:(%f,%f)",(long)originX,(long)originY,(long)sizeX,(long)sizeY,cSize.width,cSize.height,cTopLeft.x,cTopLeft.y);
  return [NSDictionary dictionaryWithObjectsAndKeys:
           [NSNumber numberWithInteger:originX], SCREEN_ORIGIN_X,
           [NSNumber numberWithInteger:originY], SCREEN_ORIGIN_Y,
           [NSNumber numberWithInteger:sizeX], SCREEN_SIZE_X,
           [NSNumber numberWithInteger:sizeY], SCREEN_SIZE_Y,
           [NSNumber numberWithInteger:(NSInteger)cSize.width], WINDOW_SIZE_X,
           [NSNumber numberWithInteger:(NSInteger)cSize.height], WINDOW_SIZE_Y,
           [NSNumber numberWithInteger:(NSInteger)nSize.width], NEW_WINDOW_SIZE_X,
           [NSNumber numberWithInteger:(NSInteger)nSize.height], NEW_WINDOW_SIZE_Y,
           [NSNumber numberWithInteger:(NSInteger)cTopLeft.x], WINDOW_TOP_LEFT_X,
           [NSNumber numberWithInteger:(NSInteger)cTopLeft.y], WINDOW_TOP_LEFT_Y, nil];
}

- (NSPoint) getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
  // If monitor does not exist and we arent going to default to current screen
  if (![self monitorExists] && ![[SlateConfig getInstance] getBoolConfig:DEFAULT_TO_CURRENT_SCREEN]) {
    return cTopLeft;
  }
  NSDictionary *values = [self getScreenAndWindowValues:cTopLeft currentSize:cSize newSize:nSize];
  return [topLeft getPointWithDict:values];
}

- (NSSize) getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize {
  // If monitor does not exist and we arent going to default to current screen
  if (![self monitorExists] && ![[SlateConfig getInstance] getBoolConfig:DEFAULT_TO_CURRENT_SCREEN]) {
    return cSize;
  }
  NSDictionary *values = [self getScreenAndWindowValues:cTopLeft currentSize:cSize newSize:cSize];
  return [dimensions getSizeWithDict:values];
}

- (void)dealloc {
  [self setTopLeft:nil];
  [self setDimensions:nil];
  [super dealloc];
}

@end

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
  BOOL shouldMoveFirst = moveFirst;
  if (shouldMoveFirst) {
    SlateLogger(@"Move First");
    NSPoint nTopLeft = [self getTopLeftWithCurrentWindowRect:cWindowRect newSize:nSize screenWrapper:sw];

    // check if we really should move first - if moving first moves the window offscreen, we should resize first and assume that will work better
    NSRect tmpWindowRect = NSMakeRect(nTopLeft.x, nTopLeft.y, cSize.width, cSize.height);
    if ([sw isRectOffScreen:tmpWindowRect]) {
      // Resize First
      SlateLogger(@"Resize First because moving first would fail.");
      success = [aw resizeWindow:nSize];
      NSSize realNewSize = [aw getCurrentSize];
      nTopLeft = [self getTopLeftWithCurrentWindowRect:cWindowRect newSize:realNewSize screenWrapper:sw];
      success = [aw moveWindow:nTopLeft] && success;
    } else {
      success = [aw moveWindow:nTopLeft];
      success = [aw resizeWindow:nSize] && success;
    }
  } else {
    SlateLogger(@"Resize First");
    success = [aw resizeWindow:nSize];
    NSSize realNewSize = [aw getCurrentSize];
    NSPoint nTopLeft = [self getTopLeftWithCurrentWindowRect:cWindowRect newSize:realNewSize screenWrapper:sw];
    success = [aw moveWindow:nTopLeft] && success;
  }
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

+ (id)moveOperationFromString:(NSString *)moveOperation {
  // move <topLeft> <dimensions> <optional:monitor>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:moveOperation into:tokens];
  
  if ([tokens count] < 3) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", moveOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Move operations require the following format: 'move topLeftX;topLeftY width;height [optional:screemNumber]'", moveOperation] userInfo:nil]);
  }
  
  Operation *op = nil;
  if ([moveOperation rangeOfString:NEW_WINDOW_SIZE].length > 0) {
    op = [[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:1] dimensions:[tokens objectAtIndex:2] monitor:([tokens count] >=4 ? [tokens objectAtIndex:3] : REF_CURRENT_SCREEN) moveFirst:NO];
  } else {
    op = [[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:1] dimensions:[tokens objectAtIndex:2] monitor:([tokens count] >=4 ? [tokens objectAtIndex:3] : REF_CURRENT_SCREEN)];
  }
  return op;
}

+ (id)pushOperationFromString:(NSString *)pushOperation {
  // push <top|bottom|up|down|left|right> <optional:none|center|bar|bar-resize:expression> <optional:monitor (must specify previous option to specify monitor)>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:pushOperation into:tokens];
  
  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", pushOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Push operations require the following format: 'push direction [optional:style]'", pushOperation] userInfo:nil]);
  }
  
  NSString *direction = [tokens objectAtIndex:1];
  NSString *dimensions = @"windowSizeX;windowSizeY";
  NSString *topLeft = nil;
  NSString *style = NONE;
  if ([tokens count] >= 3) {
    style = [tokens objectAtIndex:2];
  }
  if ([direction isEqualToString:TOP] || [direction isEqualToString:UP]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2;screenOriginY";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX;screenOriginY";
      dimensions = @"screenSizeX;windowSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = @"screenOriginX;screenOriginY";
      dimensions = [@"screenSizeX;" stringByAppendingString:resizeExpression];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"windowTopLeftX;screenOriginY";
    } else {
      SlateLogger(@"ERROR: Unrecognized style '%@'", style);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else if ([direction isEqualToString:BOTTOM] || [direction isEqualToString:DOWN]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2;screenOriginY+screenSizeY-windowSizeY";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX;screenOriginY+screenSizeY-windowSizeY";
      dimensions = @"screenSizeX;windowSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = [@"screenOriginX;screenOriginY+screenSizeY-" stringByAppendingString:resizeExpression];
      dimensions = [@"screenSizeX;" stringByAppendingString:resizeExpression];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"windowTopLeftX;screenOriginY+screenSizeY-windowSizeY";
    } else {
      SlateLogger(@"ERROR: Unrecognized style '%@'", style);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else if ([direction isEqualToString:LEFT]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX;screenOriginY+(screenSizeY-windowSizeY)/2";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX;screenOriginY";
      dimensions = @"windowSizeX;screenSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = @"screenOriginX;screenOriginY";
      dimensions = [resizeExpression stringByAppendingString:@",screenSizeY"];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"screenOriginX;windowTopLeftY";
    } else {
      SlateLogger(@"ERROR: Unrecognized style '%@'", style);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else if ([direction isEqualToString:RIGHT]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX+screenSizeX-windowSizeX;screenOriginY+(screenSizeY-windowSizeY)/2";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX+screenSizeX-windowSizeX;screenOriginY";
      dimensions = @"windowSizeX;screenSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = [[@"screenOriginX+screenSizeX-" stringByAppendingString:resizeExpression] stringByAppendingString:@";screenOriginY"];
      dimensions = [resizeExpression stringByAppendingString:@";screenSizeY"];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"screenOriginX+screenSizeX-windowSizeX;windowTopLeftY";
    } else {
      SlateLogger(@"ERROR: Unrecognized style '%@'", style);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else {
    SlateLogger(@"ERROR: Unrecognized direction '%@'", direction);
    @throw([NSException exceptionWithName:@"Unrecognized Direction" reason:[NSString stringWithFormat:@"Unrecognized direction '%@' in '%@'", direction, pushOperation] userInfo:nil]);
  }
  Operation *op = [[MoveOperation alloc] initWithTopLeft:topLeft dimensions:dimensions monitor:([tokens count] >=4 ? [tokens objectAtIndex:3] : REF_CURRENT_SCREEN)];
  return op;
}

+ (id)nudgeOperationFromString:(NSString *)nudgeOperation {
  // nudge x y
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:nudgeOperation into:tokens];
  
  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", nudgeOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Nudge operations require the following format: 'nudge x y'", nudgeOperation] userInfo:nil]);
  }
  
  NSString *tlX = WINDOW_TOP_LEFT_X;
  NSString *x = [tokens objectAtIndex:1];
  NSString *nudgePercentOf = [[SlateConfig getInstance] getConfig:NUDGE_PERCENT_OF];
  if ([x hasSuffix:PERCENT]) {
    // % Nudge
    tlX = [tlX stringByAppendingString:[x stringByReplacingOccurrencesOfString:PERCENT withString:[NSString stringWithFormat:@"*%@X/100",nudgePercentOf]]];
  } else {
    // Hard Nudge
    tlX = [tlX stringByAppendingString:x];
  }
  
  NSString *tlY = WINDOW_TOP_LEFT_Y;
  NSString *y = [tokens objectAtIndex:2];
  if ([y hasSuffix:PERCENT]) {
    // % Nudge
    tlY = [tlY stringByAppendingString:[y stringByReplacingOccurrencesOfString:PERCENT withString:[NSString stringWithFormat:@"*%@Y/100",nudgePercentOf]]];
  } else {
    // Hard Nudge
    tlY = [tlY stringByAppendingString:y];
  }
  Operation *op = [[MoveOperation alloc] initWithTopLeft:[[tlX stringByAppendingString:SEMICOLON] stringByAppendingString:tlY] dimensions:@"windowSizeX;windowSizeY" monitor:REF_CURRENT_SCREEN];
  return op;
}

+ (id)throwOperationFromString:(NSString *)throwOperation {
  // throw <monitor> <optional:style (default is noresize)>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:throwOperation into:tokens];
  
  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", throwOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Throw operations require the following format: 'throw screen [optional:style]'", throwOperation] userInfo:nil]);
  }
  
  NSString *tl = @"screenOriginX;screenOriginY";
  NSString *dim = @"windowSizeX;windowSizeY";
  if ([tokens count] >= 3) {
    NSString *style = [tokens objectAtIndex:2];
    if ([style isEqualToString:RESIZE]) {
      tl = @"screenOriginX;screenOriginY";
      dim = @"screenSizeX;screenSizeY";
    } else if ([style hasPrefix:RESIZE_WITH_VALUE]) {
      tl = @"screenOriginX;screenOriginY";
      dim = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
    } else if ([style isEqualToString:NORESIZE]) {
      // do nothing
    } else {
      SlateLogger(@"ERROR: Unrecognized style '%@'", style);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, throwOperation] userInfo:nil]);
    }
  }
  Operation *op = [[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:[tokens objectAtIndex:1]];
  return op;
}

+ (id)cornerOperationFromString:(NSString *)cornerOperation {
  // corner <top-left|top-right|bottom-left|bottom-right> <optional:resize:expression> <optional:monitor>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:cornerOperation into:tokens];
  
  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", cornerOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Corner operations require the following format: 'corner direction [optional:style]'", cornerOperation] userInfo:nil]);
  }
  
  NSString *tl = nil;
  NSString *dim = @"windowSizeX;windowSizeY";
  NSString *direction = [tokens objectAtIndex:1];
  
  if ([tokens count] >= 3) {
    NSString *style = [tokens objectAtIndex:2];
    if ([style hasPrefix:RESIZE_WITH_VALUE]) {
      dim = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
    }
  }
  
  if ([direction isEqualToString:TOP_LEFT]) {
    tl = @"screenOriginX;screenOriginY";
  } else if ([direction isEqualToString:TOP_RIGHT]) {
    tl = [[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:SEMICOLON] objectAtIndex:0]] stringByAppendingString:@";screenOriginY"];
  } else if ([direction isEqualToString:BOTTOM_LEFT]) {
    tl = [@"screenOriginX;screenOriginY+screenSizeY-" stringByAppendingString:[[dim componentsSeparatedByString:SEMICOLON] objectAtIndex:1]];
  } else if ([direction isEqualToString:BOTTOM_RIGHT]) {
    tl = [[[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:SEMICOLON] objectAtIndex:0]] stringByAppendingString:@";screenOriginY+screenSizeY-"] stringByAppendingString:[[dim componentsSeparatedByString:SEMICOLON] objectAtIndex:1]];
  } else {
    SlateLogger(@"ERROR: Unrecognized corner '%@'", direction);
    @throw([NSException exceptionWithName:@"Unrecognized Corner" reason:[NSString stringWithFormat:@"Unrecognized corner '%@' in '%@'", direction, cornerOperation] userInfo:nil]);
  }
  
  Operation *op = [[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:([tokens count] >=4 ? [tokens objectAtIndex:3] : REF_CURRENT_SCREEN)];
  return op;
}

@end

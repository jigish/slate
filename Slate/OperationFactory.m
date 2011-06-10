//
//  OperationFactory.m
//  Slate
//
//  Created by Jigish Patel on 5/28/11.
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

#import "ChainOperation.h"
#import "Constants.h"
#import "OperationFactory.h"
#import "MoveOperation.h"
#import "ResizeOperation.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"


@implementation OperationFactory

+ (id)createOperationFromString:(NSString *)opString {
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:opString into:tokens maxTokens:2];
  NSString *op = [tokens objectAtIndex:0];
  Operation *operation = nil;
  if ([op isEqualToString:MOVE]) {
    operation = [self createMoveOperationFromString:opString];
  } else if ([op isEqualToString:RESIZE]) {
    operation = [self createResizeOperationFromString:opString];
  } else if ([op isEqualToString:PUSH]) {
    operation = [self createPushOperationFromString:opString];
  } else if ([op isEqualToString:NUDGE]) {
    operation = [self createNudgeOperationFromString:opString];
  } else if ([op isEqualToString:THROW]) {
    operation = [self createThrowOperationFromString:opString];
  } else if ([op isEqualToString:CORNER]) {
    operation = [self createCornerOperationFromString:opString];
  } else if ([op isEqualToString:CHAIN]) {
    operation = [self createChainOperationFromString:opString];
  } else {
    NSLog(@"ERROR: Unrecognized operation '%s'", [opString cStringUsingEncoding:NSASCIIStringEncoding]);
    [tokens release];
    @throw([NSException exceptionWithName:@"Unrecognized Operation" reason:[NSString stringWithFormat:@"Unrecognized operation '%@' in '%@'", op, opString] userInfo:nil]);
  }
  [tokens release];
  return operation;
}

+ (id)createMoveOperationFromString:(NSString *)moveOperation {
  // move <topLeft> <dimensions> <optional:monitor>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:moveOperation into:tokens];
  
  if ([tokens count] < 3) {
    NSLog(@"ERROR: Invalid Parameters '%s'", [moveOperation cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Move operations require the following format: 'move topLeftX;topLeftY width;height [optional:screemNumber]'", moveOperation] userInfo:nil]);
  }
  
  Operation *op = nil;
  if ([moveOperation rangeOfString:NEW_WINDOW_SIZE].location != NSNotFound) {
    op = [[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:1] dimensions:[tokens objectAtIndex:2] monitor:([tokens count] >=4 ? [[tokens objectAtIndex:3] integerValue] : -1) moveFirst:NO];
  } else {
    op = [[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:1] dimensions:[tokens objectAtIndex:2] monitor:([tokens count] >=4 ? [[tokens objectAtIndex:3] integerValue] : -1)];
  }
  [tokens release];
  return op;
}

+ (id)createResizeOperationFromString:(NSString *)resizeOperation {
  // resize <x> <y> <optional:anchor>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:resizeOperation into:tokens];
  
  if ([tokens count] < 3) {
    NSLog(@"ERROR: Invalid Parameters '%s'", [resizeOperation cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Resize operations require the following format: 'resize resizeX resizeY [optional:anchor]'", resizeOperation] userInfo:nil]);
  }
  
  NSString *anchor = TOP_LEFT;
  if ([tokens count] >= 4) {
    anchor = [tokens objectAtIndex:3];
  }
  Operation *op = [[ResizeOperation alloc] initWithAnchor:anchor xResize:[tokens objectAtIndex:1] yResize:[tokens objectAtIndex:2]];
  [tokens release];
  return op;
}

+ (id)createPushOperationFromString:(NSString *)pushOperation {
  // push <top|bottom|up|down|left|right> <optional:none|center|bar|bar-resize:expression>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:pushOperation into:tokens];
  
  if ([tokens count] < 2) {
    NSLog(@"ERROR: Invalid Parameters '%s'", [pushOperation cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Push operations require the following format: 'push direction [optional:style]'", pushOperation] userInfo:nil]);
  }
  
  NSString *direction = [tokens objectAtIndex:1];
  NSString *dimensions = @"windowSizeX,windowSizeY";
  NSString *topLeft = nil;
  NSString *style = NONE;
  if ([tokens count] >= 3) {
    style = [tokens objectAtIndex:2];
  }
  if ([direction isEqualToString:TOP] || [direction isEqualToString:UP]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2,screenOriginY";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX,screenOriginY";
      dimensions = @"screenSizeX,windowSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = @"screenOriginX,screenOriginY";
      dimensions = [@"screenSizeX," stringByAppendingString:resizeExpression];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"windowTopLeftX,screenOriginY";
    } else {
      NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else if ([direction isEqualToString:BOTTOM] || [direction isEqualToString:DOWN]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2,screenOriginY+screenSizeY-windowSizeY";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX,screenOriginY+screenSizeY-windowSizeY";
      dimensions = @"screenSizeX,windowSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = [@"screenOriginX,screenOriginY+screenSizeY-" stringByAppendingString:resizeExpression];
      dimensions = [@"screenSizeX," stringByAppendingString:resizeExpression];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"windowTopLeftX,screenOriginY+screenSizeY-windowSizeY";
    } else {
      NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else if ([direction isEqualToString:LEFT]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX,screenOriginY+(screenSizeY-windowSizeY)/2";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX,screenOriginY";
      dimensions = @"windowSizeX,screenSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = @"screenOriginX,screenOriginY";
      dimensions = [resizeExpression stringByAppendingString:@",screenSizeY"];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"screenOriginX,windowTopLeftY";
    } else {
      NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else if ([direction isEqualToString:RIGHT]) {
    if ([style isEqualToString:CENTER]) {
      topLeft = @"screenOriginX+screenSizeX-windowSizeX,screenOriginY+(screenSizeY-windowSizeY)/2";
    } else if ([style isEqualToString:BAR]) {
      topLeft = @"screenOriginX+screenSizeX-windowSizeX,screenOriginY";
      dimensions = @"windowSizeX,screenSizeY";
    } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
      NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
      topLeft = [[@"screenOriginX+screenSizeX-" stringByAppendingString:resizeExpression] stringByAppendingString:@",screenOriginY"];
      dimensions = [resizeExpression stringByAppendingString:@",screenSizeY"];
    } else if ([style isEqualToString:NONE]) {
      topLeft = @"screenOriginX+screenSizeX-windowSizeX,windowTopLeftY";
    } else {
      NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, pushOperation] userInfo:nil]);
    }
  } else {
    NSLog(@"ERROR: Unrecognized direction '%s'", [direction cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Unrecognized Direction" reason:[NSString stringWithFormat:@"Unrecognized direction '%@' in '%@'", direction, pushOperation] userInfo:nil]);
  }
  Operation *op = [[MoveOperation alloc] initWithTopLeft:topLeft dimensions:dimensions monitor:-1];
  [tokens release];
  return op;
}

+ (id)createNudgeOperationFromString:(NSString *)nudgeOperation {
  // nudge x y
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:nudgeOperation into:tokens];
  
  if ([tokens count] < 2) {
    NSLog(@"ERROR: Invalid Parameters '%s'", [nudgeOperation cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Nudge operations require the following format: 'nudge x y'", nudgeOperation] userInfo:nil]);
  }
  
  NSString *tlX = WINDOW_TOP_LEFT_X;
  NSString *x = [tokens objectAtIndex:1];
  NSString *nudgePercentOf = [[SlateConfig getInstance] getConfig:NUDGE_PERCENT_OF] != nil ? [[SlateConfig getInstance] getConfig:NUDGE_PERCENT_OF] : @"windowSize";
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
  Operation *op = [[MoveOperation alloc] initWithTopLeft:[[tlX stringByAppendingString:COMMA] stringByAppendingString:tlY] dimensions:@"windowSizeX,windowSizeY" monitor:-1];
  [tokens release];
  return op;
}

+ (id)createThrowOperationFromString:(NSString *)throwOperation {
  // throw <monitor> <optional:style (default is noresize)>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:throwOperation into:tokens];
  
  if ([tokens count] < 2) {
    NSLog(@"ERROR: Invalid Parameters '%s'", [throwOperation cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Throw operations require the following format: 'throw screen [optional:style]'", throwOperation] userInfo:nil]);
  }
  
  NSString *tl = @"screenOriginX,screenOriginY";
  NSString *dim = @"windowSizeX,windowSizeY";
  if ([tokens count] >= 3) {
    NSString *style = [tokens objectAtIndex:2];
    if ([style isEqualToString:RESIZE]) {
      tl = @"screenOriginX,screenOriginY";
      dim = @"screenSizeX,screenSizeY";
    } else if ([style hasPrefix:RESIZE_WITH_VALUE]) {
      tl = @"screenOriginX,screenOriginY";
      dim = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
    } else if ([style isEqualToString:NORESIZE]) {
      // do nothing
    } else {
      NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
      @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, throwOperation] userInfo:nil]);
    }
  }
  Operation *op = [[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:[[tokens objectAtIndex:1] integerValue]];
  [tokens release];
  return op;
}

+ (id)createCornerOperationFromString:(NSString *)cornerOperation {
  // corner <top-left|top-right|bottom-left|bottom-right> <optional:resize:expression>
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:cornerOperation into:tokens];
  
  if ([tokens count] < 2) {
    NSLog(@"ERROR: Invalid Parameters '%s'", [cornerOperation cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Corner operations require the following format: 'corner direction [optional:style]'", cornerOperation] userInfo:nil]);
  }
  
  NSString *tl = nil;
  NSString *dim = @"windowSizeX,windowSizeY";
  NSString *direction = [tokens objectAtIndex:1];
  
  if ([tokens count] >= 3) {
    NSString *style = [tokens objectAtIndex:2];
    if ([style hasPrefix:RESIZE_WITH_VALUE]) {
      dim = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
    }
  }
  
  if ([direction isEqualToString:TOP_LEFT]) {
    tl = @"screenOriginX,screenOriginY";
  } else if ([direction isEqualToString:TOP_RIGHT]) {
    tl = [[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:0]] stringByAppendingString:@",screenOriginY"];
  } else if ([direction isEqualToString:BOTTOM_LEFT]) {
    tl = [@"screenOriginX,screenOriginY+screenSizeY-" stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:1]];
  } else if ([direction isEqualToString:BOTTOM_RIGHT]) {
    tl = [[[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:0]] stringByAppendingString:@",screenOriginY+screenSizeY-"] stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:1]];
  } else {
    NSLog(@"ERROR: Unrecognized corner '%s'", [direction cStringUsingEncoding:NSASCIIStringEncoding]);
    @throw([NSException exceptionWithName:@"Unrecognized Corner" reason:[NSString stringWithFormat:@"Unrecognized corner '%@' in '%@'", direction, cornerOperation] userInfo:nil]);
  }
  
  Operation *op = [[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:-1];
  [tokens release];
  return op;
}

+ (id)createChainOperationFromString:(NSString *)chainOperation {
  // chain op[ | op]+
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:chainOperation into:tokens maxTokens:2];
  
  if ([tokens count] < 2) {
    NSLog(@"ERROR: Invalid Parameters '%@'", chainOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Chain operations require the following format: 'chain op[|op]+'", chainOperation] userInfo:nil]);
  }
  
  NSString *opsString = [tokens objectAtIndex:1];
  NSArray *ops = [opsString componentsSeparatedByString:@" | "];
  NSMutableArray *opArray = [[NSMutableArray alloc] initWithCapacity:10];
  for (NSInteger i = 0; i < [ops count]; i++) {
    Operation *op = [self createOperationFromString:[ops objectAtIndex:i]];
    if (op != nil) {
      [opArray addObject:op];
    } else {
      NSLog(@"ERROR: Invalid Operation in Chain: '%@'", [ops objectAtIndex:i]);
      @throw([NSException exceptionWithName:@"Invalid Operation in Chain" reason:[NSString stringWithFormat:@"Invalid operation '%@' in chain.", [ops objectAtIndex:i]] userInfo:nil]);
    }
  }
  
  Operation *op = [[ChainOperation alloc] initWithArray:opArray];
  [opArray release];
  [tokens release];
  return op;
}

@end

//
//  ThrowOperation.m
//  Slate
//
//  Created by Jigish Patel on 1/20/13.
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

#import "ThrowOperation.h"
#import "Constants.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"

@implementation ThrowOperation

- (NSArray *)requiredOptions {
  return [NSArray arrayWithObjects:OPT_SCREEN, nil];
}

- (void)beforeInitOptions {
  // throw is basically an alias for move with some reasonable defaults for x, y, width, and height
  [self setTopLeft:[[ExpressionPoint alloc] initWithX:@"screenOriginX" y:@"screenOriginY"]];
  [self setDimensions:[[ExpressionPoint alloc] initWithX:@"windowSizeX" y:@"windowSizeY"]];
}

+ (id)throwOperation {
  return [[ThrowOperation alloc] init];
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

@end

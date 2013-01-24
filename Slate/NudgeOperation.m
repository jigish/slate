//
//  NudgeOperation.m
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

#import "NudgeOperation.h"
#import "Constants.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"
#import "SlateConfig.h"

@implementation NudgeOperation

- (NSArray *)requiredOptions {
  return [NSArray arrayWithObjects:OPT_X, OPT_Y, nil];
}

- (void)beforeInitOptions {
  [self setDimensions:[[ExpressionPoint alloc] initWithX:@"windowSizeX" y:@"windowSizeY"]];
  [self setMonitor:REF_CURRENT_SCREEN];
}

- (void)parseOption:(NSString *)name value:(NSString *)value {
  // all options should be strings
  if (value == nil) { return; }
  if (![value isKindOfClass:[NSString class]]) {
    @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", name, value] userInfo:nil]);
    return;
  }
  NSString *nudgePercentOf = [[SlateConfig getInstance] getConfig:NUDGE_PERCENT_OF];
  if ([name isEqualToString:OPT_X]) {
    NSString *tlX = WINDOW_TOP_LEFT_X;
    if ([value hasSuffix:PERCENT]) {
      // % Nudge
      tlX = [tlX stringByAppendingString:[value stringByReplacingOccurrencesOfString:PERCENT withString:[NSString stringWithFormat:@"*%@X/100",nudgePercentOf]]];
    } else {
      // Hard Nudge
      tlX = [tlX stringByAppendingString:value];
    }
    [[self topLeft] setX:tlX];
  } else if ([name isEqualToString:OPT_Y]) {
    NSString *tlY = WINDOW_TOP_LEFT_Y;
    if ([value hasSuffix:PERCENT]) {
      // % Nudge
      tlY = [tlY stringByAppendingString:[value stringByReplacingOccurrencesOfString:PERCENT withString:[NSString stringWithFormat:@"*%@Y/100",nudgePercentOf]]];
    } else {
      // Hard Nudge
      tlY = [tlY stringByAppendingString:value];
    }
    [[self topLeft] setY:tlY];
  }
}

+ (id)nudgeOperation {
  return [[NudgeOperation alloc] init];
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

@end

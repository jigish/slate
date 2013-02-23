//
//  CornerOperation.m
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

#import "CornerOperation.h"
#import "StringTokenizer.h"
#import "Constants.h"
#import "SlateLogger.h"

@implementation CornerOperation

- (NSArray *)requiredOptions {
  return [NSArray arrayWithObjects:OPT_DIRECTION, nil];
}

- (void)afterEvalOptions {
  NSString *width = [[self options] objectForKey:OPT_WIDTH];
  if (width == nil) { width = @"windowSizeX"; }
  NSString *height = [[self options] objectForKey:OPT_HEIGHT];
  if (height == nil) { height = @"windowSizeY"; }
  [self setDimensions:[[ExpressionPoint alloc] initWithX:width y:height]];
  NSString *screen = [[self options] objectForKey:OPT_SCREEN];
  if (screen == nil) { screen = REF_CURRENT_SCREEN; }
  [self setMonitor:screen];
  NSString *direction = [[self options] objectForKey:OPT_DIRECTION];
  if ([direction isEqualToString:TOP_LEFT]) {
    [self setTopLeft:[[ExpressionPoint alloc] initWithX:@"screenOriginX" y:@"screenOriginY"]];
  } else if ([direction isEqualToString:TOP_RIGHT]) {
    [self setTopLeft:[[ExpressionPoint alloc] initWithX:[NSString stringWithFormat:@"screenOriginX+screenSizeX-(%@)", [[self dimensions] x]] y:@"screenOriginY"]];
  } else if ([direction isEqualToString:BOTTOM_LEFT]) {
    [self setTopLeft:[[ExpressionPoint alloc] initWithX:@"screenOriginX" y:[NSString stringWithFormat:@"screenOriginY+screenSizeY-(%@)", [[self dimensions] y]]]];
  } else if ([direction isEqualToString:BOTTOM_RIGHT]) {
    [self setTopLeft:[[ExpressionPoint alloc] initWithX:[NSString stringWithFormat:@"screenOriginX+screenSizeX-(%@)", [[self dimensions] x]] y:[NSString stringWithFormat:@"screenOriginY+screenSizeY-(%@)", [[self dimensions] y]]]];
  } else {
    SlateLogger(@"ERROR: Unrecognized corner '%@'", direction);
    @throw([NSException exceptionWithName:@"Unrecognized Corner" reason:[NSString stringWithFormat:@"Unrecognized corner '%@'", direction] userInfo:nil]);
  }
}

+ (id)cornerOperation {
  return [[CornerOperation alloc] init];
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

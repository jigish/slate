//
//  Layout.m
//  Slate
//
//  Created by Jigish Patel on 6/13/11.
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

#import "ApplicationOptions.h"
#import "Constants.h"
#import "Layout.h"
#import "Operation.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"

@implementation Layout

@synthesize name;
@synthesize appStates;
@synthesize appOptions;
@synthesize appOrder;

- (id)init {
  self = [super init];
  if (self) {
    appStates = [NSMutableDictionary dictionary];
    appOptions = [NSMutableDictionary dictionary];
    appOrder = [NSMutableArray array];
  }
  return self;
}

- (id)initWithString:(NSString *)layout {
  self = [self init];
  if (self) {
    [self addWithString:layout];
  }
  return self;
}

- (void)addWithString:(NSString *)layout {
  // layout <name> <app name> <op+params> (| <op+params>)*
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:layout into:tokens maxTokens:4 quoteChars:[NSCharacterSet characterSetWithCharactersInString:QUOTES]];
  if ([tokens count] <=3) {
    @throw([NSException exceptionWithName:@"Unrecognized Layout" reason:layout userInfo:nil]);
  }

  [self setName:[tokens objectAtIndex:1]];

  NSArray *appNameAndOptions = [[tokens objectAtIndex:2] componentsSeparatedByString:COLON];
  NSString *appName = [appNameAndOptions objectAtIndex:0];
  if ([appOptions objectForKey:appName] != nil) [appOrder removeObject:appName];
  [appOrder addObject:appName];

  if ([appNameAndOptions count] > 1) {
    NSString *options = [appNameAndOptions objectAtIndex:1];
    ApplicationOptions *appOpts = [[ApplicationOptions alloc] init];
    NSArray *optArr = [options componentsSeparatedByString:COMMA];
    for (NSInteger i = 0; i < [optArr count]; i++) {
      NSString *option = [optArr objectAtIndex:i];
      if ([option isEqualToString:IGNORE_FAIL]) {
        [appOpts setIgnoreFail:YES];
      } else if ([option isEqualToString:REPEAT]) {
        [appOpts setRepeat:YES];
      } else if ([option isEqualToString:MAIN_FIRST]) {
        [appOpts setMainFirst:YES];
      } else if ([option isEqualToString:MAIN_LAST]) {
        [appOpts setMainLast:YES];
      } else if ([option isEqualToString:SORT_TITLE]) {
        [appOpts setSortTitle:YES];
      } else if ([option rangeOfString:TITLE_ORDER].length > 0) {
        [appOpts setTitleOrder:[[[option componentsSeparatedByString:EQUALS] objectAtIndex:1] componentsSeparatedByString:SEMICOLON]];
      }
    }
    [appOptions setObject:appOpts forKey:appName];
  } else {
    [appOptions setObject:[[ApplicationOptions alloc] init] forKey:appName];
  }
  NSString *opsString = [tokens objectAtIndex:3];
  NSArray *ops = [opsString componentsSeparatedByString:PIPE];
  NSMutableArray *opArray = [[NSMutableArray alloc] initWithCapacity:10];
  for (NSInteger i = 0; i < [ops count]; i++) {
    Operation *op = [Operation operationFromString:[ops objectAtIndex:i]];
    if (op != nil) {
      [opArray addObject:op];
    } else {
      SlateLogger(@"ERROR: Invalid Operation in Chain: '%@'", [ops objectAtIndex:i]);
      @throw([NSException exceptionWithName:@"Invalid Operation in Chain" reason:[NSString stringWithFormat:@"Invalid operation '%@' in chain.", [ops objectAtIndex:i]] userInfo:nil]);
    }
  }

  [[self appStates] setObject:opArray forKey:appName];
}

@end

//
//  ChainOperation.m
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
#import "ScreenWrapper.h"
#import "WindowState.h"
#import "StringTokenizer.h"
#import "Constants.h"
#import "SlateLogger.h"
#import "JSController.h"
#import <WebKit/WebKit.h>
#import "JSOperation.h"

@implementation ChainOperation

@synthesize operations;
@synthesize currentOp;

- (id)init {
  self = [super init];
  if (self) {
    [self setCurrentOp:[[NSMutableDictionary alloc] initWithCapacity:10]];
    [self setOperations:[NSArray array]];
  }
  return self;
}

- (id)initWithArray:(NSArray *)opArray {
  self = [self init];
  if (self) {
    [self setCurrentOp:[[NSMutableDictionary alloc] initWithCapacity:10]];
    [self setOperations:opArray];
  }
  return self;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Chain Operation -----------------");
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) success = [self doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
  SlateLogger(@"-----------------  End Chain Operation  -----------------");
  return success;
}

- (BOOL) doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = NO;
  [self evalOptionsWithAccessibilityWrapper:aw screenWrapper:sw];
  NSInteger opRun = 0;
  if ([aw inited]) {
    opRun = [self getNextOperation:aw];
    success = [[operations objectAtIndex:opRun] doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
    if (success)
      [self afterComplete:aw opRun:opRun];
  }
  return success;
}

- (BOOL)testOperation:(NSInteger)op {
  BOOL success = [[operations objectAtIndex:op] testOperation];
  return success;
}

- (BOOL)testOperation {
  BOOL success = YES;
  for (NSInteger op = 0; op < [operations count]; op++) {
    success = [self testOperation:op] && success;
  }
  return success;
}

- (void)afterComplete:(AccessibilityWrapper *)aw opRun:(NSInteger)op {
  NSInteger nextOpInt = 0;
  if (op+1 < [operations count])
    nextOpInt = op+1;
  NSNumber *nextOp = [NSNumber numberWithInteger:nextOpInt];

  if (aw != nil) {
    [self setNextOperation:aw nextOp:nextOp];
  }
}

- (NSInteger)getNextOperation:(AccessibilityWrapper *)aw {
  WindowState *ws = [[WindowState alloc] init:aw];
  NSNumber *nextOp = [currentOp objectForKey:ws];
  if (nextOp != nil)
    return [nextOp integerValue];
  return 0;
}

- (void)setNextOperation:(AccessibilityWrapper *)aw nextOp:(NSNumber *)op {
  WindowState *ws = [[WindowState alloc] init:aw];
  [currentOp setObject:op forKey:ws];
}

- (NSArray *)requiredOptions {
  return [NSArray arrayWithObject:OPT_OPERATIONS];
}

- (void)parseOption:(NSString *)_name value:(id)value {
  if (value == nil) { return; }
  if ([_name isEqualToString:OPT_OPERATIONS]) {
    if (![value isKindOfClass:[NSArray class]]) {
      @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", _name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", _name, value] userInfo:nil]);
      return;
    }
    NSMutableArray *ops = [NSMutableArray array];
    for (id key in value) {
      Operation *op = nil;
      if ([key isKindOfClass:[WebScriptObject class]]) {
        op = [JSOperation jsOperationWithFunction:key];
      } else if ([key isKindOfClass:[Operation class]]) {
        op = key;
      }

      if (op == nil) {
        @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", _name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", _name, value] userInfo:nil]);
      }
      [ops addObject:op];
    }
    [self setOperations:ops];
  }
}

+ (id)chainOperation {
  return [[ChainOperation alloc] init];
}

+ (id)chainOperationFromString:(NSString *)chainOperation {
  // chain op[ | op]+
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:chainOperation into:tokens maxTokens:2];

  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", chainOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Chain operations require the following format: 'chain op[|op]+'", chainOperation] userInfo:nil]);
  }

  NSString *opsString = [tokens objectAtIndex:1];
  NSArray *ops = [opsString componentsSeparatedByString:PIPE_PADDED];
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

  Operation *op = [[ChainOperation alloc] initWithArray:opArray];
  return op;
}

@end

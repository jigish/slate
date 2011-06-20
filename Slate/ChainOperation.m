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


@implementation ChainOperation

@synthesize operations;
@synthesize currentOp;

- (id)init {
  self = [super init];
  if (self) {
    [self setCurrentOp:0];
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
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) success = [self doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
  [sw release];
  [aw release];
  return success;
}

- (BOOL) doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = NO;
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
  [ws release];
  if (nextOp != nil)
    return [nextOp integerValue];
  return 0;
}

- (void)setNextOperation:(AccessibilityWrapper *)aw nextOp:(NSNumber *)op {
  WindowState *ws = [[WindowState alloc] init:aw];
  [currentOp setObject:op forKey:ws];
  [ws release];
}

- (void)dealloc {
  [self setOperations:nil];
  [super dealloc];
}

@end

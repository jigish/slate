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
    [self setCurrentOp:0];
    [self setOperations:opArray];
  }
  
  return self;
}

- (BOOL)doOperation {
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) {
    success = [[operations objectAtIndex:currentOp] doOperation:aw];
  }
  [self afterComplete:aw];
  [aw release];
  return success;
}

- (BOOL)testCurrentOperation {
  BOOL success = [[operations objectAtIndex:currentOp] testOperation];
  [self afterComplete:nil];
  return success;
}

- (BOOL)testOperation {
  BOOL success = YES;
  do {
    success = [self testCurrentOperation] && success;
  } while (currentOp != 0);
  return success;
}

- (void)afterComplete:(AccessibilityWrapper *)aw {
  if (currentOp+1 >= [operations count])
    [self setCurrentOp:0];
  else
    [self setCurrentOp:currentOp+1];
}

- (void)dealloc {
  [self setOperations:nil];
  [super dealloc];
}

@end

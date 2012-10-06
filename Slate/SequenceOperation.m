//
//  SequenceOperation.m
//  Slate
//
//  Created by Jigish Patel on 10/5/12.
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

#import "SequenceOperation.h"
#import "SlateLogger.h"
#import "StringTokenizer.h"
#import "Constants.h"

@implementation SequenceOperation

@synthesize operations;

- (id)init {
  self = [super init];
  return self;
}

- (id)initWithArray:(NSArray *)opArray {
  self = [self init];

  if (self) {
    [self setOperations:opArray];
  }

  return self;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Sequence Operation -----------------");
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:sw];
  SlateLogger(@"-----------------  End Sequence Operation  -----------------");
  return success;
}

- (BOOL) doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)sw {
  for (NSInteger i = 0; i < [[self operations] count]; i++) {
    AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
    for (NSInteger j = 0; j < [[[self operations] objectAtIndex:i] count]; j++) {
      [[[[self operations] objectAtIndex:i] objectAtIndex:j] doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
    }
  }
  return YES;
}

- (BOOL)testOperation {
  BOOL success = YES;
  for (NSInteger i = 0; i < [operations count]; i++) {
    for (NSInteger op = 0; op < [[operations objectAtIndex:i] count]; op++) {
      [[[operations objectAtIndex:i] objectAtIndex:op] testOperation];
    }
  }
  return success;
}

+ (id)sequenceOperationFromString:(NSString *)sequenceOperation {
  // sequence op[ (\||>) op]+
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:sequenceOperation into:tokens maxTokens:2];
  
  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", sequenceOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Sequence operations require the following format: 'chain op [(\\||>) op]+'", sequenceOperation] userInfo:nil]);
  }
  
  NSString *opsString = [tokens objectAtIndex:1];
  NSArray *ops = [opsString componentsSeparatedByString:PIPE];
  NSMutableArray *opArray = [[NSMutableArray alloc] initWithCapacity:10];
  for (NSInteger i = 0; i < [ops count]; i++) {
    NSArray *sameWindowOps = [[ops objectAtIndex:i] componentsSeparatedByString:GREATER_THAN];
    NSMutableArray *sameWindowOpArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSInteger j = 0; j < [sameWindowOps count]; j++) {
      Operation *op = [Operation operationFromString:[sameWindowOps objectAtIndex:j]];
      if (op != nil) {
        [sameWindowOpArray addObject:op];
      } else {
        SlateLogger(@"ERROR: Invalid Operation in Sequence: '%@'", [sameWindowOps objectAtIndex:j]);
        @throw([NSException exceptionWithName:@"Invalid Operation in Sequence" reason:[NSString stringWithFormat:@"Invalid operation '%@' in sequence.", [sameWindowOps objectAtIndex:j]] userInfo:nil]);
      }
    }
    [opArray addObject:sameWindowOpArray];
  }
  
  Operation *op = [[SequenceOperation alloc] initWithArray:opArray];
  return op;
}



@end

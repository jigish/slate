//
//  DeleteSnapshotOperation.m
//  Slate
//
//  Created by Jigish Patel on 2/28/12.
//  Copyright 2012 Jigish Patel. All rights reserved.
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

#import "DeleteSnapshotOperation.h"
#import "Constants.h"
#import "SlateConfig.h"

@implementation DeleteSnapshotOperation

@synthesize name, pop;

- (id)init {
  self = [super init];
  if (self) {
    pop = YES;
  }
  return self;
}

- (id)initWithName:(NSString *)theName options:(NSString *)options {
  self = [self init];
  if (self) {
    [self setName:theName];
    if (options) {
      NSArray *optionsTokens = [options componentsSeparatedByString:SEMICOLON];
      for (NSInteger i = 0; i < [optionsTokens count]; i++) {
        NSString *option = [optionsTokens objectAtIndex:i];
        if ([ALL isEqualToString:option]) {
          pop = NO;
        }
      }
    }
  }
  return self;
}

- (BOOL)doOperation {
  NSLog(@"----------------- Begin Delete Snapshot Operation -----------------");
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  NSLog(@"-----------------  End Delete Snapshot Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  [[SlateConfig getInstance] deleteSnapshot:name pop:pop];
  return YES;
}

- (BOOL)testOperation {
  return YES;
}

@end

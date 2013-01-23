//
//  JSOperation.m
//  Slate
//
//  Created by Jigish Patel on 1/22/13.
//  Copyright 2013 Jigish Patel. All rights reserved.
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

#import "JSOperation.h"
#import "JSController.h"
#import "AccessibilityWrapper.h"
#import "ScreenWrapper.h"
#import "SlateLogger.h"
#import "JSWindowWrapper.h"

@implementation JSOperation

@synthesize function;

- (id)init {
  self = [super init];
  if (self) {
    [self setOpName:@"js"];
  }
  return self;
}

- (id)initWithFunction:(WebScriptObject *)_function {
  self = [super init];
  if (self) {
    [self setOpName:@"js"];
    [self setFunction:_function];
  }
  return self;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = YES;
  [self evalOptionsWithAccessibilityWrapper:aw screenWrapper:sw];
  [[JSController getInstance] runFunction:[self function] withArg:[[JSWindowWrapper alloc] initWithAccessibilityWrapper:aw
                                                                                                          screenWrapper:sw]];
  return success;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin JS Operation -----------------");
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] init];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = NO;
  if ([aw inited]) success = [self doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
  SlateLogger(@"-----------------  End JS Operation  -----------------");
  return success;
}

- (BOOL)testOperation {
  return function != nil && [@"function" isEqualToString:[[JSController getInstance] jsTypeof:function]];
}

+ (JSOperation *)jsOperationWithFunction:(WebScriptObject*)function {
  return [[JSOperation alloc] initWithFunction:function];
}

@end

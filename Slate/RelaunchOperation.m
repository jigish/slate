//
//  RelaunchOperation.m
//  Slate
//
//  Created by Jigish Patel on 10/11/12.
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

#import "RelaunchOperation.h"
#import "SlateLogger.h"
#import "SlateAppDelegate.h"

@implementation RelaunchOperation

- (id)init {
  self = [super init];
  return self;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Focus Operation -----------------");
  // We don't use the passed in AccessibilityWrapper or ScreenWrapper so they are nil. No need to waste time creating them here.
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  SlateLogger(@"-----------------  End Focus Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  [(SlateAppDelegate *)[NSApp delegate] relaunch];
  return YES;
}

- (BOOL)testOperation {
  return YES;
}

- (BOOL)shouldTakeUndoSnapshot {
  return NO;
}

+ (id)relaunchOperationFromString:(NSString *)unused {
  Operation *op = [[RelaunchOperation alloc] init];
  return op;
}

@end

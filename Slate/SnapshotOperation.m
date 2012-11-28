//
//  SnapshotOperation.m
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

#import "SnapshotOperation.h"
#import "Constants.h"
#import "Snapshot.h"
#import "WindowSnapshot.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"
#import "RunningApplications.h"

@implementation SnapshotOperation

@synthesize name, saveToDisk, isStack, stackSize;

- (id)init {
  self = [super init];
  if (self) {
    saveToDisk = NO;
    isStack = NO;
    stackSize = [[SlateConfig getInstance] getIntegerConfig:SNAPSHOT_MAX_STACK_SIZE];
  }
  return self;
}

- (id)initWithName:(NSString *)theName options:(NSString *)options {
  self = [self init];
  if (self) {
    [self setStackSize:[[SlateConfig getInstance] getIntegerConfig:SNAPSHOT_MAX_STACK_SIZE]];
    [self setName:theName];
    if (options) {
      NSArray *optionsTokens = [options componentsSeparatedByString:SEMICOLON];
      for (NSInteger i = 0; i < [optionsTokens count]; i++) {
        NSString *option = [optionsTokens objectAtIndex:i];
        if ([SAVE_TO_DISK isEqualToString:option]) {
          saveToDisk = YES;
        } else if ([STACK isEqualToString:option]) {
          isStack = YES;
        }
      }
    }
  }
  return self;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Snapshot Operation -----------------");
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  SlateLogger(@"-----------------  End Snapshot Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  Snapshot *snapshot = [[Snapshot alloc] init];
  for (NSRunningApplication *app in [RunningApplications getInstance]) {
    NSString *appName = [app localizedName];
    pid_t appPID = [app processIdentifier];
    SlateLogger(@"I see application '%@' with pid '%d'", appName, appPID);
    AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
    CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      SlateLogger(@" Printing Window: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);
      NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
      if ([title isEqualToString:@""]) continue;
      AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windowsArr, i)];
      NSSize size = [aw getCurrentSize];
      NSPoint tl = [aw getCurrentTopLeft];
      [snapshot addWindow:[[WindowSnapshot alloc] initWithAppName:appName title:title topLeft:tl size:size] app:appName];
    }
  }
  [[SlateConfig getInstance] addSnapshot:snapshot name:name saveToDisk:saveToDisk isStack:isStack stackSize:stackSize];
  return YES;
}

- (BOOL)testOperation {
  return YES;
}

+ (id)snapshotOperationFromString:(NSString *)snapshotOperation {
  // snapshot name options
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:snapshotOperation into:tokens maxTokens:3];

  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", snapshotOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Snapshot operations require the following format: 'snapshot name options'", snapshotOperation] userInfo:nil]);
  }

  Operation *op = [[SnapshotOperation alloc] initWithName:[tokens objectAtIndex:1] options:([tokens count] > 2 ? [tokens objectAtIndex:2] : nil)];
  return op;
}

@end

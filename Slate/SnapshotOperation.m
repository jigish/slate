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

@implementation SnapshotOperation

@synthesize name, saveToDisk, isStack;

- (id)init {
  self = [super init];
  if (self) {
    saveToDisk = NO;
    isStack = NO;
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
  NSLog(@"----------------- Begin Snapshot Operation -----------------");
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  NSLog(@"-----------------  End Snapshot Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];
  Snapshot *snapshot = [[Snapshot alloc] init];
  for (NSInteger i = 0; i < [apps count]; i++) {
    NSDictionary *app = [apps objectAtIndex:i];
    NSString *appName = [app objectForKey:@"NSApplicationName"];
    NSNumber *appPID = [app objectForKey:@"NSApplicationProcessIdentifier"];
    NSLog(@"I see application '%@' with pid '%@'", appName, appPID);
    // Yes, I am aware that the following blocks are inefficient. Deal with it.
    AXUIElementRef appRef = AXUIElementCreateApplication([appPID intValue]);
    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
    CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      NSLog(@" Printing Window: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);
      NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
      if ([title isEqualToString:@""]) continue;
      AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windowsArr, i)];
      NSSize size = [aw getCurrentSize];
      NSPoint tl = [aw getCurrentTopLeft];
      [snapshot addWindow:[[WindowSnapshot alloc] initWithAppName:appName title:title topLeft:tl size:size] app:appName];
    }
  }
  [[SlateConfig getInstance] addSnapshot:snapshot name:name saveToDisk:saveToDisk isStack:isStack];
  return YES;
}

- (BOOL)testOperation {
  return YES;
}

- (void)dealloc {
  [self setName:nil];
  [super dealloc];
}

@end

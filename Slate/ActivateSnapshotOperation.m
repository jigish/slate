//
//  ActivateSnapshotOperation.m
//  Slate
//
//  Created by Jigish Patel on 3/1/12.
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

#import "ActivateSnapshotOperation.h"
#import "Constants.h"
#import "Snapshot.h"
#import "SlateConfig.h"
#import "WindowSnapshot.h"
#import "NSString+Levenshtein.h"

@implementation ActivateSnapshotOperation

@synthesize name, del;

- (id)init {
  self = [super init];
  if (self) {
    del = NO;
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
        if ([DELETE isEqualToString:option]) {
          del = YES;
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
  Snapshot *snapshot = [[SlateConfig getInstance] popSnapshot:name remove:del];
  if (snapshot == nil) return YES;
  for (NSInteger i = 0; i < [apps count]; i++) {
    NSDictionary *app = [apps objectAtIndex:i];
    NSString *appName = [app objectForKey:@"NSApplicationName"];
    NSNumber *appPID = [app objectForKey:@"NSApplicationProcessIdentifier"];
    NSLog(@"I see application '%@' with pid '%@'", appName, appPID);
    AXUIElementRef appRef = AXUIElementCreateApplication([appPID intValue]);
    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
    CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
    NSArray *windowSnapshots = [[snapshot apps] objectForKey:appName];
    // Check windows
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      NSLog(@" Checking Window: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);
      NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
      if ([title isEqualToString:@""]) continue;
      AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windowsArr, i)];
      // Find best snapshot using levenshtein distance of title
      float bestDistance = 1000.0;
      WindowSnapshot *bestSnapshot = nil;
      for (WindowSnapshot *ws in windowSnapshots) {
        float lDistance = [title levenshteinDistance:[ws title]];
        if (lDistance < bestDistance || bestSnapshot == nil) {
          bestDistance = lDistance;
          bestSnapshot = ws;
        }
      }
      if (bestSnapshot == nil) continue;
      [aw moveWindow:[bestSnapshot topLeft]];
      [aw resizeWindow:[bestSnapshot size]];
    }
  }
  return YES;
}

- (BOOL)testOperation {
  return YES;
}

@end

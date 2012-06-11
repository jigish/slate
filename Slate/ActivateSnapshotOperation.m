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
#import "StringTokenizer.h"
#import "SlateLogger.h"
#import "RunningApplications.h"

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
  SlateLogger(@"----------------- Begin Snapshot Operation -----------------");
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  SlateLogger(@"-----------------  End Snapshot Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  return [ActivateSnapshotOperation activateSnapshot:name remove:del];
}

- (BOOL)testOperation {
  return YES;
}

+ (BOOL)activateSnapshot:(NSString *)name remove:(BOOL)del {
  Snapshot *snapshot = [[SlateConfig getInstance] popSnapshot:name remove:del];
  if (snapshot == nil) return YES;
  for (NSRunningApplication *app in [RunningApplications getInstance]) {
    NSString *appName = [app localizedName];
    pid_t appPID = [app processIdentifier];
    SlateLogger(@"I see application '%@' with pid '%d'", appName, appPID);
    AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
    CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
    NSArray *windowSnapshots = [[snapshot apps] objectForKey:appName];
    // Check windows
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      SlateLogger(@" Checking Window: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);
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

+ (id)activateSnapshotOperationFromString:(NSString *)activateSnapshotOperation {
  // activate-snapshot name options
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:activateSnapshotOperation into:tokens maxTokens:3];
  
  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", activateSnapshotOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Activate Snapshot operations require the following format: 'delete-snapshot name options'", activateSnapshotOperation] userInfo:nil]);
  }
  
  Operation *op = [[ActivateSnapshotOperation alloc] initWithName:[tokens objectAtIndex:1] options:([tokens count] > 2 ? [tokens objectAtIndex:2] : nil)];
  return op;
}

@end

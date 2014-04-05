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
    [self setName:nil];
  }
  return self;
}

- (id)initWithName:(NSString *)theName options:(NSString *)_options {
  self = [self init];
  if (self) {
    [self setName:theName];
    if (_options) {
      NSArray *optionsTokens = [_options componentsSeparatedByString:SEMICOLON];
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
  [self evalOptionsWithAccessibilityWrapper:iamnil screenWrapper:iamalsonil];
  return [ActivateSnapshotOperation activateSnapshot:name remove:del];
}

- (BOOL)testOperation {
  return YES;
}

- (NSArray *)requiredOptions {
  return [NSArray arrayWithObject:OPT_NAME];
}

- (void)parseOption:(NSString *)_name value:(id)value {
  if (value == nil) { return; }
  if ([_name isEqualToString:OPT_NAME]) {
    if (![value isKindOfClass:[NSString class]]) {
      @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", _name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", _name, value] userInfo:nil]);
      return;
    }
    [self setName:value];
  } else if ([_name isEqualToString:OPT_DELETE]) {
    if (![value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSString class]] && ![value isKindOfClass:[NSNumber class]]) {
      @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", _name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", _name, value] userInfo:nil]);
      return;
    }
    [self setDel:[value boolValue]];
  }
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
      // Find best snapshot
      WindowSnapshot *bestSnapshot = nil;
      if ([[[SlateConfig getInstance] getConfig:SNAPSHOT_TITLE_MATCH app:appName] isEqualToString:SEQUENTIAL]) {
        float bestDistance = 0.0;
        for (WindowSnapshot *ws in windowSnapshots) {
          float sDistance = [title sequentialDistance:[ws title]];
          if (sDistance > bestDistance || bestSnapshot == nil) {
            bestDistance = sDistance;
            bestSnapshot = ws;
          }
        }
      } else {
        float bestDistance = 1000.0;
        for (WindowSnapshot *ws in windowSnapshots) {
          float lDistance = [title levenshteinDistance:[ws title]];
          if (lDistance < bestDistance || bestSnapshot == nil) {
            bestDistance = lDistance;
            bestSnapshot = ws;
          }
        }
      }
      if (bestSnapshot == nil) continue;
      [aw moveWindow:[bestSnapshot topLeft]];
      [aw resizeWindow:[bestSnapshot size]];
    }
  }
  return YES;
}

+ (id)activateSnapshotOperation {
  return [[ActivateSnapshotOperation alloc] init];
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

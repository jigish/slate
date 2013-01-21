//
//  FocusOperation.m
//  Slate
//
//  Created by Jigish Patel on 6/21/11.
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

#import "Constants.h"
#import "FocusOperation.h"
#import "MathUtils.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"
#import "RunningApplications.h"

@implementation FocusOperation

@synthesize direction, app;

- (id)init {
  self = [super init];
  if (self) {
    [self setDirection:DIRECTION_UNKNOWN];
    [self setApp:nil];
  }
  return self;
}

- (id)initWithDirectionOrApp:(NSString *)s {
  self = [super init];
  if (self) {
    [self setDirection:DIRECTION_UNKNOWN];
    [self setApp:nil];
    if ([s length] <= 1) {
      // fail
    } else if ([s isEqualToString:UP] || [s isEqualToString:ABOVE]) {
      [self setDirection:DIRECTION_UP];
    } else if ([s isEqualToString:DOWN] || [s isEqualToString:BELOW]) {
      [self setDirection:DIRECTION_DOWN];
    } else if ([s isEqualToString:LEFT]) {
      [self setDirection:DIRECTION_LEFT];
    } else if ([s isEqualToString:RIGHT]) {
      [self setDirection:DIRECTION_RIGHT];
    } else if ([s isEqualToString:BEHIND]) {
      [self setDirection:DIRECTION_BEHIND];
    } else if ([[NSCharacterSet characterSetWithCharactersInString:QUOTES] characterIsMember:[s characterAtIndex:0]] &&
               [[NSCharacterSet characterSetWithCharactersInString:QUOTES] characterIsMember:[s characterAtIndex:([s length] - 1)]]) {
      // App name
      [self setApp:[s substringWithRange:NSMakeRange(1, [s length]-2)]];
    }
  }
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
  [self evalOptions];
  // App case
  if ([self app] != nil) {
    for (NSRunningApplication *runningApp in [RunningApplications getInstance]) {
      if ([[self app] isEqualToString:[runningApp localizedName]]) {
        // Match!
        if ([AccessibilityWrapper focusMainWindow:runningApp]) {
          return YES;
        }
        return NO;
      }
    }
    return NO;
  }

  // Direction case
  AccessibilityWrapper *caAW = [[AccessibilityWrapper alloc] init];
  if (![caAW inited]) return NO;
  NSPoint cwTL = [caAW getCurrentTopLeft];
  NSSize cwSize = [caAW getCurrentSize];
  NSRect cwRect = NSMakeRect(cwTL.x, cwTL.y, cwSize.width, cwSize.height);
  NSString *cwTitle = [AccessibilityWrapper getTitle:[caAW window]];
  NSRect checkRect;
  NSInteger focusCheckWidth = [[SlateConfig getInstance] getIntegerConfig:FOCUS_CHECK_WIDTH];
  while (focusCheckWidth <= [[SlateConfig getInstance] getIntegerConfig:FOCUS_CHECK_WIDTH_MAX]) {
    SlateLogger(@"Checking for adjacent windows with width=%i",(int)focusCheckWidth);
    if (direction == DIRECTION_UP) checkRect = NSMakeRect(cwTL.x, cwTL.y-focusCheckWidth, cwSize.width, focusCheckWidth);
    else if (direction == DIRECTION_DOWN) checkRect = NSMakeRect(cwTL.x, cwTL.y+cwSize.height, cwSize.width, focusCheckWidth);
    else if (direction == DIRECTION_LEFT) checkRect = NSMakeRect(cwTL.x-focusCheckWidth, cwTL.y, focusCheckWidth, cwSize.height);
    else if (direction == DIRECTION_RIGHT) checkRect = NSMakeRect(cwTL.x+cwSize.width, cwTL.y, focusCheckWidth, cwSize.height);
    else if (direction == DIRECTION_BEHIND) checkRect = NSMakeRect(cwTL.x, cwTL.y, cwSize.width, cwSize.height);
    else {
      return NO;
    }
    NSRect biggestIntersection = NSZeroRect;
    AXUIElementRef windowToFocus;
    AXUIElementRef appToFocus;
    BOOL foundFocus = NO;
    BOOL foundFocusInSameApp = NO;
    for (NSRunningApplication *runningApp in [RunningApplications getInstance]) {
      pid_t appPID = [runningApp processIdentifier];
      SlateLogger(@"I see application '%@' with pid '%d'", [runningApp localizedName], appPID);

      AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
      CFArrayRef windows = [AccessibilityWrapper windowsInApp:appRef];
      if (!windows || CFArrayGetCount(windows) == 0) continue;

      for (NSInteger i = 0; i < CFArrayGetCount(windows); i++) {
        AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windows, i)];

        if ([aw isMinimizedOrHidden]) {
          SlateLogger(@" Window is minimized, skipping");
          continue;
        }

        NSString *wTitle = [aw getTitle];
        if ([wTitle isEqualToString:@""]){
          SlateLogger(@" Title is empty, skipping");
          continue; // Chrome and Finder have invisible windows for some reason
        }

        NSPoint wTL = [aw getCurrentTopLeft];
        NSSize wSize = [aw getCurrentSize];
        SlateLogger(@" Checking window in %@ in direction %i with rect: (%f,%f %f,%f), title: [%@]",[runningApp localizedName],(int)direction,wTL.x,wTL.y,wSize.width,wSize.height,wTitle);
        NSRect windowRect = NSMakeRect(wTL.x, wTL.y, wSize.width, wSize.height);

        if ([wTitle isEqualToString:cwTitle] && NSEqualRects(windowRect, cwRect) && NSEqualPoints(wTL, cwTL)) {
          SlateLogger(@" Ignoring current window");
          continue;
        }
        NSRect intersection = NSIntersectionRect(checkRect, windowRect);
        if ([MathUtils isRect:intersection biggerThan:NSZeroRect] && [AccessibilityWrapper processIdentifierOfUIElement:[caAW app]] == appPID) {
          SlateLogger(@"  Found window in same app in direction %i",(int)direction);
          if ([[SlateConfig getInstance] getBoolConfig:FOCUS_PREFER_SAME_APP]
              && (!foundFocusInSameApp || [MathUtils isRect:intersection biggerThan:biggestIntersection])) {
            SlateLogger(@"   Preferring same app.");
            appToFocus = appRef;
            windowToFocus = CFArrayGetValueAtIndex(windows, i);
            biggestIntersection = intersection;
            foundFocus = YES;
            foundFocusInSameApp = YES;
          } else if ([MathUtils isRect:intersection biggerThan:biggestIntersection]) {
            appToFocus = appRef;
            windowToFocus = CFArrayGetValueAtIndex(windows, i);
            biggestIntersection = intersection;
            foundFocus = YES;
          }
        } else if ([MathUtils isRect:intersection biggerThan:biggestIntersection]) {
          SlateLogger(@"  Found window in %@ in direction %i (intersection: %f,%f %f,%f)",[runningApp localizedName],(int)direction,intersection.origin.x,intersection.origin.y,intersection.size.width,intersection.size.height);
          appToFocus = appRef;
          windowToFocus = CFArrayGetValueAtIndex(windows, i);
          biggestIntersection = intersection;
          foundFocus = YES;
        }
      }
      // check if same app && foundFocus && prefer_same_app
      if(foundFocusInSameApp && [AccessibilityWrapper processIdentifierOfUIElement:[caAW app]] == appPID && [[SlateConfig getInstance] getBoolConfig:FOCUS_PREFER_SAME_APP]) {
        AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appToFocus window:windowToFocus];
        [aw focus];
        return YES;
      }
    }
    if (foundFocus) {
      AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appToFocus window:windowToFocus];
      [aw focus];
      return YES;
    }
    focusCheckWidth += [[SlateConfig getInstance] getIntegerConfig:FOCUS_CHECK_WIDTH];
  }
  return NO;
}

- (BOOL)testOperation {
  if ([self direction] == DIRECTION_UNKNOWN && [self app] == nil)
    @throw [NSException exceptionWithName:@"Unknown Direction" reason:@"direction" userInfo:nil];
  return YES;
}

- (NSString *)checkRequiredOptions:(NSDictionary *)_options {
  if ([_options objectForKey:OPT_APP] == nil && [_options objectForKey:OPT_DIRECTION] == nil) {
    return [[NSArray arrayWithObjects:OPT_APP, OPT_DIRECTION, nil] componentsJoinedByString:@" or "];
  }
  return nil;
}

- (void)parseOption:(NSString *)name value:(id)value {
  if (value == nil) { return; }
  if ([name isEqualToString:OPT_APP]) {
    // should be string
    if (![value isKindOfClass:[NSString class]]) {
      @throw([NSException exceptionWithName:@"Invalid App" reason:[NSString stringWithFormat:@"Invalid App %@", value] userInfo:nil]);
      return;
    }
    [self setApp:value];
  } else if ([name isEqualToString:OPT_DIRECTION]) {
    // should be a string
    if (![value isKindOfClass:[NSString class]]) {
      @throw([NSException exceptionWithName:@"Invalid Direction" reason:[NSString stringWithFormat:@"Invalid Direction %@", value] userInfo:nil]);
      return;
    }
    if ([value isEqualToString:UP] || [value isEqualToString:ABOVE]) {
      [self setDirection:DIRECTION_UP];
    } else if ([value isEqualToString:DOWN] || [value isEqualToString:BELOW]) {
      [self setDirection:DIRECTION_DOWN];
    } else if ([value isEqualToString:LEFT]) {
      [self setDirection:DIRECTION_LEFT];
    } else if ([value isEqualToString:RIGHT]) {
      [self setDirection:DIRECTION_RIGHT];
    } else if ([value isEqualToString:BEHIND]) {
      [self setDirection:DIRECTION_BEHIND];
    } else {
      @throw([NSException exceptionWithName:@"Invalid Direction" reason:[NSString stringWithFormat:@"Invalid Direction %@", value] userInfo:nil]);
      return;
    }
  }
}

+ (id)focusOperation {
  return [[FocusOperation alloc] init];
}

+ (id)focusOperationFromString:(NSString *)focusOperation {
  // focus direction
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:focusOperation into:tokens maxTokens:2];

  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", focusOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Focus operations require the following format: 'focus direction'", focusOperation] userInfo:nil]);
  }

  Operation *op = [[FocusOperation alloc] initWithDirectionOrApp:[tokens objectAtIndex:1]];
  return op;
}

@end

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


@implementation FocusOperation

@synthesize direction;

- (id)init {
  self = [super init];
  return self;
}

- (id)initWithDirection:(NSString *)d {
  self = [super init];
  if (self) {
    if ([d isEqualToString:UP] || [d isEqualToString:ABOVE]) {
      [self setDirection:DIRECTION_UP];
    } else if ([d isEqualToString:DOWN] || [d isEqualToString:BELOW]) {
      [self setDirection:DIRECTION_DOWN];
    } else if ([d isEqualToString:LEFT]) {
      [self setDirection:DIRECTION_LEFT];
    } else if ([d isEqualToString:RIGHT]) {
      [self setDirection:DIRECTION_RIGHT];
    } else if ([d isEqualToString:BEHIND]) {
      [self setDirection:DIRECTION_BEHIND];
    } else {
      [self setDirection:DIRECTION_UNKNOWN];
    }
  }
  return self;
}

- (BOOL)doOperation {
  NSLog(@"----------------- Begin Focus Operation -----------------");
  // We don't use the passed in AccessibilityWrapper or ScreenWrapper so they are nil. No need to waste time creating them here.
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  NSLog(@"-----------------  End Focus Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  BOOL success = YES;
  AccessibilityWrapper *caAW = [[AccessibilityWrapper alloc] init];
  if (![caAW inited]) return NO;
  NSPoint cwTL = [caAW getCurrentTopLeft];
  NSSize cwSize = [caAW getCurrentSize];
  NSRect cwRect = NSMakeRect(cwTL.x, cwTL.y, cwSize.width, cwSize.height);
  NSString *cwTitle = [AccessibilityWrapper getTitle:[caAW window]];
  NSRect checkRect;
  NSInteger focusCheckWidth = [[SlateConfig getInstance] getIntegerConfig:FOCUS_CHECK_WIDTH defaultValue:FOCUS_CHECK_WIDTH_DEFAULT];
  if (direction == DIRECTION_UP) checkRect = NSMakeRect(cwTL.x, cwTL.y-focusCheckWidth, cwSize.width, focusCheckWidth);
  else if (direction == DIRECTION_DOWN) checkRect = NSMakeRect(cwTL.x, cwTL.y+cwSize.height, cwSize.width, focusCheckWidth);
  else if (direction == DIRECTION_LEFT) checkRect = NSMakeRect(cwTL.x-focusCheckWidth, cwTL.y, focusCheckWidth, cwSize.height);
  else if (direction == DIRECTION_RIGHT) checkRect = NSMakeRect(cwTL.x+cwSize.width, cwTL.y, focusCheckWidth, cwSize.height);
  else if (direction == DIRECTION_BEHIND) checkRect = NSMakeRect(cwTL.x, cwTL.y, cwSize.width, cwSize.height);
  else {
    [caAW release];
    return NO;
  }
  NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];
  NSRect biggestIntersection = NSZeroRect;
  AXUIElementRef windowToFocus;
  AXUIElementRef appToFocus;
  BOOL foundFocus = NO;
  BOOL foundFocusInSameApp = NO;
  for (NSInteger j = 0; j < [apps count]; j++) {
    NSDictionary *app = [apps objectAtIndex:j];
    NSString *appName = [app objectForKey:@"NSApplicationName"];
    NSNumber *appPID = [app objectForKey:@"NSApplicationProcessIdentifier"];
    NSLog(@"I see application '%@' with pid '%@'", appName, appPID);

    AXUIElementRef appRef = AXUIElementCreateApplication([appPID intValue]);
    CFArrayRef windows = [AccessibilityWrapper windowsInApp:appRef];
    if (!windows || CFArrayGetCount(windows) == 0) continue;

    for (NSInteger i = 0; i < CFArrayGetCount(windows); i++) {
      AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windows, i)];

      if ([AccessibilityWrapper isWindowMinimizedOrHidden:[aw window]]) {
        NSLog(@" Window is minimized, skipping");
        [aw release];
        continue;
      }

      NSString *wTitle = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windows, i)];
      if ([wTitle isEqualToString:@""]){
        NSLog(@" Title is empty, skipping");
        [aw release];
        continue; // Chrome and Finder have invisible windows for some reason
      }

      NSPoint wTL = [aw getCurrentTopLeft];
      NSSize wSize = [aw getCurrentSize];
      NSLog(@" Checking window in %@ in direction %i with rect: (%f,%f %f,%f), title: [%@]",appName,(int)direction,wTL.x,wTL.y,wSize.width,wSize.height,wTitle);
      NSRect windowRect = NSMakeRect(wTL.x, wTL.y, wSize.width, wSize.height);

      if ([wTitle isEqualToString:cwTitle] && NSEqualRects(windowRect, cwRect) && NSEqualPoints(wTL, cwTL)) {
        NSLog(@" Ignoring current window");
        [aw release];
        continue;
      }
      NSRect intersection = NSIntersectionRect(checkRect, windowRect);
      if ([MathUtils isRect:intersection biggerThan:NSZeroRect] && [AccessibilityWrapper processIdentifierOfUIElement:[caAW app]] == [appPID intValue]) {
        NSLog(@"  Found window in same app in direction %i",(int)direction);
        if ([[SlateConfig getInstance] getBoolConfig:FOCUS_PREFER_SAME_APP defaultValue:FOCUS_PREFER_SAME_APP_DEFAULT]
            && (!foundFocusInSameApp || [MathUtils isRect:intersection biggerThan:biggestIntersection])) {
          NSLog(@"   Preferring same app.");
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
        NSLog(@"  Found window in %@ in direction %i (intersection: %f,%f %f,%f)",appName,(int)direction,intersection.origin.x,intersection.origin.y,intersection.size.width,intersection.size.height);
        appToFocus = appRef;
        windowToFocus = CFArrayGetValueAtIndex(windows, i);
        biggestIntersection = intersection;
        foundFocus = YES;
      }
      [aw release];
    }
    // check if same app && foundFocus && prefer_same_app
    if(foundFocusInSameApp && [AccessibilityWrapper processIdentifierOfUIElement:[caAW app]] == [appPID intValue] && [[SlateConfig getInstance] getBoolConfig:FOCUS_PREFER_SAME_APP defaultValue:FOCUS_PREFER_SAME_APP_DEFAULT]) {
      AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appToFocus window:windowToFocus];
      [aw focus];
      [aw release];
      [caAW release];
      return YES;
    }
  }
  if (!foundFocus) {
    [caAW release];
    return NO;
  } else {
    AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appToFocus window:windowToFocus];
    [aw focus];
    [aw release];
  }
  [caAW release];
  return success;
}

- (BOOL)testOperation {
  if (direction == DIRECTION_UNKNOWN)
    @throw [NSException exceptionWithName:@"Unknown Direction" reason:@"direction" userInfo:nil];
  return YES;
}

- (void)dealloc {
  [super dealloc];
}

@end

//
//  LayoutOperation.m
//  Slate
//
//  Created by Jigish Patel on 6/14/11.
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

#import "ApplicationOptions.h"
#import "Constants.h"
#import "Layout.h"
#import "LayoutOperation.h"
#import "SlateConfig.h"


@implementation LayoutOperation

@synthesize name;

- (id)init {
  self = [super init];
  return self;
}

- (id)initWithName:(NSString *)theName {
  self = [self init];
  if (self) {
    [self setName:theName];
  }
  return self;
}

- (BOOL)doOperation {
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  // We don't use the passed in AccessibilityWrapper so it is nil. No need to waste time creating one here
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:sw];
  [sw release];
  return success;
}

// Note that the AccessibilityWrapper is never used because layouts use multiple applications
- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)unused screenWrapper:(ScreenWrapper *)sw {
  BOOL success = YES;
  NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];
  for (NSInteger i = 0; i < [apps count]; i++) {
    NSDictionary *app = [apps objectAtIndex:i];
    NSString *appName = [app objectForKey:@"NSApplicationName"];
    NSNumber *appPID = [app objectForKey:@"NSApplicationProcessIdentifier"];
    NSLog(@"I see application '%@' with pid '%@'", appName, appPID);
    Layout *layout = [[[SlateConfig getInstance] layouts] objectForKey:[self name]];
    if (layout == nil) {
      @throw([NSException exceptionWithName:@"Unrecognized Layout" reason:[self name] userInfo:nil]);
    }
    NSArray *operations = [[layout appStates] objectForKey:appName];
    if (operations == nil) {
      continue;
    }

    // Yes, I am aware that the following blocks are inefficient. Deal with it.
    AXUIElementRef appRef = AXUIElementCreateApplication([appPID intValue]);
    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
    CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
    CFMutableArrayRef windows = CFArrayCreateMutable(kCFAllocatorDefault, CFArrayGetCount(windowsArr), &kCFTypeArrayCallBacks);
    CFMutableArrayRef windowsAppend = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    // First Pass for main window if needed
    if ([(ApplicationOptions *)[[layout appOptions] objectForKey:appName] mainFirst]) {
      NSLog(@"Main First");
      for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
        if([AccessibilityWrapper isMainWindow:CFArrayGetValueAtIndex(windowsArr, i)]) {
          NSLog(@" Found Main");
          CFArrayAppendValue(windows, CFArrayGetValueAtIndex(windowsArr, i));
          CFArrayRemoveValueAtIndex(windowsArr, i);
          break;
        }
      }
    } else if ([(ApplicationOptions *)[[layout appOptions] objectForKey:appName] mainLast]) {
      NSLog(@"Main Last");
      CFRelease(windowsAppend);
      windowsAppend = CFArrayCreateMutable(kCFAllocatorDefault, 1, &kCFTypeArrayCallBacks);
      for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
        if([AccessibilityWrapper isMainWindow:CFArrayGetValueAtIndex(windowsArr, i)]) {
          NSLog(@" Found Main");
          CFArrayAppendValue(windowsAppend, CFArrayGetValueAtIndex(windowsArr, i));
          CFArrayRemoveValueAtIndex(windowsArr, i);
          break;
        }
      }
    }
    // Second Pass for title order if needed
    if ([(ApplicationOptions *)[[layout appOptions] objectForKey:appName] titleOrder] != nil) {
      NSMutableArray *titleOrder = [NSMutableArray arrayWithArray:[(ApplicationOptions *)[[layout appOptions] objectForKey:appName] titleOrder]];
      NSLog(@"Title Order: %@", titleOrder);
      for (NSInteger j = 0; j < [titleOrder count]; j++) {
        for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
          NSLog(@" Checking Title: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);
          if([[AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)] isEqualToString:[titleOrder objectAtIndex:j]]) {
            NSLog(@" Found Title: %@", [titleOrder objectAtIndex:j]);
            CFArrayAppendValue(windows, CFArrayGetValueAtIndex(windowsArr, i));
            CFArrayRemoveValueAtIndex(windowsArr, i);
            break;
          }
        }
      }
    }
    // Third Pass for sort
    if ([(ApplicationOptions *)[[layout appOptions] objectForKey:appName] sortTitle]) {
      NSLog(@"Sort By Title");
      while (CFArrayGetCount(windowsArr) > 0) {
        NSString *title = nil;
        NSInteger index = 0;
        for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
          NSString *currTitle = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
          if (title == nil) {
            title = currTitle;
            index = i;
            continue;
          }
          if ([title compare:currTitle] == NSOrderedDescending) {
            title = currTitle;
            index = i;
          }
        }
        CFArrayAppendValue(windows, CFArrayGetValueAtIndex(windowsArr, index));
        CFArrayRemoveValueAtIndex(windowsArr, index);
      }
    } else {
      NSLog(@"No Sort");
      CFArrayAppendArray(windows, windowsArr, CFRangeMake(0, CFArrayGetCount(windowsArr)));
    }
    CFArrayAppendArray(windows, windowsAppend, CFRangeMake(0, CFArrayGetCount(windowsAppend)));

    NSInteger failedWindows = 0;
    BOOL appSuccess = YES;
    if ([(ApplicationOptions *)[[layout appOptions] objectForKey:appName] repeat]) {
      for (NSInteger i = 0; i < CFArrayGetCount(windows); i++) {
        AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windows, i)];
        appSuccess = [[operations objectAtIndex:((i-failedWindows) % [operations count])] doOperationWithAccessibilityWrapper:aw screenWrapper:sw] && appSuccess;
        if (![(ApplicationOptions *)[[layout appOptions] objectForKey:appName] ignoreFail] && !appSuccess)
          failedWindows++;
        [aw release];
      }
    } else {
      for (NSInteger i = 0; i < CFArrayGetCount(windows) && i-failedWindows < [operations count]; i++) {
        AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windows, i)];
        appSuccess = [[operations objectAtIndex:(i-failedWindows)] doOperationWithAccessibilityWrapper:aw screenWrapper:sw] && appSuccess;
        if (![(ApplicationOptions *)[[layout appOptions] objectForKey:appName] ignoreFail] && !appSuccess)
          failedWindows++;
        [aw release];
      }
    }
    success = appSuccess && success;
    CFRelease(windows);
    CFRelease(windowsArr);
    CFRelease(windowsAppend);
  }
  return success;
}

- (BOOL)testOperation:(Operation *)op {
  BOOL success = [op testOperation];
  return success;
}

- (BOOL)testOperation {
  BOOL success = YES;
  Layout *layout = [[[SlateConfig getInstance] layouts] objectForKey:[self name]];
  if (layout == nil) {
    @throw([NSException exceptionWithName:@"Unrecognized Layout" reason:[self name] userInfo:nil]);
  }
  NSArray *apps = [[layout appStates] allKeys];
  for (NSInteger i = 0; i < [apps count]; i++) {
    NSArray *ops = [[layout appStates] objectForKey:[apps objectAtIndex:i]];
    for (NSInteger op = 0; op < [ops count]; op++) {
      success = [self testOperation:[ops objectAtIndex:op]] && success;
    }
  }
  return success;
}

@end

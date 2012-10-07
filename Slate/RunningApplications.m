//
//  RunningApplications.m
//  Slate
//
//  Created by Jigish Patel on 3/22/12.
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

#import "RunningApplications.h"
#import "SlateLogger.h"
#import "AccessibilityWrapper.h"
#import "Constants.h"

@implementation RunningApplications

@synthesize apps, appNameToApp, windows, appToWindows, titleToWindow, unusedWindowNumbers, nextWindowNumber, pidToObserver;

static RunningApplications *_instance = nil;

+ (RunningApplications *)getInstance {
  @synchronized([RunningApplications class]) {
    if (!_instance)
      _instance = [[[RunningApplications class] alloc] init];
    return _instance;
  }
}

+ (BOOL)isAppSelectable:(NSRunningApplication *)app {
  return [app activationPolicy] == NSApplicationActivationPolicyRegular;
}

// WINDOW INFO:
//   0 = title
//   1 = NSRunningApplication
//   2 = window number
static void windowCreated(pid_t currPID, AXUIElementRef element, RunningApplications *ref) {
  SlateLogger(@">> WINDOW CREATED <<");
  [ref pruneWindows];
  NSString *title = [AccessibilityWrapper getTitle:element];
  if (title == nil || [EMPTY isEqualToString:title]) return; // skip empty title windows because they are invisible
  NSMutableArray *windowInfo = [NSMutableArray array];
  [windowInfo addObject:title];
  [windowInfo addObject:[NSRunningApplication runningApplicationWithProcessIdentifier:currPID]];
  if ([[ref unusedWindowNumbers] count] > 0) {
    [windowInfo addObject:[[ref unusedWindowNumbers] objectAtIndex:0]];
    [[ref unusedWindowNumbers] removeObjectAtIndex:0];
  } else {
    [windowInfo addObject:[NSNumber numberWithInteger:[ref nextWindowNumber]]];
    [ref setNextWindowNumber:[ref nextWindowNumber]+1];
  }
  [[ref windows] insertObject:windowInfo atIndex:0];
  if ([[ref titleToWindow] objectForKey:title]) {
    [[[ref titleToWindow] objectForKey:title] addObject:windowInfo];
  } else {
    [[ref titleToWindow] setObject:[NSMutableArray arrayWithObject:windowInfo] forKey:title];
  }
  [[[ref appToWindows] objectForKey:[NSNumber numberWithInteger:currPID]] addObject:windowInfo];
}

static void windowCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon) {
  SlateLogger(@">>> %@ for %@", notification, [AccessibilityWrapper getRole:element]);
  if (![AccessibilityWrapper isWindow:element]) return;
  RunningApplications *ref = (__bridge RunningApplications *)refcon;
  pid_t currPID = [AccessibilityWrapper processIdentifierOfUIElement:element];

  // Title Changed, update windows
  if (CFStringCompare(notification, kAXTitleChangedNotification, 0) == kCFCompareEqualTo) {
    SlateLogger(@">>> TITLE CHANGED TO %@", [AccessibilityWrapper getTitle:element]);
    NSNumber *appPID = [NSNumber numberWithInteger:[AccessibilityWrapper processIdentifierOfUIElement:element]];
    NSMutableArray *oldWindowsInApp = [[[ref appToWindows] objectForKey:appPID] mutableCopy];
    CFArrayRef windowsArr = [AccessibilityWrapper windowsInApp:AXUIElementCreateApplication([appPID intValue])];
    // Remove all windows if app has no windows
    if (!windowsArr || CFArrayGetCount(windowsArr) == 0) return;
    if (oldWindowsInApp == nil || [oldWindowsInApp count] == 0) {
      windowCreated(currPID, element, ref);
      return;
    }
    // set up title counts
    NSMutableDictionary *tmpTitleToCount = [NSMutableDictionary dictionary];
    for (NSMutableArray *windowInfo in oldWindowsInApp) {
      NSString *title = [windowInfo objectAtIndex:0];
      if ([tmpTitleToCount objectForKey:title]) {
        [tmpTitleToCount setObject:[NSNumber numberWithInteger:([[tmpTitleToCount objectForKey:title] integerValue]+1)] forKey:title];
      } else {
        [tmpTitleToCount setObject:[NSNumber numberWithInteger:1] forKey:title];
      }
    }
    // figure out which title is new
    NSString *newTitle = nil;
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      AXUIElementRef window = CFArrayGetValueAtIndex(windowsArr, i);
      NSString *currTitle = [AccessibilityWrapper getTitle:window];
      NSNumber *currCount = [tmpTitleToCount objectForKey:currTitle];
      if (currCount == nil || [currCount integerValue] == 0) {
        newTitle = currTitle;
      } else {
        [tmpTitleToCount setObject:[NSNumber numberWithInteger:([currCount integerValue]-1)] forKey:currTitle];
      }
    }
    // figure out which title is old
    NSString *oldTitle = nil;
    for (NSString *currTitle in [tmpTitleToCount allKeys]) {
      NSNumber *currCount = [tmpTitleToCount objectForKey:currTitle];
      if (currCount != nil && [currCount integerValue] > 0) {
        oldTitle = currTitle;
        break;
      }
    }
    // out with the old and in with the new
    if (oldTitle != nil && newTitle != nil) {
      for (NSMutableArray *windowInfo in oldWindowsInApp) {
        if ([[windowInfo objectAtIndex:0] isEqualToString:oldTitle]) {
          [windowInfo removeObjectAtIndex:0];
          [windowInfo insertObject:[AccessibilityWrapper getTitle:element] atIndex:0];
          NSMutableArray *windowsForTitle = [[ref titleToWindow] objectForKey:oldTitle];
          if (!windowsForTitle || [windowsForTitle count] == 0) continue;
          if ([windowsForTitle count] == 1) {
            [[ref titleToWindow] removeObjectForKey:oldTitle];
          } else {
            [windowsForTitle removeObject:windowInfo];
          }
          windowsForTitle = [[ref titleToWindow] objectForKey:[windowInfo objectAtIndex:0]];
          if (!windowsForTitle) {
            [[ref titleToWindow] setObject:[NSMutableArray arrayWithObject:windowInfo] forKey:[windowInfo objectAtIndex:0]];
          } else {
            [windowsForTitle insertObject:windowInfo atIndex:0];
            [[ref titleToWindow] setObject:windowsForTitle forKey:[windowInfo objectAtIndex:0]];
          }
          [ref pruneWindows];
          return;
        }
      }
    }
    [ref pruneWindows];
    return;
  }

  // Focus Changed, update windows
  if (CFStringCompare(notification, kAXFocusedWindowChangedNotification, 0) == kCFCompareEqualTo) {
    [ref pruneWindows];
    return;
  }

  // Window created, add to windows
  windowCreated(currPID, element, ref);
  SlateLogger(@">>> END %@ for %@", notification, [AccessibilityWrapper getRole:element]);
}

- (id)init {
  self = [super init];
  if (self) {
    unusedWindowNumbers = [NSMutableArray array];
    nextWindowNumber = 0;
    apps = [NSMutableArray array];
    appNameToApp = [NSMutableDictionary dictionary];
    windows = [NSMutableArray array];
    appToWindows = [NSMutableDictionary dictionary];
    pidToObserver = [NSMutableDictionary dictionary];
    titleToWindow = [NSMutableDictionary dictionary];
    SlateLogger(@"------------------ Checking Running Applications ------------------");
    NSArray *appsArr = [[NSWorkspace sharedWorkspace] runningApplications];
    NSRunningApplication *currentApp = [NSRunningApplication currentApplication];
    for (NSRunningApplication *app in appsArr) {
      if ([RunningApplications isAppSelectable:app]) {
        SlateLogger(@"  Selectable: %@", [app localizedName]);
        [apps addObject:app];
        [appNameToApp setObject:app forKey:[app localizedName]];
        SlateLogger(@"    I see application '%@'", [app localizedName]);
        // check for windows
        NSNumber *appPID = [NSNumber numberWithInteger:[app processIdentifier]];
        [appToWindows setObject:[NSMutableArray array] forKey:appPID];
        AXUIElementRef appRef = AXUIElementCreateApplication([app processIdentifier]);
        CFArrayRef windowsArr = [AccessibilityWrapper windowsInApp:appRef];
        if (windowsArr && CFArrayGetCount(windowsArr) > 0) {
          SlateLogger(@"      Has Windows: %@", [app localizedName]);
          for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
            NSMutableArray *windowInfo = [NSMutableArray array];
            AXUIElementRef window = CFArrayGetValueAtIndex(windowsArr, i);
            NSString *title = [AccessibilityWrapper getTitle:window];
            if (title == nil || [EMPTY isEqualToString:title]) continue; // skip empty title windows because they are invisible
            SlateLogger(@"        Title: %@", title);
            [windowInfo addObject:title];
            [windowInfo addObject:app];
            [windowInfo addObject:[NSNumber numberWithInteger:nextWindowNumber]];
            if ([self isCurrentApplication:app] && [AccessibilityWrapper isMainWindow:window]) {
              [windows insertObject:windowInfo atIndex:0];
              [[appToWindows objectForKey:appPID] insertObject:windowInfo atIndex:0];
            } else if ([AccessibilityWrapper isMainWindow:window]) {
              [windows addObject:windowInfo];
              [[appToWindows objectForKey:appPID] insertObject:windowInfo atIndex:0];
            } else {
              [windows addObject:windowInfo];
              [[appToWindows objectForKey:appPID] addObject:windowInfo];
            }
            NSMutableArray *windowsForTitle = [titleToWindow objectForKey:title];
            if (!windowsForTitle) {
              [titleToWindow setObject:[NSMutableArray arrayWithObject:windowInfo] forKey:title];
            } else {
              [windowsForTitle addObject:windowInfo];
              [titleToWindow setObject:windowsForTitle forKey:title];
            }
            nextWindowNumber++;
          }
        }
        if ([self isCurrentApplication:app]) {
          currentApp = app;
        }
        AXError err;
        AXUIElementRef sendingApp = AXUIElementCreateApplication([app processIdentifier]);
        AXObserverRef observer;
        err = AXObserverCreate([app processIdentifier], windowCallback, &observer);
        err = AXObserverAddNotification(observer, sendingApp, kAXWindowCreatedNotification, (__bridge void *)self);
        err = AXObserverAddNotification(observer, sendingApp, kAXFocusedWindowChangedNotification, (__bridge void *)self);
        err = AXObserverAddNotification(observer, sendingApp, kAXTitleChangedNotification, (__bridge void *)self);
        CFRunLoopAddSource ([[NSRunLoop currentRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
        [pidToObserver setObject:[NSValue valueWithPointer:observer] forKey:[NSNumber numberWithInteger:[app processIdentifier]]];
      }
    }
    SlateLogger(@"CURRENT APP = '%@'", [currentApp localizedName]);
    [self bringAppToFront:currentApp];
    SlateLogger(@"------------------ Done Checking Running Applications ------------------");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationKilled:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationLaunched:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationDeactivated:) name:NSWorkspaceDidHideApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationActivated:) name:NSWorkspaceDidUnhideApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationDeactivated:) name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
  }
  return self;
}

- (NSRunningApplication *)currentApplication {
  // ownsMenuBar is 10.7+ only
  if ([[NSRunningApplication currentApplication] respondsToSelector:@selector(ownsMenuBar)]) {
    NSArray *appsArr = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in appsArr) {
      if ([RunningApplications isAppSelectable:app]) {
        if ([app ownsMenuBar]) return app;
      }
    }
  }
  return [NSRunningApplication currentApplication];
}

- (BOOL)isCurrentApplication:(NSRunningApplication *)app {
  // ownsMenuBar is 10.7+ only
  if ([[NSRunningApplication currentApplication] respondsToSelector:@selector(ownsMenuBar)]) {
    return [app ownsMenuBar];
  }
  return app == [NSRunningApplication currentApplication];
}

- (void)pruneWindows {
  NSArray *windowsCopy = [windows copy];
  for (NSArray *windowInfo in windowsCopy) {
    if (![apps containsObject:[windowInfo objectAtIndex:1]]) {
      [self removeWindow:windowInfo];
      SlateLogger(@"  PRUNE Because app died");
    }
  }
  for (NSRunningApplication *app in apps) {
    NSNumber *appPID = [NSNumber numberWithInteger:[app processIdentifier]];
    NSMutableArray *oldWindowsInApp = [[appToWindows objectForKey:appPID] mutableCopy];
    CFArrayRef windowsArr = [AccessibilityWrapper windowsInRunningApp:app];
    // Remove all windows if app has no windows
    if (!windowsArr || CFArrayGetCount(windowsArr) == 0) {
      NSArray *windowsToRemove = [[appToWindows objectForKey:appPID] copy];
      for (NSArray *windowInfo in windowsToRemove) {
        [self removeWindow:windowInfo];
        SlateLogger(@"  PRUNE Because app has no windows");
      }
      continue;
    }
    // Remove windows that are no longer open. No need to add windows that we havn't seen because technically our callback should catch it.
    for (NSArray *windowInfo in oldWindowsInApp) {
      BOOL found = NO;
      for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
        AXUIElementRef window = CFArrayGetValueAtIndex(windowsArr, i);
        if ([[windowInfo objectAtIndex:0] isEqualToString:[AccessibilityWrapper getTitle:window]]) {
          found = YES;
        }
      }
      if (!found)  {
        [self removeWindow:windowInfo];
        SlateLogger(@"  PRUNE Because title mismatch");
      }
    }
  }
}

- (void)removeWindow:(NSArray *)windowInfo {
  [unusedWindowNumbers addObject:[windowInfo objectAtIndex:2]];
  [windows removeObject:windowInfo];
  NSNumber *appPID = [NSNumber numberWithInteger:[[windowInfo objectAtIndex:1] processIdentifier]];
  if ([appToWindows objectForKey:appPID] != nil) {
    [[appToWindows objectForKey:appPID] removeObject:windowInfo];
  }
  NSMutableArray *windowsForTitle = [titleToWindow objectForKey:[windowInfo objectAtIndex:0]];
  if (!windowsForTitle || [windowsForTitle count] <= 1) {
    [titleToWindow removeObjectForKey:[windowInfo objectAtIndex:0]];
  } else {
    [windowsForTitle removeObject:windowInfo];
    [titleToWindow setObject:windowsForTitle forKey:[windowInfo objectAtIndex:0]];
  }
}

- (void)notificationRecieved:(id)notification {
  SlateLogger(@"NOTE RECIEVED: %@", [notification name]);
}

- (void)applicationActivated:(id)notification {
  SlateLogger(@"Activated: %@", [notification name]);
  NSRunningApplication *activatedApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
  if ([[activatedApp localizedName] isEqualToString:@"Slate"]) return;
  [self bringAppToFront:activatedApp];
  [self pruneWindows];
}

- (void)applicationDeactivated:(id)notification {
  SlateLogger(@"Deactivated: %@", [notification name]);
}

- (void)applicationLaunched:(id)notification {
  SlateLogger(@"Launched: %@", [notification name]);
  NSRunningApplication *launchedApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
  if ([[launchedApp localizedName] isEqualToString:@"Slate"]) return;
  NSNumber *appPID = [NSNumber numberWithInteger:[launchedApp processIdentifier]];
  [appToWindows setObject:[NSMutableArray array] forKey:appPID];
  // add already created windows
  CFArrayRef windowsArr = [AccessibilityWrapper windowsInApp:AXUIElementCreateApplication([launchedApp processIdentifier])];
  if (windowsArr != NULL) {
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      AXUIElementRef element = CFArrayGetValueAtIndex(windowsArr, i);
      NSString *title = [AccessibilityWrapper getTitle:element];
      if (title == nil || [EMPTY isEqualToString:title]) continue; // skip empty title windows because they are invisible
      NSMutableArray *windowInfo = [NSMutableArray array];
      [windowInfo addObject:title];
      [windowInfo addObject:[NSRunningApplication runningApplicationWithProcessIdentifier:[launchedApp processIdentifier]]];
      if ([[self unusedWindowNumbers] count] > 0) {
        [windowInfo addObject:[[self unusedWindowNumbers] objectAtIndex:0]];
        [[self unusedWindowNumbers] removeObjectAtIndex:0];
      } else {
        [windowInfo addObject:[NSNumber numberWithInteger:[self nextWindowNumber]]];
        [self setNextWindowNumber:[self nextWindowNumber]+1];
      }
      [[self windows] insertObject:windowInfo atIndex:0];
      NSMutableArray *windowsForTitle = [[self titleToWindow] objectForKey:title];
      if (!windowsForTitle) {
        [[self titleToWindow] setObject:[NSMutableArray arrayWithObject:windowInfo] forKey:title];
      } else {
        [windowsForTitle addObject:windowInfo];
        [[self titleToWindow] setObject:windowsForTitle forKey:title];
      }
      [[[self appToWindows] objectForKey:[NSNumber numberWithInteger:[launchedApp processIdentifier]]] addObject:windowInfo];
    }
  }
  AXError err;
  AXUIElementRef sendingApp = AXUIElementCreateApplication([launchedApp processIdentifier]);
  AXObserverRef observer;
  err = AXObserverCreate([launchedApp processIdentifier], windowCallback, &observer);
  err = AXObserverAddNotification(observer, sendingApp, kAXWindowCreatedNotification, (__bridge void *)self);
  err = AXObserverAddNotification(observer, sendingApp, kAXFocusedWindowChangedNotification, (__bridge void *)self);
  err = AXObserverAddNotification(observer, sendingApp, kAXTitleChangedNotification, (__bridge void *)self);
  CFRunLoopAddSource ([[NSRunLoop currentRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
  [pidToObserver setObject:[NSValue valueWithPointer:observer] forKey:[NSNumber numberWithInteger:[launchedApp processIdentifier]]];
  [self bringAppToFront:launchedApp];
  [self pruneWindows];
}

- (void)applicationKilled:(id)notification {
  SlateLogger(@"Killed: %@", [notification name]);
  NSRunningApplication *app = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
  [apps removeObject:app];
  [appNameToApp removeObjectForKey:[app localizedName]];
  NSNumber *appPID = [NSNumber numberWithInteger:[app processIdentifier]];
  [appToWindows removeObjectForKey:appPID];
  AXObserverRemoveNotification([[pidToObserver objectForKey:[NSNumber numberWithInteger:[app processIdentifier]]] pointerValue], AXUIElementCreateApplication([app processIdentifier]), kAXWindowCreatedNotification);
  [pidToObserver removeObjectForKey:[NSNumber numberWithInteger:[app processIdentifier]]];
  [self pruneWindows];
  [self bringAppToFront:[self currentApplication]];
}

- (void)bringAppToFront:(NSRunningApplication *)app {
  if (![RunningApplications isAppSelectable:app]) return;
  [apps removeObject:app];
  [apps insertObject:app atIndex:0];
#ifdef DEBUG
  SlateLogger(@"  New App Order:");
  for (NSRunningApplication *app in apps) {
    SlateLogger(@"    %@", [app localizedName]);
  }
#endif
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id *)stackbuf count:(NSUInteger)len {
  return [apps countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (NSArray *)windowIdsForTitle:(NSString *)title {
  NSArray *windowsForTitle = [titleToWindow objectForKey:title];
  if (windowsForTitle == nil || [windowsForTitle count] == 0) return nil;
  NSMutableArray *windowIdsForTitle = [NSMutableArray array];
  for(NSArray *windowInfo in windowsForTitle) {
    [windowIdsForTitle addObject:[windowInfo objectAtIndex:2]];
  }
  return windowIdsForTitle;
}

@end

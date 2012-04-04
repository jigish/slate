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

@synthesize apps, windows, appToWindows, titleToWindow, unusedWindowNumbers, nextWindowNumber, pidToObserver;

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
    CFArrayRef windowsArr = [AccessibilityWrapper windowsInApp:AXUIElementCreateApplication([appPID integerValue])];
    // Remove all windows if app has no windows
    if (!windowsArr || CFArrayGetCount(windowsArr) == 0) return;
    for (NSMutableArray *windowInfo in oldWindowsInApp) {
      BOOL found = NO;
      for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
        AXUIElementRef window = CFArrayGetValueAtIndex(windowsArr, i);
        if ([[windowInfo objectAtIndex:0] isEqualToString:[AccessibilityWrapper getTitle:window]]) {
          found = YES;
        }
      }
      if (!found)  {
        NSString *oldTitle = [windowInfo objectAtIndex:0];
        [windowInfo removeObjectAtIndex:0];
        [windowInfo insertObject:[AccessibilityWrapper getTitle:element] atIndex:0];
        [[ref titleToWindow] removeObjectForKey:oldTitle];
        [[ref titleToWindow] setObject:windowInfo forKey:[windowInfo objectAtIndex:0]];
        [ref pruneWindows];
        return;
      }
    }
    [ref pruneWindows];
    return;
  }

  // Focus Changed, update windows
  if (CFStringCompare(notification, kAXFocusedWindowChangedNotification, 0) == kCFCompareEqualTo) {
    NSArray *windows = [[ref windows] copy];
    for (NSArray *windowInfo in windows) {
      NSString *title = [windowInfo objectAtIndex:0];
      pid_t appPID = [[windowInfo objectAtIndex:1] processIdentifier];
      if (currPID == appPID && [title isEqualToString:[AccessibilityWrapper getTitle:element]]) {
        [ref bringWindowToFront:windowInfo];
        [ref pruneWindows];
        SlateLogger(@">>> ENDED WELL %@ for %@", notification, [AccessibilityWrapper getRole:element]);
        return;
      }
    }
    SlateLogger(@">>> ENDED BAD %@ for %@", notification, [AccessibilityWrapper getRole:element]);
    [ref pruneWindows];
    return;
  }

  // Window created, add to windows
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
  [[ref titleToWindow] setObject:windowInfo forKey:title];
  [[[ref appToWindows] objectForKey:[NSNumber numberWithInteger:currPID]] addObject:windowInfo];
#ifdef DEBUG
  SlateLogger(@"  New Window Order:");
  for (NSArray *windowInfo in [ref windows]) {
    SlateLogger(@"    [%@] %@ #%@", [[windowInfo objectAtIndex:1] localizedName], [windowInfo objectAtIndex:0], [windowInfo objectAtIndex:2]);
  }
#endif
  SlateLogger(@">>> END %@ for %@", notification, [AccessibilityWrapper getRole:element]);
}

- (id)init {
  self = [super init];
  if (self) {
    unusedWindowNumbers = [NSMutableArray array];
    nextWindowNumber = 0;
    apps = [NSMutableArray array];
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
            if ([app ownsMenuBar] && [AccessibilityWrapper isMainWindow:window]) {
              [windows insertObject:windowInfo atIndex:0];
              [[appToWindows objectForKey:appPID] insertObject:windowInfo atIndex:0];
            } else if ([AccessibilityWrapper isMainWindow:window]) {
              [windows addObject:windowInfo];
              [[appToWindows objectForKey:appPID] insertObject:windowInfo atIndex:0];
            } else {
              [windows addObject:windowInfo];
              [[appToWindows objectForKey:appPID] addObject:windowInfo];
            }
            [titleToWindow setObject:windowInfo forKey:title];
            nextWindowNumber++;
          }
        }
        if ([app ownsMenuBar]) {
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
  NSArray *appsArr = [[NSWorkspace sharedWorkspace] runningApplications];
  for (NSRunningApplication *app in appsArr) {
    if ([RunningApplications isAppSelectable:app]) {
      if ([app ownsMenuBar]) return app;
    }
  }
  return [NSRunningApplication currentApplication];
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
#ifdef DEBUG
  SlateLogger(@"  New Window Order:");
  for (NSArray *windowInfo in windows) {
    SlateLogger(@"    [%@] %@ #%@", [[windowInfo objectAtIndex:1] localizedName], [windowInfo objectAtIndex:0], [windowInfo objectAtIndex:2]);
  }
#endif
}

- (void)removeWindow:(NSArray *)windowInfo {
  [unusedWindowNumbers addObject:[windowInfo objectAtIndex:2]];
  [windows removeObject:windowInfo];
  NSNumber *appPID = [NSNumber numberWithInteger:[[windowInfo objectAtIndex:1] processIdentifier]];
  if ([appToWindows objectForKey:appPID] != nil) {
    [[appToWindows objectForKey:appPID] removeObject:windowInfo];
  }
  [titleToWindow removeObjectForKey:[windowInfo objectAtIndex:0]];
}

- (void)notificationRecieved:(id)notification {
  SlateLogger(@"NOTE RECIEVED: %@", [notification name]);
}

- (void)applicationActivated:(id)notification {
  SlateLogger(@"Activated: %@", [notification name]);
  NSRunningApplication *activatedApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
  if ([[activatedApp localizedName] isEqualToString:@"Slate"]) return;
  [self bringAppToFront:activatedApp];
  NSArray *windowInfo = [titleToWindow objectForKey:[AccessibilityWrapper getTitle:[AccessibilityWrapper focusedWindowInRunningApp:activatedApp]]];
  if (windowInfo != nil) [self bringWindowToFront:windowInfo];
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
  NSArray *windowInfo = [titleToWindow objectForKey:[AccessibilityWrapper getTitle:[AccessibilityWrapper focusedWindowInRunningApp:launchedApp]]];
  if (windowInfo != nil) [self bringWindowToFront:windowInfo];
  [self pruneWindows];
}

- (void)applicationKilled:(id)notification {
  SlateLogger(@"Killed: %@", [notification name]);
  NSRunningApplication *app = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
  [apps removeObject:app];
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

- (void)bringWindowToFront:(NSArray *)windowInfo {
  [windows removeObject:windowInfo];
  [windows insertObject:windowInfo atIndex:0];
#ifdef DEBUG
  SlateLogger(@"  New Window Order:");
  for (NSArray *windowInfo in windows) {
    SlateLogger(@"    [%@] %@ #%@", [[windowInfo objectAtIndex:1] localizedName], [windowInfo objectAtIndex:0], [windowInfo objectAtIndex:2]);
  }
#endif
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id *)stackbuf count:(NSUInteger)len {
  return [apps countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (NSInteger)windowIdForTitle:(NSString *)title {
  if ([titleToWindow objectForKey:title] == nil) return -1;
  return [[[titleToWindow objectForKey:title] objectAtIndex:2] integerValue];
}

@end

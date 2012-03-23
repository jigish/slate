//
//  RunningApplications.m
//  Slate
//
//  Created by Jigish Patel on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RunningApplications.h"
#import "SlateLogger.h"
#import "AccessibilityWrapper.h"

@implementation RunningApplications

@synthesize apps;

static RunningApplications *_instance = nil;

+ (RunningApplications *)getInstance {
  @synchronized([RunningApplications class]) {
    if (!_instance)
      _instance = [[[RunningApplications class] alloc] init];
    return _instance;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    apps = [NSMutableArray array];
    SlateLogger(@"------------------ Checking Running Applications ------------------");
    NSArray *appsArr = [[NSWorkspace sharedWorkspace] runningApplications];
    NSRunningApplication *currentApp = [NSRunningApplication currentApplication];
    for (NSRunningApplication *app in appsArr) {
      if ([AccessibilityWrapper isAppSelectable:app]) {
        [apps addObject:app];
        if ([app ownsMenuBar]) {
          currentApp = app;
        }
        SlateLogger(@"I see application '%@'", [app localizedName]);
      }
    }
    SlateLogger(@"CURRENT APP = '%@'", [currentApp localizedName]);
    [self bringAppToFront:currentApp];
    SlateLogger(@"------------------ Done Checking Running Applications ------------------");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationKilled:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationActivated:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
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
    if ([AccessibilityWrapper isAppSelectable:app]) {
      if ([app ownsMenuBar]) return app;
    }
  }
  return [NSRunningApplication currentApplication];
}

- (void)applicationActivated:(id)notification {
  SlateLogger(@"Activated: %@", [notification name]);
  [self bringAppToFront:[[notification userInfo] objectForKey:NSWorkspaceApplicationKey]];
}

- (void)applicationDeactivated:(id)notification {
  SlateLogger(@"Deactivated: %@", [notification name]);
}

- (void)applicationKilled:(id)notification {
  SlateLogger(@"Killed: %@", [notification name]);
  [apps removeObject:[[notification userInfo] objectForKey:NSWorkspaceApplicationKey]];
  [self bringAppToFront:[self currentApplication]];
}

- (void)bringAppToFront:(NSRunningApplication *)app {
  if ([AccessibilityWrapper isAppIgnored:app]) return;
  [apps removeObject:app];
  [apps insertObject:app atIndex:0];
  //SlateLogger(@"  New App Order:");
  //for (NSRunningApplication *app in apps) {
  //  SlateLogger(@"    %@", [app localizedName]);
  //}
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id *)stackbuf count:(NSUInteger)len {
  return [apps countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end

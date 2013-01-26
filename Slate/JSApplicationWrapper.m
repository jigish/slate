//
//  JSApplicationWrapper.m
//  Slate
//
//  Created by Jigish Patel on 1/21/13.
//  Copyright 2013 Jigish Patel. All rights reserved.
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

#import "JSApplicationWrapper.h"
#import "AccessibilityWrapper.h"
#import "ScreenWrapper.h"
#import "JSController.h"
#import "JSWindowWrapper.h"
#import "JSOperationWrapper.h"

@implementation JSApplicationWrapper

static NSDictionary *jsawJsMethods;

@synthesize aw, sw, app;

- (id)init {
  self = [super init];
  if (self) {
    [self setAw:[[AccessibilityWrapper alloc] init]];
    [self setSw:[[ScreenWrapper alloc] init]];
    [self setApp:[NSRunningApplication runningApplicationWithProcessIdentifier:[aw processIdentifier]]];
    [JSApplicationWrapper setJsMethods];
  }
  return self;
}

- (id)initWithAccessibilityWrapper:(AccessibilityWrapper *)_aw screenWrapper:(ScreenWrapper *)_sw {
  self = [super init];
  if (self) {
    [self setAw:_aw];
    [self setSw:_sw];
    [self setApp:[NSRunningApplication runningApplicationWithProcessIdentifier:[aw processIdentifier]]];
    [JSApplicationWrapper setJsMethods];
  }
  return self;
}

- (id)initWithRunningApplication:(NSRunningApplication *)_app screenWrapper:(ScreenWrapper *)_sw {
  self = [super init];
  if (self) {
    [self setApp:_app];
    [self setAw:nil];
    [self setSw:_sw];
    [JSApplicationWrapper setJsMethods];
  }
  return self;
}

- (pid_t)pid {
  return [app processIdentifier];
}

- (NSString *)name {
  return [app localizedName];
}

- (id)focusedWindow {
  AccessibilityWrapper *_aw = [[AccessibilityWrapper alloc] initWithApp:AXUIElementCreateApplication([app processIdentifier])
                                                                 window:[AccessibilityWrapper focusedWindowInRunningApp:app]];
  return [[JSWindowWrapper alloc] initWithAccessibilityWrapper:_aw screenWrapper:sw];
}

- (void)eachWindow:(id)funcOrOp {
  NSString *type = [[JSController getInstance] jsTypeof:funcOrOp];
  CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInRunningApp:app];
  if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) return;
  CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
  if ([funcOrOp isKindOfClass:[Operation class]] || [funcOrOp isKindOfClass:[JSOperationWrapper class]]) {
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      AccessibilityWrapper *_aw = [[AccessibilityWrapper alloc] initWithApp:AXUIElementCreateApplication([app processIdentifier])
                                                                     window:CFArrayGetValueAtIndex(windowsArr, i)];
      [funcOrOp doOperationWithAccessibilityWrapper:_aw screenWrapper:sw];
    }
  } else if ([@"function" isEqualToString:type]) {
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      AccessibilityWrapper *_aw = [[AccessibilityWrapper alloc] initWithApp:AXUIElementCreateApplication([app processIdentifier])
                                                                     window:CFArrayGetValueAtIndex(windowsArr, i)];
      [[JSController getInstance] runFunction:funcOrOp withArg:[[JSWindowWrapper alloc] initWithAccessibilityWrapper:_aw screenWrapper:sw]];
    }
  }
}

- (NSString *)toString {
  return [self name];
}

+ (void)setJsMethods {
  if (jsawJsMethods == nil) {
    jsawJsMethods = @{
      NSStringFromSelector(@selector(pid)): @"pid",
      NSStringFromSelector(@selector(name)): @"name",
      NSStringFromSelector(@selector(eachWindow:)): @"eachWindow",
      NSStringFromSelector(@selector(focusedWindow)): @"focusedWindow",
    };
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [jsawJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [jsawJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end

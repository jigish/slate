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

@implementation JSApplicationWrapper

static NSDictionary *jsawJsMethods;

@synthesize aw, app;

- (id)init {
  self = [super init];
  if (self) {
    [self setAw:[[AccessibilityWrapper alloc] init]];
    [self setApp:[NSRunningApplication runningApplicationWithProcessIdentifier:[aw processIdentifier]]];
    [JSApplicationWrapper setJsMethods];
  }
  return self;
}

- (id)initWithAccessibilityWrapper:(AccessibilityWrapper *)_aw {
  self = [super init];
  if (self) {
    [self setAw:_aw];
    [self setApp:[NSRunningApplication runningApplicationWithProcessIdentifier:[aw processIdentifier]]];
    [JSApplicationWrapper setJsMethods];
  }
  return self;
}

- (id)initWithRunningApplication:(NSRunningApplication *)_app {
  self = [super init];
  if (self) {
    [self setApp:_app];
    [self setAw:nil];
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

+ (void)setJsMethods {
  if (jsawJsMethods == nil) {
    jsawJsMethods = @{
      NSStringFromSelector(@selector(pid)): @"pid",
      NSStringFromSelector(@selector(name)): @"name",
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

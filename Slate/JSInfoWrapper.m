//
//  JSInfoWrapper.m
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

#import "JSInfoWrapper.h"
#import "ScreenWrapper.h"
#import <WebKit/WebKit.h>
#import "JSWindowWrapper.h"
#import "JSApplicationWrapper.h"
#import "AccessibilityWrapper.h"

@implementation JSInfoWrapper

@synthesize sw, aw;

static JSInfoWrapper *_instance = nil;
static NSDictionary *jsiwJsMethods;

+ (JSInfoWrapper *)getInstance {
  @synchronized([JSInfoWrapper class]) {
    if (!_instance)
      _instance = [[[JSInfoWrapper class] alloc] init];
    return _instance;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    [self setAw:nil];
    [self setSw:nil];
    [JSInfoWrapper setJsMethods];
  }
  return self;
}

- (id)initWithAccessibilityWrapper:(AccessibilityWrapper *)_aw screenWrapper:(ScreenWrapper *)_sw {
  self = [super init];
  if (self) {
    [self setAw:_aw];
    [self setSw:_sw];
    [JSInfoWrapper setJsMethods];
  }
  return self;
}

- (JSWindowWrapper *)window {
  return [[JSWindowWrapper alloc] initWithAccessibilityWrapper:aw screenWrapper:sw];
}

- (JSApplicationWrapper *)app {
  return [[JSApplicationWrapper alloc] initWithAccessibilityWrapper:aw];
}

+ (void)setJsMethods {
  if (jsiwJsMethods == nil) {
    jsiwJsMethods = @{
      NSStringFromSelector(@selector(window)): @"window",
      NSStringFromSelector(@selector(app)): @"app",
    };
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [jsiwJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [jsiwJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end

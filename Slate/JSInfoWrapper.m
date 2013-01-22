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

static NSDictionary *siwJsMethods;

@implementation JSInfoWrapper

@synthesize sw;

- (id)init {
  self = [super init];
  if (self) {
    [self setSw:[[ScreenWrapper alloc] init]];
    [JSInfoWrapper setJsMethods];
  }
  return self;
}

- (id)initWithScreenWrapper:(ScreenWrapper *)_sw {
  self = [super init];
  if (self) {
    [self setSw:_sw];
    [JSInfoWrapper setJsMethods];
  }
  return self;
}

- (JSWindowWrapper *)focusedWindow {
  return [[JSWindowWrapper alloc] init];
}

- (JSWindowWrapper *)focusedApplication {
  return [[JSWindowWrapper alloc] init];
}

+ (void)setJsMethods {
  if (siwJsMethods == nil) {
    siwJsMethods = @{
      NSStringFromSelector(@selector(focusedWindow)): @"focusedWindow",
    };
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [siwJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [siwJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end

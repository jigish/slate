//
//  JSScreenWrapper.m
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

#import "JSScreenWrapper.h"
#import "ScreenWrapper.h"
#import "JSController.h"

@implementation JSScreenWrapper

static NSDictionary *jsswJsMethods = nil;

@synthesize screenId;
@synthesize sw;

- (id)init {
  self = [super init];
  if (self) {
    [self setScreenId:0];
    [self setSw:[[ScreenWrapper alloc] init]];
    [JSScreenWrapper setJsMethods];
  }
  return self;
}

- (id)initWithScreenId:(NSInteger)_id screenWrapper:(ScreenWrapper *)_sw {
  self = [super init];
  if (self) {
    [self setScreenId:_id];
    [self setSw:_sw];
    [JSScreenWrapper setJsMethods];
  }
  return self;
}

- (id)resolution {
  NSRect rect = [sw getScreenRectForRef:[self screenId]];
  return [[JSController getInstance] marshall:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:rect.size.width],
                                                                                         @"width",
                                                                                         [NSNumber numberWithInteger:rect.size.height],
                                                                                         @"height", nil]];
}

- (NSString *)toString {
  return [NSString stringWithFormat:@"%ld", [self screenId]];
}

- (BOOL)isMain {
  return [sw isMainScreenRef:[self screenId]];
}

+ (void)setJsMethods {
  if (jsswJsMethods == nil) {
    jsswJsMethods = @{
      NSStringFromSelector(@selector(screenId)): @"id",
      NSStringFromSelector(@selector(resolution)): @"resolution",
      NSStringFromSelector(@selector(isMain)): @"isMain",
    };
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [jsswJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [jsswJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end

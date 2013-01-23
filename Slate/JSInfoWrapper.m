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
#import "JSController.h"
#import "RunningApplications.h"
#import "ExpressionPoint.h"
#import "JSScreenWrapper.h"

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
    [self setAw:[[AccessibilityWrapper alloc] init]];
    [self setSw:[[ScreenWrapper alloc] init]];
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
  return [[JSApplicationWrapper alloc] initWithAccessibilityWrapper:aw screenWrapper:sw];
}

- (NSDictionary *)screenAndWindowValues:(NSString *)screen {
  NSInteger screenId = 0;
  NSPoint wTL = [aw getCurrentTopLeft];
  NSSize wSize = [aw getCurrentSize];
  NSRect wRect = NSMakeRect(wTL.x, wTL.y, wSize.width, wSize.height);
  if (screen != nil) {
    screenId = [sw getScreenId:screen windowRect:wRect];
  } else {
    screenId = [sw getScreenIdForRect:wRect];
  }
  return [sw getScreenAndWindowValues:screenId window:wRect newSize:wRect.size];
}

- (JSWindowWrapper *)windowUnderPoint:(id)point {
  id pointDict = [[JSController getInstance] unmarshall:point];
  if (![pointDict isKindOfClass:[NSDictionary class]]) { return NO; }
  if ([pointDict objectForKey:@"x"] == nil) { return NO; }
  if ([pointDict objectForKey:@"y"] == nil) { return NO; }

  NSDictionary *values = nil;
  float x = 0;
  if ([[pointDict objectForKey:@"x"] isKindOfClass:[NSString class]]) {
    values = [self screenAndWindowValues:[pointDict objectForKey:@"screen"]];
    x = [ExpressionPoint expToFloat:[pointDict objectForKey:@"x"] withDict:values];
  } else if ([[pointDict objectForKey:@"x"] isKindOfClass:[NSNumber class]] ||
             [[pointDict objectForKey:@"x"] isKindOfClass:[NSValue class]]) {
    x = [[pointDict objectForKey:@"x"] floatValue];
  } else {
    return NO;
  }
  float y = 0;
  if ([[pointDict objectForKey:@"y"] isKindOfClass:[NSString class]]) {
    if (values == nil) {
      values = [self screenAndWindowValues:[pointDict objectForKey:@"screen"]];
    }
    y = [ExpressionPoint expToFloat:[pointDict objectForKey:@"y"] withDict:values];
  } else if ([[pointDict objectForKey:@"y"] isKindOfClass:[NSNumber class]] ||
             [[pointDict objectForKey:@"y"] isKindOfClass:[NSValue class]]) {
    y = [[pointDict objectForKey:@"y"] floatValue];
  } else {
    return NO;
  }

  AXUIElementRef win = [AccessibilityWrapper windowUnderPoint:NSMakePoint(x, y)];
  if (win == nil || win == NULL) { return nil; }
  AXUIElementRef app = [AccessibilityWrapper applicationForElement:win];
  AccessibilityWrapper *_aw = [[AccessibilityWrapper alloc] initWithApp:app window:win];
  return [[JSWindowWrapper alloc] initWithAccessibilityWrapper:_aw screenWrapper:sw];
}

- (void)eachApp:(id)func {
  for (NSRunningApplication *runningApp in [RunningApplications getInstance]) {
    [[JSController getInstance] runFunction:func withArg:[[JSApplicationWrapper alloc] initWithRunningApplication:runningApp
                                                                                                    screenWrapper:sw]];
  }
}

- (JSScreenWrapper *)screen {
  NSPoint tl = [aw getCurrentTopLeft];
  NSSize size = [aw getCurrentSize];
  NSRect wRect = NSMakeRect(tl.x, tl.y, size.width, size.height);
  return [[JSScreenWrapper alloc] initWithScreenId:[sw getScreenRefIdForRect:wRect] screenWrapper:sw];
}

- (BOOL)isRectOffScreen:(id)rect {
  id rectDict = [[JSController getInstance] unmarshall:rect];
  if (![rectDict isKindOfClass:[NSDictionary class]]) { return NO; }
  if ([rectDict objectForKey:@"x"] == nil) { return NO; }
  if ([rectDict objectForKey:@"y"] == nil) { return NO; }
  if ([rectDict objectForKey:@"width"] == nil) { return NO; }
  if ([rectDict objectForKey:@"height"] == nil) { return NO; }

  float x = 0;
  if ([[rectDict objectForKey:@"x"] isKindOfClass:[NSNumber class]] ||
      [[rectDict objectForKey:@"x"] isKindOfClass:[NSValue class]]) {
    x = [[rectDict objectForKey:@"x"] floatValue];
  } else {
    return NO;
  }
  float y = 0;
  if ([[rectDict objectForKey:@"y"] isKindOfClass:[NSNumber class]] ||
      [[rectDict objectForKey:@"y"] isKindOfClass:[NSValue class]]) {
    y = [[rectDict objectForKey:@"y"] floatValue];
  } else {
    return NO;
  }
  float width = 0;
  if ([[rectDict objectForKey:@"width"] isKindOfClass:[NSNumber class]] ||
      [[rectDict objectForKey:@"width"] isKindOfClass:[NSValue class]]) {
    width = [[rectDict objectForKey:@"width"] floatValue];
  } else {
    return NO;
  }
  float height = 0;
  if ([[rectDict objectForKey:@"height"] isKindOfClass:[NSNumber class]] ||
      [[rectDict objectForKey:@"height"] isKindOfClass:[NSValue class]]) {
    height = [[rectDict objectForKey:@"height"] floatValue];
  } else {
    return NO;
  }

  return [sw isRectOffScreen:NSMakeRect(x, y, width, height)];
}

- (JSScreenWrapper *)screenForRef:(NSString *)ref {
  NSPoint tl = [aw getCurrentTopLeft];
  NSSize size = [aw getCurrentSize];
  NSRect wRect = NSMakeRect(tl.x, tl.y, size.width, size.height);
  return [[JSScreenWrapper alloc] initWithScreenId:[sw getScreenRefId:ref windowRect:wRect] screenWrapper:sw];
}

- (NSInteger)screenCount {
  return [sw getScreenCount];
}

- (void)eachScreen:(id)func {
  for (NSInteger i = 0; i < [sw getScreenCount]; i++) {
    [[JSController getInstance] runFunction:func withArg:[[JSScreenWrapper alloc] initWithScreenId:i
                                                                                     screenWrapper:sw]];
  }
}

- (id)jsMethods {
  NSMutableArray *methods = [[jsiwJsMethods allValues] mutableCopy];
  [methods removeObject:@"jsMethods"];
  return [[JSController getInstance] marshall:methods];
}

+ (void)setJsMethods {
  if (jsiwJsMethods == nil) {
    jsiwJsMethods = @{
      NSStringFromSelector(@selector(window)): @"window",
      NSStringFromSelector(@selector(app)): @"app",
      NSStringFromSelector(@selector(screen)): @"screen",
      NSStringFromSelector(@selector(eachApp:)): @"eachApp",
      NSStringFromSelector(@selector(windowUnderPoint:)): @"windowUnderPoint",
      NSStringFromSelector(@selector(isRectOffScreen:)): @"isRectOffScreen",
      NSStringFromSelector(@selector(screenForRef:)): @"screenForRef",
      NSStringFromSelector(@selector(screenCount)): @"screenCount",
      NSStringFromSelector(@selector(eachScreen:)): @"eachScreen",
      NSStringFromSelector(@selector(jsMethods)): @"jsMethods",
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

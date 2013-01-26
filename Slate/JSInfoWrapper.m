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
#import "JSWrapperUtils.h"

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

- (JSWindowWrapper *)windowUnderPoint:(id)point {
  id pointDict = [[JSController getInstance] unmarshall:point];
  NSValue *p = [JSWrapperUtils pointFromDict:pointDict aw:aw sw:sw];
  if (p == nil) { return nil; }
  AXUIElementRef win = [AccessibilityWrapper windowUnderPoint:[p pointValue]];
  if (win == nil || win == NULL) { return nil; }
  AXUIElementRef app = [AccessibilityWrapper applicationForElement:win];
  AccessibilityWrapper *_aw = [[AccessibilityWrapper alloc] initWithApp:app window:win];
  return [[JSWindowWrapper alloc] initWithAccessibilityWrapper:_aw screenWrapper:sw];
}

- (JSScreenWrapper *)screenUnderPoint:(id)point {
  id pointDict = [[JSController getInstance] unmarshall:point];
  NSValue *p = [JSWrapperUtils pointFromDict:pointDict aw:aw sw:sw];
  if (p == nil) { return nil; }
  return [[JSScreenWrapper alloc] initWithScreenId:[sw getScreenRefIdForPoint:[p pointValue]] screenWrapper:sw];
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
  NSValue *r = [JSWrapperUtils rectFromDict:rectDict aw:aw sw:sw];
  if (r == nil) { return NO; }

  return [sw isRectOffScreen:[r rectValue]];
}

- (BOOL)isPointOffScreen:(id)point {
  id pointDict = [[JSController getInstance] unmarshall:point];
  NSValue *p = [JSWrapperUtils pointFromDict:pointDict aw:aw sw:sw];
  if (p == nil) { return NO; }
  NSPoint _point = [p pointValue];
  return [sw isRectOffScreen:NSMakeRect(_point.x, _point.y, 0, 0)];
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
      NSStringFromSelector(@selector(eachApp:)): @"eapp",
      NSStringFromSelector(@selector(windowUnderPoint:)): @"windowUnderPoint",
      NSStringFromSelector(@selector(windowUnderPoint:)): @"wup",
      NSStringFromSelector(@selector(isRectOffScreen:)): @"isRectOffScreen",
      NSStringFromSelector(@selector(isRectOffScreen:)): @"rectoff",
      NSStringFromSelector(@selector(isPointOffScreen:)): @"isPointOffScreen",
      NSStringFromSelector(@selector(isPointOffScreen:)): @"pntoff",
      NSStringFromSelector(@selector(screenForRef:)): @"screenForRef",
      NSStringFromSelector(@selector(screenForRef:)): @"screenr",
      NSStringFromSelector(@selector(screenCount)): @"screenCount",
      NSStringFromSelector(@selector(screenCount)): @"screenc",
      NSStringFromSelector(@selector(screenUnderPoint:)): @"screenUnderPoint",
      NSStringFromSelector(@selector(screenUnderPoint:)): @"sup",
      NSStringFromSelector(@selector(eachScreen:)): @"eachScreen",
      NSStringFromSelector(@selector(eachScreen:)): @"escreen",
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

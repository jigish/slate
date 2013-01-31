//
//  JSWindowWrapper.m
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

#import "JSWindowWrapper.h"
#import "AccessibilityWrapper.h"
#import "ScreenWrapper.h"
#import "JSController.h"
#import "ExpressionPoint.h"
#import "JSScreenWrapper.h"
#import "JSWrapperUtils.h"
#import "JSApplicationWrapper.h"

@implementation JSWindowWrapper

static NSDictionary *jswwJsMethods;

@synthesize aw;
@synthesize sw;

- (id)init {
  self = [super init];
  if (self) {
    [self setAw:[[AccessibilityWrapper alloc] init]];
    [self setSw:[[ScreenWrapper alloc] init]];
    [JSWindowWrapper setJsMethods];
  }
  return self;
}

- (id)initWithAccessibilityWrapper:(AccessibilityWrapper *)_aw screenWrapper:(ScreenWrapper *)_sw {
  self = [super init];
  if (self) {
    [self setAw:_aw];
    [self setSw:_sw];
    [JSWindowWrapper setJsMethods];
  }
  return self;
}

- (NSString *)title {
  return [aw getTitle];
}

- (id)rect {
  NSPoint tl = [aw getCurrentTopLeft];
  NSSize s = [aw getCurrentSize];
  return [[JSController getInstance] marshall:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:tl.x],
                                                                                         @"x",
                                                                                         [NSNumber numberWithInteger:tl.y],
                                                                                         @"y",
                                                                                         [NSNumber numberWithInteger:s.width],
                                                                                         @"width",
                                                                                         [NSNumber numberWithInteger:s.height],
                                                                                         @"height", nil]];
}

- (id)topLeft {
  NSPoint tl = [aw getCurrentTopLeft];
  return [[JSController getInstance] marshall:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:tl.x],
                                                                                         @"x",
                                                                                         [NSNumber numberWithInteger:tl.y],
                                                                                         @"y", nil]];
}

- (id)size {
  NSSize s = [aw getCurrentSize];
  return [[JSController getInstance] marshall:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:s.width],
                                                                                         @"width",
                                                                                         [NSNumber numberWithInteger:s.height],
                                                                                         @"height", nil]];
}

- (pid_t)pid {
  return [aw processIdentifier];
}

- (BOOL)focus {
  return [aw focus];
}

- (BOOL)isMinimizedOrHidden {
  return [aw isMinimizedOrHidden];
}

- (BOOL)isMovable {
  return [aw isMovable];
}

- (BOOL)isResizable {
  return [aw isResizable];
}

- (BOOL)isMain {
  return [AccessibilityWrapper isMainWindow:[aw window]];
}

- (BOOL)move:(id)point {
  id pointDict = [[JSController getInstance] unmarshall:point];
  NSValue *p = [JSWrapperUtils pointFromDict:pointDict aw:aw sw:sw];
  if (p == nil) { return NO; }
  return [aw moveWindow:[p pointValue]];
}

- (BOOL)resize:(id)size {
  id sizeDict = [[JSController getInstance] unmarshall:size];
  NSValue *s = [JSWrapperUtils sizeFromDict:sizeDict aw:aw sw:sw];
  if (s == nil) { return NO; }
  return [aw resizeWindow:[s sizeValue]];
}

- (JSScreenWrapper *)screen {
  NSPoint tl = [aw getCurrentTopLeft];
  NSSize size = [aw getCurrentSize];
  NSRect wRect = NSMakeRect(tl.x, tl.y, size.width, size.height);
  return [[JSScreenWrapper alloc] initWithScreenId:[sw getScreenRefIdForRect:wRect] screenWrapper:sw];
}

- (JSApplicationWrapper *)app {
  return [[JSApplicationWrapper alloc] initWithAccessibilityWrapper:aw screenWrapper:sw];
}

- (BOOL)doOperation:(id)op {
  return [op doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
}

+ (void)setJsMethods {
  if (jswwJsMethods == nil) {
    jswwJsMethods = @{
      NSStringFromSelector(@selector(title)): @"title",
      NSStringFromSelector(@selector(topLeft)): @"topLeft",
      NSStringFromSelector(@selector(size)): @"size",
      NSStringFromSelector(@selector(rect)): @"rect",
      NSStringFromSelector(@selector(pid)): @"pid",
      NSStringFromSelector(@selector(focus)): @"focus",
      NSStringFromSelector(@selector(isMinimizedOrHidden)): @"isMinimizedOrHidden",
      NSStringFromSelector(@selector(isMovable)): @"isMovable",
      NSStringFromSelector(@selector(isResizable)): @"isResizable",
      NSStringFromSelector(@selector(isMain)): @"isMain",
      NSStringFromSelector(@selector(move:)): @"move",
      NSStringFromSelector(@selector(resize:)): @"resize",
      NSStringFromSelector(@selector(screen)): @"screen",
      NSStringFromSelector(@selector(doOperation:)): @"doOperation",
      NSStringFromSelector(@selector(app)): @"app",
    };
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [jswwJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [jswwJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end

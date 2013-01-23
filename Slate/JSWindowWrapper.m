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

- (BOOL)isMain {
  return [AccessibilityWrapper isMainWindow:[aw window]];
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

- (BOOL)move:(id)point {
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

  return [aw moveWindow:NSMakePoint(x, y)];
}

- (BOOL)resize:(id)size {
  id sizeDict = [[JSController getInstance] unmarshall:size];
  if (![sizeDict isKindOfClass:[NSDictionary class]]) { return NO; }
  if ([sizeDict objectForKey:@"width"] == nil) { return NO; }
  if ([sizeDict objectForKey:@"height"] == nil) { return NO; }

  NSDictionary *values = nil;
  float width = 0;
  if ([[sizeDict objectForKey:@"width"] isKindOfClass:[NSString class]]) {
    values = [self screenAndWindowValues:[sizeDict objectForKey:@"screen"]];
    width = [ExpressionPoint expToFloat:[sizeDict objectForKey:@"width"] withDict:values];
  } else if ([[sizeDict objectForKey:@"width"] isKindOfClass:[NSNumber class]] ||
             [[sizeDict objectForKey:@"width"] isKindOfClass:[NSValue class]]) {
    width = [[sizeDict objectForKey:@"width"] floatValue];
  } else {
    return NO;
  }
  float height = 0;
  if ([[sizeDict objectForKey:@"height"] isKindOfClass:[NSString class]]) {
    if (values == nil) {
      values = [self screenAndWindowValues:[sizeDict objectForKey:@"screen"]];
    }
    height = [ExpressionPoint expToFloat:[sizeDict objectForKey:@"height"] withDict:values];
  } else if ([[sizeDict objectForKey:@"height"] isKindOfClass:[NSNumber class]] ||
             [[sizeDict objectForKey:@"height"] isKindOfClass:[NSValue class]]) {
    height = [[sizeDict objectForKey:@"height"] floatValue];
  } else {
    return NO;
  }

  return [aw resizeWindow:NSMakeSize(width, height)];
}

- (JSScreenWrapper *)screen {
  NSPoint tl = [aw getCurrentTopLeft];
  NSSize size = [aw getCurrentSize];
  NSRect wRect = NSMakeRect(tl.x, tl.y, size.width, size.height);
  return [[JSScreenWrapper alloc] initWithScreenId:[sw getScreenRefIdForRect:wRect] screenWrapper:sw];
}

- (BOOL)doOperation:(id)op {
  return [[JSController getInstance] doOperation:op aw:aw sw:sw];
}

+ (void)setJsMethods {
  if (jswwJsMethods == nil) {
    jswwJsMethods = @{
      NSStringFromSelector(@selector(title)): @"title",
      NSStringFromSelector(@selector(topLeft)): @"topLeft",
      NSStringFromSelector(@selector(size)): @"size",
      NSStringFromSelector(@selector(pid)): @"pid",
      NSStringFromSelector(@selector(focus)): @"focus",
      NSStringFromSelector(@selector(isMinimizedOrHidden)): @"isMinimizedOrHidden",
      NSStringFromSelector(@selector(isMain)): @"isMain",
      NSStringFromSelector(@selector(move:)): @"move",
      NSStringFromSelector(@selector(resize:)): @"resize",
      NSStringFromSelector(@selector(screen)): @"screen",
      NSStringFromSelector(@selector(doOperation:)): @"doOperation",
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

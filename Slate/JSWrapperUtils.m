//
//  JSWrapperUtils.m
//  Slate
//
//  Created by Jigish Patel on 1/22/13.
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

#import "JSWrapperUtils.h"
#import "ExpressionPoint.h"
#import "AccessibilityWrapper.h"
#import "ScreenWrapper.h"

@implementation JSWrapperUtils

+ (NSDictionary *)screenAndWindowValues:(NSString *)screen aw:(AccessibilityWrapper *)aw sw:(ScreenWrapper *)sw {
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

+ (NSValue *)pointFromDict:(id)dict aw:(AccessibilityWrapper *)aw sw:(ScreenWrapper *)sw {
  if (![dict isKindOfClass:[NSDictionary class]]) { return nil; }
  if ([dict objectForKey:@"x"] == nil) { return nil; }
  if ([dict objectForKey:@"y"] == nil) { return nil; }

  NSDictionary *values = nil;
  float x = 0;
  if ([[dict objectForKey:@"x"] isKindOfClass:[NSString class]]) {
    values = [JSWrapperUtils screenAndWindowValues:[dict objectForKey:@"screen"] aw:aw sw:sw];
    x = [ExpressionPoint expToFloat:[dict objectForKey:@"x"] withDict:values];
  } else if ([[dict objectForKey:@"x"] isKindOfClass:[NSNumber class]] ||
             [[dict objectForKey:@"x"] isKindOfClass:[NSValue class]]) {
    x = [[dict objectForKey:@"x"] floatValue];
  } else {
    return nil;
  }
  float y = 0;
  if ([[dict objectForKey:@"y"] isKindOfClass:[NSString class]]) {
    if (values == nil) {
      values = [JSWrapperUtils screenAndWindowValues:[dict objectForKey:@"screen"] aw:aw sw:sw];
    }
    y = [ExpressionPoint expToFloat:[dict objectForKey:@"y"] withDict:values];
  } else if ([[dict objectForKey:@"y"] isKindOfClass:[NSNumber class]] ||
             [[dict objectForKey:@"y"] isKindOfClass:[NSValue class]]) {
    y = [[dict objectForKey:@"y"] floatValue];
  } else {
    return nil;
  }
  return [NSValue valueWithPoint:NSMakePoint(x, y)];
}

+ (NSValue *)sizeFromDict:(id)dict aw:(AccessibilityWrapper *)aw sw:(ScreenWrapper *)sw {
  if (![dict isKindOfClass:[NSDictionary class]]) { return nil; }
  if ([dict objectForKey:@"width"] == nil) { return nil; }
  if ([dict objectForKey:@"height"] == nil) { return nil; }

  NSDictionary *values = nil;
  float width = 0;
  if ([[dict objectForKey:@"width"] isKindOfClass:[NSString class]]) {
    values = [JSWrapperUtils screenAndWindowValues:[dict objectForKey:@"screen"] aw:aw sw:sw];
    width = [ExpressionPoint expToFloat:[dict objectForKey:@"width"] withDict:values];
  } else if ([[dict objectForKey:@"width"] isKindOfClass:[NSNumber class]] ||
             [[dict objectForKey:@"width"] isKindOfClass:[NSValue class]]) {
    width = [[dict objectForKey:@"width"] floatValue];
  } else {
    return nil;
  }
  float height = 0;
  if ([[dict objectForKey:@"height"] isKindOfClass:[NSString class]]) {
    if (values == nil) {
      values = [JSWrapperUtils screenAndWindowValues:[dict objectForKey:@"screen"] aw:aw sw:sw];
    }
    height = [ExpressionPoint expToFloat:[dict objectForKey:@"height"] withDict:values];
  } else if ([[dict objectForKey:@"height"] isKindOfClass:[NSNumber class]] ||
             [[dict objectForKey:@"height"] isKindOfClass:[NSValue class]]) {
    height = [[dict objectForKey:@"height"] floatValue];
  } else {
    return nil;
  }

  return [NSValue valueWithSize:NSMakeSize(width, height)];
}

+ (NSValue *)rectFromDict:(id)dict aw:(AccessibilityWrapper *)aw sw:(ScreenWrapper *)sw {
  NSValue *pVal = [JSWrapperUtils pointFromDict:dict aw:aw sw:sw];
  if (pVal == nil) { return nil; }
  NSPoint p = [pVal pointValue];
  NSValue *sVal = [JSWrapperUtils sizeFromDict:dict aw:aw sw:sw];
  if (sVal == nil) { return nil; }
  NSSize s = [sVal sizeValue];
  return [NSValue valueWithRect:NSMakeRect(p.x, p.y, s.width, s.height)];
}

@end

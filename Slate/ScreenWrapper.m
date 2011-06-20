//
//  ScreenWrapper.m
//  Slate
//
//  Created by Jigish Patel on 6/17/11.
//  Copyright 2011 Jigish Patel. All rights reserved.
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

#import "Constants.h"
#import "ScreenWrapper.h"
#import "SlateConfig.h"


@implementation ScreenWrapper

@synthesize screens;

- (id)init {
  self = [super init];
  if (self) {
    [self setScreens:[NSScreen screens]];
  }
  return self;
}

- (id)initWithScreens:(NSArray *)theScreens {
  self = [super init];
  if (self) {
    [self setScreens:theScreens];
  }
  return self;
}

- (NSInteger)getScreenId:(NSString *)screenRef windowRect:(NSRect)window {
  NSInteger screenId = ID_IGNORE_SCREEN;
  NSInteger currentScreenId = [self getScreenIdForRect:window];
  NSRect screenRect = [self convertScreenRectToWindowCoords:currentScreenId];
  if ([screenRef rangeOfString:@"right"].length > 0) {
    NSRect testRect = NSMakeRect(screenRect.origin.x+screenRect.size.width, screenRect.origin.y, 1, screenRect.size.height);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:@"left"].length > 0) {
    NSRect testRect = NSMakeRect(screenRect.origin.x-1, screenRect.origin.y, 1, screenRect.size.height);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:@"above"].length > 0 || [screenRef rangeOfString:@"up"].length > 0) {
    NSRect testRect = NSMakeRect(screenRect.origin.x, screenRect.origin.y - 1, screenRect.size.width, 1);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:@"below"].length > 0 || [screenRef rangeOfString:@"down"].length > 0) {
    NSRect testRect = NSMakeRect(screenRect.origin.x, screenRect.origin.y + screenRect.size.height, screenRect.size.width, 1);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:@"next"].length > 0) {
    if (currentScreenId == [screens count] - 1)
      screenId = ID_MAIN_SCREEN;
    else
      screenId = currentScreenId+1;
  } else if ([screenRef rangeOfString:@"prev"].length > 0) {
    if (currentScreenId == ID_MAIN_SCREEN)
      screenId = [screens count] - 1;
    else
      screenId = currentScreenId-1;
  } else if ([screenRef rangeOfString:@"x"].length > 0) {
    NSArray *tokens = [screenRef componentsSeparatedByString:@"x"];
    if ([tokens count] < 2) return ID_IGNORE_SCREEN;
    NSInteger width = [[tokens objectAtIndex:0] integerValue];
    NSInteger height = [[tokens objectAtIndex:1] integerValue];
    for (NSUInteger i = 0; i < [screens count]; i++) {
      NSSize size = [self convertScreenRectToWindowCoords:i].size;
      if (size.width == width && size.height == height) return i;
    }
    screenId = [[SlateConfig getInstance] getBoolConfig:DEFAULT_TO_CURRENT_SCREEN 
                                           defaultValue:DEFAULT_TO_CURRENT_SCREEN_DEFAULT] ? ID_CURRENT_SCREEN : ID_IGNORE_SCREEN;
  } else {
    screenId = [screenRef integerValue];
  }
  NSLog(@"getScreenId for ref=[%@] current=[%ld] screen=[%ld]", screenRef, (long)currentScreenId, (long)screenId);
  if (screenId == ID_CURRENT_SCREEN) {
    return currentScreenId;
  } else if (screenId < ID_MAIN_SCREEN) {
    return ID_IGNORE_SCREEN;
  } else if (ID_MAIN_SCREEN <= screenId && screenId < [screens count]) {
    return screenId;
  } else if ([[SlateConfig getInstance] getBoolConfig:DEFAULT_TO_CURRENT_SCREEN defaultValue:DEFAULT_TO_CURRENT_SCREEN_DEFAULT]) {
    return currentScreenId;
  } else {
    return ID_IGNORE_SCREEN;
  }
}

- (NSInteger)getScreenIdForRect:(NSRect)rect {
  NSRect largestIntersection = NSZeroRect;
  NSInteger screenIndex = ID_IGNORE_SCREEN;
  for (NSInteger i = 0; i < [screens count]; i++) {
    NSRect currentIntersection = NSIntersectionRect([self convertScreenRectToWindowCoords:i], rect);
    if ([self isRect:currentIntersection biggerThan:largestIntersection]) {
      largestIntersection = currentIntersection;
      screenIndex = i;
    }
  }
  return screenIndex;
}

- (BOOL)screenExists:(NSInteger)screenId {
  NSInteger count = ((NSInteger)[[NSScreen screens] count]);
  return (ID_MAIN_SCREEN <= screenId && screenId < count) ? YES : NO;
}

- (BOOL)isRect:(NSRect)rect1 biggerThan:(NSRect)rect2 {
  return rect1.size.width*rect1.size.height > rect2.size.width*rect2.size.height;
}

- (NSDictionary *)getScreenAndWindowValues:(NSInteger)screenId window:(NSRect)cWindowRect newSize:(NSSize)nSize {
  NSInteger originX = 0;
  NSInteger originY = 0;
  NSInteger sizeX = 0;
  NSInteger sizeY = 0;
  if ([self screenExists:screenId]) {
    NSRect screenRect = [self convertScreenVisibleRectToWindowCoords:screenId];
    sizeX = screenRect.size.width;
    sizeY = screenRect.size.height;
    originX = screenRect.origin.x;
    originY = screenRect.origin.y;
  } else {
    return [NSDictionary dictionary];
  }
  NSSize cSize = cWindowRect.size;
  NSPoint cTopLeft = cWindowRect.origin;
  NSLog(@"screenOrigin:(%ld,%ld), screenSize:(%ld,%ld), windowSize:(%f,%f), windowTopLeft:(%f,%f)",(long)originX,
        (long)originY,
        (long)sizeX,
        (long)sizeY,
        cSize.width,
        cSize.height,
        cTopLeft.x,
        cTopLeft.y);
  return [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInteger:originX], SCREEN_ORIGIN_X,
          [NSNumber numberWithInteger:originY], SCREEN_ORIGIN_Y,
          [NSNumber numberWithInteger:sizeX], SCREEN_SIZE_X,
          [NSNumber numberWithInteger:sizeY], SCREEN_SIZE_Y,
          [NSNumber numberWithInteger:(NSInteger)cSize.width], WINDOW_SIZE_X,
          [NSNumber numberWithInteger:(NSInteger)cSize.height], WINDOW_SIZE_Y,
          [NSNumber numberWithInteger:(NSInteger)nSize.width], NEW_WINDOW_SIZE_X,
          [NSNumber numberWithInteger:(NSInteger)nSize.height], NEW_WINDOW_SIZE_Y,
          [NSNumber numberWithInteger:(NSInteger)cTopLeft.x], WINDOW_TOP_LEFT_X,
          [NSNumber numberWithInteger:(NSInteger)cTopLeft.y], WINDOW_TOP_LEFT_Y, nil];
}

// The following two methods are the only methods that should contain the frame/visibleFrame calls. All other methods should fetch the frame
// and/or visibleFrame using these methods. This is due to the comment above flipYCoordinateOfRect.
- (NSRect)convertScreenRectToWindowCoords:(NSInteger)screenId {
  if (screenId == ID_MAIN_SCREEN) {
    return [[screens objectAtIndex:screenId] frame];
  } else if ([self screenExists:screenId]) {
    return [self flipYCoordinateOfRect:[[screens objectAtIndex:screenId] frame] withReference:[[screens objectAtIndex:ID_MAIN_SCREEN] frame]];
  }
  return NSZeroRect;
}

- (NSRect)convertScreenVisibleRectToWindowCoords:(NSInteger)screenId {
  if (screenId == ID_MAIN_SCREEN) {
    return [self flipYCoordinateOfRect:[[screens objectAtIndex:ID_MAIN_SCREEN] visibleFrame] withReference:[[screens objectAtIndex:ID_MAIN_SCREEN] frame]];
  } else if ([self screenExists:screenId]) {
    return [self flipYCoordinateOfRect:[[screens objectAtIndex:screenId] visibleFrame] withReference:[[screens objectAtIndex:ID_MAIN_SCREEN] frame]];
  }
  return NSZeroRect;
}

// I understand that the following method is stupidly written. Apple apparently enjoys keeping
// multiple types of coordinate spaces. NSScreen.origin returns bottom-left while we need
// top-left for window moving. Go figure.
- (NSRect)flipYCoordinateOfRect:(NSRect)original withReference:(NSRect)reference {
  return NSMakeRect(original.origin.x,
                    reference.size.height - (reference.origin.y + original.origin.y + original.size.height),
                    original.size.width,
                    original.size.height);
}

// I understand that the following method is stupidly written. Apple apparently enjoys keeping
// multiple types of coordinate spaces. NSScreen.origin returns bottom-left while we need
// top-left for window moving. Go figure.
- (NSRect)unflipYCoordinateOfRect:(NSRect)original withReference:(NSRect)reference {
  return NSMakeRect(original.origin.x,
                    reference.size.height - (reference.origin.y + original.origin.y + original.size.height),
                    original.size.width,
                    original.size.height);
}

@end

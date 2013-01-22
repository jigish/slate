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
#import "MathUtils.h"
#import "ScreenWrapper.h"
#import "SlateConfig.h"
#import "SlateLogger.h"

static NSMutableArray *leftToRightToDefault = nil;
static NSString *resolutions = nil;

@implementation ScreenWrapper

@synthesize screens;

+ (void)initialize {
  if (!leftToRightToDefault) {
    leftToRightToDefault = [[NSMutableArray alloc] init];
    [ScreenWrapper updateStatics];
  }
}

+ (void)updateLeftToRightToDefault {
  [ScreenWrapper updateLeftToRightToDefault:[NSScreen screens]];
}

+ (void)updateLeftToRightToDefault:(NSArray *)theScreens {
  leftToRightToDefault = [[NSMutableArray alloc] initWithCapacity:[theScreens count]];
  NSArray *sortedByXThenY = [theScreens sortedArrayUsingComparator: ^(id screen1, id screen2) {
    NSRect screen1Rect = [ScreenWrapper convertScreenRectToWindowCoords:screen1 withReference:[theScreens objectAtIndex:ID_MAIN_SCREEN]];
    NSRect screen2Rect = [ScreenWrapper convertScreenRectToWindowCoords:screen2 withReference:[theScreens objectAtIndex:ID_MAIN_SCREEN]];
    if (screen1Rect.origin.x > screen2Rect.origin.x) {
      return (NSComparisonResult)NSOrderedDescending;
    }
    if (screen1Rect.origin.x < screen2Rect.origin.x) {
      return (NSComparisonResult)NSOrderedAscending;
    }
    if (screen1Rect.origin.y < screen2Rect.origin.y) {
      return (NSComparisonResult)NSOrderedDescending;
    }
    if (screen1Rect.origin.y > screen2Rect.origin.y) {
      return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
  }];
  for (NSInteger i = 0; i < [sortedByXThenY count]; i++) {
    NSNumber *defaultId = nil;
    for (NSInteger j = 0; j < [theScreens count]; j++) {
      if ([sortedByXThenY objectAtIndex:i] == [theScreens objectAtIndex:j]) {
        defaultId = [NSNumber numberWithInteger:j];
        break;
      }
    }
    [leftToRightToDefault addObject:defaultId];
  }
}

+ (void)updateScreenResolutions {
  [ScreenWrapper updateScreenResolutions:[NSScreen screens]];
}

+ (void)updateScreenResolutions:(NSArray *)theScreens {
  resolutions = @"";
  for (NSScreen *screen in theScreens) {
    NSRect screenRect =[screen frame];
    resolutions = [resolutions stringByAppendingFormat:@"%i%@%i,",(int)screenRect.size.width,X,(int)screenRect.size.height];
  }
}

+ (void)updateStatics {
  SlateLogger(@"-- updateStatics");
  [ScreenWrapper updateLeftToRightToDefault];
  [ScreenWrapper updateScreenResolutions];
}

+ (BOOL)hasScreenConfigChanged {
  NSString *oldResolutions = [NSString stringWithString:resolutions];
  NSArray *oldLeftToRight = [NSArray arrayWithArray:leftToRightToDefault];
  [ScreenWrapper updateStatics];
  if (![oldResolutions isEqualToString:resolutions]) return YES;
  if ([oldLeftToRight count] != [leftToRightToDefault count]) return YES;
  for (NSInteger i = 0; i < [oldLeftToRight count]; i++) {
    if ([[oldLeftToRight objectAtIndex:i] integerValue] != [[leftToRightToDefault objectAtIndex:i] integerValue]) return YES;
  }
  return NO;
}

- (id)init {
  return [self initWithScreens:[NSScreen screens]];
}

- (id)initWithScreens:(NSArray *)theScreens {
  self = [super init];
  if (self) {
    [self setScreens:theScreens];
    [ScreenWrapper updateLeftToRightToDefault:theScreens];
  }
  return self;
}

- (NSInteger)getScreenCount {
  return [screens count];
}

- (void)getScreenResolutionStrings:(NSMutableArray *)strings {
  for (NSInteger i = 0; i < [screens count]; i++) {
    NSRect screenRect = [self convertScreenRectToWindowCoords:i];
    NSString *resolution = [NSString stringWithFormat:@"%i%@%i",(int)screenRect.size.width,X,(int)screenRect.size.height];
    SlateLogger(@"Adding resolution: %@",resolution);
    [strings addObject:resolution];
  }
}

- (NSRect)getScreenRect:(NSInteger)screenId {
  return [self convertScreenRectToWindowCoords:screenId];
}

- (NSInteger)convertDefaultOrderToLeftToRightOrder:(NSInteger)screenId {
  return [[leftToRightToDefault objectAtIndex:screenId] integerValue];
}

- (NSInteger)getScreenId:(NSString *)screenRef windowRect:(NSRect)window {
  NSInteger screenId = ID_IGNORE_SCREEN;
  NSInteger currentScreenId = [self getScreenIdForRect:window];
  NSRect screenRect = [self convertScreenRectToWindowCoords:currentScreenId];
  if ([screenRef rangeOfString:RIGHT].length > 0) { // Orientation Based
    NSRect testRect = NSMakeRect(screenRect.origin.x+screenRect.size.width, screenRect.origin.y, 1, screenRect.size.height);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:LEFT].length > 0) {
    NSRect testRect = NSMakeRect(screenRect.origin.x-1, screenRect.origin.y, 1, screenRect.size.height);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:ABOVE].length > 0 || [screenRef rangeOfString:UP].length > 0) {
    NSRect testRect = NSMakeRect(screenRect.origin.x, screenRect.origin.y - 1, screenRect.size.width, 1);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:BELOW].length > 0 || [screenRef rangeOfString:UP].length > 0) {
    NSRect testRect = NSMakeRect(screenRect.origin.x, screenRect.origin.y + screenRect.size.height, screenRect.size.width, 1);
    screenId = [self getScreenIdForRect:testRect];
  } else if ([screenRef rangeOfString:NEXT].length > 0) {
    if (currentScreenId == [screens count] - 1)
      screenId = ID_MAIN_SCREEN;
    else
      screenId = currentScreenId+1;
  } else if ([screenRef rangeOfString:PREVIOUS].length > 0 || [screenRef rangeOfString:PREV].length > 0) {
    if (currentScreenId == ID_MAIN_SCREEN)
      screenId = [screens count] - 1;
    else
      screenId = currentScreenId-1;
  } else if ([screenRef rangeOfString:X].length > 0) { // Resolution Based
    NSArray *tokens = [screenRef componentsSeparatedByString:X];
    if ([tokens count] < 2) return ID_IGNORE_SCREEN;
    NSInteger width = [[tokens objectAtIndex:0] integerValue];
    NSInteger height = [[tokens objectAtIndex:1] integerValue];
    for (NSUInteger i = 0; i < [screens count]; i++) {
      NSSize size = [self convertScreenRectToWindowCoords:i].size;
      if (size.width == width && size.height == height) return i;
    }
    screenId = [[SlateConfig getInstance] getBoolConfig:DEFAULT_TO_CURRENT_SCREEN] ? ID_CURRENT_SCREEN : ID_IGNORE_SCREEN;
  } else if ([screenRef rangeOfString:ORDERED].length > 0) { // Explicitly Ordered
    NSArray *tokens = [screenRef componentsSeparatedByString:COLON];
    if ([tokens count] < 2) return ID_IGNORE_SCREEN;
    NSInteger leftToRightId = [[tokens objectAtIndex:1] integerValue];
    screenId = (leftToRightId < ID_MAIN_SCREEN || leftToRightId > [screens count]) ? leftToRightId : [[leftToRightToDefault objectAtIndex:leftToRightId] integerValue];
  } else {
    NSInteger screenRefInt = [screenRef integerValue];
    if (screenRefInt < ID_MAIN_SCREEN || screenRefInt >= [screens count]) {
      screenId = screenRefInt;
    } else {
      screenId = [[SlateConfig getInstance] getBoolConfig:ORDER_SCREENS_LEFT_TO_RIGHT] ? [[leftToRightToDefault objectAtIndex:screenRefInt] integerValue] : screenRefInt;
    }
  }
  SlateLogger(@"getScreenId for ref=[%@] current=[%ld] screen=[%ld]", screenRef, (long)currentScreenId, (long)screenId);
  if (screenId == ID_CURRENT_SCREEN) {
    return currentScreenId;
  } else if (screenId < ID_MAIN_SCREEN) {
    return ID_IGNORE_SCREEN;
  } else if (ID_MAIN_SCREEN <= screenId && screenId < [screens count]) {
    return screenId;
  } else if ([[SlateConfig getInstance] getBoolConfig:DEFAULT_TO_CURRENT_SCREEN]) {
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
    if ([MathUtils isRect:currentIntersection biggerThan:largestIntersection]) {
      largestIntersection = currentIntersection;
      screenIndex = i;
    }
  }
  return screenIndex;
}

- (NSInteger)getScreenIdForPoint:(NSPoint)point {
  for (NSInteger i = 0; i < [screens count]; i++) {
    NSRect screen = [self convertScreenRectToWindowCoords:i];
    if (screen.origin.x <= point.x && screen.origin.x+screen.size.width >= point.x &&
        screen.origin.y <= point.y && screen.origin.y+screen.size.height >= point.y)
      return i;
  }
  return -1;
}

- (BOOL)isMainScreen:(NSInteger)screenID {
  return screenID == ID_MAIN_SCREEN;
}

- (BOOL)isRectOffScreen:(NSRect)rect {
  // Check all corners to see if they are on a screen
  // Top-left
  if ([self getScreenIdForPoint:NSMakePoint(rect.origin.x, rect.origin.y)] < 0) return YES;
  // Top-right
  if ([self getScreenIdForPoint:NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y)] < 0) return YES;
  // Bottom-left
  if ([self getScreenIdForPoint:NSMakePoint(rect.origin.x, rect.origin.y+rect.size.height)] < 0) return YES;
  // Bottom-right
  if ([self getScreenIdForPoint:NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height)] < 0) return YES;
  return NO;
}

- (BOOL)screenExists:(NSInteger)screenId {
  NSInteger count = ((NSInteger)[[NSScreen screens] count]);
  return (ID_MAIN_SCREEN <= screenId && screenId < count) ? YES : NO;
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
  SlateLogger(@"screenOrigin:(%ld,%ld), screenSize:(%ld,%ld), windowSize:(%f,%f), windowTopLeft:(%f,%f)",(long)originX,
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

// The following three methods are the only methods that should contain the frame/visibleFrame calls. All other methods should fetch the frame
// and/or visibleFrame using these methods. This is due to the comment above flipYCoordinateOfRect.
- (NSRect)convertScreenRectToWindowCoords:(NSInteger)screenId {
  if (screenId == ID_MAIN_SCREEN) {
    return [[screens objectAtIndex:screenId] frame];
  } else if ([self screenExists:screenId]) {
    return [MathUtils flipYCoordinateOfRect:[[screens objectAtIndex:screenId] frame] withReference:[[screens objectAtIndex:ID_MAIN_SCREEN] frame]];
  }
  return NSZeroRect;
}

+ (NSRect)convertScreenRectToWindowCoords:(NSScreen *)screen withReference:(NSScreen *)refScreen {
  if (screen) {
    return [MathUtils flipYCoordinateOfRect:[screen frame] withReference:[refScreen frame]];
  }
  return NSZeroRect;
}

- (NSRect)convertScreenVisibleRectToWindowCoords:(NSInteger)screenId {
  if (screenId == ID_MAIN_SCREEN) {
    return [MathUtils flipYCoordinateOfRect:[[screens objectAtIndex:ID_MAIN_SCREEN] visibleFrame] withReference:[[screens objectAtIndex:ID_MAIN_SCREEN] frame]];
  } else if ([self screenExists:screenId]) {
    return [MathUtils flipYCoordinateOfRect:[[screens objectAtIndex:screenId] visibleFrame] withReference:[[screens objectAtIndex:ID_MAIN_SCREEN] frame]];
  }
  return NSZeroRect;
}

- (NSPoint)convertTopLeftToScreenRelative:(NSPoint)topLeft screen:(NSInteger)screenId {
  NSRect screenRect = [self convertScreenVisibleRectToWindowCoords:screenId];
  return NSMakePoint(topLeft.x-screenRect.origin.x, topLeft.y-screenRect.origin.y);
}

@end

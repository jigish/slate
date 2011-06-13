//
//  WindowState.m
//  Slate
//
//  Created by Jigish Patel on 6/13/11.
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

#import "AccessibilityWrapper.h"
#import "WindowState.h"


@implementation WindowState

@synthesize appPID;
@synthesize size;
@synthesize topLeft;

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (id)init:(AccessibilityWrapper *)aw {
  self = [self init];
  if (self && [aw inited]) {
    [self setAppPID:[AccessibilityWrapper processIdentifierOfUIElement:[aw window]]];
    [self setSize:[aw getCurrentSize]];
    [self setTopLeft:[aw getCurrentTopLeft]];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  WindowState *other = [[WindowState alloc] init];
  [other setAppPID:[self appPID]];
  [other setSize:[self size]];
  [other setTopLeft:[self topLeft]];
  return other;
}

- (BOOL)isEqual:(NSObject *)other {
  if ([other isKindOfClass:[WindowState class]]) {
    return [(WindowState *)other appPID] == [self appPID] && NSEqualSizes([(WindowState *)other size],[self size]) && NSEqualPoints([(WindowState *)other topLeft], [self topLeft]);
  }
  return NO;
}

- (NSUInteger)hash {
  NSUInteger prime = 31;
  NSUInteger result = 1;
  result = prime * result + [self appPID];
  result = prime * result + [self size].width;
  result = prime * result + [self size].height;
  result = prime * result + [self topLeft].x;
  result = prime * result + [self topLeft].y;
  return result;
}

@end

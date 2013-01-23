//
//  ScreenState.m
//  Slate
//
//  Created by Jigish Patel on 6/19/11.
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
#import "ScreenState.h"
#import "StringTokenizer.h"


@implementation ScreenState

@synthesize layout;
@synthesize type;
@synthesize count;
@synthesize resolutions;

- (id)init {
  self = [super init];
  if (self) {
    [self setLayout:nil];
    [self setType:TYPE_UNKNOWN];
    [self setCount:TYPE_UNKNOWN];
    [self setResolutions:nil];
  }
  return self;
}

- (id)initWithString:(NSString *)state {
  // defaultLayout <name> <screen-setup>
  self = [self init];
  if (self) {
    NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
    [StringTokenizer tokenize:state into:tokens];
    if ([tokens count] < 3) {
      return nil;
    }
    [self setLayout:[tokens objectAtIndex:1]];
    // Parse screen-setup
    //   count:NUMBER
    //   resolutions:WIDTHxHEIGHT;...
    NSArray *screenSetup = [[tokens objectAtIndex:2] componentsSeparatedByString:COLON];
    if ([screenSetup count] < 2) {
      return nil;
    }
    if ([[screenSetup objectAtIndex:0] isEqualToString:COUNT]) {
      [self setCount:[[screenSetup objectAtIndex:1] integerValue]];
      [self setType:TYPE_COUNT];
    } else if ([[screenSetup objectAtIndex:0] isEqualToString:RESOLUTIONS]) {
      [self setResolutions:[NSMutableArray arrayWithArray:[[screenSetup objectAtIndex:1] componentsSeparatedByCharactersInSet:
                                                           [NSCharacterSet characterSetWithCharactersInString:[SEMICOLON stringByAppendingString:COMMA]]]]];
      [resolutions sortUsingSelector:@selector(compare:)];
      [self setType:TYPE_RESOLUTIONS];
    } else {
      return nil;
    }
  }
  return self;
}

- (id)initWithConfig:(id)screenConfig layout:(NSString *)_layout {
  self = [self init];
  if (self) {
    [self setLayout:_layout];
    if ([screenConfig isKindOfClass:[NSValue class]] || [screenConfig isKindOfClass:[NSNumber class]]) {
      [self setCount:[screenConfig integerValue]];
      [self setType:TYPE_COUNT];
    } else if ([screenConfig isKindOfClass:[NSArray class]]) {
      [self setResolutions:[screenConfig mutableCopy]];
      [resolutions sortUsingSelector:@selector(compare:)];
      [self setType:TYPE_RESOLUTIONS];
    } else {
      return nil;
    }
  }
  return self;
}


@end

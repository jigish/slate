//
//  SwitchView.m
//  Slate
//
//  Created by Jigish Patel on 3/9/12.
//  Copyright 2012 Jigish Patel. All rights reserved.
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

#import "SwitchView.h"
#import "SlateConfig.h"
#import "Constants.h"

@implementation SwitchView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) [self setWantsLayer:YES];
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  NSArray *bgColorArr = [[SlateConfig getInstance] getArrayConfig:SWITCH_BACKGROUND_COLOR];
  if ([bgColorArr count] < 4) bgColorArr = [SWITCH_BACKGROUND_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
  NSColor *backgroundColor = [NSColor colorWithDeviceRed:[[bgColorArr objectAtIndex:0] floatValue]/255.0
                                                   green:[[bgColorArr objectAtIndex:1] floatValue]/255.0
                                                    blue:[[bgColorArr objectAtIndex:2] floatValue]/255.0
                                                   alpha:[[bgColorArr objectAtIndex:3] floatValue]];
  [backgroundColor set];
  float cornerSize = [[SlateConfig getInstance] getFloatConfig:SWITCH_ROUNDED_CORNER_SIZE];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerSize yRadius:cornerSize];
  [path fill];
}

@end

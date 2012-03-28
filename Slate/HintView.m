//
//  HintView.m
//  Slate
//
//  Created by Jigish Patel on 3/3/12.
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

#import "HintView.h"
#import "Constants.h"
#import "NSColor+Conversions.h"
#import "SlateConfig.h"

@implementation HintView

@synthesize text;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) [self setWantsLayer:YES];
  return self;
}

- (void)drawCenteredText:(NSString *)string bounds:(NSRect)rect attributes:(NSDictionary *)attributes {
  NSSize size = [string sizeWithAttributes:attributes];
  NSPoint origin = NSMakePoint(rect.origin.x + (rect.size.width - size.width) / 2,
                               rect.origin.y + (rect.size.height - size.height) / 2);
  [string drawAtPoint:origin withAttributes:attributes];
}

- (void)drawRect:(NSRect)dirtyRect {
  NSArray *bgColorArr = [[SlateConfig getInstance] getArrayConfig:WINDOW_HINTS_BACKGROUND_COLOR];
  NSArray *fColorArr = [[SlateConfig getInstance] getArrayConfig:WINDOW_HINTS_FONT_COLOR];
  if ([bgColorArr count] < 4) bgColorArr = [WINDOW_HINTS_BACKGROUND_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
  if ([fColorArr count] < 4) fColorArr = [WINDOW_HINTS_FONT_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
  NSColor *backgroundColor = [NSColor colorWithDeviceRed:[[bgColorArr objectAtIndex:0] floatValue]/255.0
                                                   green:[[bgColorArr objectAtIndex:1] floatValue]/255.0
                                                    blue:[[bgColorArr objectAtIndex:2] floatValue]/255.0
                                                   alpha:[[bgColorArr objectAtIndex:3] floatValue]];
  NSColor *fontColor = [NSColor colorWithDeviceRed:[[fColorArr objectAtIndex:0] floatValue]/255.0
                                             green:[[fColorArr objectAtIndex:1] floatValue]/255.0
                                              blue:[[fColorArr objectAtIndex:2] floatValue]/255.0
                                             alpha:[[fColorArr objectAtIndex:3] floatValue]];
  [backgroundColor set];
  float cornerSize = [[SlateConfig getInstance] getFloatConfig:WINDOW_HINTS_ROUNDED_CORNER_SIZE];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerSize yRadius:cornerSize];
  [path fill];
  [self drawCenteredText:text
                  bounds:self.bounds
              attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:[[SlateConfig getInstance] getConfig:WINDOW_HINTS_FONT_NAME]
                                                                                    size:[[SlateConfig getInstance] getFloatConfig:WINDOW_HINTS_FONT_SIZE]],
                                                                    NSFontAttributeName,
                                                                    fontColor,
                                                                    NSForegroundColorAttributeName, nil]];
}

@end

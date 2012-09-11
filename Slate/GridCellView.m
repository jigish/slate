//
//  GridCellView.m
//  Slate
//
//  Created by Jigish Patel on 9/10/12.
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

#import "GridCellView.h"
#import "SlateConfig.h"
#import "Constants.h"

@implementation GridCellView

@synthesize bg, inactiveBg, activeBg, cornerSize;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setWantsLayer:YES];
    NSArray *bgColorArr = [[SlateConfig getInstance] getArrayConfig:GRID_CELL_BACKGROUND_COLOR];
    if ([bgColorArr count] < 4) bgColorArr = [GRID_CELL_BACKGROUND_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
    NSColor *backgroundColor = [NSColor colorWithDeviceRed:[[bgColorArr objectAtIndex:0] floatValue]/255.0
                                                     green:[[bgColorArr objectAtIndex:1] floatValue]/255.0
                                                      blue:[[bgColorArr objectAtIndex:2] floatValue]/255.0
                                                     alpha:[[bgColorArr objectAtIndex:3] floatValue]];
    [self setBg:backgroundColor];
    [self setInactiveBg:backgroundColor];
    NSArray *activeColorArr = [[SlateConfig getInstance] getArrayConfig:GRID_CELL_SELECTED_COLOR];
    if ([activeColorArr count] < 4) activeColorArr = [GRID_CELL_SELECTED_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
    NSColor *activeColor = [NSColor colorWithDeviceRed:[[activeColorArr objectAtIndex:0] floatValue]/255.0
                                                 green:[[activeColorArr objectAtIndex:1] floatValue]/255.0
                                                  blue:[[activeColorArr objectAtIndex:2] floatValue]/255.0
                                                 alpha:[[activeColorArr objectAtIndex:3] floatValue]];
    [self setActiveBg:activeColor];
    [self setCornerSize:[[SlateConfig getInstance] getFloatConfig:GRID_CELL_ROUNDED_CORNER_SIZE]];
  }
  return self;
}

- (void)activate {
  [self setBg:[self activeBg]];
  [self setNeedsDisplay:YES];
}

- (void)deactivate {
  [self setBg:[self inactiveBg]];
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  [[self bg] set];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:[self cornerSize] yRadius:[self cornerSize]];
  [path fill];
}

@end

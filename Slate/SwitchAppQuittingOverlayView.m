//
//  SwitchAppQuittingOverlayView.m
//  Slate
//
//  Created by Jigish Patel on 3/22/12.
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

#import "SwitchAppQuittingOverlayView.h"

@implementation SwitchAppQuittingOverlayView

@synthesize force;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setWantsLayer:YES];
    force = NO;
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [[NSColor redColor] set];
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(self.bounds.origin.x, self.bounds.origin.y)];
  [path lineToPoint:NSMakePoint(self.bounds.origin.x, self.bounds.origin.y+5)];
  [path lineToPoint:NSMakePoint(self.bounds.origin.x+self.bounds.size.width-5,
                                self.bounds.origin.y+self.bounds.size.height)];
  [path lineToPoint:NSMakePoint(self.bounds.origin.x+self.bounds.size.width,
                                self.bounds.origin.y+self.bounds.size.height)];
  [path lineToPoint:NSMakePoint(self.bounds.origin.x+self.bounds.size.width,
                                self.bounds.origin.y+self.bounds.size.height-5)];
  [path lineToPoint:NSMakePoint(self.bounds.origin.x+5, self.bounds.origin.y)];
  [path closePath];
  [path fill];
  if (force) {
    NSBezierPath *path2 = [NSBezierPath bezierPath];
    [path2 moveToPoint:NSMakePoint(self.bounds.origin.x+self.bounds.size.width, self.bounds.origin.y)];
    [path2 lineToPoint:NSMakePoint(self.bounds.origin.x+self.bounds.size.width-5, self.bounds.origin.y)];
    [path2 lineToPoint:NSMakePoint(self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height-5)];
    [path2 lineToPoint:NSMakePoint(self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height)];
    [path2 lineToPoint:NSMakePoint(self.bounds.origin.x+5, self.bounds.origin.y+self.bounds.size.height)];
    [path2 lineToPoint:NSMakePoint(self.bounds.origin.x+self.bounds.size.width, self.bounds.origin.y+5)];
    [path2 closePath];
    [path2 fill];
  }
}

@end

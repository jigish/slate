//
//  SwitchAppView.m
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

#import "SwitchAppView.h"
#import "SlateConfig.h"
#import "Constants.h"
#import "NSColor+Conversions.h"
#import "SwitchAppQuittingOverlayView.h"

@implementation SwitchAppView

static const float HIDDEN_ALPHA = 0.2;
static const float SHOWN_ALPHA = 1.0;

@synthesize selected, hidden, quitting, forceQuitting, app, iconView, quittingView;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    selected = NO;
    hidden = NO;
    quitting = NO;
    forceQuitting = NO;
    iconView = nil;
    quittingView = nil;
    [self setWantsLayer:YES];
  }
  return self;
}

- (void)updateSelected:(BOOL)theSelected {
  [self setSelected:theSelected];
  [self setNeedsDisplay:YES];
}

- (void)updateApp:(NSRunningApplication *)theApp {
  [self setApp:theApp];
  [self setHidden:[theApp isHidden]];
  float myWidth = [self frame].size.width;
  float myHeight = [self frame].size.height;
  if (iconView != nil) {
    [iconView removeFromSuperview];
  }
  iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 5, myWidth-10, myHeight-10)];
  NSImage *icon = [app icon];
  [icon setScalesWhenResized:YES];
  [icon setSize:NSMakeSize(myWidth-10, myHeight-10)];
  [iconView setImage:icon];
  [iconView setAlphaValue:(hidden ? HIDDEN_ALPHA : SHOWN_ALPHA)];
  [self addSubview:iconView];
  [self setNeedsDisplay:YES];
}

- (void)updateHidden:(BOOL)theHidden {
  [self setHidden:theHidden];
  [iconView setAlphaValue:(hidden ? HIDDEN_ALPHA : SHOWN_ALPHA)];
  [self setNeedsDisplay:YES];
}

- (void)updateQuitting:(BOOL)theQuitting {
  [self setQuitting:theQuitting];
  if (quitting) {
    quittingView = [[SwitchAppQuittingOverlayView alloc] initWithFrame:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
    [self addSubview:quittingView];
  } else {
    [quittingView removeFromSuperview];
  }
  [self setNeedsDisplay:YES];
}

- (void)updateForceQuitting:(BOOL)theForceQuitting {
  [self setForceQuitting:theForceQuitting];
  if (forceQuitting) {
    quittingView = [[SwitchAppQuittingOverlayView alloc] initWithFrame:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
    [quittingView setForce:YES];
    [self addSubview:quittingView];
  } else {
    [quittingView removeFromSuperview];
  }
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  NSColor *backgroundColor = [NSColor clearColor];
  if (selected) {
    NSArray *bgColorArr = [[SlateConfig getInstance] getArrayConfig:SWITCH_SELECTED_COLOR];
    if ([bgColorArr count] < 4) bgColorArr = [SWITCH_SELECTED_COLOR_DEFAULT componentsSeparatedByString:COMMA];
    backgroundColor = [NSColor colorWithDeviceRed:[[bgColorArr objectAtIndex:0] floatValue]/255.0
                                                     green:[[bgColorArr objectAtIndex:1] floatValue]/255.0
                                                      blue:[[bgColorArr objectAtIndex:2] floatValue]/255.0
                                                     alpha:[[bgColorArr objectAtIndex:3] floatValue]];
  }
  [backgroundColor set];
  float cornerSize = [[SlateConfig getInstance] getFloatConfig:SWITCH_ROUNDED_CORNER_SIZE];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerSize yRadius:cornerSize];
  [path fill];
}

@end

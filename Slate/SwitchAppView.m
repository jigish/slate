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
static const float STROKE_WIDTH = -5;

@synthesize selected, hidden, quitting, forceQuitting, app, iconView, textField, quittingView;

static NSColor *switchFontColor = nil;
static NSFont *switchFont = nil;
static float iconSize = -1;
static float iconPadding = -1;
static float switchFontHeight = -1;

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
    if (switchFontColor == nil) {
      NSArray *fColorArr = [[SlateConfig getInstance] getArrayConfig:SWITCH_FONT_COLOR];
      if ([fColorArr count] < 4) fColorArr = [SWITCH_FONT_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
      switchFontColor = [NSColor colorWithDeviceRed:[[fColorArr objectAtIndex:0] floatValue]/255.0
                                              green:[[fColorArr objectAtIndex:1] floatValue]/255.0
                                               blue:[[fColorArr objectAtIndex:2] floatValue]/255.0
                                              alpha:[[fColorArr objectAtIndex:3] floatValue]];
    }
    if (switchFont == nil) {
      switchFont = [NSFont fontWithName:[[SlateConfig getInstance] getConfig:SWITCH_FONT_NAME] size:[[SlateConfig getInstance] getFloatConfig:SWITCH_FONT_SIZE]];
    }
    if (iconSize < 0) {
      iconSize = [[SlateConfig getInstance] getFloatConfig:SWITCH_ICON_SIZE];
    }
    if (iconPadding < 0) {
      iconPadding = [[SlateConfig getInstance] getFloatConfig:SWITCH_ICON_PADDING];
    }
    if (switchFontHeight < 0) {
      NSString *testString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
      NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:[[SlateConfig getInstance] getConfig:SWITCH_FONT_NAME]
                                                                                            size:[[SlateConfig getInstance] getFloatConfig:SWITCH_FONT_SIZE]],
                                  NSFontAttributeName, nil];
      NSSize size = [testString sizeWithAttributes:attributes];
      switchFontHeight = size.height;
    }
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
  if (iconView != nil) {
    [iconView removeFromSuperview];
  }
  if ([[SlateConfig getInstance] getBoolConfig:SWITCH_SHOW_TITLES] && [[[SlateConfig getInstance] getConfig:SWITCH_ORIENTATION] isEqualToString:SWITCH_ORIENTATION_HORIZONTAL]) {
    iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(iconPadding, self.frame.size.height - iconSize - iconPadding*2, iconSize, iconSize)];
  } else {
    iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(iconPadding, iconPadding, iconSize, iconSize)];
  }
  NSImage *icon = [app icon];
  [icon setScalesWhenResized:YES];
  [icon setSize:NSMakeSize(iconSize, iconSize)];
  [iconView setImage:icon];
  [iconView setAlphaValue:(hidden ? HIDDEN_ALPHA : SHOWN_ALPHA)];
  [self addSubview:iconView];
  if ([[SlateConfig getInstance] getBoolConfig:SWITCH_SHOW_TITLES]) {
    if ([[[SlateConfig getInstance] getConfig:SWITCH_ORIENTATION] isEqualToString:SWITCH_ORIENTATION_VERTICAL]) {
      textField = [[NSTextField alloc] initWithFrame:NSMakeRect(iconSize+iconPadding*2, self.frame.size.height/2 - switchFontHeight/2, self.frame.size.width - iconSize - iconPadding*2, switchFontHeight)];
    } else {
      textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, iconPadding, iconSize+iconPadding*2, self.frame.size.height - iconSize - iconPadding*3)];
    }
    NSMutableAttributedString *theTitle = [[NSMutableAttributedString alloc] initWithString:[theApp localizedName]];
    NSRange everything = NSMakeRange(0, [theTitle length]);
    [theTitle addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:STROKE_WIDTH] range:everything];
    [theTitle setAlignment:NSCenterTextAlignment range:everything];
    [textField setAttributedStringValue:theTitle];
    [textField setSelectable:NO];
    [textField setEditable:NO];
    [textField setBezeled:NO];
    [textField setBordered:NO];
    [textField setAlignment:NSCenterTextAlignment];
    [textField setBackgroundColor:[NSColor clearColor]];
    [textField setFont:switchFont];
    [textField setTextColor:switchFontColor];
    [self addSubview:textField];
  }
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
  NSColor *borderColor = [NSColor clearColor];
  if (selected) {
    NSArray *bgColorArr = [[SlateConfig getInstance] getArrayConfig:SWITCH_SELECTED_BACKGROUND_COLOR];
    if ([bgColorArr count] < 4) bgColorArr = [SWITCH_SELECTED_BACKGROUND_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
    backgroundColor = [NSColor colorWithDeviceRed:[[bgColorArr objectAtIndex:0] floatValue]/255.0
                                                     green:[[bgColorArr objectAtIndex:1] floatValue]/255.0
                                                      blue:[[bgColorArr objectAtIndex:2] floatValue]/255.0
                                                     alpha:[[bgColorArr objectAtIndex:3] floatValue]];
    NSArray *borderColorArr = [[SlateConfig getInstance] getArrayConfig:SWITCH_SELECTED_BORDER_COLOR];
    if ([borderColorArr count] < 4) bgColorArr = [SWITCH_SELECTED_BORDER_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
    borderColor = [NSColor colorWithDeviceRed:[[borderColorArr objectAtIndex:0] floatValue]/255.0
                                        green:[[borderColorArr objectAtIndex:1] floatValue]/255.0
                                         blue:[[borderColorArr objectAtIndex:2] floatValue]/255.0
                                        alpha:[[borderColorArr objectAtIndex:3] floatValue]];
  }
  float borderSize = [[SlateConfig getInstance] getFloatConfig:SWITCH_SELECTED_BORDER_SIZE];
  float cornerSize = [[SlateConfig getInstance] getFloatConfig:SWITCH_ROUNDED_CORNER_SIZE];
  [[NSGraphicsContext currentContext] saveGraphicsState];
  [[NSGraphicsContext currentContext] setShouldAntialias:YES];
  if (borderSize > 0 && selected) {
    [backgroundColor set];
    [NSBezierPath setDefaultLineWidth:1.0];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect([self bounds].origin.x+borderSize/2,
                                                                            [self bounds].origin.y+borderSize/2,
                                                                            [self bounds].size.width-borderSize,
                                                                            [self bounds].size.height-borderSize)
                                                         xRadius:cornerSize
                                                         yRadius:cornerSize];
    [path fill];
    [borderColor set];
    [NSBezierPath setDefaultLineWidth:borderSize];
    path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect([self bounds].origin.x+borderSize/2,
                                                                            [self bounds].origin.y+borderSize/2,
                                                                            [self bounds].size.width-borderSize,
                                                                            [self bounds].size.height-borderSize)
                                                         xRadius:cornerSize
                                                         yRadius:cornerSize];
    [path stroke];
  } else {
    [backgroundColor set];
    [NSBezierPath setDefaultLineWidth:1.0];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerSize yRadius:cornerSize];
    [path fill];
  }
  /*if (borderSize > 0 && selected) {
    [borderColor set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerSize yRadius:cornerSize];
    [path fill];
    [backgroundColor set];
    path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect([self bounds].origin.x+borderSize,
                                                                            [self bounds].origin.y+borderSize,
                                                                            [self bounds].size.width-borderSize*2,
                                                                            [self bounds].size.height-borderSize*2)
                                           xRadius:cornerSize
                                           yRadius:cornerSize];
    [path fill];
  } else {
    [backgroundColor set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerSize yRadius:cornerSize];
    [path fill];
  }*/
  [[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end

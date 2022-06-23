//
//  SwitchAppView.h
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

#import <Cocoa/Cocoa.h>

@class SwitchAppQuittingOverlayView;

@interface SwitchAppView : NSView {
  BOOL selected;
  BOOL hidden;
  BOOL quitting;
  BOOL forceQuitting;
  NSRunningApplication *app;
  NSImageView *iconView;
  NSTextField *textField;
  SwitchAppQuittingOverlayView *quittingView;
}

@property (assign) BOOL selected;
@property (assign) BOOL quitting;
@property (assign) BOOL forceQuitting;
@property NSRunningApplication *app;
@property NSImageView *iconView;
@property NSTextField *textField;
@property SwitchAppQuittingOverlayView *quittingView;

- (void)updateSelected:(BOOL)theSelected;
- (void)updateApp:(NSRunningApplication *)theApp;
- (void)updateHidden:(BOOL)theHidden;
- (void)updateQuitting:(BOOL)theQuitting;
- (void)updateForceQuitting:(BOOL)theForceQuitting;

@end

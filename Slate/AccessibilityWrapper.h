//
//  AccessibilityWrapper.h
//  Slate
//
//  Created by Jigish Patel on 6/10/11.
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

#import <Foundation/Foundation.h>


@interface AccessibilityWrapper : NSObject {
@private
  AXUIElementRef app;
  AXUIElementRef window;
  BOOL inited;
}

@property (assign) AXUIElementRef app;
@property (assign) AXUIElementRef window;
@property (assign) BOOL inited;

- (id)initWithApp:(AXUIElementRef)appRef window:(AXUIElementRef)windowRef;

+ (NSPoint)getTopLeftForWindow:(AXUIElementRef)window;
- (NSPoint)getCurrentTopLeft;
+ (NSSize)getSizeForWindow:(AXUIElementRef)window;
- (NSSize)getCurrentSize;
- (BOOL)moveWindow:(NSPoint)thePoint;
- (BOOL)resizeWindow:(NSSize)theSize;
- (BOOL)focus;
- (BOOL)isMinimizedOrHidden;
- (NSString *)getTitle;
- (pid_t)processIdentifier;
+ (BOOL)focusWindow:(AXUIElementRef)window;
+ (BOOL)focusMainWindow:(NSRunningApplication *)app;
+ (BOOL)focusApp:(NSRunningApplication *)app;
+ (pid_t)processIdentifierOfUIElement:(AXUIElementRef)element;
+ (CFArrayRef)windowsInApp:(AXUIElementRef)app;
+ (CFArrayRef)windowsInRunningApp:(NSRunningApplication *)app;
+ (AXUIElementRef)focusedWindowInRunningApp:(NSRunningApplication *)app;
+ (BOOL)isMainWindow:(AXUIElementRef)window;
+ (NSString *)getTitle:(AXUIElementRef)window;
- (BOOL)isMovable;
- (BOOL)isResizable;
+ (BOOL)isWindowMinimizedOrHidden:(AXUIElementRef)window inApp:(AXUIElementRef)app;
+ (AXUIElementRef)windowUnderPoint:(NSPoint)point;
+ (void)createSystemWideElement;
+ (AXUIElementRef)applicationForElement:(AXUIElementRef)element;
+ (BOOL)isWindow:(AXUIElementRef)element;
+ (NSString *)getRole:(AXUIElementRef)element;

@end

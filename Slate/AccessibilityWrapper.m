//
//  AccessibilityWrapper.m
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

#import "AccessibilityWrapper.h"


@implementation AccessibilityWrapper

@synthesize systemWideElement;
@synthesize app;
@synthesize window;
@synthesize inited;

- (id)init {
  self = [super init];
  if (self) {
    if (!AXAPIEnabled()) {
      NSLog(@"ERROR: AXAPI must be enabled!");
      [self setInited:NO];
      return self;
    }
    [self setSystemWideElement:AXUIElementCreateSystemWide()];
    
    // Get App that has focus
    AXUIElementCopyAttributeValue(systemWideElement, (CFStringRef)kAXFocusedApplicationAttribute, (CFTypeRef *)&app);
    
    // Get Window that has focus
    if (AXUIElementCopyAttributeValue((AXUIElementRef)app, (CFStringRef)NSAccessibilityFocusedWindowAttribute, (CFTypeRef *)&window) == kAXErrorSuccess) {
      [self setInited:YES];
    } else {
      [self setInited:NO];
      NSLog(@"ERROR: Could not fetch focused window");
    }
  }
  
  return self;
}

- (NSPoint)getCurrentTopLeft {
  CFTypeRef _cPosition;
  NSPoint cTopLeft;
  
  if (AXUIElementCopyAttributeValue((AXUIElementRef)window, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef *)&_cPosition) == kAXErrorSuccess) {
    if (!AXValueGetValue(_cPosition, kAXValueCGPointType, (void *)&cTopLeft)) {
      NSLog(@"ERROR: Could not decode position");
      cTopLeft = NSMakePoint(0, 0);
    }
  } else {
    NSLog(@"ERROR: Could not fetch position");
    cTopLeft = NSMakePoint(0, 0);
  }
  
  return cTopLeft;
}

- (NSSize)getCurrentSize {
  CFTypeRef _cSize;
  NSSize cSize;
  
  if (AXUIElementCopyAttributeValue((AXUIElementRef)window, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef *)&_cSize) == kAXErrorSuccess) {
    if (!AXValueGetValue(_cSize, kAXValueCGSizeType, (void *)&cSize)) {
      NSLog(@"ERROR: Could not decode size");
      cSize = NSMakeSize(0, 0);
    }
  } else {
    NSLog(@"ERROR: Could not fetch size");
    cSize = NSMakeSize(0, 0);
  }
  
  return cSize;
}

- (BOOL)moveWindow:(NSPoint)thePoint {
  CFTypeRef _position;
  _position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
  if (AXUIElementSetAttributeValue((AXUIElementRef)window, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef *)_position) != kAXErrorSuccess) {
    NSLog(@"ERROR: Could not change position");
    return NO;
  }
  return YES;
}

- (BOOL)resizeWindow:(NSSize)theSize {
  CFTypeRef _size;
  _size = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
  if (AXUIElementSetAttributeValue((AXUIElementRef)window, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef *)_size) != kAXErrorSuccess) {
    NSLog(@"ERROR: Could not change size");
    return NO;
  }
  return YES;
}

@end

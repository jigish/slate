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
#import "Constants.h"
#import "SlateLogger.h"

@implementation AccessibilityWrapper

@synthesize systemWideElement;
@synthesize app;
@synthesize window;
@synthesize inited;

- (id)init {
  self = [super init];
  if (self) {
    if (!AXAPIEnabled()) {
      SlateLogger(@"ERROR: AXAPI must be enabled!");
      [self setInited:NO];
      return self;
    }
    [self setSystemWideElement:AXUIElementCreateSystemWide()];

    // Get App that has focus
    CFTypeRef _app;
    AXUIElementCopyAttributeValue(systemWideElement, (CFStringRef)kAXFocusedApplicationAttribute, (CFTypeRef *)&_app);
    [self setApp:(AXUIElementRef)_app];

    // Get Window that has focus
    CFTypeRef _window;
    if (AXUIElementCopyAttributeValue(app, (CFStringRef)NSAccessibilityFocusedWindowAttribute, (CFTypeRef *)&_window) == kAXErrorSuccess) {
      [self setWindow:(AXUIElementRef)_window];
      [self setInited:YES];
    } else {
      [self setInited:NO];
      SlateLogger(@"ERROR: Could not fetch focused window");
    }
  }

  return self;
}

- (id)initWithApp:(AXUIElementRef)appRef window:(AXUIElementRef)windowRef {
  self = [super init];
  if (self) {
    if (!AXAPIEnabled()) {
      SlateLogger(@"ERROR: AXAPI must be enabled!");
      [self setInited:NO];
      return self;
    }
    [self setSystemWideElement:AXUIElementCreateSystemWide()];
    [self setApp:appRef];
    [self setWindow:windowRef];
    [self setInited:YES];
  }

  return self;
}

- (NSPoint)getCurrentTopLeft {
  CFTypeRef _cPosition;
  NSPoint cTopLeft;

  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef *)&_cPosition) == kAXErrorSuccess) {
    if (!AXValueGetValue(_cPosition, kAXValueCGPointType, (void *)&cTopLeft)) {
      SlateLogger(@"ERROR: Could not decode position");
      cTopLeft = NSMakePoint(0, 0);
    }
  } else {
    SlateLogger(@"ERROR: Could not fetch position");
    cTopLeft = NSMakePoint(0, 0);
  }

  return cTopLeft;
}

- (NSSize)getCurrentSize {
  CFTypeRef _cSize;
  NSSize cSize;

  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef *)&_cSize) == kAXErrorSuccess) {
    if (!AXValueGetValue(_cSize, kAXValueCGSizeType, (void *)&cSize)) {
      SlateLogger(@"ERROR: Could not decode size");
      cSize = NSMakeSize(0, 0);
    }
  } else {
    SlateLogger(@"ERROR: Could not fetch size");
    cSize = NSMakeSize(0, 0);
  }

  return cSize;
}

- (BOOL)moveWindow:(NSPoint)thePoint {
  CFTypeRef _position;
  _position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
  if (AXUIElementSetAttributeValue(window, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef *)_position) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change position");
    return NO;
  }
  return YES;
}

- (BOOL)resizeWindow:(NSSize)theSize {
  CFTypeRef _size;
  _size = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
  if (AXUIElementSetAttributeValue(window, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef *)_size) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change size");
    return NO;
  }
  return YES;
}

- (BOOL)focus {
  if (AXUIElementSetAttributeValue(app, (CFStringRef)NSAccessibilityFrontmostAttribute, kCFBooleanTrue) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change focus to app");
    return NO;
  }
  if (AXUIElementSetAttributeValue(window, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change focus to window");
    return NO;
  }
  return YES;
}

+ (pid_t)processIdentifierOfUIElement:(AXUIElementRef)element {
  pid_t pid = 0;
  if (AXUIElementGetPid (element, &pid) == kAXErrorSuccess) {
    return pid;
  } else {
    return 0;
  }
}

+ (CFArrayRef)windowsInApp:(AXUIElementRef)app {
  CFArrayRef _windows;
  if (AXUIElementCopyAttributeValues(app, kAXWindowsAttribute, 0, 100, &_windows) == kAXErrorSuccess) {
    return _windows;
  }
  return nil;
}

+ (BOOL)isMainWindow:(AXUIElementRef)window {
  CFTypeRef _isMain;
  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityMainAttribute, (CFTypeRef *)&_isMain) == kAXErrorSuccess) {
    NSNumber *isMain = (__bridge NSNumber *) _isMain;
    return [isMain boolValue];
  }
  return NO;
}

+ (NSString *)getTitle:(AXUIElementRef)window {
  CFTypeRef _title;
  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef *)&_title) == kAXErrorSuccess) {
    NSString *title = (__bridge NSString *) _title;
    return title;
  }
  return @"";
}

+ (BOOL)isWindowMinimizedOrHidden:(AXUIElementRef)window {
  CFTypeRef _isMinimized;
  CFTypeRef _isHidden;
  BOOL isMinimized = NO;
  BOOL isHidden = NO;
  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityHiddenAttribute, (CFTypeRef *)&_isHidden) == kAXErrorSuccess) {
    NSNumber *isHiddenNum = (__bridge NSNumber *) _isHidden;
    isHidden = [isHiddenNum boolValue];
  }
  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityMinimizedAttribute, (CFTypeRef *)&_isMinimized) == kAXErrorSuccess) {
    NSNumber *isMinimizedNum = (__bridge NSNumber *) _isMinimized;
    isMinimized = [isMinimizedNum boolValue];
  }
  return isMinimized || isHidden;
}

@end

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

static AXUIElementRef systemWideElement = NULL;
static NSDictionary *unselectableApps = nil;

@implementation AccessibilityWrapper

@synthesize app;
@synthesize window;
@synthesize inited;

- (id)init {
  self = [super init];
  if (self) {
    [AccessibilityWrapper createSystemWideElement];

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
    [AccessibilityWrapper createSystemWideElement];
    [self setApp:appRef];
    [self setWindow:windowRef];
    [self setInited:YES];
  }

  return self;
}

+ (NSPoint)getTopLeftForWindow:(AXUIElementRef)window {
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
  if (_cPosition != NULL) CFRelease(_cPosition);

  return cTopLeft;
}

- (NSPoint)getCurrentTopLeft {
  return [AccessibilityWrapper getTopLeftForWindow:window];
}

+ (NSSize)getSizeForWindow:(AXUIElementRef)window {
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
  if (_cSize != NULL) CFRelease(_cSize);

  return cSize;
}

- (NSSize)getCurrentSize {
  return [AccessibilityWrapper getSizeForWindow:window];
}

- (BOOL)moveWindow:(NSPoint)thePoint {
  CFTypeRef _position;
  _position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
  if (AXUIElementSetAttributeValue(window, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef *)_position) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change position");
    if (_position != NULL) CFRelease(_position);
    return NO;
  }
  if (_position != NULL) CFRelease(_position);
  return YES;
}

- (BOOL)resizeWindow:(NSSize)theSize {
  CFTypeRef _size;
  _size = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
  if (AXUIElementSetAttributeValue(window, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef *)_size) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change size");
    if (_size != NULL) CFRelease(_size);
    return NO;
  }
  if (_size != NULL) CFRelease(_size);
  return YES;
}

- (BOOL)focus {
  return [AccessibilityWrapper focusWindow:[self window]];
}

- (BOOL)isMinimizedOrHidden {
  return [AccessibilityWrapper isWindowMinimizedOrHidden:[self window] inApp:[self app]];
}

- (BOOL)isMovable {
  return [self moveWindow:[self getCurrentTopLeft]];
}

- (BOOL)isResizable {
  return [self resizeWindow:[self getCurrentSize]];
}

- (NSString *)getTitle {
  return [AccessibilityWrapper getTitle:[self window]];
}

- (pid_t)processIdentifier {
  return [AccessibilityWrapper processIdentifierOfUIElement:[self app]];
}

+ (BOOL)focusApp:(NSRunningApplication *)app {
  SlateLogger(@"Focusing app: '%@'", [app localizedName]);
  AXUIElementRef appRef = AXUIElementCreateApplication([app processIdentifier]);
  if (AXUIElementSetAttributeValue(appRef, (CFStringRef)NSAccessibilityFrontmostAttribute, kCFBooleanTrue) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change focus to app");
    if (appRef != NULL) CFRelease(appRef);
    return NO;
  }
  if (appRef != NULL) CFRelease(appRef);
  return YES;
}

+ (BOOL)focusMainWindow:(NSRunningApplication *)app {
  BOOL couldFocus = YES;
  CFTypeRef _window;
  pid_t focusPID = [app processIdentifier];
  AXUIElementCopyAttributeValue(AXUIElementCreateApplication(focusPID), (CFStringRef)NSAccessibilityFocusedWindowAttribute, (CFTypeRef *)&_window);
  if (_window == NULL) return [AccessibilityWrapper focusApp:app];
  if (AXUIElementSetAttributeValue((AXUIElementRef)_window, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change focus to window");
    couldFocus = NO;
  }
  ProcessSerialNumber psn;
  GetProcessForPID(focusPID, &psn);
  SetFrontProcessWithOptions(&psn, kSetFrontProcessFrontWindowOnly);
  if (_window != NULL) CFRelease(_window);
  return couldFocus;
}

+ (BOOL)focusWindow:(AXUIElementRef)window {
  BOOL couldFocus = YES;
  if (AXUIElementSetAttributeValue(window, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue) != kAXErrorSuccess) {
    SlateLogger(@"ERROR: Could not change focus to window");
    couldFocus = NO;
  }
  pid_t focusPID = [AccessibilityWrapper processIdentifierOfUIElement:window];
  ProcessSerialNumber psn;
  GetProcessForPID(focusPID, &psn);
  SetFrontProcessWithOptions(&psn, kSetFrontProcessFrontWindowOnly);
  return couldFocus;
}

+ (pid_t)processIdentifierOfUIElement:(AXUIElementRef)element {
  [AccessibilityWrapper createSystemWideElement];
  pid_t pid = 0;
  if (AXUIElementGetPid (element, &pid) == kAXErrorSuccess) {
    return pid;
  } else {
    return 0;
  }
}

+ (CFArrayRef)windowsInApp:(AXUIElementRef)app {
  [AccessibilityWrapper createSystemWideElement];
  CFArrayRef _windows;
  if (AXUIElementCopyAttributeValues(app, kAXWindowsAttribute, 0, 100, &_windows) == kAXErrorSuccess) {
    return _windows;
  }
  return nil;
}

+ (CFArrayRef)windowsInRunningApp:(NSRunningApplication *)app {
  return [AccessibilityWrapper windowsInApp:AXUIElementCreateApplication([app processIdentifier])];
}

+ (AXUIElementRef)focusedWindowInRunningApp:(NSRunningApplication *)app {
  CFTypeRef _window;
  AXUIElementCopyAttributeValue(AXUIElementCreateApplication([app processIdentifier]), (CFStringRef)NSAccessibilityFocusedWindowAttribute, (CFTypeRef *)&_window);
  return _window;
}

+ (BOOL)isMainWindow:(AXUIElementRef)window {
  [AccessibilityWrapper createSystemWideElement];
  CFTypeRef _isMain;
  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityMainAttribute, (CFTypeRef *)&_isMain) == kAXErrorSuccess) {
    NSNumber *isMain = (__bridge NSNumber *) _isMain;
    return [isMain boolValue];
  }
  return NO;
}

+ (NSString *)getTitle:(AXUIElementRef)window {
  [AccessibilityWrapper createSystemWideElement];
  CFTypeRef _title;
  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef *)&_title) == kAXErrorSuccess) {
    NSString *title = (__bridge NSString *) _title;
    if (_title != NULL) CFRelease(_title);
    return title;
  }
  if (_title != NULL) CFRelease(_title);
  return @"";
}

+ (BOOL)isWindowMinimizedOrHidden:(AXUIElementRef)window inApp:(AXUIElementRef)app {
  [AccessibilityWrapper createSystemWideElement];
  CFTypeRef _isMinimized;
  CFTypeRef _isHidden;
  BOOL isMinimized = NO;
  BOOL isHidden = NO;
  if (AXUIElementCopyAttributeValue(app, (CFStringRef)NSAccessibilityHiddenAttribute, (CFTypeRef *)&_isHidden) == kAXErrorSuccess) {
    NSNumber *isHiddenNum = (__bridge NSNumber *) _isHidden;
    isHidden = [isHiddenNum boolValue];
  }
  if (AXUIElementCopyAttributeValue(window, (CFStringRef)NSAccessibilityMinimizedAttribute, (CFTypeRef *)&_isMinimized) == kAXErrorSuccess) {
    NSNumber *isMinimizedNum = (__bridge NSNumber *) _isMinimized;
    isMinimized = [isMinimizedNum boolValue];
  }
  return isMinimized || isHidden;
}

+ (AXUIElementRef)windowUnderPoint:(NSPoint)point {
  [AccessibilityWrapper createSystemWideElement];
  AXUIElementRef _element;
  if ((AXUIElementCopyElementAtPosition(systemWideElement, point.x, point.y, &_element) == kAXErrorSuccess) && _element) {
    CFTypeRef _role;
    if (AXUIElementCopyAttributeValue(_element, (CFStringRef)NSAccessibilityRoleAttribute, (CFTypeRef *)&_role) == kAXErrorSuccess) {
      if ([(__bridge NSString *)_role isEqualToString:NSAccessibilityWindowRole]) {
        if (_role != NULL) CFRelease(_role);
        return _element;
      }
      if (_role != NULL) CFRelease(_role);
    }
    CFTypeRef _window;
    if (AXUIElementCopyAttributeValue(_element, (CFStringRef)NSAccessibilityWindowAttribute, (CFTypeRef *)&_window) == kAXErrorSuccess) {
      if (_element != NULL) CFRelease(_element);
      return (AXUIElementRef)_window;
    }
  }
  SlateLogger(@"Returning null");
  return NULL;
}

+ (AXUIElementRef)applicationForElement:(AXUIElementRef)element {
  return AXUIElementCreateApplication([AccessibilityWrapper processIdentifierOfUIElement:element]);
}

+ (void)createSystemWideElement {
  if (systemWideElement == NULL) {
    systemWideElement = AXUIElementCreateSystemWide();
    unselectableApps = [NSDictionary dictionaryWithObjectsAndKeys:@"SystemUIServer", @"SystemUIServer",
                                                                  @"Slate", @"Slate",
                                                                  @"Dropbox", @"Dropbox",
                                                                  @"loginwindow", @"loginwindow", nil];
  }
}

+ (BOOL)isWindow:(AXUIElementRef)element {
  CFTypeRef _role;
  AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityRoleAttribute, &_role);
  BOOL isWindow = [NSAccessibilityWindowRole isEqualToString:(__bridge NSString *)_role];
  if (_role != NULL) CFRelease(_role);
  return isWindow;
}

+ (NSString *)getRole:(AXUIElementRef)element {
  if (element == NULL || element == nil) return nil;
  CFTypeRef _role;
  if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityRoleAttribute, &_role) == kAXErrorSuccess) {
    NSString *role =  (__bridge NSString *)_role;
    if (_role != NULL) CFRelease(_role);
    return role;
  }
  return nil;
}

@end

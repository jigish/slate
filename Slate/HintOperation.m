//
//  HintOperation.m
//  Slate
//
//  Created by Jigish Patel on 3/2/12.
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

#import "HintOperation.h"
#import "Constants.h"
#import "ScreenWrapper.h"
#import "HintWindow.h"
#import "HintView.h"
#import "AccessibilityWrapper.h"
#import "Binding.h"
#import "SlateAppDelegate.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"

@implementation HintOperation

@synthesize hints, windows, apps, hotkeyRefs, hideTimer, currentWindow, currentHint, hintCharacters;

- (id)init {
  self = [super init];
  if (self) {
    hints = [NSMutableArray array];
    windows = [NSMutableArray array];
    apps = [NSMutableArray array];
    hotkeyRefs = [NSMutableArray array];
    hideTimer = nil;
    currentHint = 0;
    [self setHintCharacters:HINT_CHARACTERS];
  }
  return self;
}

- (id)initWithCharacters:(NSString *)characters {
  self = [self init];
  if (self) {
    if (characters != nil) [self setHintCharacters:characters];
  }
  return self;
}

- (NSString *)currentHintCode {
  NSString *code = nil;
  if (currentHint >= [hintCharacters length]) return code;
  code = [hintCharacters substringWithRange:NSMakeRange(currentHint, 1)];
  SlateLogger(@"    GIVING CODE: %@", code);
  currentHint++;
  return code;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Hint Operation -----------------");
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  SlateLogger(@"-----------------  End Hint Operation  -----------------");
  return success;
}

- (void)createHintWindowFor:(AXUIElementRef)windowRef inApp:(AXUIElementRef)appRef {
  NSString *hintCode = [self currentHintCode];
  if (hintCode == nil) return;
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:windowRef];
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  NSPoint tl = [aw getCurrentTopLeft];
  NSInteger screenId = [sw getScreenIdForPoint:tl];
  if (screenId < 0) return;
  // convert top left to screen relative
  tl = [sw convertTopLeftToScreenRelative:tl screen:screenId];
  // now need to flip y coord
  tl.y = [[[sw screens] objectAtIndex:screenId] visibleFrame].size.height - tl.y;
  NSRect frame = NSMakeRect(tl.x + HINT_X_PADDING,
                            tl.y - [[SlateConfig getInstance] getIntegerConfig:WINDOW_HINTS_HEIGHT],
                            [[SlateConfig getInstance] getIntegerConfig:WINDOW_HINTS_WIDTH],
                            [[SlateConfig getInstance] getIntegerConfig:WINDOW_HINTS_HEIGHT]);
  NSWindow *window = [[HintWindow alloc] initWithContentRect:frame
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO
                                                      screen:[[sw screens] objectAtIndex:screenId]];
  [window setReleasedWhenClosed:NO];
  [window setOpaque:NO];
  [window setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
  [window makeKeyAndOrderFront:NSApp];
  [window setLevel:(NSScreenSaverWindowLevel - 1)];
  HintView *label = [[HintView alloc] initWithFrame:frame];
  [label setText:hintCode];
  [window setContentView:label];
  [hints addObject:window];
  [windows addObject:[NSValue valueWithPointer:windowRef]];
  [apps addObject:[NSValue valueWithPointer:appRef]];
  
  // Register the hotkey
  NSNumber *keyCode = [[Binding asciiToCodeDict] objectForKey:[hintCode lowercaseString]];
  EventHotKeyID myHotKeyID;
  EventHotKeyRef myHotKeyRef;
  myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%i",(currentHint-1)] cStringUsingEncoding:NSASCIIStringEncoding];
  myHotKeyID.id = (UInt32)(currentHint-1);
  RegisterEventHotKey([keyCode integerValue], 0, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
  [hotkeyRefs addObject:[NSValue valueWithPointer:myHotKeyRef]];
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  if (hideTimer != nil) return YES;
  [self setCurrentHint:0];
  [self setCurrentWindow:[[AccessibilityWrapper alloc] init]];
  NSArray *appsArr = [[NSWorkspace sharedWorkspace] launchedApplications];
  for (NSDictionary *app in appsArr) {
    NSNumber *appPID = [app objectForKey:@"NSApplicationProcessIdentifier"];
    SlateLogger(@"I see application '%@' with pid '%@'", [app objectForKey:@"NSApplicationName"], appPID);
    AXUIElementRef appRef = AXUIElementCreateApplication([appPID intValue]);
    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
    CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
      if (title == nil || [EMPTY isEqualToString:title]) continue; // skip empty title windows because they are invisible
      SlateLogger(@"  Hinting Window: %@", title);
      [self createHintWindowFor:CFArrayGetValueAtIndex(windowsArr, i) inApp:appRef];
    }
  }
  [self setHideTimer:[NSTimer scheduledTimerWithTimeInterval:[[SlateConfig getInstance] getFloatConfig:WINDOW_HINTS_DURATION]
                                                      target:self
                                                    selector:@selector(killHints)
                                                    userInfo:nil
                                                     repeats:NO]];
  [(SlateAppDelegate *)[NSApp delegate] setCurrentHintOperation:self];
  return YES;
}

- (BOOL)testOperation {
  return YES;
}

- (void)killHints {
  [self killHints:NO];
}

- (void)killHints:(BOOL)refocus {
  for (NSValue *hotkeyRef in hotkeyRefs) {
    UnregisterEventHotKey([hotkeyRef pointerValue]);
  }
  [hotkeyRefs removeAllObjects];
  if ([self hideTimer]) [[self hideTimer] invalidate];
  [self setHideTimer:nil];
  for (NSWindow *hint in hints) {
    [hint close];
  }
  [hints removeAllObjects];
  [windows removeAllObjects];
  [apps removeAllObjects];
  if (refocus && currentWindow) [currentWindow focus];
  [self setCurrentWindow:nil];
  [(SlateAppDelegate *)[NSApp delegate] setCurrentHintOperation:nil];
}

- (void)activateHintKey:(NSInteger)hintId {
  if ([hints objectAtIndex:hintId]) {
    AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:[[apps objectAtIndex:hintId] pointerValue] window:[[windows objectAtIndex:hintId] pointerValue]];
    [aw focus];
  }
  [self killHints];
}

+ (id)hintOperationFromString:(NSString *)hintOperation {
  // hint characters
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:hintOperation into:tokens maxTokens:2];
  Operation *op = [[HintOperation alloc] initWithCharacters:([tokens count] > 1) ? [tokens objectAtIndex:1] : nil];
  return op;
}

@end

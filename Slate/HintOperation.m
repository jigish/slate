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
#import "ExpressionPoint.h"
#import "RunningApplications.h"

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
    ignoreHidden = [[SlateConfig getInstance] getBoolConfig:WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS];
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
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:sw];
  SlateLogger(@"-----------------  End Hint Operation  -----------------");
  return success;
}

- (void)createHintWindowFor:(AXUIElementRef)windowRef inApp:(AXUIElementRef)appRef screenWrapper:(ScreenWrapper *)sw {
  NSString *hintCode = [self currentHintCode];
  if (hintCode == nil) return;
  AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:windowRef];
  NSPoint wTL = [aw getCurrentTopLeft];
  NSSize wSize = [aw getCurrentSize];
  NSInteger screenId = [sw getScreenIdForPoint:wTL];
  if (screenId < 0) return;
  NSScreen *screen = [[sw screens] objectAtIndex:screenId];
  // convert top left to screen relative for the NSWindow
  NSPoint tl = [sw convertTopLeftToScreenRelative:wTL screen:screenId];
  // now need to flip y coord
  tl.y = [screen frame].size.height - ([sw isMainScreen:screenId] ? MAIN_MENU_HEIGHT : 0) - tl.y;
  NSMutableDictionary *values = [[sw getScreenAndWindowValues:screenId window:NSMakeRect(tl.x, tl.y, wSize.width, wSize.height) newSize:wSize] mutableCopy];
  float whHeight = [ExpressionPoint expToFloat:[[SlateConfig getInstance] getConfig:WINDOW_HINTS_HEIGHT] withDict:values];
  float whWidth = [ExpressionPoint expToFloat:[[SlateConfig getInstance] getConfig:WINDOW_HINTS_WIDTH] withDict:values];
  [values setObject:[NSNumber numberWithFloat:whWidth] forKey:WINDOW_HINTS_WIDTH];
  [values setObject:[NSNumber numberWithFloat:whHeight] forKey:WINDOW_HINTS_HEIGHT];
  // these two arrays are guarenteed to be the same size because of testOperation
  NSArray *whTLXArr = [[SlateConfig getInstance] getArrayConfig:WINDOW_HINTS_TOP_LEFT_X];
  NSArray *whTLYArr = [[SlateConfig getInstance] getArrayConfig:WINDOW_HINTS_TOP_LEFT_Y];
  NSInteger i = 0;
  float whTLXRel = [ExpressionPoint expToFloat:[whTLXArr objectAtIndex:i] withDict:values];
  float whTLYRel = [ExpressionPoint expToFloat:[whTLYArr objectAtIndex:i] withDict:values];
  float whTLX = tl.x + whTLXRel;
  float whTLY = tl.y - whTLYRel;
  NSRect frame = NSMakeRect(whTLX, whTLY - whHeight, whWidth, whHeight);
  // check frame boundaries to make sure it is over the window we want it to be over
  // cycle through config for all possible locations
  if (ignoreHidden) {
    BOOL foundValidLocation = NO;
    do {
      whTLXRel = [ExpressionPoint expToFloat:[whTLXArr objectAtIndex:i] withDict:values];
      whTLYRel = [ExpressionPoint expToFloat:[whTLYArr objectAtIndex:i] withDict:values];
      whTLX = tl.x + whTLXRel;
      whTLY = tl.y - whTLYRel;
      frame = NSMakeRect(whTLX, whTLY - whHeight, whWidth, whHeight);
      if ([[AccessibilityWrapper getTitle:[AccessibilityWrapper
                                           windowUnderPoint:NSMakePoint(wTL.x + whTLXRel + whWidth/2,
                                                                        wTL.y + whTLYRel + whHeight/2)]]
           isEqualToString:[AccessibilityWrapper getTitle:windowRef]]) {
        foundValidLocation = YES;
      }
      i++;
    } while (!foundValidLocation && i < [whTLXArr count]);
    if (!foundValidLocation) {
      SlateLogger(@"        No locations visible, do not show hint!");
      currentHint--; // reset current hint so we can use this code again
      return;
    }
  }
  if ([hints count] < currentHint) {
    SlateLogger(@"        New Window!");
    NSWindow *window = [[HintWindow alloc] initWithContentRect:frame
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO
                                                        screen:screen];
    [window setReleasedWhenClosed:NO];
    [window setOpaque:NO];
    [window setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    [window makeKeyAndOrderFront:NSApp];
    [window setLevel:(NSScreenSaverWindowLevel - 1)];
    HintView *label = [[HintView alloc] initWithFrame:frame];
    [label setText:hintCode];
    [window setContentView:label];
    NSWindowController *wc = [[NSWindowController alloc] initWithWindow:window];
    [hints addObject:wc];
  } else {
    NSWindowController *wc = [hints objectAtIndex:(currentHint - 1)];
    [[wc window] setFrame:NSMakeRect(frame.origin.x+screen.frame.origin.x, frame.origin.y+screen.frame.origin.y, frame.size.width, frame.size.height) display:NO];
    [wc showWindow:[wc window]];
  }
  [windows addObject:[NSValue valueWithPointer:windowRef]];
  [apps addObject:[NSValue valueWithPointer:appRef]];
  
  // Register the hotkey
  NSNumber *keyCode = [[Binding asciiToCodeDict] objectForKey:[hintCode lowercaseString]];
  EventHotKeyID myHotKeyID;
  EventHotKeyRef myHotKeyRef;
  myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%i",(currentHint - 1)] cStringUsingEncoding:NSASCIIStringEncoding];
  myHotKeyID.id = (UInt32)(currentHint - 1);
  RegisterEventHotKey([keyCode integerValue], 0, myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
  [hotkeyRefs addObject:[NSValue valueWithPointer:myHotKeyRef]];
}

CFComparisonResult leftToRightWindows(const void *val1, const void *val2, void *context) {
  AXUIElementRef w1 = val1;
  AXUIElementRef w2 = val2;
  NSPoint w1TL = [AccessibilityWrapper getTopLeftForWindow:w1];
  NSPoint w2TL = [AccessibilityWrapper getTopLeftForWindow:w2];
  if (w1TL.x < w2TL.x) {
    return kCFCompareLessThan;
  } else if (w1TL.x > w2TL.x) {
    return kCFCompareGreaterThan;
  } else {
    if (w1TL.y < w2TL.y) {
      return kCFCompareLessThan;
    } else if (w1TL.y > w2TL.y) {
      return kCFCompareGreaterThan;
    }
  }
  return kCFCompareEqualTo;
}

CFComparisonResult rightToLeftWindows(const void *val1, const void *val2, void *context) {
  AXUIElementRef w1 = val1;
  AXUIElementRef w2 = val2;
  NSPoint w1TL = [AccessibilityWrapper getTopLeftForWindow:w1];
  NSPoint w2TL = [AccessibilityWrapper getTopLeftForWindow:w2];
  if (w1TL.x < w2TL.x) {
    return kCFCompareGreaterThan;
  } else if (w1TL.x > w2TL.x) {
    return kCFCompareLessThan;
  } else {
    if (w1TL.y < w2TL.y) {
      return kCFCompareLessThan;
    } else if (w1TL.y > w2TL.y) {
      return kCFCompareGreaterThan;
    }
  }
  return kCFCompareEqualTo;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)sw {
  if (hideTimer != nil) return YES;
  [(SlateAppDelegate *)[NSApp delegate] setCurrentHintOperation:self];
  ignoreHidden = [[SlateConfig getInstance] getBoolConfig:WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS];
  [self setCurrentHint:0];
  [self setCurrentWindow:[[AccessibilityWrapper alloc] init]];
  if ([[[SlateConfig getInstance] getConfig:WINDOW_HINTS_ORDER] isEqualToString:WINDOW_HINTS_ORDER_NONE]) {
    // normal fast way
    for (NSRunningApplication *app in [RunningApplications getInstance]) {
      pid_t appPID = [app processIdentifier];
      SlateLogger(@"I see application '%@' with pid '%d'", [app localizedName], appPID);
      AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
      CFArrayRef windowsArr = [AccessibilityWrapper windowsInApp:appRef];
      if (!windowsArr || CFArrayGetCount(windowsArr) == 0) continue;
      for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
        NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
        if (title == nil || [EMPTY isEqualToString:title]) continue; // skip empty title windows because they are invisible
        SlateLogger(@"  Hinting Window: %@", title);
        [self createHintWindowFor:CFArrayGetValueAtIndex(windowsArr, i) inApp:appRef screenWrapper:sw];
      }
    }
  } else {
    // custom order
    CFMutableArrayRef allWindows = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    for (NSRunningApplication *app in [RunningApplications getInstance]) {
      pid_t appPID = [app processIdentifier];
      SlateLogger(@"I see application '%@' with pid '%d'", [app localizedName], appPID);
      AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
      CFArrayRef windowsArr = [AccessibilityWrapper windowsInApp:appRef];
      CFArrayAppendArray(allWindows, windowsArr, CFRangeMake(0, CFArrayGetCount(windowsArr)));
    }
    // check which custom order and sort accordingly. if someone was stupid and entered a bad config, do nothing.
    if ([[[SlateConfig getInstance] getConfig:WINDOW_HINTS_ORDER] isEqualToString:WINDOW_HINTS_ORDER_LEFT_TO_RIGHT]) {
      CFArraySortValues(allWindows, CFRangeMake(0, CFArrayGetCount(allWindows)), leftToRightWindows, NULL);
    } else if ([[[SlateConfig getInstance] getConfig:WINDOW_HINTS_ORDER] isEqualToString:WINDOW_HINTS_ORDER_RIGHT_TO_LEFT]) {
      CFArraySortValues(allWindows, CFRangeMake(0, CFArrayGetCount(allWindows)), rightToLeftWindows, NULL);
    }
    for (NSInteger i = 0; i < CFArrayGetCount(allWindows); i++) {
      NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(allWindows, i)];
      if (title == nil || [EMPTY isEqualToString:title]) continue; // skip empty title windows because they are invisible
      SlateLogger(@"  Hinting Window: %@", title);
      CFTypeRef _window = CFArrayGetValueAtIndex(allWindows, i);
      [self createHintWindowFor:(AXUIElementRef)_window inApp:[AccessibilityWrapper applicationForElement:(AXUIElementRef)_window] screenWrapper:sw];
    }
  }

  // Register the escape hotkey
  NSNumber *keyCode = [[Binding asciiToCodeDict] objectForKey:@"esc"];
  EventHotKeyID myHotKeyID;
  EventHotKeyRef myHotKeyRef;
  myHotKeyID.signature = *[@"hotkeyESC" cStringUsingEncoding:NSASCIIStringEncoding];
  myHotKeyID.id = (UInt32)(currentHint+1);
  RegisterEventHotKey([keyCode integerValue], 0, myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
  [hotkeyRefs addObject:[NSValue valueWithPointer:myHotKeyRef]];

  // Set the hide timer
  [self setHideTimer:[NSTimer scheduledTimerWithTimeInterval:[[SlateConfig getInstance] getFloatConfig:WINDOW_HINTS_DURATION]
                                                      target:self
                                                    selector:@selector(killHints)
                                                    userInfo:nil
                                                     repeats:NO]];
  return YES;
}

- (BOOL)testOperation {
  NSArray *whTLXArr = [[SlateConfig getInstance] getArrayConfig:WINDOW_HINTS_TOP_LEFT_X];
  NSArray *whTLYArr = [[SlateConfig getInstance] getArrayConfig:WINDOW_HINTS_TOP_LEFT_Y];
  return [whTLXArr count] == [whTLYArr count] && [whTLXArr count] > 0;
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
  for (NSWindowController *hint in hints) {
    [hint close];
  }
  [windows removeAllObjects];
  [apps removeAllObjects];
  if (refocus && currentWindow) [currentWindow focus];
  [self setCurrentWindow:nil];
  [(SlateAppDelegate *)[NSApp delegate] setCurrentHintOperation:nil];
}

- (void)activateHintKey:(NSInteger)hintId {
  if (hintId == currentHint+1) {
    // escape key
    [self killHints];
    return;
  }
  if (hintId >= [hints count]) {
    return;
  }
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

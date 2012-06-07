//
//  SlateAppDelegate.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
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

#import "Constants.h"
#import "SlateAppDelegate.h"
#import "SlateConfig.h"
#import "Binding.h"
#import "HintOperation.h"
#import "SlateLogger.h"
#import "SnapshotList.h"
#import "SnapshotOperation.h"
#import "ActivateSnapshotOperation.h"
#import "SwitchOperation.h"
#import "RunningApplications.h"

@implementation SlateAppDelegate

@synthesize currentHintOperation, currentSwitchBinding, menuSnapshotOperation, menuActivateSnapshotOperation, cmdTabBinding, cmdShiftTabBinding;

static NSObject *timerLock = nil;
static NSObject *keyUpLock = nil;
static NSTimer *currentTimer = nil;
static EventHotKeyID currentHotKey;
static SlateAppDelegate *selfRef = nil;
static EventHandlerRef modifiersEvent;

- (IBAction)reconfig {
  NSArray *bindings = [[SlateConfig getInstance] bindings];
  for (NSInteger i = 0; i < [bindings count]; i++) {
    Binding *binding = [bindings objectAtIndex:i];
    UnregisterEventHotKey([binding hotKeyRef]);
  }

  [self loadConfig];
  [self registerHotKeys];
}

- (IBAction)currentWindowInfo {
  [windowInfoController showWindow:windowInfo];
  [windowInfo makeKeyAndOrderFront:NSApp];
  [windowInfo setLevel:(NSScreenSaverWindowLevel - 1)];
}

- (IBAction)configurationHelper {
  NSString *configFile = [@"~/.slate" stringByExpandingTildeInPath];
  [configHelperTextView setFont:[NSFont fontWithName:@"Menlo" size:11]];
  [configHelperTextView setString:[NSString stringWithContentsOfFile:[configFile stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil]];
  [configHelperController showWindow:configHelper];
  [configHelper makeKeyAndOrderFront:NSApp];
  [configHelper setLevel:(NSScreenSaverWindowLevel - 1)];
}

- (void)loadConfig {
  [[SlateConfig getInstance] load];
}

- (void)registerHotKeys {
  SlateLogger(@"Registering HotKeys...");
  EventTypeSpec eventType;
  EventTypeSpec eventReleasedType;
  eventType.eventClass = kEventClassKeyboard;
  eventType.eventKind = kEventHotKeyPressed;
  eventReleasedType.eventClass = kEventClassKeyboard;
  eventReleasedType.eventKind = kEventHotKeyReleased;

  InstallEventHandler(GetEventMonitorTarget(), &OnHotKeyEvent, 1, &eventType, (__bridge void *)self, NULL);
  InstallEventHandler(GetEventMonitorTarget(), &OnHotKeyReleasedEvent, 1, &eventReleasedType, (__bridge void *)self, NULL);

  NSArray *bindings = [[SlateConfig getInstance] bindings];
  for (NSInteger i = 0; i < [bindings count]; i++) {
    Binding *binding = [bindings objectAtIndex:i];
    if ([binding keyCode] == 48 && [binding modifiers] == cmdKey) {
      cmdTabBinding = i;
      SlateLogger(@"Found CMD+Tab binding!");
    } else if ([binding keyCode] == 48 && [binding modifiers] == (cmdKey + shiftKey)) {
      cmdShiftTabBinding = i;
      SlateLogger(@"Found CMD+Shift+Tab binding!");
    }
    EventHotKeyID myHotKeyID;
    EventHotKeyRef myHotKeyRef;
    myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%i",i] cStringUsingEncoding:NSASCIIStringEncoding];
    myHotKeyID.id = (UInt32)i;
    RegisterEventHotKey([binding keyCode], [binding modifiers], myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
    [binding setHotKeyRef:myHotKeyRef];
  }
  SlateLogger(@"HotKeys registered.");
}

- (void)createMenuSnapshotOperations {
  [self setMenuSnapshotOperation:[SnapshotOperation operationFromString:@"snapshot menuSnapshot save-to-disk"]];
  [self setMenuActivateSnapshotOperation:[ActivateSnapshotOperation operationFromString:@"activate-snapshot menuSnapshot"]];
}

- (IBAction)takeSnapshot {
  [menuSnapshotOperation doOperation];
}

- (IBAction)activateSnapshot {
  [menuActivateSnapshotOperation doOperation];
}

- (IBAction)aboutWindow {
  [NSApp orderFrontStandardAboutPanel:self];
  NSArray *windows = [NSApp windows];
  for (NSWindow *window in windows) {
    [window setLevel:(NSScreenSaverWindowLevel - 1)];
  }
}

- (OSStatus)timerActivateBinding:(NSTimer *)timer {
  return [self activateBinding:currentHotKey isRepeat:YES];
}

- (OSStatus)activateBinding:(EventHotKeyID)hkCom isRepeat:(BOOL)isRepeat {
  HintOperation *hintop = [self currentHintOperation];
  Binding *switchop = [self currentSwitchBinding];
  if (hintop != nil) {
    [hintop activateHintKey:hkCom.id];
    return noErr;
  }
  if (switchop != nil) {
    [(SwitchOperation *)[switchop op] activateSwitchKey:hkCom isRepeat:isRepeat];
    @synchronized(timerLock) {
      if (currentTimer != nil) {
        [currentTimer invalidate];
        currentTimer = nil;
      }
      // Setup timer to repeat operation
      currentHotKey = hkCom;
      currentTimer = [NSTimer scheduledTimerWithTimeInterval:[[SlateConfig getInstance] getDoubleConfig:(isRepeat ? SWITCH_SECONDS_BETWEEN_REPEAT : SWITCH_SECONDS_BEFORE_REPEAT)]
                                                      target:selfRef
                                                    selector:@selector(timerActivateBinding:)
                                                    userInfo:nil
                                                     repeats:NO];
    }
    return noErr;
  }

  Binding *binding = [[[SlateConfig getInstance] bindings] objectAtIndex:hkCom.id];
  if (binding) {
    SlateLogger(@"Running Operation %@", [[[SlateConfig getInstance] bindings] objectAtIndex:hkCom.id]);
    if ([[binding op] isKindOfClass:[SwitchOperation class]]) {
      // makes sure that if switch is called immediately after opening slate we don't run into issues
      NSArray *currentApps = [[RunningApplications getInstance] apps];
      if ([currentApps count] > 0) {
        [AccessibilityWrapper focusApp:[currentApps objectAtIndex:0]];
      }
      [self setCurrentSwitchBinding:binding];
      EventTypeSpec modifiersChangedType;
      modifiersChangedType.eventClass = kEventClassKeyboard;
      modifiersChangedType.eventKind = kEventRawKeyModifiersChanged;
      InstallEventHandler(GetEventMonitorTarget(), &OnModifiersChangedEvent, 1, &modifiersChangedType, (__bridge void *)self, &modifiersEvent);
    }
    [binding doOperation];
    if (!(cmdTabBinding > 0 && [[[SlateConfig getInstance] bindings] objectAtIndex:cmdTabBinding] == binding) &&
        !(cmdShiftTabBinding > 0 && [[[SlateConfig getInstance] bindings] objectAtIndex:cmdShiftTabBinding] == binding) &&
        ([binding repeat] || [[binding op] isKindOfClass:[SwitchOperation class]])) {
      @synchronized(timerLock) {
        if (currentTimer != nil) {
          [currentTimer invalidate];
          currentTimer = nil;
        }
        // Setup timer to repeat operation
        currentHotKey = hkCom;
        if (![[binding op] isKindOfClass:[SwitchOperation class]] || !keyUpSeen) {
          currentTimer = [NSTimer scheduledTimerWithTimeInterval:[[SlateConfig getInstance] getDoubleConfig:([[binding op] isKindOfClass:[SwitchOperation class]] ?
                                                                                                             (isRepeat ? SWITCH_SECONDS_BETWEEN_REPEAT : SWITCH_SECONDS_BEFORE_REPEAT) :
                                                                                                             (isRepeat ? SECONDS_BETWEEN_REPEAT : SECONDS_BEFORE_REPEAT))]
                                                          target:selfRef
                                                        selector:@selector(timerActivateBinding:)
                                                        userInfo:nil
                                                         repeats:NO];
        }
      }
    }
  }
  return noErr;
}

// Quartz Event Tap for reserved key bindings (CMD+Tab or CMD+Shift+Tab)
static const NSTimeInterval KEY_UP_BUFFER = -0.020;
static BOOL keyUpSeen = YES;
static NSDate *keyUpTime = nil;
CGEventRef EatAppSwitcherCallback(CGEventTapProxy proxy, CGEventType type,  CGEventRef event, void *refcon) {
  @synchronized(keyUpLock) {
    CGEventFlags flags = CGEventGetFlags(event);
    int64_t keyCode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    SlateLogger(@"KEY DOWN - FLAGS: %llu, KEYCODE: %lld", (uint64_t)flags, keyCode);
    // 48 is tab key code
    if (keyCode == 48 &&
        ((flags & kCGEventFlagMaskCommand) == kCGEventFlagMaskCommand) &&
        ((flags & kCGEventFlagMaskAlternate) != kCGEventFlagMaskAlternate) &&
        ((flags & kCGEventFlagMaskControl) != kCGEventFlagMaskControl) &&
        ((flags & kCGEventFlagMaskAlphaShift) != kCGEventFlagMaskAlphaShift) &&
        ((flags & kCGEventFlagMaskHelp) != kCGEventFlagMaskHelp) &&
        ((flags & kCGEventFlagMaskNumericPad) != kCGEventFlagMaskNumericPad) &&
        ((flags & kCGEventFlagMaskSecondaryFn) != kCGEventFlagMaskSecondaryFn)) {
      SlateLogger(@"  IS CMD+TAB");
      if (keyUpSeen) {
        SlateLogger(@"    KEY UP SEEN: %f", [keyUpTime timeIntervalSinceNow]);
        if (keyUpTime && [keyUpTime timeIntervalSinceNow] > KEY_UP_BUFFER) {
          return NULL;
        }
        @synchronized(timerLock) {
          if (currentTimer != nil) {
            [currentTimer invalidate];
            currentTimer = nil;
          }
        }
        keyUpSeen = NO;
        keyUpTime = nil;
        SlateAppDelegate *del = (__bridge SlateAppDelegate *)refcon;
        EventHotKeyID myHotKeyID;
        NSInteger hotkeyID = ((flags & kCGEventFlagMaskShift) == kCGEventFlagMaskShift) ? [del cmdShiftTabBinding] : [del cmdTabBinding];
        if (hotkeyID < 0) return NULL;
        myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%i",hotkeyID] cStringUsingEncoding:NSASCIIStringEncoding];
        myHotKeyID.id = (UInt32)hotkeyID;
        [del activateBinding:myHotKeyID isRepeat:NO];
      } else {
        SlateLogger(@"    KEY UP NOT SEEN");
        @synchronized(timerLock) {
          if (currentTimer != nil) {
            [currentTimer invalidate];
            currentTimer = nil;
          }
        }
        SlateAppDelegate *del = (__bridge SlateAppDelegate *)refcon;
        EventHotKeyID myHotKeyID;
        NSInteger hotkeyID = ((flags & kCGEventFlagMaskShift) == kCGEventFlagMaskShift) ? [del cmdShiftTabBinding] : [del cmdTabBinding];
        if (hotkeyID < 0) return NULL;
        myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%i",hotkeyID] cStringUsingEncoding:NSASCIIStringEncoding];
        myHotKeyID.id = (UInt32)hotkeyID;
        [del activateBinding:myHotKeyID isRepeat:YES];
      }
      return NULL;
    }
    return event;
  }
}

CGEventRef EatAppSwitcherResetCallback(CGEventTapProxy proxy, CGEventType type,  CGEventRef event, void *refcon) {
  @synchronized(keyUpLock) {
    SlateLogger(@"KEY UP");
    @synchronized(timerLock) {
      if (currentTimer != nil) {
        [currentTimer invalidate];
        currentTimer = nil;
      }
    }
    keyUpSeen = YES;
    keyUpTime = [NSDate date];
    return event;
  }
}

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
  @synchronized(timerLock) {
    if (currentTimer != nil) {
      [currentTimer invalidate];
      currentTimer = nil;
    }
  }
  if (![(__bridge id)userData isKindOfClass:[SlateAppDelegate class]]) return noErr;
  EventHotKeyID hkCom;
  GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
  return [(__bridge SlateAppDelegate *)userData activateBinding:hkCom isRepeat:NO];
}

OSStatus OnHotKeyReleasedEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
  @synchronized(timerLock) {
    if (currentTimer != nil) {
      [currentTimer invalidate];
      currentTimer = nil;
    }
  }
  return noErr;
}

OSStatus OnModifiersChangedEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
  SlateLogger(@"Modifiers changed");
  @synchronized(timerLock) {
    if (currentTimer != nil) {
      [currentTimer invalidate];
      currentTimer = nil;
    }
  }
  Binding *currSwitch = [(__bridge SlateAppDelegate *)userData currentSwitchBinding];
  UInt32 modifiers;
  GetEventParameter(theEvent, kEventParamKeyModifiers, typeUInt32, NULL, sizeof(modifiers), NULL, &modifiers);
  if (currSwitch != nil) {
    if ([(SwitchOperation *)[currSwitch op] modifiersChanged:[currSwitch modifiers] new:modifiers]) {
      [(__bridge SlateAppDelegate *)userData setCurrentSwitchBinding:nil];
      RemoveEventHandler(modifiersEvent);
      keyUpSeen = YES;
    }
  }
  return noErr;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  if (cmdTabBinding > 0 || cmdShiftTabBinding > 0) {
    CFMachPortRef keyDownEventTap;
    CFRunLoopSourceRef keyDownRunLoopSource;
    keyDownEventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, CGEventMaskBit(kCGEventKeyDown), EatAppSwitcherCallback, (__bridge void *)self);
    keyDownRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyDownEventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), keyDownRunLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(keyDownEventTap, true);

    CFMachPortRef keyUpEventTap;
    CFRunLoopSourceRef keyUpRunLoopSource;
    keyUpEventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, CGEventMaskBit(kCGEventKeyUp), EatAppSwitcherResetCallback, (__bridge void *)self);
    keyUpRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyUpEventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), keyUpRunLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(keyUpEventTap, true);
  }
}

- (void)awakeFromNib {
  cmdTabBinding = -1;
  cmdShiftTabBinding = -1;
  currentHintOperation = nil;

  windowInfoController = [[NSWindowController alloc] initWithWindow:windowInfo];
  configHelperController = [[NSWindowController alloc] initWithWindow:configHelper];

  NSMenuItem *aboutItem = [statusMenu insertItemWithTitle:@"About Slate" action:@selector(aboutWindow) keyEquivalent:@"" atIndex:0];
  [aboutItem setTarget:self];

  NSMenuItem *takeSnapshotItem = [statusMenu insertItemWithTitle:@"Take Snapshot" action:@selector(takeSnapshot) keyEquivalent:@"" atIndex:3];
  [takeSnapshotItem setTarget:self];

  activateSnapshotItem = [statusMenu insertItemWithTitle:@"Activate Snapshot" action:@selector(activateSnapshot) keyEquivalent:@"" atIndex:4];
  [activateSnapshotItem setTarget:self];

  NSMenuItem *loadConfigItem = [statusMenu insertItemWithTitle:@"Load Config" action:@selector(reconfig) keyEquivalent:@"" atIndex:1];
  [loadConfigItem setTarget:self];

  NSMenuItem *windowInfoItem = [statusMenu insertItemWithTitle:@"Current Window Info" action:@selector(currentWindowInfo) keyEquivalent:@"" atIndex:3];
  [windowInfoItem setTarget:self];

  //NSMenuItem *configInfoItem = [statusMenu insertItemWithTitle:@"Configuration Helper" action:@selector(configurationHelper) keyEquivalent:@"" atIndex:2];
  //[configInfoItem setTarget:self];

  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
  [statusItem setMenu:statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"status"]];
  [statusItem setHighlightMode:YES];

  // Ensure no timer exists
  @synchronized(timerLock) {
    currentTimer = nil;
    timerLock = [[NSObject alloc] init];
  }

  @synchronized(keyUpLock) {
    keyUpLock = [[NSObject alloc] init];
  }

  // Check if Accessibility API is enabled
  if (!AXAPIEnabled()) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Quit"];
    [alert addButtonWithTitle:@"Skip"];
    [alert setMessageText:[NSString stringWithFormat:@"ERROR Access for assistive devices is not enabled. Please enable it."]];
    [alert setInformativeText:[NSString stringWithFormat:@"Settings > Universal Access > Enable access for assistive devices."]];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }

  // Read Config
  [self loadConfig];

  // Register Hot Keys
  [self registerHotKeys];

  [self createMenuSnapshotOperations];

  // Setup App list
  NSArray *rapps = [[RunningApplications getInstance] apps];
  if ([rapps count] > 0) [AccessibilityWrapper focusMainWindow:[rapps objectAtIndex:0]];

  selfRef = self;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if (menuItem == activateSnapshotItem) {
    SnapshotList *menuSnapshots = [[[SlateConfig getInstance] snapshots] objectForKey:@"menuSnapshot"];
    if (menuSnapshots == nil || [[menuSnapshots snapshots] count] <= 0) {
      return NO;
    }
  }
  return YES;
}

@end

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
#import "JSController.h"
#import "Binding.h"
#import "HintOperation.h"
#import "SlateLogger.h"
#import "SnapshotList.h"
#import "SnapshotOperation.h"
#import "ActivateSnapshotOperation.h"
#import "DeleteSnapshotOperation.h"
#import "SwitchOperation.h"
#import "RunningApplications.h"
#import "GridOperation.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation SlateAppDelegate

@synthesize currentHintOperation, currentGridOperation, currentSwitchBinding, menuSnapshotOperation;
@synthesize menuActivateSnapshotOperation, cmdTabBinding, cmdShiftTabBinding, modalHotKeyRefs, modalIdToKey;
@synthesize currentModalKey, currentModalHotKeyRefs, undoSnapshotOperation, undoDeleteSnapshotOperation, hasUndoOperation;

static NSObject *timerLock = nil;
static NSObject *keyUpLock = nil;
static NSTimer *currentTimer = nil;
static EventHotKeyID currentHotKey;
static SlateAppDelegate *selfRef = nil;
static EventHandlerRef modifiersEvent;

- (IBAction)updateLaunchState {
  if ([launchOnLoginItem state] == NSControlStateValueOn) {
    // currently on
    [self deleteFromLoginItems];
    [self setLaunchOnLoginItemStatus];
  } else {
    // currently off
    [self addToLoginItems];
    [self setLaunchOnLoginItemStatus];
  }
}

- (IBAction)relaunch {
  // A detached shell waits for this process to exit, then reopens the app bundle. The PID and bundle path are
  // passed as positional arguments ($1, $2), never interpolated into the script.
  NSString *script = @"while /bin/kill -0 \"$1\" 2>/dev/null; do /bin/sleep 0.1; done; exec /usr/bin/open \"$2\"";
  NSString *pid = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
  NSTask *task = [[NSTask alloc] init];
  [task setExecutableURL:[NSURL fileURLWithPath:@"/bin/sh"]];
  [task setArguments:@[@"-c", script, @"slate-relaunch", pid, [[NSBundle mainBundle] bundlePath]]];
  NSError *error = nil;
  if (![task launchAndReturnError:&error]) {
    NSLog(@"ERROR: Unable to relaunch Slate: %@", error);
    return;
  }
  NSLog(@"Relaunching Slate.");
  [NSApp terminate:self];
}

- (IBAction)currentWindowInfo {
  // Center on the screen under the mouse and bring Slate (a menu bar app) to the front.
  NSPoint mouse = [NSEvent mouseLocation];
  NSScreen *screen = [NSScreen mainScreen];
  for (NSScreen *candidate in [NSScreen screens]) {
    if (NSMouseInRect(mouse, [candidate frame], NO)) { screen = candidate; break; }
  }
  NSRect visible = [screen visibleFrame];
  NSSize size = [windowInfo frame].size;
  [windowInfo setFrameOrigin:NSMakePoint(NSMidX(visible) - size.width / 2, NSMidY(visible) - size.height / 2)];
  if (@available(macOS 14.0, *)) {
    [NSApp activate];
  } else {
    [NSApp activateIgnoringOtherApps:YES];
  }
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
  [self setHasUndoOperation:NO];
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

  NSMutableArray *bindings = [[SlateConfig getInstance] bindings];

  for (NSInteger i = 0; i < [bindings count]; i++) {
    Binding *binding = [bindings objectAtIndex:i];
    SlateLogger(@"REGISTERING KEY: %u, MODIFIERS: %u", [binding keyCode], [binding modifiers]);
    if ([binding keyCode] == 48 && [binding modifiers] == cmdKey) {
      cmdTabBinding = i;
      SlateLogger(@"Found CMD+Tab binding!");
    } else if ([binding keyCode] == 48 && [binding modifiers] == (cmdKey + shiftKey)) {
      cmdShiftTabBinding = i;
      SlateLogger(@"Found CMD+Shift+Tab binding!");
    }
    EventHotKeyID myHotKeyID;
    EventHotKeyRef myHotKeyRef;
    myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%li",i] cStringUsingEncoding:NSASCIIStringEncoding];
    myHotKeyID.id = (UInt32)i;
    RegisterEventHotKey([binding keyCode], [binding modifiers], myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
    [binding setHotKeyRef:myHotKeyRef];
  }

  NSArray *modalKeys = [[[SlateConfig getInstance] modalBindings] allKeys];
  NSInteger i = MODAL_BEGIN_ID;
  for (NSString *modalHashKey in modalKeys) {
    SlateLogger(@"REGISTERING MODAL KEY: %@", modalHashKey);
    NSArray *modalKeyArr = [Binding modalHashKeyToKeyAndModifiers:modalHashKey];
    if (modalKeyArr == nil) continue;
    EventHotKeyID myHotKeyID;
    EventHotKeyRef myHotKeyRef;
    myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%li",i] cStringUsingEncoding:NSASCIIStringEncoding];
    myHotKeyID.id = (UInt32)i;
    RegisterEventHotKey([[modalKeyArr objectAtIndex:0] unsignedIntValue], [[modalKeyArr objectAtIndex:1] unsignedIntValue], myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
    [[self modalHotKeyRefs] setObject:[NSValue valueWithPointer:myHotKeyRef] forKey:modalHashKey];
    [[self modalIdToKey] setObject:modalHashKey forKey:[NSNumber numberWithInteger:i]];
    i++;
  }
  SlateLogger(@"HotKeys registered.");
}

- (void)createSnapshotOperations {
  SnapshotOperation *undoSnapOp = [SnapshotOperation operationFromString:[NSString stringWithFormat:@"snapshot %@ save-to-disk;stack", UNDO_SNAPSHOT]];
  [undoSnapOp setStackSize:[[SlateConfig getInstance] getIntegerConfig:UNDO_MAX_STACK_SIZE]];
  [self setUndoSnapshotOperation:undoSnapOp];
  [self setUndoDeleteSnapshotOperation:[DeleteSnapshotOperation operationFromString:[NSString stringWithFormat:@"delete-snapshot %@ all", UNDO_SNAPSHOT]]];
  [self setMenuSnapshotOperation:[SnapshotOperation operationFromString:[NSString stringWithFormat:@"snapshot %@ save-to-disk", MENU_SNAPSHOT]]];
  [self setMenuActivateSnapshotOperation:[ActivateSnapshotOperation operationFromString:[NSString stringWithFormat:@"activate-snapshot %@", MENU_SNAPSHOT]]];
  [[self undoDeleteSnapshotOperation] doOperation];
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

- (void)resetModalKey {
  // clear out bindings
  for (NSValue *hotKeyRef in [self currentModalHotKeyRefs]) {
    UnregisterEventHotKey([hotKeyRef pointerValue]);
  }
  // reset status image
  [[statusItem button] setImage:[NSImage imageNamed:@"status"]];
  currentModalKey = nil;
}

- (OSStatus)activateBinding:(EventHotKeyID)hkCom isRepeat:(BOOL)isRepeat {
  SlateLogger(@"ACTIVATING BINDING: %u", hkCom.id);
  // check if there is a currently open binding
  HintOperation *hintop = [self currentHintOperation];
  GridOperation *gridop = [self currentGridOperation];
  Binding *switchop = [self currentSwitchBinding];
  if (hintop != nil) {
    [hintop activateHintKey:hkCom.id];
    return noErr;
  }
  if (gridop != nil) {
    [gridop activateGridKey:hkCom.id];
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

  // check modal stuffs
  NSNumber *hkId = [NSNumber numberWithInteger:hkCom.id];
  NSString *modalKey = [[self modalIdToKey] objectForKey:hkId];
  if (modalKey != nil) {
    if (currentModalKey != nil && [modalKey isEqualToString:currentModalKey]) {
      [self resetModalKey];
      return noErr;
    } else if (currentModalKey == nil) {
      SlateLogger(@"FOUND MODAL KEY BINDING, REGISTERING!");
      // register all these bindings
      [[self currentModalHotKeyRefs] removeAllObjects];
      NSArray *modalOperations = [[[SlateConfig getInstance] modalBindings] objectForKey:modalKey];
      NSInteger i = CURRENT_MODAL_BEGIN_ID;
      for (Binding *binding in modalOperations) {
        EventHotKeyID myHotKeyID;
        EventHotKeyRef myHotKeyRef;
        myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%li",i] cStringUsingEncoding:NSASCIIStringEncoding];
        myHotKeyID.id = (UInt32)i;
        RegisterEventHotKey([binding keyCode], 0, myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
        [binding setHotKeyRef:myHotKeyRef];
        [[self currentModalHotKeyRefs] addObject:[NSValue valueWithPointer:myHotKeyRef]];
        i++;
      }
      if (![EMPTY isEqualToString:[[SlateConfig getInstance] getConfig:MODAL_ESCAPE_KEY]]) {
        EventHotKeyID myHotKeyID;
        EventHotKeyRef myHotKeyRef;
        myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%li",MODAL_ESCAPE_ID] cStringUsingEncoding:NSASCIIStringEncoding];
        myHotKeyID.id = (UInt32)MODAL_ESCAPE_ID;
        NSArray *keyarr = [Binding getKeystrokeFromString:[[SlateConfig getInstance] getConfig:MODAL_ESCAPE_KEY]];
        RegisterEventHotKey([[keyarr objectAtIndex:0] unsignedIntValue], [[keyarr objectAtIndex:1] unsignedIntValue], myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
        [[self currentModalHotKeyRefs] addObject:[NSValue valueWithPointer:myHotKeyRef]];
      }
      [self setCurrentModalKey:modalKey];
      // change status image
      [[statusItem button] setImage:[NSImage imageNamed:@"statusActive"]];
      return noErr;
    }
  }

  if (hkCom.id >= [[[SlateConfig getInstance] bindings] count]) {
    if (currentModalKey != nil) {
      if (hkCom.id == MODAL_ESCAPE_ID) {
        [self resetModalKey];
      } else {
        NSInteger potentialId = hkCom.id - CURRENT_MODAL_BEGIN_ID;
        if (potentialId >= 0 && potentialId < [[[[SlateConfig getInstance] modalBindings] objectForKey:currentModalKey] count]) {
          Binding *binding = [[[[SlateConfig getInstance] modalBindings] objectForKey:currentModalKey] objectAtIndex:potentialId];
          [binding doOperation];
          if (![binding toggle]) {
            // clear out bindings
            [self resetModalKey];
          }
        }
      }
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
        myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%li",hotkeyID] cStringUsingEncoding:NSASCIIStringEncoding];
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
        myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%li",hotkeyID] cStringUsingEncoding:NSASCIIStringEncoding];
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

- (void)setLaunchOnLoginItemStatus {
  if ([self isInLoginItems]) [launchOnLoginItem setState:NSControlStateValueOn];
  else [launchOnLoginItem setState:NSControlStateValueOff];
}

- (void)awakeFromNib {
  // Unit tests run inside Slate.app (TEST_HOST). Skip startup so tests don't prompt for Accessibility,
  // load the user's config or register global hot keys.
  if ([[[NSProcessInfo processInfo] environment] objectForKey:@"XCTestConfigurationFilePath"] != nil) {
    NSLog(@"Running as unit test host: skipping Slate startup.");
    return;
  }

  cmdTabBinding = -1;
  cmdShiftTabBinding = -1;
  currentHintOperation = nil;
  currentGridOperation = nil;

  [self setModalHotKeyRefs:[NSMutableDictionary dictionary]];
  [self setModalIdToKey:[NSMutableDictionary dictionary]];
  [self setCurrentModalHotKeyRefs:[NSMutableArray array]];

  windowInfoController = [[NSWindowController alloc] initWithWindow:windowInfo];
  configHelperController = [[NSWindowController alloc] initWithWindow:configHelper];

  NSMenuItem *aboutItem = [statusMenu insertItemWithTitle:@"About Slate" action:@selector(aboutWindow) keyEquivalent:@"" atIndex:0];
  [aboutItem setTarget:self];

  NSMenuItem *takeSnapshotItem = [statusMenu insertItemWithTitle:@"Take Snapshot" action:@selector(takeSnapshot) keyEquivalent:@"" atIndex:3];
  [takeSnapshotItem setTarget:self];

  activateSnapshotItem = [statusMenu insertItemWithTitle:@"Activate Snapshot" action:@selector(activateSnapshot) keyEquivalent:@"" atIndex:4];
  [activateSnapshotItem setTarget:self];

  NSMenuItem *loadConfigItem = [statusMenu insertItemWithTitle:@"Relaunch and Load Config" action:@selector(relaunch) keyEquivalent:@"" atIndex:1];
  [loadConfigItem setTarget:self];

  launchOnLoginItem = [statusMenu insertItemWithTitle:@"Launch Slate on Login" action:@selector(updateLaunchState) keyEquivalent:@"" atIndex:2];
  [self setLaunchOnLoginItemStatus];
  [launchOnLoginItem setTarget:self];

  NSMenuItem *windowInfoItem = [statusMenu insertItemWithTitle:@"Current Window Info" action:@selector(currentWindowInfo) keyEquivalent:@"" atIndex:4];
  [windowInfoItem setTarget:self];

  //NSMenuItem *configInfoItem = [statusMenu insertItemWithTitle:@"Configuration Helper" action:@selector(configurationHelper) keyEquivalent:@"" atIndex:2];
  //[configInfoItem setTarget:self];

  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
  [statusItem setMenu:statusMenu];
  NSImage *statusImage = [NSImage imageNamed:@"status"];
  [statusImage setTemplate:YES];
  [[statusItem button] setImage:statusImage];

  // Ensure no timer exists
  @synchronized(timerLock) {
    currentTimer = nil;
    timerLock = [[NSObject alloc] init];
  }

  @synchronized(keyUpLock) {
    keyUpLock = [[NSObject alloc] init];
  }

  // Check if Accessibility API is enabled. If not, macOS prompts the user to grant access in
  // System Settings > Privacy & Security > Accessibility.
  NSDictionary *axOptions = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @YES};
  if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)axOptions)) {
    NSLog(@"WARNING: Slate is not trusted for Accessibility. Window operations will fail until access is granted.");
  }

  // Read Config
  [self loadConfig];

  // Register Hot Keys
  [self registerHotKeys];

  [self createSnapshotOperations];

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

- (BOOL)isInLoginItems {
  return [[SMAppService mainAppService] status] == SMAppServiceStatusEnabled;
}

- (void)addToLoginItems {
  NSError *error = nil;
  if (![[SMAppService mainAppService] registerAndReturnError:&error]) {
    NSLog(@"ERROR: Unable to add Slate to login items: %@", error);
  }
}

- (void)deleteFromLoginItems {
  NSError *error = nil;
  if (![[SMAppService mainAppService] unregisterAndReturnError:&error]) {
    NSLog(@"ERROR: Unable to remove Slate from login items: %@", error);
  }
}

@end

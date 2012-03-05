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

@implementation SlateAppDelegate

@synthesize currentHintOperation;

static NSObject *timerLock = nil;
static NSTimer *currentTimer = nil;
static EventHotKeyID currentHotKey;
static SlateAppDelegate *selfRef = nil;

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

  InstallApplicationEventHandler(&OnHotKeyEvent, 1, &eventType, (__bridge void *)self, NULL);
  InstallApplicationEventHandler(&OnHotKeyReleasedEvent, 1, &eventReleasedType, (__bridge void *)self, NULL);

  NSArray *bindings = [[SlateConfig getInstance] bindings];
  for (NSInteger i = 0; i < [bindings count]; i++) {
    Binding *binding = [bindings objectAtIndex:i];
    EventHotKeyID myHotKeyID;
    EventHotKeyRef myHotKeyRef;
    myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%i",i] cStringUsingEncoding:NSASCIIStringEncoding];
    myHotKeyID.id = (UInt32)i;
    RegisterEventHotKey([binding keyCode], [binding modifiers], myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
    [binding setHotKeyRef:myHotKeyRef];
  }
  SlateLogger(@"HotKeys registered.");
}

- (void) runBinding:(NSTimer *)timer {
  if ([[[SlateConfig getInstance] bindings] objectAtIndex:currentHotKey.id]) {
    [[[[SlateConfig getInstance] bindings] objectAtIndex:currentHotKey.id] doOperation];
  }
}

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
  if (![(__bridge id)userData isKindOfClass:[SlateAppDelegate class]]) return noErr;
  EventHotKeyID hkCom;
  GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
  
  HintOperation *hintop = [(__bridge SlateAppDelegate *)userData currentHintOperation];
  if (hintop != nil) {
    [hintop activateHintKey:hkCom.id];
    return noErr;
  }

  if ([[[SlateConfig getInstance] bindings] objectAtIndex:hkCom.id]) {
    [[[[SlateConfig getInstance] bindings] objectAtIndex:hkCom.id] doOperation];
    if ([[[[SlateConfig getInstance] bindings] objectAtIndex:hkCom.id] repeat]) {
      @synchronized(timerLock) {
        if (currentTimer != nil) {
          [currentTimer invalidate];
          currentTimer = nil;
        }
        // Setup timer to repeat operation
        currentHotKey = hkCom;
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:[[SlateConfig getInstance] getDoubleConfig:SECONDS_BETWEEN_REPEAT]
                                target:selfRef
                                selector:@selector(runBinding:)
                                userInfo:nil
                                repeats:YES];
      }
    }
  }

  return noErr;
}

OSStatus OnHotKeyReleasedEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
  if (![(__bridge id)userData isKindOfClass:[SlateAppDelegate class]]) return noErr;
  if ([(__bridge SlateAppDelegate *)userData currentHintOperation] != nil) return noErr;
  EventHotKeyID hkCom;
  GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);

  @synchronized(timerLock) {
    if (currentTimer != nil && hkCom.id == currentHotKey.id) {
      [currentTimer invalidate];
      currentTimer = nil;
    }
  }
  return noErr;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  
}

- (void)processNotification:(id)notification {
  SlateLogger(@"Notification: %@", notification);
  SlateLogger(@"Notification Name: %@", [notification name]);
}

- (void)awakeFromNib {
  currentHintOperation = nil;

  windowInfoController = [[NSWindowController alloc] initWithWindow:windowInfo];
  
  NSMenuItem *loadConfigItem = [statusMenu insertItemWithTitle:@"Load Config" action:@selector(reconfig) keyEquivalent:@"" atIndex:0];
  [loadConfigItem setTarget:self];
  
  NSMenuItem *windowInfoItem = [statusMenu insertItemWithTitle:@"Current Window Info" action:@selector(currentWindowInfo) keyEquivalent:@"" atIndex:1];
  [windowInfoItem setTarget:self];

  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
  [statusItem setMenu:statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"status"]];
  [statusItem setHighlightMode:YES];

  // Ensure no timer exists
  @synchronized(timerLock) {
    currentTimer = nil;
    timerLock = [[NSObject alloc] init];
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

  selfRef = self;
}

@end

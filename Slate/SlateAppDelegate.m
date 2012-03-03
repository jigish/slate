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

@implementation SlateAppDelegate

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
}

- (void)loadConfig {
  [[SlateConfig getInstance] load];
}

- (void)registerHotKeys {
  NSLog(@"Registering HotKeys...");
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
  NSLog(@"HotKeys registered.");
}

- (void) runBinding:(NSTimer *)timer {
  if ([[[SlateConfig getInstance] bindings] objectAtIndex:currentHotKey.id]) {
    [[[[SlateConfig getInstance] bindings] objectAtIndex:currentHotKey.id] doOperation];
  }
}

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
  EventHotKeyID hkCom;
  GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);

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
  NSLog(@"Notification: %@", notification);
  NSLog(@"Notification Name: %@", [notification name]);
}

- (void)awakeFromNib {
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

  // Read Config
  [self loadConfig];

  // Register Hot Keys
  [self registerHotKeys];

  selfRef = self;
}

@end

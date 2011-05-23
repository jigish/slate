//
//  SlateAppDelegate.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SlateAppDelegate.h"
#import "SlateConfig.h"
#import "Binding.h"

@implementation SlateAppDelegate

- (IBAction)reconfig {
  NSArray *bindings = [[SlateConfig getInstance] getBindings];
  for (int i = 0; i < [bindings count]; i++) {
    Binding *binding = [bindings objectAtIndex:i];
    UnregisterEventHotKey([binding hotKeyRef]);
  }

  [self loadConfig];
  [self registerHotKeys];
}

- (void)loadConfig {
  [[SlateConfig getInstance] load];
}

- (void)registerHotKeys {
  NSLog(@"Registering HotKeys...");
  EventTypeSpec eventType;
  eventType.eventClass = kEventClassKeyboard;
  eventType.eventKind = kEventHotKeyPressed;

  InstallApplicationEventHandler(&OnHotKeyEvent, 1, &eventType, (void *)self, NULL);

  NSArray *bindings = [[SlateConfig getInstance] getBindings];
  for (int i = 0; i < [bindings count]; i++) {
    Binding *binding = [bindings objectAtIndex:i];
    EventHotKeyID myHotKeyID;
    EventHotKeyRef myHotKeyRef;
    myHotKeyID.signature = *[[NSString stringWithFormat:@"hotkey%i",i] cStringUsingEncoding:NSASCIIStringEncoding];
    myHotKeyID.id = i;
    RegisterEventHotKey([binding keyCode], [binding modifiers], myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
    [binding setHotKeyRef:myHotKeyRef];
  }
  NSLog(@"HotKeys registered.");
}

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
  EventHotKeyID hkCom;

  GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);

  if ([[[SlateConfig getInstance] getBindings] objectAtIndex:hkCom.id]) {
    Binding *binding = [[[SlateConfig getInstance] getBindings] objectAtIndex:hkCom.id];
    if (!AXAPIEnabled()) {
      NSLog(@"ERROR: AXAPI must be enabled!");
      return 1;
    }
    AXUIElementRef _systemWideElement;
    AXUIElementRef _focusedApp;
    CFTypeRef _focusedWindow;
    CFTypeRef _position;
    CFTypeRef _size;
    CFTypeRef _cPosition;
    CFTypeRef _cSize;
    NSPoint cTopLeft;
    NSSize cSize;
    _systemWideElement = AXUIElementCreateSystemWide();

    // Get App that has focus
    AXUIElementCopyAttributeValue(_systemWideElement, (CFStringRef)kAXFocusedApplicationAttribute, (CFTypeRef *)&_focusedApp);

    // Get Window that has focus
    if (AXUIElementCopyAttributeValue((AXUIElementRef)_focusedApp, (CFStringRef)NSAccessibilityFocusedWindowAttribute, (CFTypeRef *)&_focusedWindow) == kAXErrorSuccess) {
      if (AXUIElementCopyAttributeValue((AXUIElementRef)_focusedWindow, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef *)&_cPosition) == kAXErrorSuccess) {
        if (!AXValueGetValue(_cPosition, kAXValueCGPointType, (void *)&cTopLeft)) {
          NSLog(@"ERROR: Could not decode position");
          cTopLeft = NSMakePoint(0, 0);
        }
      } else {
        NSLog(@"ERROR: Could not fetch position");
        cTopLeft = NSMakePoint(0, 0);
      }

      if (AXUIElementCopyAttributeValue((AXUIElementRef)_focusedWindow, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef *)&_cSize) == kAXErrorSuccess) {
        if (!AXValueGetValue(_cSize, kAXValueCGSizeType, (void *)&cSize)) {
          NSLog(@"ERROR: Could not decode size");
          cSize = NSMakeSize(0, 0);
        }
      } else {
        NSLog(@"ERROR: Could not fetch size");
        cSize = NSMakeSize(0, 0);
      }

      // Update position
      NSPoint thePoint = [[binding op] getTopLeftWithCurrentTopLeft:NSMakePoint(cTopLeft.x,cTopLeft.y) currentSize:NSMakeSize(cSize.width,cSize.height)];
      _position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
      if (AXUIElementSetAttributeValue((AXUIElementRef)_focusedWindow, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef *)_position) != kAXErrorSuccess) {
        NSLog(@"ERROR: Could not change position");
      }

      // Update size
      NSSize theSize = [[binding op] getDimensionsWithCurrentTopLeft:NSMakePoint(cTopLeft.x,cTopLeft.y) currentSize:NSMakeSize(cSize.width,cSize.height)];
      _size = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
      if (AXUIElementSetAttributeValue((AXUIElementRef)_focusedWindow, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef *)_size) != kAXErrorSuccess) {
        NSLog(@"ERROR: Could not change size");
      }

    } else {
      NSLog(@"ERROR: Could not fetch focused window");
    }
  }

  return noErr;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
}

- (void)awakeFromNib {
  NSMenuItem *loadConfigItem = [statusMenu insertItemWithTitle:@"Load Config" action:@selector(reconfig) keyEquivalent:@"" atIndex:0];
  [loadConfigItem setTarget:self];

  statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength] retain];
  [statusItem setMenu:statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"icon_16x16x32"]];
  [statusItem setHighlightMode:YES];

  // Read Config
  [self loadConfig];

  // Register Hot Keys
  [self registerHotKeys];
}

@end

//
//  SlateAppDelegate.h
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

@interface SlateAppDelegate : NSObject <NSApplicationDelegate> {
@private
  IBOutlet NSMenu *statusMenu;
  NSStatusItem *statusItem;
}

- (IBAction)reconfig;
- (void)loadConfig;
- (void)registerHotKeys;

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

@end

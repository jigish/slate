//
//  SlateAppDelegate.h
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
OSStatus OnHotKeyReleasedEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

@end

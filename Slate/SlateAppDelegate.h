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

@class SwitchOperation;
@class SnapshotOperation;
@class ActivateSnapshotOperation;
@class DeleteSnapshotOperation;
@class HintOperation;
@class Binding;
@class GridOperation;

@interface SlateAppDelegate : NSObject <NSApplicationDelegate> {
@private
  IBOutlet NSMenu *statusMenu;
  NSMenuItem *activateSnapshotItem;
  NSMenuItem *launchOnLoginItem;
  IBOutlet NSWindow *windowInfo;
  IBOutlet NSWindow *configHelper;
  IBOutlet NSTextView *configHelperTextView;
  NSStatusItem *statusItem;
  NSWindowController *windowInfoController;
  NSWindowController *configHelperController;
  HintOperation *currentHintOperation;
  GridOperation *currentGridOperation;
  Binding *currentSwitchBinding;
  SnapshotOperation *menuSnapshotOperation;
  SnapshotOperation *undoSnapshotOperation;
  ActivateSnapshotOperation *menuActivateSnapshotOperation;
  DeleteSnapshotOperation *undoDeleteSnapshotOperation;
  NSInteger cmdTabBinding;
  NSInteger cmdShiftTabBinding;
  NSMutableDictionary *modalHotKeyRefs;
  NSMutableDictionary *modalIdToKey;
  NSString *currentModalKey;
  NSMutableArray *currentModalHotKeyRefs;
  BOOL hasUndoOperation;
}

@property HintOperation *currentHintOperation;
@property GridOperation *currentGridOperation;
@property Binding *currentSwitchBinding;
@property SnapshotOperation *menuSnapshotOperation;
@property SnapshotOperation *undoSnapshotOperation;
@property ActivateSnapshotOperation *menuActivateSnapshotOperation;
@property DeleteSnapshotOperation *undoDeleteSnapshotOperation;
@property (assign) NSInteger cmdTabBinding;
@property (assign) NSInteger cmdShiftTabBinding;
@property NSMutableDictionary *modalHotKeyRefs;
@property NSMutableDictionary *modalIdToKey;
@property NSString *currentModalKey;
@property NSMutableArray *currentModalHotKeyRefs;
@property (assign) BOOL hasUndoOperation;


- (IBAction)updateLaunchState;
- (IBAction)relaunch;
- (IBAction)currentWindowInfo;
- (IBAction)configurationHelper;
- (IBAction)aboutWindow;
- (IBAction)hideMenuBarIcon;
- (void)loadConfig;
- (void)registerHotKeys;
- (void)createSnapshotOperations;
- (IBAction)takeSnapshot;
- (IBAction)activateSnapshot;
- (OSStatus)timerActivateBinding:(NSTimer *)timer;
- (void)resetModalKey;
- (OSStatus)activateBinding:(EventHotKeyID)hkCom isRepeat:(BOOL)isRepeat;
- (BOOL)isInLoginItems;
- (void)addToLoginItems;
- (void)deleteFromLoginItems;
- (void)setLaunchOnLoginItemStatus;

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);
OSStatus OnHotKeyReleasedEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);
OSStatus OnModifiersChangedEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

@end

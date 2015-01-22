//
//  RunningApplications.h
//  Slate
//
//  Created by Jigish Patel on 3/22/12.
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

#import <Foundation/Foundation.h>

typedef int CGSConnectionID;
CG_EXTERN CGSConnectionID CGSMainConnectionID(void);
bool CGSEventIsAppUnresponsive(CGSConnectionID cid, const ProcessSerialNumber *psn);

@interface RunningApplications : NSObject <NSFastEnumeration> {
  NSMutableArray *apps;
  NSMutableDictionary *appNameToApp;
  NSMutableArray *windows;
  NSMutableDictionary *appToWindows;
  NSMutableDictionary *titleToWindow;
  NSInteger nextWindowNumber;
  NSMutableArray *unusedWindowNumbers;
  NSMutableDictionary *pidToObserver;
}

@property NSMutableArray *apps;
@property NSMutableDictionary *appNameToApp;
@property NSMutableArray *windows;
@property NSMutableDictionary *appToWindows;
@property NSMutableDictionary *titleToWindow;
@property (assign) NSInteger nextWindowNumber;
@property NSMutableArray *unusedWindowNumbers;
@property NSMutableDictionary *pidToObserver;

+ (RunningApplications *)getInstance;
+ (BOOL)isAppSelectable:(NSRunningApplication *)app;
+ (NSRunningApplication *)focusedApp;

- (void)pruneWindows;
- (NSArray *)windowIdsForTitle:(NSString *)title;

@end

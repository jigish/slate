//
//  SwitchOperation.h
//  Slate
//
//  Created by Jigish Patel on 3/9/12.
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

#import "Operation.h"
#import <Carbon/Carbon.h>

@interface SwitchOperation : Operation {
  NSMutableArray *switchers;
  NSMutableArray *switchersToViews;
  UInt32 modifiers;
  UInt32 backKeyCode;
  EventHotKeyRef backHotKeyRef;
  UInt32 quitKeyCode;
  EventHotKeyRef quitHotKeyRef;
  UInt32 fquitKeyCode;
  EventHotKeyRef fquitHotKeyRef;
  UInt32 hideKeyCode;
  EventHotKeyRef hideHotKeyRef;
}

@property (assign) UInt32 modifiers;

- (void)activateSwitchKey:(EventHotKeyID)key isRepeat:(BOOL)isRepeat;
- (BOOL)modifiersChanged:(UInt32)was new:(UInt32)new;
+ (id)switchOperationFromString:(NSString *)hintOperation;

@end

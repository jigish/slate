//
//  Binding.h
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
#import <Foundation/Foundation.h>

@class Operation;

@interface Binding : NSObject {
@private
  Operation *op;
  UInt32 keyCode;
  UInt32 modifiers;
  NSNumber *modalKey;
  UInt32 modalModifiers;
  EventHotKeyRef hotKeyRef;
  BOOL repeat;
  BOOL toggle;
}

@property  Operation *op;
@property (assign) UInt32 keyCode;
@property (assign) UInt32 modifiers;
@property NSNumber *modalKey;
@property (assign) UInt32 modalModifiers;
@property (assign) EventHotKeyRef hotKeyRef;
@property (assign) BOOL repeat;
@property (assign) BOOL toggle;

+ (NSDictionary *)asciiToCodeDict;
- (id)initWithString:(NSString *)binding;
- (id)initWithKeystroke:(NSString*)keystroke operation:(Operation*)op_ repeat:(BOOL)repeat_;
- (BOOL)doOperation;
- (NSString *)modalHashKey;
+ (NSArray *)modalHashKeyToKeyAndModifiers:(NSString *)modalHashKey;
+ (NSArray *)getKeystrokeFromString:(NSString *)keystroke;

@end

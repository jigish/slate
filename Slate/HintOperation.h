//
//  HintOperation.h
//  Slate
//
//  Created by Jigish Patel on 3/2/12.
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

#import <Carbon/Carbon.h>

#import "Operation.h"

@interface HintOperation : Operation {
@private
  NSMutableDictionary *hints;
  NSMutableDictionary *windows;
  NSMutableDictionary *apps;
  NSMutableArray *hotkeyRefs;
  NSMutableArray *frames;
  NSTimer *hideTimer;
  AccessibilityWrapper *currentWindow;
  NSInteger currentHint;
  NSString *hintCharacters;
  BOOL ignoreHidden;
  
  BOOL spreadOnCollision;
  NSUInteger spreadSearchWidth;
  NSUInteger spreadSearchHeight;
  NSUInteger spreadPadding;
}

@property NSMutableDictionary *hints;
@property NSMutableDictionary *windows;
@property NSMutableDictionary *apps;
@property NSMutableArray *frames;
@property NSMutableArray *hotkeyRefs;
@property NSTimer *hideTimer;
@property AccessibilityWrapper *currentWindow;
@property NSInteger currentHint;
@property NSString *hintCharacters;

- (id)initWithCharacters:(NSString *)characters;
- (void)killHints;
- (void)activateHintKey:(NSInteger)hintId;
- (BOOL)collidesWithExistingHint:(NSPoint)origin;

+ (id)hintOperationFromString:(NSString *)hintOperation;

@end

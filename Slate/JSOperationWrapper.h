//
//  JSOperationWrapper.h
//  Slate
//
//  Created by Jigish Patel on 1/25/13.
//  Copyright 2013 Jigish Patel. All rights reserved.
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
#import <WebKit/WebKit.h>

@class AccessibilityWrapper;
@class ScreenWrapper;
@class Operation;

@interface JSOperationWrapper : NSObject {
  Operation *op;
}

@property (strong) Operation *op;

- (BOOL)run;
- (JSOperationWrapper *)dup:(WebScriptObject *)opts;
- (BOOL)doOperation;
- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw;

+ (JSOperationWrapper *)operation:(NSString*)name options:(WebScriptObject *)opts;
+ (JSOperationWrapper *)operationFromString:(NSString *)opString;

@end

//
//  Operation.h
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

#import <Foundation/Foundation.h>
#import "AccessibilityWrapper.h"
#import "ScreenWrapper.h"


@interface Operation : NSObject {
  NSString *opName;
  NSMutableDictionary *options;
  NSMutableDictionary *dynamicOptions;
}

@property NSString *opName;
@property NSMutableDictionary *options;
@property NSMutableDictionary *dynamicOptions;

- (BOOL)doOperation;
- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw;
- (BOOL)testOperation;
- (BOOL)testOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw;
- (BOOL)shouldTakeUndoSnapshot;
- (NSArray *)requiredOptions;
- (NSString *)checkRequiredOptions:(NSDictionary *)_options;
- (void)beforeInitOptions;
- (void)initOptions:(NSDictionary *)_options;
- (void)parseOption:(NSString *)name value:(id)value;
- (void)evalOptionsWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw;
- (void)afterEvalOptions;
- (id)dup:(NSDictionary *)_options;

+ (id)operationFromString:(NSString *)opString;
+ (id)operationWithName:(NSString *)op options:(NSDictionary *)options;
+ (BOOL)isRepeatOnHoldOp:(NSString *)op;

@end

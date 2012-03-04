//
//  ChainOperation.h
//  Slate
//
//  Created by Jigish Patel on 5/28/11.
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
#import "Operation.h"

@interface ChainOperation : Operation {
@private
  NSArray *operations;
  NSMutableDictionary *__unsafe_unretained currentOp;
}

@property  NSArray *operations;
@property (unsafe_unretained) NSMutableDictionary *currentOp;

- (BOOL)testOperation:(NSInteger)op;
- (void)afterComplete:(AccessibilityWrapper *)aw opRun:(NSInteger)op ;
- (id)initWithArray:(NSArray *)opArray;
- (NSInteger)getNextOperation:(AccessibilityWrapper *)aw;
- (void)setNextOperation:(AccessibilityWrapper *)aw nextOp:(NSNumber *)op;

+ (id)chainOperationFromString:(NSString *)chainOperation;

@end

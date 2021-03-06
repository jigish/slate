//
//  MoveOperation.h
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
#import "Operation.h"
#import "ExpressionPoint.h"


@interface MoveOperation : Operation {
@private
  ExpressionPoint *topLeft;
  ExpressionPoint *dimensions;
  NSString *monitor;
  NSInteger screenId;
}

@property ExpressionPoint *topLeft;
@property ExpressionPoint *dimensions;
@property NSString *monitor;
@property NSInteger screenId;

- (id)initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(NSString *)mon;
- (id)initWithTopLeftEP:(ExpressionPoint *)tl dimensionsEP:(ExpressionPoint *)dim screenId:(NSInteger)myScreenId;
- (NSPoint)getTopLeftWithCurrentWindowRect:(NSRect)cWindowRect newSize:(NSSize)nSize screenWrapper:(ScreenWrapper *)sw;
- (NSSize)getDimensionsWithCurrentWindowRect:(NSRect)cWindowRect screenWrapper:(ScreenWrapper *)sw;

+ (id)moveOperation;
+ (id)moveOperationFromString:(NSString *)moveOperation;

@end

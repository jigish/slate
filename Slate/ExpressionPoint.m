//
//  ExpressionPoint.m
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

#import "ExpressionPoint.h"


@implementation ExpressionPoint

@synthesize x;
@synthesize y;

- (id)init {
  self = [super init];
  if (self) {
    [self setX:@"0"];
    [self setY:@"0"];
  }

  return self;
}

- (id)initWithX: (NSString *)xVal y:(NSString *)yVal {
  self = [super init];
  if (self) {
    [self setX:xVal];
    [self setY:yVal];
  }

  return self;
}

- (void)dealloc {
  [self setX:nil];
  [self setY:nil];
  [super dealloc];
}

- (NSPoint) getPointWithDict: (NSDictionary *)values {
  return NSMakePoint([self expToInteger:x withDict:values],[self expToInteger:y withDict:values]);
}

- (NSSize) getSizeWithDict: (NSDictionary *)values {
  return NSMakeSize([self expToInteger:x withDict:values],[self expToInteger:y withDict:values]);
}

- (NSInteger) expToInteger: (NSString *)exp withDict:(NSDictionary *)values {
  if (exp != nil) {
    NSComparisonPredicate *pred = (NSComparisonPredicate *)[NSPredicate predicateWithFormat:[exp stringByAppendingString:@" == 42"]];
    NSExpression *lexp = [pred leftExpression];
    NSNumber *result = [lexp expressionValueWithObject:values context:nil];
    if (result == nil)
      @throw([NSException exceptionWithName:@"Unable to compute result" reason:exp userInfo:nil]);
    return [result integerValue];
  }
  return 0;
}

@end

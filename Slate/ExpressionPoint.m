//
//  ExpressionPoint.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

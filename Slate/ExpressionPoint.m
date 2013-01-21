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
#import "ScriptingController.h"


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

- (id)initWithX:(NSString *)xVal y:(NSString *)yVal {
  self = [super init];
  if (self) {
    [self setX:xVal];
    [self setY:yVal];
  }

  return self;
}


- (NSPoint)getPointWithDict:(NSDictionary *)values {
  return NSMakePoint([ExpressionPoint expToFloat:x withDict:values],[ExpressionPoint expToFloat:y withDict:values]);
}

- (NSSize)getSizeWithDict:(NSDictionary *)values {
  return NSMakeSize([ExpressionPoint expToFloat:x withDict:values],[ExpressionPoint expToFloat:y withDict:values]);
}

+ (NSDictionary *)evaluateJS:(NSString *)exp {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"javascript\\d+"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
  [regex enumerateMatchesInString:exp options:0 range:NSMakeRange(0, [exp length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
    for (NSUInteger i = 0; i < [match numberOfRanges]; i++) {
      NSRange r = [match rangeAtIndex:0];
      NSString *jsExp = [exp substringWithRange:r];
      NSString *key = [jsExp stringByReplacingOccurrencesOfString:@"javascript" withString:@""];
      id val = [[ScriptingController getInstance] runCallableFunction:key];
      [dict setObject:[NSString stringWithFormat:@"%@", val] forKey:jsExp];
    }
  }];
  return dict;
}

+ (float)expToFloat:(NSString *)exp withDict:(NSDictionary *)values {
  if (exp != nil) {
    // first check if there is any javascript we need to run
    NSDictionary *jsValues = [ExpressionPoint evaluateJS:exp];
    NSString *jsExp = [NSString stringWithString:exp];
    for (NSString *key in [jsValues allKeys]) {
      jsExp = [jsExp stringByReplacingOccurrencesOfString:key withString:[jsValues objectForKey:key]];
    }
    // then do the normal predicate stuff
    NSComparisonPredicate *pred = (NSComparisonPredicate *)[NSPredicate predicateWithFormat:[jsExp stringByAppendingString:@" == 42"]];
    NSExpression *lexp = [pred leftExpression];
    NSNumber *result = [lexp expressionValueWithObject:values context:nil];
    if (result == nil)
      @throw([NSException exceptionWithName:@"Unable to compute result" reason:jsExp userInfo:nil]);
    return [result floatValue];
  }
  @throw([NSException exceptionWithName:@"Expression is nil" reason:exp userInfo:nil]);
}

@end

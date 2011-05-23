//
//  ExpressionPoint.h
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ExpressionPoint : NSObject {
@private
  NSString *x;
  NSString *y;
}

@property (assign) NSString *x;
@property (assign) NSString *y;

- (id)initWithX: (NSString *)xVal y: (NSString *)yVal;

- (NSPoint) getPointWithDict: (NSDictionary *)values;
- (NSSize) getSizeWithDict: (NSDictionary *)values;

- (NSInteger) expToInteger: (NSString *)exp withDict:(NSDictionary *)values;

@end

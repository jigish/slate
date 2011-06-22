//
//  MathUtils.h
//  Slate
//
//  Created by Jigish Patel on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MathUtils : NSObject {}

+ (BOOL)isRect:(NSRect)rect1 biggerThan:(NSRect)rect2;
+ (NSRect)flipYCoordinateOfRect:(NSRect)original withReference:(NSRect)reference;
+ (NSRect)scaleRect:(NSRect)rect factor:(double)factor;
+ (NSRect)weightedIntersectionOf:(NSRect)rect1 and:(NSRect)rect2 weight:(double)weight;

@end

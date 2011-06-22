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

@end

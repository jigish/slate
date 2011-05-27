//
//  MoveOperation.h
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operation.h"
#import "ExpressionPoint.h"


@interface MoveOperation : Operation {
@private
  ExpressionPoint *topLeft;
  ExpressionPoint *dimensions;
  int monitor;
}

@property (retain) ExpressionPoint *topLeft;
@property (retain) ExpressionPoint *dimensions;
@property (assign) int monitor;

- (NSDictionary *) getScreenAndWindowValues:(NSPoint)cTopLeft currentSize:(NSSize)cSize;
- (id)initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(int)mon;

@end

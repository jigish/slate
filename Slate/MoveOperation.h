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
  NSInteger monitor;
}

@property (retain) ExpressionPoint *topLeft;
@property (retain) ExpressionPoint *dimensions;
@property (assign) NSInteger monitor;

- (NSDictionary *) getScreenAndWindowValues:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize;
- (id)initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(NSInteger)mon;
- (id) initWithTopLeft:(NSString *)tl dimensions:(NSString *)dim monitor:(NSInteger)mon moveFirst:(BOOL)mf;

@end

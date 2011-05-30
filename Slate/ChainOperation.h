//
//  ChainOperation.h
//  Slate
//
//  Created by Jigish Patel on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operation.h"

@interface ChainOperation : Operation {
  NSArray *operations;
  NSInteger currentOp;
}

@property (retain) NSArray *operations;
@property (assign) NSInteger currentOp;

- (id)initWithArray:(NSArray *)opArray;

@end

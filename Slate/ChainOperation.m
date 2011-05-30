//
//  ChainOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChainOperation.h"


@implementation ChainOperation

@synthesize operations;
@synthesize currentOp;

- (id)init {
  self = [super init];
  if (self) {
    [self setCurrentOp:0];
  }
  return self;
}

- (id)initWithArray:(NSArray *)opArray {
  self = [self init];
  
  if (self) {
    [self setCurrentOp:0];
    [self setOperations:opArray];
    [self setMoveFirst:[[operations objectAtIndex:(currentOp/2)] moveFirst]];
  }
  
  return self;
}

- (NSPoint) getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
  NSPoint topLeft = [[operations objectAtIndex:(currentOp/2)] getTopLeftWithCurrentTopLeft:cTopLeft currentSize:cSize newSize:nSize];
  if ((currentOp+1)/2 >= [operations count])
    [self setCurrentOp:0];
  else
    [self setCurrentOp:currentOp+1];
  [self setMoveFirst:[[operations objectAtIndex:(currentOp/2)] moveFirst]];
  return topLeft;
}

- (NSSize) getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize {
  NSSize dimensions = [[operations objectAtIndex:(currentOp/2)] getDimensionsWithCurrentTopLeft:cTopLeft currentSize:cSize];
  if ((currentOp+1)/2 >= [operations count])
    [self setCurrentOp:0];
  else
    [self setCurrentOp:currentOp+1];
  [self setMoveFirst:[[operations objectAtIndex:(currentOp/2)] moveFirst]];
  return dimensions;
}

- (void)dealloc {
  [self setOperations:nil];
  [super dealloc];
}

@end

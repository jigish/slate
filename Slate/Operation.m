//
//  Operation.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Operation.h"


@implementation Operation

@synthesize moveFirst;

- (id)init {
  self = [super init];
  if (self) {
    [self setMoveFirst:YES];
  }

  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (NSPoint) getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
  return NSMakePoint(0, 0);
}
- (NSSize) getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize {
  return NSMakeSize(100, 100);
}

@end

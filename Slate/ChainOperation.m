//
//  ChainOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/28/11.
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
    [self setMoveFirst:[[operations objectAtIndex:currentOp] moveFirst]];
  }
  
  return self;
}

- (NSPoint)getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
  NSPoint topLeft = [[operations objectAtIndex:currentOp] getTopLeftWithCurrentTopLeft:cTopLeft currentSize:cSize newSize:nSize];
  [self setMoveFirst:[[operations objectAtIndex:currentOp] moveFirst]];
  return topLeft;
}

- (NSSize)getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize {
  NSSize dimensions = [[operations objectAtIndex:currentOp] getDimensionsWithCurrentTopLeft:cTopLeft currentSize:cSize];
  [self setMoveFirst:[[operations objectAtIndex:currentOp] moveFirst]];
  return dimensions;
}

- (void)afterComplete {
  if (currentOp+1 >= [operations count])
    [self setCurrentOp:0];
  else
    [self setCurrentOp:currentOp+1];
  
  // TODO: figure out a way to register for window resize/close events!
}

- (void)dealloc {
  [self setOperations:nil];
  [super dealloc];
}

@end

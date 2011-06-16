//
//  ApplicationOptions.m
//  Slate
//
//  Created by Jigish Patel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ApplicationOptions.h"


@implementation ApplicationOptions

@synthesize ignoreFail;
@synthesize repeat;
@synthesize mainFirst;
@synthesize mainLast;
@synthesize alphabetical;

- (id)init {
  self = [super init];
  if (self) {
    [self setIgnoreFail:NO];
    [self setRepeat:NO];
    [self setMainFirst:NO];
    [self setMainLast:NO];
    [self setAlphabetical:NO];
  }
  return self;
}

@end

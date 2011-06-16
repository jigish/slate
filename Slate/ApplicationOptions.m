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
@synthesize sortTitle;
@synthesize titleOrder;

- (id)init {
  self = [super init];
  if (self) {
    [self setIgnoreFail:NO];
    [self setRepeat:NO];
    [self setMainFirst:NO];
    [self setMainLast:NO];
    [self setSortTitle:NO];
    [self setTitleOrder:nil];
  }
  return self;
}

@end

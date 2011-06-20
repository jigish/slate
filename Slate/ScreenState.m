//
//  ScreenState.m
//  Slate
//
//  Created by Jigish Patel on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "ScreenState.h"
#import "StringTokenizer.h"


@implementation ScreenState

@synthesize layout;
@synthesize type;
@synthesize count;
@synthesize resolutions;

- (id)init {
  self = [super init];
  if (self) {
    [self setLayout:nil];
    [self setType:TYPE_UNKNOWN];
    [self setCount:TYPE_UNKNOWN];
    [self setResolutions:nil];
  }
  return self;
}

- (id)initWithString:(NSString *)state {
  // defaultLayout <name> <screen-setup>
  self = [self init];
  if (self) {
    NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
    [StringTokenizer tokenize:state into:tokens];
    if ([tokens count] < 3) {
      [tokens release];
      return nil;
    }
    [self setLayout:[tokens objectAtIndex:1]];
    // Parse screen-setup
    //   count:NUMBER
    //   resolutions:WIDTHxHEIGHT;...
    NSArray *screenSetup = [[tokens objectAtIndex:2] componentsSeparatedByString:COLON];
    if ([screenSetup count] < 2) {
      [tokens release];
      return nil;
    }
    if ([[screenSetup objectAtIndex:0] isEqualToString:COUNT]) {
      [self setCount:[[screenSetup objectAtIndex:1] integerValue]];
      [self setType:TYPE_COUNT];
    } else if ([[screenSetup objectAtIndex:0] isEqualToString:RESOLUTIONS]) {
      [self setResolutions:[NSMutableArray arrayWithArray:[[screenSetup objectAtIndex:1] componentsSeparatedByCharactersInSet:
                                                           [NSCharacterSet characterSetWithCharactersInString:[SEMICOLON stringByAppendingString:COMMA]]]]];
      [resolutions sortUsingSelector:@selector(compare:)];
      [self setType:TYPE_RESOLUTIONS];
    } else {
      [tokens release];
      return nil;
    }
    [tokens release];
  }
  return self;
}

- (void)dealloc {
  [self setLayout:nil];
  [self setResolutions:nil];
  [super dealloc];
}

@end

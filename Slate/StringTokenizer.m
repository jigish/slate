//
//  StringTokenizer.m
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StringTokenizer.h"


@implementation StringTokenizer

+ (BOOL)isSpaceChar:(unichar)c {
  return [[NSCharacterSet whitespaceCharacterSet] characterIsMember:c];
}

+ (NSArray *)tokenize:(NSString *)s {
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
  NSMutableString *token = [[NSMutableString alloc] initWithCapacity:10];
  for (NSInteger i = 0; i < [s length]; i++) {
    if ([self isSpaceChar:[s characterAtIndex:i]]) {
      if (![token isEqualToString:@""]) {
        [array addObject:[NSString stringWithString:token]];
        [token release];
        token = [[NSMutableString alloc] initWithCapacity:10];
      }
    } else {
      [token appendFormat:@"%C", [s characterAtIndex:i]];
    }
  }
  if (![token isEqualToString:@""]) {
    [array addObject:[NSString stringWithString:token]];
  }
  [token release];
  return array;
}

+ (NSArray *)tokenize:(NSString *)s maxTokens:(NSInteger) maxTokens {
  if (maxTokens <=1) {
    return [NSArray arrayWithObject:s];
  }
  NSInteger numTokens = 0;
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
  NSMutableString *token = [[NSMutableString alloc] initWithCapacity:10];
  for (NSInteger i = 0; i < [s length]; i++) {
    if ([self isSpaceChar:[s characterAtIndex:i]]) {
      if (![token isEqualToString:@""] && numTokens < (maxTokens-1)) {
        numTokens++;
        [array addObject:[NSString stringWithString:token]];
        [token release];
        token = [[NSMutableString alloc] initWithCapacity:10];
      } else if (numTokens >= (maxTokens-1)) {
        [token appendFormat:@"%C", [s characterAtIndex:i]];
      }
    } else {
      [token appendFormat:@"%C", [s characterAtIndex:i]];
    }
  }
  if (![token isEqualToString:@""]) {
    [array addObject:[NSString stringWithString:token]];
  }
  [token release];
  return array;
}

@end

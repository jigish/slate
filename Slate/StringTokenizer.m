//
//  StringTokenizer.m
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
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

#import "StringTokenizer.h"


@implementation StringTokenizer

+ (BOOL)isSpaceChar:(unichar)c {
  return [[NSCharacterSet whitespaceCharacterSet] characterIsMember:c];
}

+ (BOOL)isQuoteChar:(unichar)c quoteChars:(NSCharacterSet *)quotes {
  return [quotes characterIsMember:c];
}

+ (void)tokenize:(NSString *)s into:(NSMutableArray *)array {
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
}

+ (void)tokenize:(NSString *)s into:(NSMutableArray *)array maxTokens:(NSInteger)maxTokens {
  if (maxTokens <=1) {
    [array addObject:s];
  }
  NSInteger numTokens = 0;
  NSMutableString *token = [[NSMutableString alloc] initWithCapacity:10];
  for (NSInteger i = 0; i < [s length]; i++) {
    if ([self isSpaceChar:[s characterAtIndex:i]]) {
      if (![token isEqualToString:@""] && numTokens < (maxTokens-1)) {
        numTokens++;
        [array addObject:[NSString stringWithString:token]];
        [token release];
        token = [[NSMutableString alloc] initWithCapacity:10];
      } else if (numTokens >= (maxTokens-1)) {
        if ([token isEqualToString:@""] && [self isSpaceChar:[s characterAtIndex:i]]) continue;
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
}

+ (void)tokenize:(NSString *)s into:(NSMutableArray *)array maxTokens:(NSInteger)maxTokens quoteChars:(NSCharacterSet *)quotes {
  if (maxTokens <=1) {
    [array addObject:s];
  }
  NSInteger numTokens = 0;
  NSMutableString *token = [[NSMutableString alloc] initWithCapacity:10];
  BOOL quoteSeen = NO;
  for (NSInteger i = 0; i < [s length]; i++) {
    if ([self isSpaceChar:[s characterAtIndex:i]]) {
      if (![token isEqualToString:@""] && numTokens < (maxTokens-1) && !quoteSeen) {
        numTokens++;
        [array addObject:[NSString stringWithString:token]];
        [token release];
        token = [[NSMutableString alloc] initWithCapacity:10];
      } else if (numTokens >= (maxTokens-1) || quoteSeen) {
        [token appendFormat:@"%C", [s characterAtIndex:i]];
      }
    } else if (numTokens >= (maxTokens-1)) {
      [token appendFormat:@"%C", [s characterAtIndex:i]];
    } else if ([self isQuoteChar:[s characterAtIndex:i] quoteChars:quotes]) {
      quoteSeen = !quoteSeen;
    } else {
      [token appendFormat:@"%C", [s characterAtIndex:i]];
    }
  }
  if (![token isEqualToString:@""]) {
    [array addObject:[NSString stringWithString:token]];
  }
  [token release];
}

+ (void)firstToken:(NSString *)s into:(NSMutableString *)token {
  for (NSInteger i = 0; i < [s length]; i++) {
    if ([self isSpaceChar:[s characterAtIndex:i]]) {
      if (![token isEqualToString:@""]) {
        return;
      }
    } else {
      [token appendFormat:@"%C", [s characterAtIndex:i]];
    }
  }
}

@end

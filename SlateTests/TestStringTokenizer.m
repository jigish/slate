//
//  TestStringTokenizer.m
//  Slate
//
//  Created by Jigish Patel on 10/16/12.
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

#import "TestStringTokenizer.h"
#import "StringTokenizer.h"

@implementation TestStringTokenizer

/*
 + (void)tokenize:(NSString *)s into:(NSMutableArray *)array;
 + (void)tokenize:(NSString *)s into:(NSMutableArray *)array maxTokens:(NSInteger)maxTokens;
 + (void)tokenize:(NSString *)s into:(NSMutableArray *)array maxTokens:(NSInteger)maxTokens quoteChars:(NSCharacterSet *)quotes;
 + (void)firstToken:(NSString *)s into:(NSMutableString *)token;
 + (NSString *)removeQuotes:(NSString *)s quoteChars:(NSCharacterSet *)quoteChars;
*/

- (void)testIsSpaceChar {
  XCTAssertTrue([StringTokenizer isSpaceChar:' '], @"work.");
  XCTAssertTrue([StringTokenizer isSpaceChar:'\t'], @"work.");
}

- (void)testIsQuoteChar {
  NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@""];
  XCTAssertFalse([StringTokenizer isQuoteChar:'"' quoteChars:cs], @"stuff");
  cs = [NSCharacterSet characterSetWithCharactersInString:@"\""];
  XCTAssertTrue([StringTokenizer isQuoteChar:'"' quoteChars:cs], @"stuff");
  cs = [NSCharacterSet characterSetWithCharactersInString:@"'"];
  XCTAssertFalse([StringTokenizer isQuoteChar:'"' quoteChars:cs], @"stuff");
  cs = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
  XCTAssertTrue([StringTokenizer isQuoteChar:'"' quoteChars:cs], @"stuff");
  cs = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
  XCTAssertTrue([StringTokenizer isQuoteChar:'\'' quoteChars:cs], @"stuff");
}

- (void)testTokenizeInto {
  NSMutableArray *arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi tokenize\t\t  me" into:arr];
  XCTAssertTrue([arr count] == 3, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize"], @"wtf");
  XCTAssertTrue([[arr objectAtIndex:2] isEqualToString:@"me"], @"OMGWTFBBQ");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hitokenizeme" into:arr];
  XCTAssertTrue([arr count] == 1, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hitokenizeme"], @"work damnit");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"" into:arr];
  XCTAssertTrue([arr count] == 0, @"shit should work");
}

- (void)testTokenizeIntoQuoteChars {
  NSMutableArray *arr = [NSMutableArray array];
  NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
  [StringTokenizer tokenize:@"hi tokenize\t\t  me" into:arr quoteChars:cs];
  XCTAssertTrue([arr count] == 3, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize"], @"wtf");
  XCTAssertTrue([[arr objectAtIndex:2] isEqualToString:@"me"], @"OMGWTFBBQ");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"" into:arr quoteChars:cs];
  XCTAssertTrue([arr count] == 0, @"shit should work");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi 'tokenize\t\t  me'" into:arr maxTokens:100 quoteChars:cs];
  XCTAssertTrue([arr count] == 2, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize\t\t  me"], @"wtf");
}

- (void)testTokenizeIntoMaxTokens {
  NSMutableArray *arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi tokenize\t\t  me" into:arr maxTokens:100];
  XCTAssertTrue([arr count] == 3, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize"], @"wtf");
  XCTAssertTrue([[arr objectAtIndex:2] isEqualToString:@"me"], @"OMGWTFBBQ");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi tokenize\t\t  me" into:arr maxTokens:2];
  XCTAssertTrue([arr count] == 2, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize\t\t  me"], @"wtf");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi tokenize me" into:arr maxTokens:1];
  XCTAssertTrue([arr count] == 1, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi tokenize me"], @"work damnit");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"" into:arr maxTokens:1000];
  XCTAssertTrue([arr count] == 0, @"shit should work");
}

- (void)testTokenizeIntoMaxTokensQuoteChars {
  NSMutableArray *arr = [NSMutableArray array];
  NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
  [StringTokenizer tokenize:@"hi tokenize\t\t  me" into:arr maxTokens:100 quoteChars:cs];
  XCTAssertTrue([arr count] == 3, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize"], @"wtf");
  XCTAssertTrue([[arr objectAtIndex:2] isEqualToString:@"me"], @"OMGWTFBBQ");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi tokenize\t\t  me" into:arr maxTokens:2 quoteChars:cs];
  XCTAssertTrue([arr count] == 2, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize\t\t  me"], @"wtf");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi tokenize me" into:arr maxTokens:1 quoteChars:cs];
  XCTAssertTrue([arr count] == 1, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi tokenize me"], @"work damnit");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"" into:arr maxTokens:1000 quoteChars:cs];
  XCTAssertTrue([arr count] == 0, @"shit should work");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi 'tokenize\t\t  me'" into:arr maxTokens:100 quoteChars:cs];
  XCTAssertTrue([arr count] == 2, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize\t\t  me"], @"wtf");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi 'tokenize\t\t  \"me\"'" into:arr maxTokens:100 quoteChars:cs];
  XCTAssertTrue([arr count] == 2, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize\t\t  \"me\""], @"wtf");
  arr = [NSMutableArray array];
  [StringTokenizer tokenize:@"hi 'tokenize\t\t  \"me\"'" into:arr quoteChars:cs];
  XCTAssertTrue([arr count] == 2, @"shit should work");
  XCTAssertTrue([[arr objectAtIndex:0] isEqualToString:@"hi"], @"work damnit");
  XCTAssertTrue([[arr objectAtIndex:1] isEqualToString:@"tokenize\t\t  \"me\""], @"wtf");
}

@end

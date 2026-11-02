//
//  TestNSString+Levenshtein.m
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

#import "TestNSString+Levenshtein.h"
#import "NSString+Levenshtein.h"

@implementation TestNSString_Levenshtein

- (void)testLevenshteinDistance {
  NSString *a = @"hello";
  NSString *b = @"helo";
  NSString *c = @"hallo";
  NSString *d = @"helllo";
  NSString *e = @"hldla";
  XCTAssertEqual([a levenshteinDistance:b], (float)1, @"Levenshtein Distance between hello and helo should be 1");
  XCTAssertEqual([a levenshteinDistance:c], (float)1, @"Levenshtein Distance between hello and hallo should be 1");
  XCTAssertEqual([a levenshteinDistance:d], (float)1, @"Levenshtein Distance between hello and helllo should be 1");
  XCTAssertEqual([a levenshteinDistance:e], (float)3, @"Levenshtein Distance between hello and hldlo should be 3");
}

- (void)testSequentialDistance {
  NSString *a = @"hello";
  NSString *b= @"hell";
  NSString *c = @"hallo";
  NSString *d = @"ello";
  NSString *e = @"helllo";
  NSString *f = @"heldlo";
  XCTAssertEqual([a sequentialDistance:b], (float)4, @"Sequential Distance between hello and hell should be 4");
  XCTAssertEqual([a sequentialDistance:c], (float)1, @"Sequential Distance between hello and hallo should be 1");
  XCTAssertEqual([a sequentialDistance:d], (float)0, @"Sequential Distance between hello and hallo should be 0");
  XCTAssertEqual([a sequentialDistance:e], (float)4, @"Sequential Distance between hello and ello should be 4");
  XCTAssertEqual([a sequentialDistance:f], (float)3, @"Sequential Distance between hello and heldlo should be 3");
}

@end

//
//  TestNSString+Indicies.m
//  Slate
//
//  Created by Jigish Patel on 10/1/12.
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

#import "TestNSString+Indicies.h"
#import "NSString+Indicies.h"

@implementation TestNSString_Indicies

- (void)testIndexOfString {
  NSString *test = @"hello&i%am-a$test#string";
  XCTAssertEqual([test indexOfString:@"&"], (NSInteger)5, @"index of & should be 5");
  XCTAssertEqual([test indexOfString:@"0"], (NSInteger)-1, @"index of 0 should be -1");
  XCTAssertEqual([test indexOfString:@"hello"], (NSInteger)0, @"index of hello should be 0");
  XCTAssertEqual([test indexOfString:@"g"], (NSInteger)([test length]-1), @"index of 0 should be ld", [test length]-1);
}

- (void)testIndexOfChar {
  NSString *test = @"hello&i%am-a$test#string";
  XCTAssertEqual([test indexOfChar:'&'], (NSInteger)5, @"index of & should be 5");
  XCTAssertEqual([test indexOfChar:'0'], (NSInteger)-1, @"index of 0 should be -1");
  XCTAssertEqual([test indexOfChar:'h'], (NSInteger)0, @"index of h should be 0");
  XCTAssertEqual([test indexOfChar:'g'], (NSInteger)([test length]-1), @"index of g should be %ld", [test length]-1);
}

@end

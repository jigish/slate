//
//  TestExpressionPoint.m
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

#import "TestExpressionPoint.h"
#import "ExpressionPoint.h"

@implementation TestExpressionPoint

/*
- (NSPoint)getPointWithDict:(NSDictionary *)values;
- (NSSize)getSizeWithDict:(NSDictionary *)values;

+ (float)expToFloat:(NSString *)exp withDict:(NSDictionary *)values;
*/

- (void)testInitandProperties {
  NSString *x = @"x";
  NSString *y = @"y";
  ExpressionPoint *a = [[ExpressionPoint alloc] initWithX:x y:y];
  STAssertEquals([a x], x, @"x should be x");
  STAssertEquals([a y], y, @"y should be y");
  [a setX:y];
  [a setY:x];
  STAssertEquals([a x], y, @"x should be y");
  STAssertEquals([a y], x, @"y should be x");
}

- (void)testGetPointWithDict {
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:5], @"var1",
                        [NSNumber numberWithInteger:10], @"var2",
                        [NSNumber numberWithInteger:2], @"var3", nil];
  ExpressionPoint *a = [[ExpressionPoint alloc] initWithX:@"var1+var2" y:@"var1*var2"];
  NSPoint p = [a getPointWithDict:dict];
  STAssertTrue(NSEqualPoints(p, NSMakePoint(15, 50)), @"Shit should work");
  [a setX:@"sqrt((var2/var3)*var1)+count({1,2,3})"]; // 5 + 3
  [a setY:@"var3**var2+sum({1,2,3})"]; // 1024 + 6
  p = [a getPointWithDict:dict];
  STAssertTrue(NSEqualPoints(p, NSMakePoint(8, 1030)), @"Shit should work");
  [a setX:@"min({1,2,3})+max({4,5,6})"]; // 1 + 6
  [a setY:@"average({1,2,3,4})+median({1,2,3,10,15})"]; // 2.5 + 3
  p = [a getPointWithDict:dict];
  STAssertTrue(NSEqualPoints(p, NSMakePoint(7, 5.5)), @"Shit should work");
  [a setX:@"floor(3.9)+(stddev({1,2,3,4,5}))**2"]; // 3 + 2
  [a setY:@"log(1000)+ln(exp(5))"]; // 3 + 5
  p = [a getPointWithDict:dict];
  STAssertTrue(NSEqualPoints(p, NSMakePoint(5, 8)), @"Shit should work");
  [a setX:@"ceiling(2.1)+abs(-2)"]; // 3 + 2
  [a setY:@"trunc(3.232472398472834723)"]; // 3
  p = [a getPointWithDict:dict];
  STAssertTrue(NSEqualPoints(p, NSMakePoint(5, 3)), @"Shit should work");
  [a setX:@"random()"]; // 0 <= me < 1
  [a setY:@"randomn(10)"]; // 0 <= me < 10
  p = [a getPointWithDict:dict];
  STAssertTrue(p.x >= 0 && p.x < 1 && p.y >= 0 && p.y < 10, @"Shit should work");
}

- (void)testGetSizeWithDict {
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:5], @"var1",
                        [NSNumber numberWithInteger:10], @"var2",
                        [NSNumber numberWithInteger:2], @"var3", nil];
  ExpressionPoint *a = [[ExpressionPoint alloc] initWithX:@"var1+var2" y:@"var1*var2"];
  NSSize p = [a getSizeWithDict:dict];
  STAssertTrue(NSEqualSizes(p, NSMakeSize(15, 50)), @"Shit should work");
  [a setX:@"sqrt((var2/var3)*var1)+count({1,2,3})"]; // 5 + 3
  [a setY:@"var3**var2+sum({1,2,3})"]; // 1024 + 6
  p = [a getSizeWithDict:dict];
  STAssertTrue(NSEqualSizes(p, NSMakeSize(8, 1030)), @"Shit should work");
  [a setX:@"min({1,2,3})+max({4,5,6})"]; // 1 + 6
  [a setY:@"average({1,2,3,4})+median({1,2,3,10,15})"]; // 2.5 + 3
  p = [a getSizeWithDict:dict];
  STAssertTrue(NSEqualSizes(p, NSMakeSize(7, 5.5)), @"Shit should work");
  [a setX:@"floor(3.9)+(stddev({1,2,3,4,5}))**2"]; // 3 + 2
  [a setY:@"log(1000)+ln(exp(5))"]; // 3 + 5
  p = [a getSizeWithDict:dict];
  STAssertTrue(NSEqualSizes(p, NSMakeSize(5, 8)), @"Shit should work");
  [a setX:@"ceiling(2.1)+abs(-2)"]; // 3 + 2
  [a setY:@"trunc(3.232472398472834723)"]; // 3
  p = [a getSizeWithDict:dict];
  STAssertTrue(NSEqualSizes(p, NSMakeSize(5, 3)), @"Shit should work");
  [a setX:@"random()"]; // 0 <= me < 1
  [a setY:@"randomn(10)"]; // 0 <= me < 10
  p = [a getSizeWithDict:dict];
  STAssertTrue(p.width >= 0 && p.width < 1 && p.height >= 0 && p.height < 10, @"Shit should work");
}

@end

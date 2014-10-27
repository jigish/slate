//
//  TestMathUtils.m
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

#import "TestMathUtils.h"
#import "MathUtils.h"

@implementation TestMathUtils

- (void)testIsRectBiggerThan {
  NSRect a = NSMakeRect(0, 0, 100, 100);
  NSRect b = NSMakeRect(0, 0, 200, 90);
  NSRect c = NSMakeRect(0, 0, 90, 200);
  NSRect d = NSMakeRect(0, 0, 200, 200);
  NSRect e = NSMakeRect(0, 0, 200, 1);
  NSRect f = NSMakeRect(0, 0, 1, 200);
  NSRect g = NSMakeRect(1000, 1000, 1, 1);
  NSRect h = NSMakeRect(1000, 1000, 101, 101);
  XCTAssertFalse([MathUtils isRect:a biggerThan:b], @"0,0,100,100 should be smaller than 0,0,200,90");
  XCTAssertFalse([MathUtils isRect:a biggerThan:c], @"0,0,100,100 should be smaller than 0,0,90,200");
  XCTAssertFalse([MathUtils isRect:a biggerThan:d], @"0,0,100,100 should be smaller than 0,0,200,200");
  XCTAssertTrue([MathUtils isRect:a biggerThan:e], @"0,0,100,100 should be bigger than 0,0,200,1");
  XCTAssertTrue([MathUtils isRect:a biggerThan:f], @"0,0,100,100 should be bigger than 0,0,1,200");
  XCTAssertTrue([MathUtils isRect:a biggerThan:g], @"0,0,100,100 should be bigger than 1000,1000,1,1");
  XCTAssertFalse([MathUtils isRect:a biggerThan:h], @"0,0,100,100 should be smaller than 1000,1000,101,101");
}

- (void)testFlipYCoordinateOfRectWithReference {
  NSRect a = NSMakeRect(0, 0, 100, 100);
  NSRect b = NSMakeRect(0, 0, 1000, 1000);
  NSRect flipped = [MathUtils flipYCoordinateOfRect:a withReference:b];
  XCTAssertTrue(NSEqualRects(flipped, NSMakeRect(0,900,100,100)), @"Flipping should work");
  a = NSMakeRect(0,-100, 100, 1500);
  b = NSMakeRect(0, 0, 1000, 1000);
  flipped = [MathUtils flipYCoordinateOfRect:a withReference:b];
  XCTAssertTrue(NSEqualRects(flipped, NSMakeRect(0,-400,100,1500)), @"Flipping should work");
}

- (void)testScaleRectFactor {
  NSRect a = NSMakeRect(100, 200, 100, 200);
  NSRect scaled = [MathUtils scaleRect:a factor:2.0];
  XCTAssertTrue(NSEqualRects(scaled, NSMakeRect(100,200,200,400)), @"Scaling should work");
  a = NSMakeRect(100, 200, 100, 200);
  scaled = [MathUtils scaleRect:a factor:0.5];
  XCTAssertTrue(NSEqualRects(scaled, NSMakeRect(100,200,50,100)), @"Scaling should work");
  a = NSMakeRect(100, 200, 100, 200);
  scaled = [MathUtils scaleRect:a factor:2.5];
  XCTAssertTrue(NSEqualRects(scaled, NSMakeRect(100,200,250,500)), @"Scaling should work");
}

- (void)testWeightedIntersectionOfAndWeight {
  NSRect a = NSMakeRect(0, 0, 100, 100);
  NSRect b = NSMakeRect(1000, 1000, 100, 100);
  NSRect c = NSMakeRect(0, 0, 50, 50);
  NSRect d = NSMakeRect(50, 50, 100, 100);
  NSRect intersection = [MathUtils weightedIntersectionOf:a and:b weight:1];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(0, 0, 0, 0)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:b weight:2];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(0, 0, 0, 0)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:b weight:0.5];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(0, 0, 0, 0)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:c weight:1];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(0, 0, 50, 50)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:c weight:2];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(0, 0, 100, 100)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:c weight:0.5];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(0, 0, 25, 25)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:d weight:1];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(50, 50, 50, 50)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:d weight:2];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(50, 50, 100, 100)), @"Weighted Intersection should work");
  intersection = [MathUtils weightedIntersectionOf:a and:d weight:0.5];
  XCTAssertTrue(NSEqualRects(intersection, NSMakeRect(50, 50, 25, 25)), @"Weighted Intersection should work");
}

@end

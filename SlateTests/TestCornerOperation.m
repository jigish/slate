//
//  TestCornerOperation.m
//  Slate
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

#import <XCTest/XCTest.h>
#import "CornerOperation.h"
#import "MoveOperation.h"
#import "ExpressionPoint.h"

@interface TestCornerOperation : XCTestCase
@end

@implementation TestCornerOperation

- (NSDictionary *)screen {
  return @{@"screenOriginX": @0, @"screenOriginY": @0, @"screenSizeX": @1000, @"screenSizeY": @1000};
}

- (void)testBottomRightResizeSubtractsWholeExpressions {
  MoveOperation *op = [CornerOperation cornerOperationFromString:@"corner bottom-right resize:screenSizeX/2-20;screenSizeY/2+20"];
  NSPoint tl = [[op topLeft] getPointWithDict:[self screen]];
  XCTAssertEqual(tl.x, 520);
  XCTAssertEqual(tl.y, 480);
}

- (void)testTopRightResizeSubtractsWholeExpression {
  MoveOperation *op = [CornerOperation cornerOperationFromString:@"corner top-right resize:screenSizeX/2-20;screenSizeY"];
  XCTAssertEqual([[op topLeft] getPointWithDict:[self screen]].x, 520);
}

- (void)testBottomLeftResizeSubtractsWholeExpression {
  MoveOperation *op = [CornerOperation cornerOperationFromString:@"corner bottom-left resize:screenSizeX;screenSizeY/2-20"];
  XCTAssertEqual([[op topLeft] getPointWithDict:[self screen]].y, 520);
}

@end

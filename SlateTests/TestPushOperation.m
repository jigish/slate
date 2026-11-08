//
//  TestPushOperation.m
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
#import "PushOperation.h"
#import "MoveOperation.h"
#import "ExpressionPoint.h"

@interface TestPushOperation : XCTestCase
@end

@implementation TestPushOperation

- (NSDictionary *)screen {
  return @{@"screenOriginX": @0, @"screenOriginY": @0, @"screenSizeX": @1000, @"screenSizeY": @1000};
}

- (void)testPushDownBarResizeSubtractsWholeExpression {
  MoveOperation *op = [PushOperation pushOperationFromString:@"push down bar-resize:screenSizeY/2-20"];
  XCTAssertEqual([[op topLeft] getPointWithDict:[self screen]].y, 520);
}

- (void)testPushRightBarResizeSubtractsWholeExpression {
  MoveOperation *op = [PushOperation pushOperationFromString:@"push right bar-resize:screenSizeX/2+20"];
  XCTAssertEqual([[op topLeft] getPointWithDict:[self screen]].x, 480);
}

@end

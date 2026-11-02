//
//  TestShellOperation.m
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

#import "TestShellOperation.h"
#import "ShellOperation.h"

@implementation TestShellOperation

- (void)testAbsoluteCommandAcceptsAbsolutePath {
  XCTAssertEqualObjects([ShellOperation absoluteCommand:@"/usr/bin/open"], @"/usr/bin/open");
}

- (void)testAbsoluteCommandExpandsTilde {
  NSString *expected = [NSHomeDirectory() stringByAppendingPathComponent:@"bin/tool"];
  XCTAssertEqualObjects([ShellOperation absoluteCommand:@"~/bin/tool"], expected);
}

- (void)testAbsoluteCommandRejectsRelativeCommands {
  XCTAssertThrowsSpecificNamed([ShellOperation absoluteCommand:@"open"], NSException, @"Invalid Shell Command");
  XCTAssertThrowsSpecificNamed([ShellOperation absoluteCommand:@"./open"], NSException, @"Invalid Shell Command");
  XCTAssertThrowsSpecificNamed([ShellOperation absoluteCommand:@"bin/open"], NSException, @"Invalid Shell Command");
}

- (void)testShellDirectiveWithAbsoluteCommand {
  ShellOperation *op = [ShellOperation shellOperationFromString:@"shell wait '/usr/bin/open -a Safari'"];
  XCTAssertEqualObjects([op command], @"/usr/bin/open");
  XCTAssertEqualObjects([op args], (@[@"-a", @"Safari"]));
  XCTAssertTrue([op waitForExit]);
}

- (void)testShellDirectiveWithRelativeCommandIsRejected {
  XCTAssertThrowsSpecificNamed([ShellOperation shellOperationFromString:@"shell 'open -a Safari'"], NSException, @"Invalid Shell Command");
}

@end

//
//  TestShellUtils.m
//  Slate
//
//  Created by Jigish Patel on 10/17/12.
//  Copyright 2012 Jigish Patel. All rights reserved.
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

#import "TestShellUtils.h"
#import "ShellUtils.h"
#import "ShellOperation.h"

@implementation TestShellUtils

- (void)testCommandExists {
  XCTAssertTrue([ShellUtils commandExists:@"command"], @"command should exist");
  XCTAssertTrue([ShellUtils commandExists:@"/usr/bin/command"], @"/usr/bin/command should exist");
  XCTAssertFalse([ShellUtils commandExists:@"/usr/command"], @"/usr/command should not exist");
  XCTAssertFalse([ShellUtils commandExists:@"oogabooga"], @"oogabooga should not exist");
  XCTAssertFalse([ShellUtils commandExists:nil], @"nil should not exist");
  XCTAssertFalse([ShellUtils commandExists:@""], @"empty string should not exist");
}

- (void)testRun {
  NSTask *task = [ShellUtils run:@"/bin/ls" args:[NSArray arrayWithObject:@"-al"] wait:YES path:nil];
  XCTAssertFalse([task isRunning], @"Task should no longer be running");
  XCTAssertEqual([task terminationStatus], 0, @"Status should be 0");
  task = [ShellUtils run:@"/usr/bin/find" args:[NSArray arrayWithObjects:@"/", @"-name", @"\"hello\"", nil] wait:NO path:@"/usr"];
  XCTAssertTrue([task isRunning], @"Task should still be running");
  XCTAssertTrue([[task currentDirectoryPath] isEqualToString:@"/usr"], @"current path should be /usr");
  [task terminate];
  [task waitUntilExit];
  XCTAssertFalse([task isRunning], @"Task should no longer be running");
  XCTAssertEqual([task terminationStatus], 15, @"Status should be 15");
}

- (void)testRunWithQuotedArgs {
  NSString *result = [ShellUtils run:@"/bin/echo 'with single' \"and double quotes\"" wait:YES path:@"/"];
  NSError *err = nil;
  NSRegularExpression *testRegex = [NSRegularExpression regularExpressionWithPattern:@"with single and double quotes" options:0 error:&err];
  int found = [testRegex numberOfMatchesInString:result options:0 range:NSMakeRange(0, [result length])];
  XCTAssertEqual(found, 1, @"Result should include all strings");
}

- (void)testShellOperationFromStringWithQuotesAndSpaces {
	id operation = [ShellOperation shellOperationFromString:@"shell '/usr/bin/open -a \"/Applications/App Store.app\"'"];
	NSUInteger argumentCount = [[operation args] count];
	
	XCTAssertEqual(argumentCount, 2, @"The shell operation must only contain two arguments");
}

@end

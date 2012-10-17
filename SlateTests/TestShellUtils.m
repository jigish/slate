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

@implementation TestShellUtils

- (void)testCommandExists {
  STAssertTrue([ShellUtils commandExists:@"command"], @"command should exist");
  STAssertTrue([ShellUtils commandExists:@"/usr/bin/command"], @"/usr/bin/command should exist");
  STAssertFalse([ShellUtils commandExists:@"/usr/command"], @"/usr/command should not exist");
  STAssertFalse([ShellUtils commandExists:@"oogabooga"], @"oogabooga should not exist");
  STAssertFalse([ShellUtils commandExists:nil], @"nil should not exist");
  STAssertFalse([ShellUtils commandExists:@""], @"empty string should not exist");
}

- (void)testRun {
  NSTask *task = [ShellUtils run:@"/bin/ls" args:[NSArray arrayWithObject:@"-al"] wait:YES path:nil];
  STAssertFalse([task isRunning], @"Task should no longer be running");
  STAssertEquals([task terminationStatus], 0, @"Status should be 0");
  task = [ShellUtils run:@"/usr/bin/find" args:[NSArray arrayWithObjects:@"/", @"-name", @"\"hello\"", nil] wait:NO path:@"/usr"];
  STAssertTrue([task isRunning], @"Task should still be running");
  STAssertTrue([[task currentDirectoryPath] isEqualToString:@"/usr"], @"current path should be /usr");
  [task terminate];
  [task waitUntilExit];
  STAssertFalse([task isRunning], @"Task should no longer be running");
  STAssertEquals([task terminationStatus], 15, @"Status should be 15");
}

@end

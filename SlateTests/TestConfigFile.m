//
//  TestConfigFile.m
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

#import "TestConfigFile.h"
#import "ConfigFile.h"

@implementation TestConfigFile {
  NSString *dir;
}

- (void)setUp {
  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
  [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)tearDown {
  [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
}

- (NSString *)writeFile:(NSString *)name contents:(NSString *)contents permissions:(short)permissions {
  NSString *path = [dir stringByAppendingPathComponent:name];
  [contents writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
  [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions: @(permissions)} ofItemAtPath:path error:nil];
  return path;
}

- (void)testReadsFileOwnedByUserAndNotWritableByOthers {
  NSError *error = nil;
  NSString *path = [self writeFile:@".slate" contents:@"bind a:ctrl relaunch\n" permissions:0644];
  XCTAssertEqualObjects([ConfigFile contentsOfFileAtPath:path error:&error], @"bind a:ctrl relaunch\n");
  XCTAssertNil(error);
}

- (void)testRejectsGroupWritableFile {
  NSError *error = nil;
  NSString *path = [self writeFile:@".slate" contents:@"x" permissions:0664];
  XCTAssertNil([ConfigFile contentsOfFileAtPath:path error:&error]);
  XCTAssertEqual([error code], ConfigFileErrorWritableByOthers);
}

- (void)testRejectsWorldWritableFile {
  NSError *error = nil;
  NSString *path = [self writeFile:@".slate" contents:@"x" permissions:0646];
  XCTAssertNil([ConfigFile contentsOfFileAtPath:path error:&error]);
  XCTAssertEqual([error code], ConfigFileErrorWritableByOthers);
}

- (void)testRejectsDirectory {
  NSError *error = nil;
  XCTAssertNil([ConfigFile contentsOfFileAtPath:dir error:&error]);
  XCTAssertEqual([error code], ConfigFileErrorNotRegularFile);
}

- (void)testFollowsSymlinkAndChecksTarget {
  NSError *error = nil;
  NSString *target = [self writeFile:@"dotfiles-slate" contents:@"ok" permissions:0644];
  NSString *link = [dir stringByAppendingPathComponent:@".slate"];
  [[NSFileManager defaultManager] createSymbolicLinkAtPath:link withDestinationPath:target error:nil];
  XCTAssertEqualObjects([ConfigFile contentsOfFileAtPath:link error:&error], @"ok");

  [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions: @(0666)} ofItemAtPath:target error:nil];
  XCTAssertNil([ConfigFile contentsOfFileAtPath:link error:&error]);
  XCTAssertEqual([error code], ConfigFileErrorWritableByOthers);
}

- (void)testMissingFileIsReportedAsMissing {
  NSError *error = nil;
  XCTAssertNil([ConfigFile contentsOfFileAtPath:[dir stringByAppendingPathComponent:@"nope"] error:&error]);
  XCTAssertTrue([ConfigFile isMissingFileError:error]);

  NSString *path = [self writeFile:@".slate" contents:@"x" permissions:0666];
  [ConfigFile contentsOfFileAtPath:path error:&error];
  XCTAssertFalse([ConfigFile isMissingFileError:error]);
}

@end

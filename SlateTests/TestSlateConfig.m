//
//  TestSlateConfig.m
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
#import "SlateConfig.h"
#import "Constants.h"

@interface TestSlateConfig : XCTestCase
@end

@implementation TestSlateConfig {
  SlateConfig *config;
}

- (void)setUp {
  config = [[SlateConfig alloc] init];
}

- (void)testAppConfigFallsBackToGlobalWhenAppHasNoConfigs {
  [config setConfig:SNAPSHOT_TITLE_MATCH to:SEQUENTIAL];
  XCTAssertEqualObjects([config getConfig:SNAPSHOT_TITLE_MATCH app:@"App"], SEQUENTIAL);
}

- (void)testAppConfigFallsBackToGlobalWhenAppLacksKey {
  [config setConfig:SNAPSHOT_TITLE_MATCH to:SEQUENTIAL];
  [[config appConfigs] setObject:[NSMutableDictionary dictionaryWithObject:@"x" forKey:@"otherKey"] forKey:@"App"];
  XCTAssertEqualObjects([config getConfig:SNAPSHOT_TITLE_MATCH app:@"App"], SEQUENTIAL);
}

- (void)testAppConfigOverridesGlobal {
  [config setConfig:SNAPSHOT_TITLE_MATCH to:SEQUENTIAL];
  [[config appConfigs] setObject:[NSMutableDictionary dictionaryWithObject:@"levenshtein" forKey:SNAPSHOT_TITLE_MATCH] forKey:@"App"];
  XCTAssertEqualObjects([config getConfig:SNAPSHOT_TITLE_MATCH app:@"App"], @"levenshtein");
}

- (void)testAppConfigFallsBackToDefaultWhenNothingSet {
  XCTAssertEqualObjects([config getConfig:SNAPSHOT_TITLE_MATCH app:@"App"], [config getConfigDefault:SNAPSHOT_TITLE_MATCH]);
}

@end

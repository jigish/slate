//
//  TestJSConfig.m
//  Slate
//
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


#import "TestJSConfig.h"
#import "SlateConfig.h"
#import "Binding.h"
#import "MoveOperation.h"
#import "JSOperation.h"

@implementation TestJSConfig

- (NSString *)writeConfig:(NSString *)js {
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.slate.js", [[NSUUID UUID] UUIDString]]];
  NSError *error = nil;
  XCTAssertTrue([js writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error], @"%@", error);
  [self addTeardownBlock:^{ [[NSFileManager defaultManager] removeItemAtPath:path error:nil]; }];
  return path;
}

- (void)testConfigAllSetsValuesAndFunctions {
  NSString *path = [self writeConfig:
    @"slate.configAll({ nudgePercentOf: 'screenSize', windowHintsFontSize: function() { return 6 * 7; } });"];
  SlateConfig *config = [SlateConfig getInstance];

  XCTAssertTrue([config loadConfigFileWithPath:path]);
  XCTAssertEqualObjects([config getConfig:@"nudgePercentOf"], @"screenSize");
  XCTAssertEqualObjects([config getConfig:@"windowHintsFontSize"], @"42", @"JS function config is evaluated on read");
}

- (void)testBindRegistersNativeAndFunctionOperations {
  NSString *path = [self writeConfig:
    @"slate.bind('right:ctrl;cmd', slate.operation('move', { x: 'screenOriginX', y: 'screenOriginY', width: 'screenSizeX/2', height: 'screenSizeY' }));\n"
     "slate.bind('left:ctrl;cmd', function(win) { });"];
  SlateConfig *config = [SlateConfig getInstance];
  NSUInteger before = [[config bindings] count];

  XCTAssertTrue([config loadConfigFileWithPath:path]);

  NSArray *added = [[config bindings] subarrayWithRange:NSMakeRange(before, [[config bindings] count] - before)];
  XCTAssertEqual([added count], (NSUInteger)2);
  XCTAssertTrue([[[added objectAtIndex:0] op] isKindOfClass:[MoveOperation class]]);
  XCTAssertTrue([[[added objectAtIndex:1] op] isKindOfClass:[JSOperation class]]);
}

@end

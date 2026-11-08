//
//  TestScreenWrapper.m
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
#import "ScreenWrapper.h"
#import "Constants.h"

// Stands in for NSScreen: ScreenWrapper only reads frame and visibleFrame.
@interface FakeScreen : NSObject
@property NSRect frame;
@property NSRect visibleFrame;
+ (instancetype)screenWithFrame:(NSRect)frame;
@end

@implementation FakeScreen
+ (instancetype)screenWithFrame:(NSRect)frame {
  FakeScreen *screen = [[FakeScreen alloc] init];
  [screen setFrame:frame];
  [screen setVisibleFrame:frame];
  return screen;
}
@end

@interface TestScreenWrapper : XCTestCase
@end

@implementation TestScreenWrapper {
  ScreenWrapper *sw;
  NSRect windowOnMainScreen;
}

// Main screen on top, second screen below it and offset to the right (so left-to-right order matches default order) (Cocoa coordinates: y grows upwards).
- (void)setUp {
  NSArray *screens = @[[FakeScreen screenWithFrame:NSMakeRect(0, 0, 1000, 800)],
                       [FakeScreen screenWithFrame:NSMakeRect(500, -800, 1000, 800)]];
  sw = [[ScreenWrapper alloc] initWithScreens:screens];
  windowOnMainScreen = NSMakeRect(10, 10, 100, 100);
}

- (void)tearDown {
  [ScreenWrapper updateLeftToRightToDefault:[NSScreen screens]];
}

- (void)testDownRefersToScreenBelow {
  XCTAssertEqual([sw getScreenId:@"down" windowRect:windowOnMainScreen], 1);
}

- (void)testBelowRefersToScreenBelow {
  XCTAssertEqual([sw getScreenId:@"below" windowRect:windowOnMainScreen], 1);
}

- (void)testOrderedEqualToScreenCountIsIgnored {
  XCTAssertNoThrow([sw getScreenId:@"ordered:2" windowRect:windowOnMainScreen]);
  XCTAssertEqual([sw getScreenId:@"ordered:2" windowRect:windowOnMainScreen], ID_IGNORE_SCREEN);
}

@end

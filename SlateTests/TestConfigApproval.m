//
//  TestConfigApproval.m
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

#import "TestConfigApproval.h"
#import "ConfigApproval.h"
#import "ConfigReview.h"
#import "SlateConfig.h"

@interface FakeApprovalStore : NSObject <ConfigApprovalStore>
@property NSString *digest;
@property BOOL persistent;
@end

@implementation FakeApprovalStore
- (NSString *)approvedDigest { return self.digest; }
- (void)storeApprovedDigest:(NSString *)digest { if (self.persistent) self.digest = digest; }
- (BOOL)isPersistent { return self.persistent; }
@end

@interface FakeApprover : NSObject <ConfigApprover>
@property BOOL answer;
@property NSUInteger asked;
@property ConfigReview *lastReview;
@end

@implementation FakeApprover
- (BOOL)approveConfig:(ConfigReview *)review persistent:(BOOL)persistent {
  self.asked++;
  self.lastReview = review;
  return self.answer;
}
@end

@implementation TestConfigApproval {
  FakeApprovalStore *store;
  FakeApprover *approver;
  ConfigApproval *approval;
  NSString *dir;
}

- (void)setUp {
  store = [[FakeApprovalStore alloc] init];
  store.persistent = YES;
  approver = [[FakeApprover alloc] init];
  approval = [[ConfigApproval alloc] initWithStore:store approver:approver];
  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
  [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)tearDown {
  [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
  [[SlateConfig getInstance] setApproval:nil];
}

- (ConfigReview *)reviewWithContents:(NSString *)contents {
  ConfigReview *review = [[ConfigReview alloc] init];
  [review addFile:@"/Users/me/.slate" contents:contents];
  return review;
}

// --- ConfigReview

- (void)testDigestChangesWithContentsAndIsStable {
  XCTAssertEqualObjects([[self reviewWithContents:@"a"] digest], [[self reviewWithContents:@"a"] digest]);
  XCTAssertNotEqualObjects([[self reviewWithContents:@"a"] digest], [[self reviewWithContents:@"b"] digest]);
}

- (void)testDigestCannotBeMatchedByMovingContentBetweenFiles {
  ConfigReview *one = [[ConfigReview alloc] init];
  [one addFile:@"/a" contents:@"xy"];
  [one addFile:@"/b" contents:@""];
  ConfigReview *two = [[ConfigReview alloc] init];
  [two addFile:@"/a" contents:@"x"];
  [two addFile:@"/b" contents:@"y"];
  XCTAssertNotEqualObjects([one digest], [two digest]);
}

- (void)testReviewCollectsShellLinesOnly {
  ConfigReview *review = [[ConfigReview alloc] init];
  [review addLine:@"bind a:ctrl shell '/usr/bin/open -a Safari'"];
  [review addLine:@"bind b:ctrl move screenOriginX;screenOriginY screenSizeX;screenSizeY"];
  XCTAssertEqualObjects([review shellLines], @[@"bind a:ctrl shell '/usr/bin/open -a Safari'"]);
}

// --- ConfigApproval decision

- (void)testMatchingDigestIsApprovedWithoutAsking {
  ConfigReview *review = [self reviewWithContents:@"a"];
  store.digest = [review digest];
  XCTAssertTrue([approval isApproved:review]);
  XCTAssertEqual(approver.asked, (NSUInteger)0);
}

- (void)testChangedConfigIsApprovedAndRemembered {
  store.digest = [[self reviewWithContents:@"old"] digest];
  approver.answer = YES;
  ConfigReview *review = [self reviewWithContents:@"new"];
  XCTAssertTrue([approval isApproved:review]);
  XCTAssertEqual(approver.asked, (NSUInteger)1);
  XCTAssertEqualObjects(store.digest, [review digest]);
  XCTAssertTrue([approval isApproved:review]);
  XCTAssertEqual(approver.asked, (NSUInteger)1, @"not asked again for the same config");
}

- (void)testRejectedConfigIsNotApprovedOrRemembered {
  store.digest = [[self reviewWithContents:@"old"] digest];
  approver.answer = NO;
  XCTAssertFalse([approval isApproved:[self reviewWithContents:@"new"]]);
  XCTAssertEqualObjects(store.digest, [[self reviewWithContents:@"old"] digest]);
}

- (void)testNonPersistentStoreAsksEveryTime {
  store.persistent = NO;
  approver.answer = YES;
  ConfigReview *review = [self reviewWithContents:@"a"];
  XCTAssertTrue([approval isApproved:review]);
  XCTAssertTrue([approval isApproved:review]);
  XCTAssertEqual(approver.asked, (NSUInteger)2);
}

// --- SlateConfig load gate

- (NSString *)writeConfig:(NSString *)name contents:(NSString *)contents {
  NSString *path = [dir stringByAppendingPathComponent:name];
  [contents writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
  return path;
}

- (void)testRejectedConfigLoadsNoBindings {
  NSString *path = [self writeConfig:@".slate" contents:@"bind right:ctrl;cmd shell '/usr/bin/true'\n"];
  approver.answer = NO;
  SlateConfig *config = [SlateConfig getInstance];
  [config setApproval:approval];
  XCTAssertTrue([config loadUserConfigAtPath:path]);
  XCTAssertEqual([[config bindings] count], (NSUInteger)0);
  XCTAssertEqualObjects([approver.lastReview shellLines], @[@"bind right:ctrl;cmd shell '/usr/bin/true'"]);
}

- (void)testApprovedConfigLoadsBindings {
  NSString *path = [self writeConfig:@".slate" contents:@"bind right:ctrl;cmd move screenOriginX;screenOriginY screenSizeX/2;screenSizeY\n"];
  approver.answer = YES;
  SlateConfig *config = [SlateConfig getInstance];
  [config setApproval:approval];
  XCTAssertTrue([config loadUserConfigAtPath:path]);
  XCTAssertEqual([[config bindings] count], (NSUInteger)1);
}

- (void)testSourcedFileChangeRequiresApproval {
  NSString *sourced = [self writeConfig:@"extra.slate" contents:@"bind left:ctrl;cmd move screenOriginX;screenOriginY screenSizeX/2;screenSizeY\n"];
  NSString *path = [self writeConfig:@".slate" contents:[NSString stringWithFormat:@"source %@\n", sourced]];
  approver.answer = YES;
  SlateConfig *config = [SlateConfig getInstance];
  [config setApproval:approval];
  XCTAssertTrue([config loadUserConfigAtPath:path]);
  XCTAssertEqualObjects([approver.lastReview paths], (@[path, sourced]));

  [self writeConfig:@"extra.slate" contents:@"bind left:ctrl;cmd shell '/usr/bin/true'\n"];
  approver.answer = NO;
  XCTAssertTrue([config loadUserConfigAtPath:path]);
  XCTAssertEqual(approver.asked, (NSUInteger)2);
  XCTAssertEqual([[config bindings] count], (NSUInteger)0);
}

@end

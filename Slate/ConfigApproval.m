//
//  ConfigApproval.m
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

#import "ConfigApproval.h"
#import "SlateLogger.h"
#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

static NSString *const ApprovalService = @"io.opus1.slate.config-approval";
static NSString *const ApprovalAccount = @"approved-config-sha256";
static const NSUInteger MaxListedLines = 20;

@implementation ConfigApproval {
  id<ConfigApprovalStore> store;
  id<ConfigApprover> approver;
}

- (instancetype)initWithStore:(id<ConfigApprovalStore>)theStore approver:(id<ConfigApprover>)theApprover {
  self = [super init];
  if (self) {
    store = theStore;
    approver = theApprover;
  }
  return self;
}

+ (instancetype)defaultApproval {
  return [[ConfigApproval alloc] initWithStore:[[KeychainConfigApprovalStore alloc] init] approver:[[AlertConfigApprover alloc] init]];
}

- (BOOL)isApproved:(ConfigReview *)review {
  NSString *digest = [review digest];
  if ([digest isEqualToString:[store approvedDigest]]) {
    SlateLogger(@"Config matches the approved config.");
    return YES;
  }
  if (![approver approveConfig:review persistent:[store isPersistent]]) {
    NSLog(@"WARNING: Config was not approved. Running without bindings or layouts.");
    return NO;
  }
  NSLog(@"Config approved by user.");
  [store storeApprovedDigest:digest];
  return YES;
}

@end

@implementation KeychainConfigApprovalStore {
  BOOL missingEntitlement;
}

- (NSDictionary *)itemQuery {
  return @{
    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
    (__bridge id)kSecAttrService: ApprovalService,
    (__bridge id)kSecAttrAccount: ApprovalAccount,
    (__bridge id)kSecUseDataProtectionKeychain: @YES,
  };
}

- (BOOL)isPersistent {
  return !missingEntitlement;
}

- (BOOL)noteMissingEntitlement:(OSStatus)status {
  if (status != errSecMissingEntitlement) return NO;
  if (!missingEntitlement) {
    NSLog(@"This build has no keychain entitlement (ad-hoc signed): config approvals are not remembered.");
  }
  missingEntitlement = YES;
  return YES;
}

- (NSString *)approvedDigest {
  NSMutableDictionary *query = [[self itemQuery] mutableCopy];
  query[(__bridge id)kSecReturnData] = @YES;
  query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
  CFTypeRef result = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
  if (status == errSecSuccess) {
    return [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];
  }
  if (status == errSecItemNotFound) {
    SlateLogger(@"No approved config in the keychain.");
  } else if (![self noteMissingEntitlement:status]) {
    NSLog(@"ERROR: Unable to read approved config from the keychain (OSStatus %d).", (int)status);
  }
  return nil;
}

- (void)storeApprovedDigest:(NSString *)digest {
  if (missingEntitlement) return;
  NSData *data = [digest dataUsingEncoding:NSUTF8StringEncoding];
  OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)[self itemQuery],
                                  (__bridge CFDictionaryRef)@{(__bridge id)kSecValueData: data});
  if (status == errSecItemNotFound) {
    NSMutableDictionary *item = [[self itemQuery] mutableCopy];
    item[(__bridge id)kSecValueData] = data;
    item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
  }
  if (status != errSecSuccess && ![self noteMissingEntitlement:status]) {
    NSLog(@"ERROR: Unable to save approved config to the keychain (OSStatus %d). You will be asked again.", (int)status);
  }
}

@end

@implementation AlertConfigApprover

+ (NSString *)list:(NSArray<NSString *> *)items {
  if ([items count] == 0) return @"  (none)";
  NSMutableArray *shown = [NSMutableArray array];
  for (NSString *item in [items subarrayWithRange:NSMakeRange(0, MIN([items count], MaxListedLines))]) {
    [shown addObject:[@"  " stringByAppendingString:[item stringByAbbreviatingWithTildeInPath]]];
  }
  if ([items count] > MaxListedLines) {
    [shown addObject:[NSString stringWithFormat:@"  ...and %lu more", (unsigned long)([items count] - MaxListedLines)]];
  }
  return [shown componentsJoinedByString:@"\n"];
}

- (BOOL)approveConfig:(ConfigReview *)review persistent:(BOOL)persistent {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setAlertStyle:NSAlertStyleWarning];
  [alert setMessageText:persistent ? @"Slate's configuration changed" : @"Load Slate's configuration?"];
  NSString *intro = persistent
    ? @"Approve only if you made these changes. Slate runs your config with Accessibility access."
    : @"This build is not signed with a development team, so approval is not remembered.";
  [alert setInformativeText:[NSString stringWithFormat:@"%@\n\nFiles:\n%@\n\nShell commands:\n%@",
                             intro, [AlertConfigApprover list:[review paths]], [AlertConfigApprover list:[review shellLines]]]];
  [alert addButtonWithTitle:@"Load Config"];
  [alert addButtonWithTitle:@"Don't Load"];
  if (@available(macOS 14.0, *)) {
    [NSApp activate];
  } else {
    [NSApp activateIgnoringOtherApps:YES];
  }
  return [alert runModal] == NSAlertFirstButtonReturn;
}

@end

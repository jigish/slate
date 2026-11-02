//
//  ConfigApproval.h
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

#import <Foundation/Foundation.h>
#import "ConfigReview.h"

// Where the digest of the last approved config is kept.
@protocol ConfigApprovalStore <NSObject>
- (NSString *)approvedDigest;
- (void)storeApprovedDigest:(NSString *)digest;
// NO when approvals cannot be remembered (e.g. ad-hoc signed builds).
- (BOOL)isPersistent;
@end

// Asks the user whether to load a config.
@protocol ConfigApprover <NSObject>
- (BOOL)approveConfig:(ConfigReview *)review persistent:(BOOL)persistent;
@end

// Config files drive actions run with Slate's Accessibility permission. A config is only loaded once the user
// has approved its exact contents, so other programs can't silently change what Slate does.
@interface ConfigApproval : NSObject

- (instancetype)initWithStore:(id<ConfigApprovalStore>)store approver:(id<ConfigApprover>)approver;
// Keychain-backed store and an alert approver.
+ (instancetype)defaultApproval;

- (BOOL)isApproved:(ConfigReview *)review;

@end

// Data protection keychain item, only accessible to Slate signed by its development team. Builds without the
// keychain-access-groups entitlement (ad-hoc signed) remember nothing.
@interface KeychainConfigApprovalStore : NSObject <ConfigApprovalStore>
@end

@interface AlertConfigApprover : NSObject <ConfigApprover>
@end

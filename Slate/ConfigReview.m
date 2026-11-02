//
//  ConfigReview.m
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

#import "ConfigReview.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ConfigReview {
  NSMutableArray<NSString *> *paths;
  NSMutableArray<NSString *> *shellLines;
  NSMutableData *framedContents;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    paths = [NSMutableArray array];
    shellLines = [NSMutableArray array];
    framedContents = [NSMutableData data];
  }
  return self;
}

- (NSArray<NSString *> *)paths { return [paths copy]; }
- (NSArray<NSString *> *)shellLines { return [shellLines copy]; }

- (void)addFile:(NSString *)path contents:(NSString *)contents {
  [paths addObject:path];
  // Length-prefixed framing so content can't be shifted between files without changing the digest.
  for (NSString *part in @[path, contents]) {
    NSData *bytes = [part dataUsingEncoding:NSUTF8StringEncoding];
    uint64_t length = CFSwapInt64HostToBig([bytes length]);
    [framedContents appendBytes:&length length:sizeof(length)];
    [framedContents appendData:bytes];
  }
}

- (void)addLine:(NSString *)line {
  if ([line rangeOfString:@"shell" options:NSCaseInsensitiveSearch].location != NSNotFound) {
    [shellLines addObject:line];
  }
}

- (BOOL)isEmpty {
  return [paths count] == 0;
}

- (NSString *)digest {
  unsigned char hash[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256([framedContents bytes], (CC_LONG)[framedContents length], hash);
  NSMutableString *hex = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) [hex appendFormat:@"%02x", hash[i]];
  return hex;
}

@end

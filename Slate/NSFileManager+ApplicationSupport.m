//
//  NSFileManager+ApplicationSupport.m
//  Slate
//
//  Created by Jigish Patel on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+ApplicationSupport.h"

@implementation NSFileManager (ApplicationSupport)

- (NSURL *)applicationSupportDirectory {
  return [self findOrCreateDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask append:[[NSBundle mainBundle] bundleIdentifier] error:nil];
}

- (NSURL *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory inDomain:(NSSearchPathDomainMask)domainMask append:(NSString *)appendComponent error:(NSError **)errorOut {
  NSArray *urls = [self URLsForDirectory:searchPathDirectory inDomains:domainMask];
  if ([urls count] == 0) return nil;
  NSURL *url = [urls objectAtIndex:0];

  if (appendComponent) {
    url = [url URLByAppendingPathComponent:appendComponent];
  }
  NSError *error;
  BOOL success = [self createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
  if (!success) {
    if (errorOut) *errorOut = error;
    return nil;
  }
  if (errorOut) *errorOut = nil;
  return url;
}

@end

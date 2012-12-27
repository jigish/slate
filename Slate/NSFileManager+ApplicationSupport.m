//
//  NSFileManager+ApplicationSupport.m
//  Slate
//
//  Created by Jigish Patel on 4/23/12.
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
  SInt32 major, minor, bugfix;
  Gestalt(gestaltSystemVersionMajor, &major);
  Gestalt(gestaltSystemVersionMinor, &minor);
  Gestalt(gestaltSystemVersionBugFix, &bugfix);
  BOOL success = NO;
  // need to use AtPath if < 10.7 because AtURL is 10.7 only
  if (major >= 10 && minor >= 7) {
    success = [self createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
  } else {
    success = [self createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
  }
  if (!success) {
    if (errorOut) *errorOut = error;
    return nil;
  }
  if (errorOut) *errorOut = nil;
  return url;
}

@end

//
//  ConfigFile.h
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

extern NSString *const ConfigFileErrorDomain;

typedef NS_ENUM(NSInteger, ConfigFileError) {
  ConfigFileErrorUnreadable = 1,
  ConfigFileErrorNotRegularFile,
  ConfigFileErrorUntrustedOwner,
  ConfigFileErrorWritableByOthers,
  ConfigFileErrorNotUTF8,
};

// A Slate configuration file. Config files drive actions run with Slate's Accessibility permission,
// so they are only read when they are regular files owned by the current user (or root) and not
// writable by group or others.
@interface ConfigFile : NSObject

// Returns the file's contents, or nil with error set when the file is missing or not trusted.
// Ownership and permissions are checked on the opened file descriptor that is then read.
+ (NSString *)contentsOfFileAtPath:(NSString *)path error:(NSError **)error;

// YES when error says the file does not exist (as opposed to being unreadable or untrusted).
+ (BOOL)isMissingFileError:(NSError *)error;

@end

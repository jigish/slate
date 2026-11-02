//
//  ConfigFile.m
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

#import "ConfigFile.h"
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

NSString *const ConfigFileErrorDomain = @"ConfigFileErrorDomain";

@implementation ConfigFile

+ (NSError *)errorWithCode:(ConfigFileError)code path:(NSString *)path reason:(NSString *)reason {
  return [NSError errorWithDomain:ConfigFileErrorDomain code:code userInfo:@{
    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ %@", path, reason],
    NSFilePathErrorKey: path,
  }];
}

+ (BOOL)isMissingFileError:(NSError *)error {
  NSError *underlying = [[error userInfo] objectForKey:NSUnderlyingErrorKey];
  return [[error domain] isEqualToString:ConfigFileErrorDomain] && [error code] == ConfigFileErrorUnreadable &&
         [[underlying domain] isEqualToString:NSPOSIXErrorDomain] && [underlying code] == ENOENT;
}

+ (NSString *)contentsOfFileAtPath:(NSString *)path error:(NSError **)error {
  NSError *failure = nil;
  NSString *contents = nil;
  int fd = open([path fileSystemRepresentation], O_RDONLY | O_CLOEXEC);
  if (fd < 0) {
    failure = [NSError errorWithDomain:ConfigFileErrorDomain code:ConfigFileErrorUnreadable userInfo:@{
      NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ cannot be opened: %s", path, strerror(errno)],
      NSFilePathErrorKey: path,
      NSUnderlyingErrorKey: [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil],
    }];
  } else {
    struct stat info;
    if (fstat(fd, &info) != 0) {
      failure = [self errorWithCode:ConfigFileErrorUnreadable path:path reason:[NSString stringWithFormat:@"cannot be inspected: %s", strerror(errno)]];
    } else if (!S_ISREG(info.st_mode)) {
      failure = [self errorWithCode:ConfigFileErrorNotRegularFile path:path reason:@"is not a regular file"];
    } else if (info.st_uid != getuid() && info.st_uid != 0) {
      failure = [self errorWithCode:ConfigFileErrorUntrustedOwner path:path reason:@"is not owned by the current user"];
    } else if ((info.st_mode & (S_IWGRP | S_IWOTH)) != 0) {
      failure = [self errorWithCode:ConfigFileErrorWritableByOthers path:path reason:@"is writable by other users (run: chmod go-w <file>)"];
    } else {
      NSData *data = [[[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:NO] readDataToEndOfFile];
      contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      if (contents == nil) {
        failure = [self errorWithCode:ConfigFileErrorNotUTF8 path:path reason:@"is not valid UTF-8"];
      }
    }
    close(fd);
  }
  if (failure != nil) {
    if (error) *error = failure;
    return nil;
  }
  return contents;
}

@end

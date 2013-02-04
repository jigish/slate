//
//  ShellUtils.m
//  Slate
//
//  Created by Jigish Patel on 10/17/12.
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

#import "ShellUtils.h"
#import "Constants.h"

@implementation ShellUtils

+ (BOOL)commandExists:(NSString *)command {
  if (command == nil || [EMPTY isEqualToString:command]) return NO;
  @try {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/command"];

    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-v", command, nil];
    [task setArguments:arguments];

    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardInput:[NSPipe pipe]];

    NSFileHandle *file;
    file = [pipe fileHandleForReading];

    [task launch];

    NSData *data;
    data = [file readDataToEndOfFile];

    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    if ([string isEqualToString:EMPTY]) {
      return NO;
    }
    return YES;
  } @catch (id ex) {
    return NO;
  }
}

+ (NSTask *)run:(NSString *)command args:(NSArray *)args wait:(BOOL)wait path:(NSString *)path {
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:command];
  [task setArguments:args];
  if (path != nil) [task setCurrentDirectoryPath:path];

  NSPipe *opipe, *ipipe;
  opipe = [NSPipe pipe];
  ipipe = [NSPipe pipe];

  [task setStandardOutput:opipe];
  [task setStandardInput:ipipe];

  NSFileHandle *file = [ipipe fileHandleForWriting];

  [task launch];
  [file closeFile];
  if (wait) [task waitUntilExit];
  return task;
}

@end

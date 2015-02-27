//
//  ShellOperation.m
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

#import "ShellOperation.h"
#import "Constants.h"
#import "SlateLogger.h"
#import "StringTokenizer.h"
#import "ShellUtils.h"

@implementation ShellOperation

@synthesize command, args, waitForExit, currentPath;

- (id)init {
  self = [super init];
  if (self) {
    [self setCommand:@""];
    [self setArgs:[NSArray array]];
    [self setWaitForExit:NO];
    [self setCurrentPath:nil];
  }
  return self;
}

- (id)initWithCommand:(NSString *)theCommand args:(NSArray *)theArgs waitForExit:(BOOL)theWaitForExit currentPath:(NSString *)theCurrentPath {
  self = [super init];
  if (self) {
    [self setCommand:theCommand];
    [self setArgs:theArgs];
    [self setWaitForExit:theWaitForExit];
    [self setCurrentPath:theCurrentPath];
  }
  return self;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Shell Operation -----------------");
  // We don't use the passed in AccessibilityWrapper or ScreenWrapper so they are nil. No need to waste time creating them here.
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  SlateLogger(@"-----------------  End Shell Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  [self evalOptionsWithAccessibilityWrapper:iamnil screenWrapper:iamalsonil];
  NSTask *task = [ShellUtils run:[self command] args:[self args] wait:[self waitForExit] path:[self currentPath]];
  return task != nil;
}

- (BOOL)testOperation {
  return [ShellUtils commandExists:[self command]];
}

- (NSArray *)requiredOptions {
  return [NSArray arrayWithObjects:OPT_COMMAND, nil];
}

- (void)parseOption:(NSString *)name value:(NSString *)value {
  // all options should be strings
  if (value == nil) { return; }
  if ([name isEqualToString:OPT_COMMAND]) {
    if (![value isKindOfClass:[NSString class]]) {
      @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", name, value] userInfo:nil]);
    }
    NSMutableArray *commandAndArgsTokens = [NSMutableArray array];
    [StringTokenizer tokenize:value into:commandAndArgsTokens];
    if ([commandAndArgsTokens count] < 1) {
      SlateLogger(@"ERROR: Invalid Shell Parameter '%@'", value);
      @throw([NSException exceptionWithName:@"Invalid Shell Parameter" reason:[NSString stringWithFormat:@"Invalid Shell Parameter '%@'.", value] userInfo:nil]);
    }
    NSString *cmd = [commandAndArgsTokens objectAtIndex:0];
    NSMutableArray *ars = [NSMutableArray array];
    for (NSInteger i = 1; i < [commandAndArgsTokens count]; i++) {
      [ars addObject:[commandAndArgsTokens objectAtIndex:i]];
    }
    [self setCommand:cmd];
    [self setArgs:ars];
  } else if ([name isEqualToString:OPT_WAIT]) {
    if (![value isKindOfClass:[NSString class]] && ![value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
      @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", name, value] userInfo:nil]);
    }
    [self setWaitForExit:[value boolValue]];
  } else if ([name isEqualToString:OPT_PATH]) {
    if (![value isKindOfClass:[NSString class]]) {
      @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", name] reason:[NSString stringWithFormat:@"Invalid %@ '%@'", name, value] userInfo:nil]);
    }
    [self setCurrentPath:[value stringByExpandingTildeInPath]];
  }
}

+ (id)shellOperation {
  return [[ShellOperation alloc] init];
}

+ (id)shellOperationFromString:(NSString *)shellOperation {
  // shell [wait] 'command'
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:shellOperation into:tokens quoteChars:[NSCharacterSet characterSetWithCharactersInString:QUOTES]];

  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", shellOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Shell operations require the following format: shell [wait] 'command'", shellOperation] userInfo:nil]);
  }

  BOOL waitForExit = NO;
  NSString *currentPath = nil;
  for (NSInteger i = 1; i < [tokens count] - 1; i++) {
    if ([[tokens objectAtIndex:i] isEqualToString:WAIT]) {
      waitForExit = YES;
    } else if ([[tokens objectAtIndex:i] hasPrefix:PATH]) {
      currentPath = [[tokens objectAtIndex:i] stringByReplacingOccurrencesOfString:PATH withString:EMPTY];
      if ([currentPath hasPrefix:TILDA]) {
        currentPath = [currentPath stringByExpandingTildeInPath];
      }
    }
  }
  NSString *commandAndArgs = [tokens lastObject];
  NSString *c = [commandAndArgs stringByReplacingOccurrencesOfString:@"\\ " withString:SPACE_WORD];
  NSMutableArray *commandAndArgsTokens = [NSMutableArray array];
  [StringTokenizer tokenize:c into:commandAndArgsTokens];
  if ([commandAndArgsTokens count] < 1) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", shellOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Shell operations require the following format: shell [wait] 'command'", shellOperation] userInfo:nil]);
  }
  NSString *command = [commandAndArgsTokens objectAtIndex:0];
    command = [command stringByReplacingOccurrencesOfString:SPACE_WORD withString:@" "];
  NSMutableArray *args = [NSMutableArray array];
  for (NSInteger i = 1; i < [commandAndArgsTokens count]; i++) {
      
    [args addObject:[[commandAndArgsTokens objectAtIndex:i] stringByReplacingOccurrencesOfString:@"<space>" withString:@" "]];
  }

  Operation *op = [[ShellOperation alloc] initWithCommand:command args:args waitForExit:waitForExit currentPath:currentPath];
  return op;

}

@end

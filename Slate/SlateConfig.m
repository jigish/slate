//
//  SlateConfig.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 Jigish Patel. All rights reserved.
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

#import "Binding.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"


@implementation SlateConfig

@synthesize bindings;
@synthesize configs;

static SlateConfig *_instance = nil;

+ (SlateConfig *)getInstance {
  @synchronized([SlateConfig class]) {
    if (!_instance)
      _instance = [[[SlateConfig class] alloc] init];
    return _instance;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    [self setConfigs:[[NSMutableDictionary alloc] init]];
    [self setBindings:[[NSMutableArray alloc] initWithCapacity:10]];
  }
  return self;
}

- (BOOL)getBoolConfig:(NSString *)key {
  return [[configs objectForKey:key] boolValue];
}

- (NSInteger)getIntegerConfig:(NSString *)key {
  return [[configs objectForKey:key] integerValue];
}

- (NSString *)getConfig:(NSString *)key {
  return [configs objectForKey:key];
}

- (BOOL)load {
  NSLog(@"Loading config...");

  // Reset configs and bindings in case we are calling from menu
  [self setConfigs:[[NSMutableDictionary alloc] init]];
  [self setBindings:[[NSMutableArray alloc] initWithCapacity:10]];

  NSString *homeDir = NSHomeDirectory();
  NSString *configFile = [homeDir stringByAppendingString:@"/.slate"];
  NSString *fileString = [NSString stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:nil];
  if (fileString == nil)
    return NO;
  NSArray *lines = [fileString componentsSeparatedByString:@"\n"];

  NSEnumerator *e = [lines objectEnumerator];
  NSString *line = [e nextObject];
  while (line) {
    NSArray *tokens = [StringTokenizer tokenize:line];
    if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"config"]) {
      // config <key> <value>
      NSLog(@"  LoadingC: %s",[line cStringUsingEncoding:NSASCIIStringEncoding]);
      [configs setObject:[tokens objectAtIndex:2] forKey:[tokens objectAtIndex:1]];
    } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"bind"]) {
      // bind <key:modifiers> <op> <parameters>
      @try {
        Binding *bind = [[Binding alloc] initWithString:line];
        NSLog(@"  LoadingB: %s",[line cStringUsingEncoding:NSASCIIStringEncoding]);
        [bindings addObject:bind];
        [bind release];
      } @catch (NSException *ex) {
        NSLog(@"  ERROR %s",[[ex name] cStringUsingEncoding:NSASCIIStringEncoding]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Skip"];
        [alert setMessageText:[ex name]];
        [alert setInformativeText:[ex reason]];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
          NSLog(@"User selected exit");
          [NSApp terminate:nil];
        }
        [alert release];
      }
    }
    [tokens release];
    line = [e nextObject];
  }

  NSLog(@"Config loaded.");
  return YES;
}

- (void)dealloc {
  [self setConfigs:nil];
  [self setBindings:nil];
  [super dealloc];
}

@end

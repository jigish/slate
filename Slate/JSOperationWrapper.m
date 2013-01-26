//
//  JSOperationWrapper.m
//  Slate
//
//  Created by Jigish Patel on 1/25/13.
//  Copyright 2013 Jigish Patel. All rights reserved.
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

#import "JSOperationWrapper.h"
#import "Operation.h"
#import "JSController.h"
#import "SlateLogger.h"
#import "SlateConfig.h"

@implementation JSOperationWrapper

static NSDictionary *jsowJsMethods;

@synthesize op;

- (id)init {
  self = [super init];
  if (self) {
    [JSOperationWrapper setJsMethods];
  }
  return self;
}

- (id)initWithOperation:(Operation *)_op {
  self = [self init];
  if (self) {
    @try {
      [self setOp:_op];
      if ([self op] == nil) { return nil; }
    } @catch (NSException *ex) {
      SlateLogger(@"   ERROR %@",[ex name]);
      NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
      [alert setMessageText:[ex name]];
      [alert setInformativeText:[ex reason]];
      if ([alert runModal] == NSAlertFirstButtonReturn) {
        SlateLogger(@"User selected exit");
        [NSApp terminate:nil];
      }
      return nil;
    }
  }
  return self;
}

- (id)initWithName:(NSString*)name options:(WebScriptObject *)opts {
  self = [self init];
  if (self) {
    @try {
      [self setOp:[Operation operationWithName:name options:[[JSController getInstance] unmarshall:opts]]];
      if ([self op] == nil) { return nil; }
    } @catch (NSException *ex) {
      SlateLogger(@"   ERROR %@",[ex name]);
      NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
      [alert setMessageText:[ex name]];
      [alert setInformativeText:[ex reason]];
      if ([alert runModal] == NSAlertFirstButtonReturn) {
        SlateLogger(@"User selected exit");
        [NSApp terminate:nil];
      }
      return nil;
    }
  }
  return self;
}

- (id)initWithString:(NSString *)str {
  self = [self init];
  if (self) {
    @try {
      [self setOp:[Operation operationFromString:str]];
      if ([self op] == nil) { return nil; }
    } @catch (NSException *ex) {
      SlateLogger(@"   ERROR %@",[ex name]);
      NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
      [alert setMessageText:[ex name]];
      [alert setInformativeText:[ex reason]];
      if ([alert runModal] == NSAlertFirstButtonReturn) {
        SlateLogger(@"User selected exit");
        [NSApp terminate:nil];
      }
      return nil;
    }
  }
  return self;
}

- (BOOL)run {
  return [[self op] doOperation];
}

- (BOOL)doOperation {
  return [[self op] doOperation];
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  return [[self op] doOperationWithAccessibilityWrapper:aw screenWrapper:sw];
}

- (JSOperationWrapper *)dup:(WebScriptObject *)opts {
  NSString *type = [[JSController getInstance] jsTypeof:opts];
  if (![@"object" isEqualToString:type]) {
    SlateLogger(@"   ERROR operation.dup parameter must be a hash");
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:@"operation.dup parameter must be a hash"];
    [alert setInformativeText:[NSString stringWithFormat:@"was: %@", type]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
    return nil;
  }
  NSDictionary *optDict = [[JSController getInstance] unmarshall:opts];
  return [[JSOperationWrapper alloc] initWithOperation:[[self op] dup:optDict]];
}

+ (JSOperationWrapper *)operation:(NSString*)name options:(WebScriptObject *)opts {
  return [[JSOperationWrapper alloc] initWithName:name options:opts];
}

+ (JSOperationWrapper *)operationFromString:(NSString *)opString {
  return [[JSOperationWrapper alloc] initWithString:opString];
}

+ (void)setJsMethods {
  if (jsowJsMethods == nil) {
    jsowJsMethods = @{
      NSStringFromSelector(@selector(run)): @"run",
      NSStringFromSelector(@selector(run)): @"do",
      NSStringFromSelector(@selector(dup:)): @"duplicate",
      NSStringFromSelector(@selector(dup:)): @"dup",
    };
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [jsowJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [jsowJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end

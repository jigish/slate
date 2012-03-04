//
//  Binding.m
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
#import "Constants.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"


@implementation Binding

@synthesize op;
@synthesize keyCode;
@synthesize modifiers;
@synthesize hotKeyRef;
@synthesize repeat;

static NSDictionary *dictionary = nil;

- (id)init {
  self = [super init];
  if (self) {
    [self setRepeat:NO];
  }
  return self;
}

// Yes, this method is huge. Deal with it.
- (id)initWithString:(NSString *)binding {
  self = [self init];
  if (self) {
    // bind <key:modifiers> <op> <parameters>
    NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
    [StringTokenizer tokenize:binding into:tokens maxTokens:3];
    if ([tokens count] <=2) {
      @throw([NSException exceptionWithName:@"Unrecognized Bind" reason:binding userInfo:nil]);
    }
    NSString *keystroke = [tokens objectAtIndex:1];
    NSArray *keyAndModifiers = [keystroke componentsSeparatedByString:COLON];
    if ([keyAndModifiers count] >= 1) {
      [self setKeyCode:(UInt32)[[[Binding asciiToCodeDict] objectForKey:[keyAndModifiers objectAtIndex:0]] integerValue]];
      [self setModifiers:0];
      if ([keyAndModifiers count] >= 2) {
        NSArray *modifiersArray = [[keyAndModifiers objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",;"]];
        NSEnumerator *modEnum = [modifiersArray objectEnumerator];
        NSString *mod = [modEnum nextObject];
        while (mod) {
          if ([mod isEqualToString:CONTROL]) {
            modifiers += controlKey;
          } else if ([mod isEqualToString:OPTION]) {
            modifiers += optionKey;
          } else if ([mod isEqualToString:COMMAND]) {
            modifiers += cmdKey;
          } else if ([mod isEqualToString:SHIFT]) {
            modifiers += shiftKey;
          } else {
            NSLog(@"ERROR: Unrecognized modifier '%@'", mod);
            @throw([NSException exceptionWithName:@"Unrecognized Modifier" reason:[NSString stringWithFormat:@"Unrecognized modifier '%@' in '%@'", mod, binding] userInfo:nil]);
          }
          mod = [modEnum nextObject];
        }
      }
    }

    NSArray *repeatOps = [[[SlateConfig getInstance] getConfig:REPEAT_ON_HOLD_OPS] componentsSeparatedByString:COMMA];
    for (NSInteger i = 0; i < [repeatOps count]; i++) {
      NSMutableString *opStr = [[NSMutableString alloc] initWithCapacity:10];
      [StringTokenizer firstToken:[tokens objectAtIndex:2] into:opStr];
      if ([opStr isEqualToString:[repeatOps objectAtIndex:i]]) {
        [self setRepeat:YES];
        break;
      }
    }

    [self setOp:[Operation operationFromString:[tokens objectAtIndex:2]]];

    if (op == nil) {
      NSLog(@"ERROR: Unable to create binding");
      @throw([NSException exceptionWithName:@"Unable To Create Binding" reason:[NSString stringWithFormat:@"Unable to create '%@'", binding] userInfo:nil]);
    }

    @try {
      [op testOperation];
    } @catch (NSException *ex) {
      NSLog(@"ERROR: Unable to test binding '%@'", binding);
      @throw([NSException exceptionWithName:@"Unable To Parse Binding" reason:[NSString stringWithFormat:@"Unable to parse '%@' in '%@'", [ex reason], binding] userInfo:nil]);
    }
  }

  return self;
}

- (BOOL)doOperation {
  return [op doOperation];
}

- (void)dealloc {
  [self setHotKeyRef:nil];
}

// This returns a dictionary containing mappings from ASCII to keyCode
+ (NSDictionary *)asciiToCodeDict {
  if (dictionary == nil) {
    dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ASCIIToCode" ofType:@"plist"]];
  }
  return dictionary;
}

@end

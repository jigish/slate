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
#import "SlateLogger.h"
#import "Operation.h"
#import "SwitchOperation.h"
#import "SlateAppDelegate.h"
#import "SnapshotOperation.h"

@implementation Binding

@synthesize op;
@synthesize keyCode;
@synthesize modifiers;
@synthesize modalKey;
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
    // bind <key:modifiers|modal-key> <op> <parameters>
    NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
    [StringTokenizer tokenize:binding into:tokens maxTokens:3];
    if ([tokens count] <=2) {
      @throw([NSException exceptionWithName:@"Unrecognized Bind" reason:binding userInfo:nil]);
    }
    [self setKeystrokeFromString:[tokens objectAtIndex:1]];
    [self setOperationAndRepeatFromString:[tokens objectAtIndex:2]];
  }

  return self;
}

- (id)initWithKeystroke:(NSString*)keystroke operation:(Operation*)op_ repeat:(BOOL)repeat_ {
  self = [self init];
  if(self) {
    [self setKeystrokeFromString:keystroke];
    self.op = op_;
    self.repeat = repeat_;
  }
  return self;
}

- (void)setKeystrokeFromString:(NSString*)keystroke {
  UInt32 theKeyCode = 0;
  UInt32 theModifiers = 0;
  NSNumber *theModalKey;
  NSArray *keyAndModifiers = [keystroke componentsSeparatedByString:COLON];
  if ([keyAndModifiers count] >= 1) {
    theKeyCode = (UInt32)[[[Binding asciiToCodeDict] objectForKey:[keyAndModifiers objectAtIndex:0]] integerValue];
    if ([keyAndModifiers count] >= 2) {
      theModalKey = [[Binding asciiToCodeDict] objectForKey:[keyAndModifiers objectAtIndex:1]];
      if (theModalKey == nil) {
        // normal case
        NSArray *modifiersArray = [[keyAndModifiers objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",;"]];
        NSEnumerator *modEnum = [modifiersArray objectEnumerator];
        NSString *mod = [modEnum nextObject];
        while (mod) {
          theModalKey = [[Binding asciiToCodeDict] objectForKey:mod];
          if ([mod isEqualToString:CONTROL]) {
            theModifiers += controlKey;
          } else if ([mod isEqualToString:OPTION]) {
            theModifiers += optionKey;
          } else if ([mod isEqualToString:COMMAND]) {
            theModifiers += cmdKey;
          } else if ([mod isEqualToString:SHIFT]) {
            theModifiers += shiftKey;
          } else if ([mod isEqualToString:FUNCTION]) {
            theModifiers += FUNCTION_KEY;
          } else if (theModalKey == nil) {
            SlateLogger(@"ERROR: Unrecognized modifier '%@'", mod);
            @throw([NSException exceptionWithName:@"Unrecognized Modifier" reason:[NSString stringWithFormat:@"Unrecognized modifier '%@' in '%@'", mod, keystroke] userInfo:nil]);
          }
          mod = [modEnum nextObject];
        }
      }
    }
  }
  keyCode = theKeyCode;
  modifiers = theModifiers;
  modalKey = theModalKey;
}

- (void)setOperationAndRepeatFromString:(NSString*)token {
  BOOL theRepeat = NO;
  NSArray *repeatOps = [[[SlateConfig getInstance] getConfig:REPEAT_ON_HOLD_OPS] componentsSeparatedByString:COMMA];
  for (NSInteger i = 0; i < [repeatOps count]; i++) {
    NSMutableString *opStr = [[NSMutableString alloc] initWithCapacity:10];
    [StringTokenizer firstToken:token into:opStr];
    if ([opStr isEqualToString:[repeatOps objectAtIndex:i]]) {
      theRepeat = YES;
      break;
    }
  }

  Operation *theOp = [Operation operationFromString:token];

  if (theOp == nil) {
    SlateLogger(@"ERROR: Unable to create binding");
    @throw([NSException exceptionWithName:@"Unable To Create Binding" reason:[NSString stringWithFormat:@"Unable to create '%@'", token] userInfo:nil]);
  }

  @try {
    [theOp testOperation];
  } @catch (NSException *ex) {
    SlateLogger(@"ERROR: Unable to test binding '%@'", token);
    @throw([NSException exceptionWithName:@"Unable To Parse Binding" reason:[NSString stringWithFormat:@"Unable to parse '%@' in '%@'", [ex reason], token] userInfo:nil]);
  }

  if ([theOp isKindOfClass:[SwitchOperation class]]) {
    [(SwitchOperation *)op setModifiers:modifiers];
  }

  op = theOp;
  repeat = theRepeat;
}

- (BOOL)doOperation {
  if ([(SlateAppDelegate *)[NSApp delegate] hasUndoOperation] && [op shouldTakeUndoSnapshot]) {
    [[(SlateAppDelegate *)[NSApp delegate] undoSnapshotOperation] doOperation];
  }
  return [op doOperation];
}

- (NSString *)modalHashKey {
  if ([self modalKey] == nil) {
    return nil;
  }
  return [NSString stringWithFormat:@"%@%@%u", [self modalKey], PLUS, [self modifiers]];
}

+ (NSArray *)modalHashKeyToKeyAndModifiers:(NSString *)modalHashKey {
  NSArray *modalKeyArr = [modalHashKey componentsSeparatedByString:PLUS];
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  NSNumber *theKey = [nf numberFromString:[modalKeyArr objectAtIndex:0]];
  NSNumber *theModifiers = [nf numberFromString:[modalKeyArr objectAtIndex:1]];
  return [NSArray arrayWithObjects:theKey, theModifiers, nil];
}

- (void)dealloc {
  [self setHotKeyRef:nil];
}

// This returns a dictionary containing mappings from ASCII to keyCode
+ (NSDictionary *)asciiToCodeDict {
  if (dictionary == nil) {
    NSString *configLayout = [[SlateConfig getInstance] getConfig:KEYBOARD_LAYOUT];
    NSString *filename;
    if ([configLayout isEqualToString:KEYBOARD_LAYOUT_DVORAK]) {
      filename = @"ASCIIToCode_Dvorak";
    } else if ([configLayout isEqualToString:KEYBOARD_LAYOUT_COLEMAK]) {
      filename = @"ASCIIToCode_Colemak";
    } else if ([configLayout isEqualToString:KEYBOARD_LAYOUT_AZERTY]) {
      filename = @"ASCIIToCode_Azerty";
    } else {
      filename = @"ASCIIToCode";
    }
    dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
  }
  return dictionary;
}

@end

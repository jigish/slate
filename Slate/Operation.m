//
//  Operation.m
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

#import "Operation.h"
#import "MoveOperation.h"
#import "ResizeOperation.h"
#import "ChainOperation.h"
#import "LayoutOperation.h"
#import "FocusOperation.h"
#import "SnapshotOperation.h"
#import "ActivateSnapshotOperation.h"
#import "DeleteSnapshotOperation.h"
#import "HintOperation.h"
#import "StringTokenizer.h"
#import "Constants.h"
#import "SlateLogger.h"
#import "SwitchOperation.h"
#import "GridOperation.h"
#import "SequenceOperation.h"
#import "VisibilityOperation.h"
#import "RelaunchOperation.h"
#import "ShellOperation.h"
#import "UndoOperation.h"
#import "SlateConfig.h"
#import <WebKit/WebKit.h>
#import "JSController.h"
#import "CornerOperation.h"
#import "ThrowOperation.h"
#import "NudgeOperation.h"
#import "PushOperation.h"
#import "JSInfoWrapper.h"

@implementation Operation

@synthesize opName;
@synthesize options;
@synthesize dynamicOptions;

- (id)init {
  self = [super init];
  if (self) {
    [self setOpName:nil];
    [self setOptions:[NSMutableDictionary dictionary]];
    [self setDynamicOptions:[NSMutableDictionary dictionary]];
  }

  return self;
}


- (BOOL)doOperation {
  return YES;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  return YES;
}

- (BOOL)testOperation {
  return YES;
}

- (BOOL)shouldTakeUndoSnapshot {
  return [[[SlateConfig getInstance] getConfig:UNDO_OPS] rangeOfString:[self opName]].location != NSNotFound;
}

- (NSArray *)requiredOptions {
  return [NSArray array];
}

- (NSString *)checkRequiredOptions:(NSDictionary *)_options {
  for (NSString *key in [self requiredOptions]) {
    id opt = [_options objectForKey:key];
    if (opt == nil) {
      return key;
    }
  }
  return nil;
}

- (void)initOptions:(NSDictionary *)_options {
  NSString *missing = [self checkRequiredOptions:_options];
  if (missing != nil) {
    SlateLogger(@"ERROR: Missing Option in %@", [self opName]);
    @throw([NSException exceptionWithName:@"Missing Option" reason:[NSString stringWithFormat:@"Missing option '%@' in '%@'", missing, [self opName]] userInfo:nil]);
    return;
  }
  [self beforeInitOptions];
  for (NSString *key in [_options allKeys]) {
    id opt = [_options objectForKey:key];
    if (opt == nil) { continue; }
    if ([opt isKindOfClass:[NSString class]] || [opt isKindOfClass:[NSValue class]] ||
        [opt isKindOfClass:[NSDictionary class]] || [opt isKindOfClass:[NSArray class]]) {
      [self.options setObject:opt forKey:key];
      [self parseOption:key value:[[self options] objectForKey:key]];
    } else if ([opt isKindOfClass:[WebScriptObject class]]) {
      // assume this is a function (otherwise it would have been converted)
      NSString *jsKey = [[JSController getInstance] addCallableFunction:opt];
      [self.dynamicOptions setObject:jsKey forKey:key];
    } else {
      [self.options setObject:[NSString stringWithFormat:@"%@", opt] forKey:key];
      [self parseOption:key value:[[self options] objectForKey:key]];
    }
  }
  if ([[self dynamicOptions] count] == 0) { [self afterEvalOptions]; };
}

- (void)beforeInitOptions {
  // OVERRIDE - runs before any options are set
}

- (void)parseOption:(NSString *)name value:(id)value {
  // OVERRIDE - runs while setting options (both normal and dynamic)
}

- (void)afterEvalOptions {
  // OVERRIDE - runs after all options are set
}

- (void)evalOptionsWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  if ([[self dynamicOptions] count] == 0) { return; }
  if (aw == nil) {
    [[JSInfoWrapper getInstance] setAw:[[AccessibilityWrapper alloc] init]];
  } else {
    [[JSInfoWrapper getInstance] setAw:aw];
  }
  if (aw == nil) {
    [[JSInfoWrapper getInstance] setSw:[[ScreenWrapper alloc] init]];
  } else {
    [[JSInfoWrapper getInstance] setSw:sw];
  }
  for (NSString *key in [[self dynamicOptions] allKeys]) {
    id result = [[JSController getInstance] runCallableFunction:[[self dynamicOptions] objectForKey:key]];
    if (result == nil) { continue; }
    [self.options setObject:result forKey:key];
    [self parseOption:key value:[[self options] objectForKey:key]];
  }
  [self afterEvalOptions];
}

+ (id)operationFromString:(NSString *)opString {
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:opString into:tokens maxTokens:2];
  NSString *op = [tokens objectAtIndex:0];
  Operation *operation = nil;
  if ([op isEqualToString:MOVE]) {
    operation = [MoveOperation moveOperationFromString:opString];
  } else if ([op isEqualToString:RESIZE]) {
    operation = [ResizeOperation resizeOperationFromString:opString];
  } else if ([op isEqualToString:PUSH]) {
    operation = [PushOperation pushOperationFromString:opString];
  } else if ([op isEqualToString:NUDGE]) {
    operation = [NudgeOperation nudgeOperationFromString:opString];
  } else if ([op isEqualToString:THROW]) {
    operation = [ThrowOperation throwOperationFromString:opString];
  } else if ([op isEqualToString:CORNER]) {
    operation = [CornerOperation cornerOperationFromString:opString];
  } else if ([op isEqualToString:CHAIN]) {
    operation = [ChainOperation chainOperationFromString:opString];
  } else if ([op isEqualToString:LAYOUT]) {
    operation = [LayoutOperation layoutOperationFromString:opString];
  } else if ([op isEqualToString:FOCUS]) {
    operation = [FocusOperation focusOperationFromString:opString];
  } else if ([op isEqualToString:SNAPSHOT]) {
    operation = [SnapshotOperation snapshotOperationFromString:opString];
  } else if ([op isEqualToString:ACTIVATE_SNAPSHOT]) {
    operation = [ActivateSnapshotOperation activateSnapshotOperationFromString:opString];
  } else if ([op isEqualToString:DELETE_SNAPSHOT]) {
    operation = [DeleteSnapshotOperation deleteSnapshotOperationFromString:opString];
  } else if ([op isEqualToString:HINT]) {
    operation = [HintOperation hintOperationFromString:opString];
  } else if ([op isEqualToString:SWITCH]) {
    operation = [SwitchOperation switchOperationFromString:opString];
  } else if ([op isEqualToString:GRID]) {
    operation = [GridOperation gridOperationFromString:opString];
  } else if ([op isEqualToString:SEQUENCE]) {
    operation = [SequenceOperation sequenceOperationFromString:opString];
  } else if ([op isEqualToString:TOGGLE] || [op isEqualToString:SHOW] || [op isEqualToString:HIDE]) {
    operation = [VisibilityOperation visibilityOperationFromString:opString];
  } else if ([op isEqualToString:RELAUNCH]) {
    operation = [RelaunchOperation relaunchOperationFromString:opString];
  } else if ([op isEqualToString:SHELL]) {
    operation = [ShellOperation shellOperationFromString:opString];
  } else if ([op isEqualToString:UNDO]) {
    operation = [UndoOperation undoOperationFromString:opString];
  } else {
    SlateLogger(@"ERROR: Unrecognized operation '%@'", opString);
    @throw([NSException exceptionWithName:@"Unrecognized Operation" reason:[NSString stringWithFormat:@"Unrecognized operation '%@' in '%@'", op, opString] userInfo:nil]);
  }
  if (operation != nil) { [operation setOpName:op]; }
  return operation;
}

+ (id)operationWithName:(NSString *)op options:(NSDictionary *)options {
  Operation *operation = nil;
  if ([op isEqualToString:MOVE]) {
    operation = [MoveOperation moveOperation];
  } else if ([op isEqualToString:RESIZE]) {
    operation = [ResizeOperation resizeOperation];
  } else if ([op isEqualToString:PUSH]) {
    operation = [PushOperation pushOperation];
  } else if ([op isEqualToString:NUDGE]) {
    operation = [NudgeOperation nudgeOperation];
  } else if ([op isEqualToString:THROW]) {
    operation = [ThrowOperation throwOperation];
  } else if ([op isEqualToString:CORNER]) {
    operation = [CornerOperation cornerOperation];
  } else if ([op isEqualToString:CHAIN]) {
    operation = [ChainOperation chainOperation];
  } else if ([op isEqualToString:LAYOUT]) {
    operation = [LayoutOperation layoutOperation];
  } else if ([op isEqualToString:FOCUS]) {
    operation = [FocusOperation focusOperation];
  } else if ([op isEqualToString:SNAPSHOT]) {
    operation = [SnapshotOperation snapshotOperation];
  } else if ([op isEqualToString:ACTIVATE_SNAPSHOT]) {
    operation = [ActivateSnapshotOperation activateSnapshotOperation];
  } else if ([op isEqualToString:DELETE_SNAPSHOT]) {
    operation = [DeleteSnapshotOperation deleteSnapshotOperation];
  } else if ([op isEqualToString:HINT]) {
    operation = [HintOperation hintOperation];
  } else if ([op isEqualToString:SWITCH]) {
    operation = [SwitchOperation switchOperation];
  } else if ([op isEqualToString:GRID]) {
    operation = [GridOperation gridOperation];
  } else if ([op isEqualToString:SEQUENCE]) {
    operation = [SequenceOperation sequenceOperation];
  } else if ([op isEqualToString:TOGGLE] || [op isEqualToString:SHOW] || [op isEqualToString:HIDE]) {
    operation = [VisibilityOperation visibilityOperation];
  } else if ([op isEqualToString:RELAUNCH]) {
    operation = [RelaunchOperation relaunchOperation];
  } else if ([op isEqualToString:SHELL]) {
    operation = [ShellOperation shellOperation];
  } else if ([op isEqualToString:UNDO]) {
    operation = [UndoOperation undoOperation];
  } else {
    SlateLogger(@"ERROR: Unrecognized operation '%@'", op);
    @throw([NSException exceptionWithName:@"Unrecognized Operation" reason:[NSString stringWithFormat:@"Unrecognized operation '%@'", op] userInfo:nil]);
  }
  if (operation != nil) {
    [operation setOpName:op];
    [operation initOptions:options];
  }
  return operation;
}

@end

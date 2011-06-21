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
#import "Constants.h"
#import "Layout.h"
#import "LayoutOperation.h"
#import "ScreenState.h"
#import "ScreenWrapper.h"
#import "SlateConfig.h"
#import "StringTokenizer.h"


@implementation SlateConfig

@synthesize configs;
@synthesize bindings;
@synthesize layouts;
@synthesize defaultLayouts;
@synthesize aliases;

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
    [self setLayouts:[[NSMutableDictionary alloc] init]];
    [self setDefaultLayouts:[[NSMutableArray alloc] init]];
    [self setAliases:[[NSMutableDictionary alloc] init]];

    // Listen for screen change notifications
    NSNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onScreenChange:) name:NOTIFICATION_SCREEN_CHANGE object:nil];
  }
  return self;
}

- (BOOL)getBoolConfig:(NSString *)key {
  return [[configs objectForKey:key] boolValue];
}

- (BOOL)getBoolConfig:(NSString *)key defaultValue:(BOOL)defaultValue {
  if ([configs objectForKey:key] != nil)
    return [[configs objectForKey:key] boolValue];
  return defaultValue;
}

- (NSInteger)getIntegerConfig:(NSString *)key {
  return [[configs objectForKey:key] integerValue];
}

- (NSInteger)getIntegerConfig:(NSString *)key defaultValue:(NSInteger)defaultValue {
  if ([configs objectForKey:key] != nil)
    return [[configs objectForKey:key] integerValue];
  return defaultValue;
}

- (double)getDoubleConfig:(NSString *)key {
  return [[configs objectForKey:key] doubleValue];
}

- (double)getDoubleConfig:(NSString *)key defaultValue:(double)defaultValue {
  if ([configs objectForKey:key] != nil)
    return [[configs objectForKey:key] doubleValue];
  return defaultValue;
}

- (NSString *)getConfig:(NSString *)key {
  return [configs objectForKey:key];
}

- (NSString *)getConfig:(NSString *)key defaultValue:(NSString *)defaultValue{
  if ([configs objectForKey:key] != nil)
    return [configs objectForKey:key];
  return defaultValue;
}

- (BOOL)load {
  NSLog(@"Loading config...");

  // Reset configs and bindings in case we are calling from menu
  [self setConfigs:[[NSMutableDictionary alloc] init]];
  [self setBindings:[[NSMutableArray alloc] initWithCapacity:10]];
  [self setLayouts:[[NSMutableDictionary alloc] init]];
  [self setAliases:[[NSMutableDictionary alloc] init]];

  if (![self append:@"~/.slate"]) {
    NSLog(@"  ERROR Could not load ~/.slate");
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Quit"];
    [alert addButtonWithTitle:@"Skip"];
    [alert setMessageText:@"ERROR Could not load ~/.slate"];
    [alert setInformativeText:@"I dunno. Figure it out."];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      NSLog(@"User selected exit");
      [NSApp terminate:nil];
    }
    [alert release];
    return NO;
  }

  if ([[SlateConfig getInstance] getBoolConfig:CHECK_DEFAULTS_ON_LOAD defaultValue:CHECK_DEFAULTS_ON_LOAD_DEFAULT]) {
    NSLog(@"Config loaded. Checking defaults...");
    [self onScreenChange:nil];
    NSLog(@"Defaults loaded.");
  } else {
    NSLog(@"Config loaded.");
  }

  return YES;
}

- (BOOL)append:(NSString *)file {
  if (file == nil) return NO;
  NSString *homeDir = NSHomeDirectory();
  NSString *configFile = file;
  if ([file rangeOfString:TILDA].location != NSNotFound)
    configFile = [file stringByReplacingOccurrencesOfString:TILDA withString:homeDir];
  else if ([file rangeOfString:SLASH].location != 0)
    configFile = [homeDir stringByAppendingFormat:@"/%@",file];
  NSString *fileString = [NSString stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:nil];
  if (fileString == nil)
    return NO;
  NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
  
  NSEnumerator *e = [lines objectEnumerator];
  NSString *line = [e nextObject];
  while (line) {
    @try {
      line = [self replaceAliases:line];
    } @catch (NSException *ex) {
      NSLog(@"   ERROR %@",[ex name]);
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
    NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
    [StringTokenizer tokenize:line into:tokens];
    if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:CONFIG]) {
      // config <key> <value>
      NSLog(@"  LoadingC: %@",line);
      [configs setObject:[tokens objectAtIndex:2] forKey:[tokens objectAtIndex:1]];
    } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:BIND]) {
      // bind <key:modifiers> <op> <parameters>
      @try {
        Binding *bind = [[Binding alloc] initWithString:line];
        NSLog(@"  LoadingB: %@",line);
        [bindings addObject:bind];
        [bind release];
      } @catch (NSException *ex) {
        NSLog(@"   ERROR %@",[ex name]);
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
    } else if ([tokens count] >= 4 && [[tokens objectAtIndex:0] isEqualToString:LAYOUT]) {
      // layout <name> <app name> <op+params> (| <op+params>)*
      @try {
        if ([layouts objectForKey:[tokens objectAtIndex:1]] == nil) {
          Layout *layout = [[Layout alloc] initWithString:line];
          NSLog(@"  LoadingL: %@",line);
          [layouts setObject:layout forKey:[layout name]];
        } else {
          Layout *layout = [layouts objectForKey:[tokens objectAtIndex:1]];
          [layout addWithString:line];
          NSLog(@"  LoadingL: %@",line);
        }
      } @catch (NSException *ex) {
        NSLog(@"   ERROR %@",[ex name]);
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
    } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:DEFAULT]) {
      // default <name> <screen-setup>
      @try {
        ScreenState *state = [[ScreenState alloc] initWithString:line];
        if (state == nil) {
          NSLog(@"   ERROR Loading default layout");
          NSAlert *alert = [[NSAlert alloc] init];
          [alert addButtonWithTitle:@"Quit"];
          [alert addButtonWithTitle:@"Skip"];
          [alert setMessageText:@"Error loading default layout"];
          [alert setInformativeText:line];
          [alert setAlertStyle:NSWarningAlertStyle];
          if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSLog(@"User selected exit");
            [NSApp terminate:nil];
          }
          [alert release];
        } else {
          [defaultLayouts addObject:state];
          NSLog(@"  LoadingDL: %@",line);
        }
        [state release];
      } @catch (NSException *ex) {
        NSLog(@"   ERROR %@",[ex name]);
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
    } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:ALIAS]) {
      // alias <name> <value>
      @try {
        [self addAlias:line];
        NSLog(@"  LoadingL: %@",line);
      } @catch (NSException *ex) {
        NSLog(@"   ERROR %@",[ex name]);
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
    } else if ([tokens count] >= 2 && [[tokens objectAtIndex:0] isEqualToString:SOURCE]) {
      // source filename optional:if_exists
      NSLog(@"  LoadingS: %@",line);
      if (![self append:[tokens objectAtIndex:1]]) {
        if ([tokens count] >= 3 && [[tokens objectAtIndex:2] isEqualToString:IF_EXISTS]) {
          NSLog(@"   Could not find file '%@' but that's ok. User specified if_exists.",[tokens objectAtIndex:1]);
        } else {
          NSLog(@"   ERROR Sourcing file '%@'",[tokens objectAtIndex:1]);
          NSAlert *alert = [[NSAlert alloc] init];
          [alert addButtonWithTitle:@"Quit"];
          [alert addButtonWithTitle:@"Skip"];
          [alert setMessageText:[NSString stringWithFormat:@"ERROR Sourcing file '%@'",[tokens objectAtIndex:1]]];
          [alert setInformativeText:@"I dunno. Figure it out."];
          [alert setAlertStyle:NSWarningAlertStyle];
          if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSLog(@"User selected exit");
            [NSApp terminate:nil];
          }
        [alert release];
        }
      }
    }
    [tokens release];
    line = [e nextObject];
  }
  return YES;
}

- (void)addAlias:(NSString *)line {
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:line into:tokens maxTokens:3];
  [aliases setObject:[tokens objectAtIndex:2] forKey:[NSString stringWithFormat:@"${%@}",[tokens objectAtIndex:1]]];
  [tokens release];
}

- (void)dealloc {
  [self setConfigs:nil];
  [self setBindings:nil];
  [super dealloc];
}

- (NSString *)replaceAliases:(NSString *)line {
  NSArray *aliasNames = [aliases allKeys];
  for (NSInteger i = 0; i < [aliasNames count]; i++) {
    line = [line stringByReplacingOccurrencesOfString:[aliasNames objectAtIndex:i] withString:[aliases objectForKey:[aliasNames objectAtIndex:i]]];
  }
  if ([line rangeOfString:@"${"].length > 0) {
    @throw([NSException exceptionWithName:@"Unrecognized Alias" reason:[NSString stringWithFormat:@"Unrecognized alias in '%@'", line] userInfo:nil]);
  }
  return line;
}

- (void)onScreenChange:(id)notification {
  NSLog(@"onScreenChange");
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  NSInteger screenCount = [sw getScreenCount];
  NSMutableArray *resolutions = [[NSMutableArray alloc] initWithCapacity:10];
  [sw getScreenResolutionStrings:resolutions];
  [resolutions sortUsingSelector:@selector(compare:)];
  for (NSInteger i = 0; i < [defaultLayouts count]; i++) {
    ScreenState *state = [defaultLayouts objectAtIndex:i];
    // Check count
    if ([state type] == TYPE_COUNT && [state count] == screenCount) {
      NSLog(@"onScreenChange count found");
      LayoutOperation *op = [[LayoutOperation alloc] initWithName:[state layout]];
      [op doOperation];
      [op release];
      break;
    }
    // Check resolutions
    if ([resolutions count] == [[state resolutions] count]) {
      NSLog(@"onScreenChange resolution counts equal. Check %@ vs %@",resolutions,[state resolutions]);
      BOOL isEqual = YES;
      for (NSInteger j = 0; j < [resolutions count]; j++) {
        if (![[resolutions objectAtIndex:j] isEqualToString:[[state resolutions] objectAtIndex:j]]) {
          isEqual = NO;
          break;
        }
      }
      if (isEqual) {
        LayoutOperation *op = [[LayoutOperation alloc] initWithName:[state layout]];
        [op doOperation];
        [op release];
        break;
      }
    }
  }
  [resolutions release];
  [sw release];
}

@end

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
#import "Snapshot.h"
#import "SnapshotList.h"
#import "JSONKit.h"
#import "SlateLogger.h"

@implementation SlateConfig

@synthesize configs;
@synthesize configDefaults;
@synthesize bindings;
@synthesize layouts;
@synthesize defaultLayouts;
@synthesize aliases;
@synthesize snapshots;

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
    [self setupDefaultConfigs];
    [self setBindings:[[NSMutableArray alloc] initWithCapacity:10]];
    [self setLayouts:[[NSMutableDictionary alloc] init]];
    [self setDefaultLayouts:[[NSMutableArray alloc] init]];
    [self setAliases:[[NSMutableDictionary alloc] init]];
    [self setSnapshots:[[NSMutableDictionary alloc] init]];

    // Listen for screen change notifications
    NSNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onScreenChange:) name:NOTIFICATION_SCREEN_CHANGE object:nil];
    [nc addObserver:self selector:@selector(onScreenChange:) name:NOTIFICATION_SCREEN_CHANGE_LION object:nil];
    //[nc addObserver:self selector:@selector(processNotification:) name:nil object:nil];
  }
  return self;
}

- (BOOL)getBoolConfig:(NSString *)key {
  return [[configs objectForKey:key] boolValue];
}

- (NSInteger)getIntegerConfig:(NSString *)key {
  return [[configs objectForKey:key] integerValue];
}

- (double)getDoubleConfig:(NSString *)key {
  return [[configs objectForKey:key] doubleValue];
}

- (float)getFloatConfig:(NSString *)key {
  return [[configs objectForKey:key] floatValue];
}

- (NSArray *)getArrayConfig:(NSString *)key {
  return [[configs objectForKey:key] componentsSeparatedByString:SEMICOLON];
}

- (NSString *)getConfig:(NSString *)key {
  return [configs objectForKey:key];
}

- (NSString *)getConfigDefault:(NSString *)key {
  return [configDefaults objectForKey:key];
}

- (BOOL)load {
  SlateLogger(@"Loading config...");

  // Reset configs and bindings in case we are calling from menu
  [self setupDefaultConfigs];
  [self setBindings:[[NSMutableArray alloc] initWithCapacity:10]];
  [self setLayouts:[[NSMutableDictionary alloc] init]];
  [self setDefaultLayouts:[[NSMutableArray alloc] init]];
  [self setAliases:[[NSMutableDictionary alloc] init]];

  if (![self append:@"~/.slate"]) {
    SlateLogger(@"  ERROR Could not load ~/.slate");
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Quit"];
    [alert addButtonWithTitle:@"Skip"];
    [alert setMessageText:@"ERROR Could not load ~/.slate"];
    [alert setInformativeText:@"I dunno. Figure it out."];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
    return NO;
  }
  
  if (![self loadSnapshots]) {
    SlateLogger(@"  ERROR Could not load %@", SNAPSHOTS_FILE);
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Quit"];
    [alert addButtonWithTitle:@"Skip"];
    [alert setMessageText:[NSString stringWithFormat:@"ERROR Could not load %@", SNAPSHOTS_FILE]];
    [alert setInformativeText:[NSString stringWithFormat:@"I dunno. Figure it out. Maybe try deleting %@", SNAPSHOTS_FILE]];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
    return NO;
  }

  if ([[SlateConfig getInstance] getBoolConfig:CHECK_DEFAULTS_ON_LOAD]) {
    SlateLogger(@"Config loaded. Checking defaults...");
    [self checkDefaults];
    SlateLogger(@"Defaults loaded.");
  } else {
    SlateLogger(@"Config loaded.");
  }

  return YES;
}

- (BOOL)append:(NSString *)file {
  if (file == nil) return NO;
  NSString *configFile = file;
  if ([file rangeOfString:SLASH].location != 0 && [file rangeOfString:TILDA].location != 0)
    configFile = [NSString stringWithFormat:@"~/%@", file];
  NSString *fileString = [NSString stringWithContentsOfFile:[configFile stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil];
  if (fileString == nil)
    return NO;
  NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
  
  NSEnumerator *e = [lines objectEnumerator];
  NSString *line = [e nextObject];
  while (line) {
    @try {
      line = [self replaceAliases:line];
    } @catch (NSException *ex) {
      SlateLogger(@"   ERROR %@",[ex name]);
      NSAlert *alert = [[NSAlert alloc] init];
      [alert addButtonWithTitle:@"Quit"];
      [alert addButtonWithTitle:@"Skip"];
      [alert setMessageText:[ex name]];
      [alert setInformativeText:[ex reason]];
      [alert setAlertStyle:NSWarningAlertStyle];
      if ([alert runModal] == NSAlertFirstButtonReturn) {
        SlateLogger(@"User selected exit");
        [NSApp terminate:nil];
      }
    }
    NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
    [StringTokenizer tokenize:line into:tokens];
    if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:CONFIG]) {
      // config <key> <value>
      SlateLogger(@"  LoadingC: %@",line);
      if ([configs objectForKey:[tokens objectAtIndex:1]] == nil) {
        SlateLogger(@"   ERROR Unrecognized config '%@'",[tokens objectAtIndex:1]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Skip"];
        [alert setMessageText:[NSString stringWithFormat:@"Unrecognized Config '%@'",[tokens objectAtIndex:1]]];
        [alert setInformativeText:line];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
          SlateLogger(@"User selected exit");
          [NSApp terminate:nil];
        }
      } else {
        [configs setObject:[tokens objectAtIndex:2] forKey:[tokens objectAtIndex:1]];
      }
    } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:BIND]) {
      // bind <key:modifiers> <op> <parameters>
      @try {
        Binding *bind = [[Binding alloc] initWithString:line];
        SlateLogger(@"  LoadingB: %@",line);
        [bindings addObject:bind];
      } @catch (NSException *ex) {
        SlateLogger(@"   ERROR %@",[ex name]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Skip"];
        [alert setMessageText:[ex name]];
        [alert setInformativeText:[ex reason]];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
          SlateLogger(@"User selected exit");
          [NSApp terminate:nil];
        }
      }
    } else if ([tokens count] >= 4 && [[tokens objectAtIndex:0] isEqualToString:LAYOUT]) {
      // layout <name> <app name> <op+params> (| <op+params>)*
      @try {
        if ([layouts objectForKey:[tokens objectAtIndex:1]] == nil) {
          Layout *layout = [[Layout alloc] initWithString:line];
          SlateLogger(@"  LoadingL: %@",line);
          [layouts setObject:layout forKey:[layout name]];
        } else {
          Layout *layout = [layouts objectForKey:[tokens objectAtIndex:1]];
          [layout addWithString:line];
          SlateLogger(@"  LoadingL: %@",line);
        }
      } @catch (NSException *ex) {
        SlateLogger(@"   ERROR %@",[ex name]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Skip"];
        [alert setMessageText:[ex name]];
        [alert setInformativeText:[ex reason]];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
          SlateLogger(@"User selected exit");
          [NSApp terminate:nil];
        }
      }
    } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:DEFAULT]) {
      // default <name> <screen-setup>
      @try {
        ScreenState *state = [[ScreenState alloc] initWithString:line];
        if (state == nil) {
          SlateLogger(@"   ERROR Loading default layout");
          NSAlert *alert = [[NSAlert alloc] init];
          [alert addButtonWithTitle:@"Quit"];
          [alert addButtonWithTitle:@"Skip"];
          [alert setMessageText:@"Error loading default layout"];
          [alert setInformativeText:line];
          [alert setAlertStyle:NSWarningAlertStyle];
          if ([alert runModal] == NSAlertFirstButtonReturn) {
            SlateLogger(@"User selected exit");
            [NSApp terminate:nil];
          }
        } else {
          [defaultLayouts addObject:state];
          SlateLogger(@"  LoadingDL: %@",line);
        }
      } @catch (NSException *ex) {
        SlateLogger(@"   ERROR %@",[ex name]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Skip"];
        [alert setMessageText:[ex name]];
        [alert setInformativeText:[ex reason]];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
          SlateLogger(@"User selected exit");
          [NSApp terminate:nil];
        }
      }
    } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:ALIAS]) {
      // alias <name> <value>
      @try {
        [self addAlias:line];
        SlateLogger(@"  LoadingL: %@",line);
      } @catch (NSException *ex) {
        SlateLogger(@"   ERROR %@",[ex name]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Skip"];
        [alert setMessageText:[ex name]];
        [alert setInformativeText:[ex reason]];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
          SlateLogger(@"User selected exit");
          [NSApp terminate:nil];
        }
      }
    } else if ([tokens count] >= 2 && [[tokens objectAtIndex:0] isEqualToString:SOURCE]) {
      // source filename optional:if_exists
      SlateLogger(@"  LoadingS: %@",line);
      if (![self append:[tokens objectAtIndex:1]]) {
        if ([tokens count] >= 3 && [[tokens objectAtIndex:2] isEqualToString:IF_EXISTS]) {
          SlateLogger(@"   Could not find file '%@' but that's ok. User specified if_exists.",[tokens objectAtIndex:1]);
        } else {
          SlateLogger(@"   ERROR Sourcing file '%@'",[tokens objectAtIndex:1]);
          NSAlert *alert = [[NSAlert alloc] init];
          [alert addButtonWithTitle:@"Quit"];
          [alert addButtonWithTitle:@"Skip"];
          [alert setMessageText:[NSString stringWithFormat:@"ERROR Sourcing file '%@'",[tokens objectAtIndex:1]]];
          [alert setInformativeText:@"I dunno. Figure it out."];
          [alert setAlertStyle:NSWarningAlertStyle];
          if ([alert runModal] == NSAlertFirstButtonReturn) {
            SlateLogger(@"User selected exit");
            [NSApp terminate:nil];
          }
        }
      }
    }
    line = [e nextObject];
  }
  return YES;
}

- (void)snapshotsFromDictionary:(NSDictionary *)snapshotsDict {
  NSArray *keys = [snapshotsDict allKeys];
  for (NSString *name in keys) {
    SnapshotList *list = [SnapshotList snapshotListFromDictionary:[snapshotsDict objectForKey:name]];
    [snapshots setObject:list forKey:[list name]];
  }
}

- (BOOL)loadSnapshots {
  NSString *fileString = [NSString stringWithContentsOfFile:[SNAPSHOTS_FILE stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil];
  if (fileString == nil || [fileString isEqualToString:EMPTY])
    return YES;
  id iShouldBeADictionary = [fileString objectFromJSONString];
  if (![iShouldBeADictionary isKindOfClass:[NSDictionary class]]) return NO;
  NSDictionary *snapshotsDict = iShouldBeADictionary;
  [self snapshotsFromDictionary:snapshotsDict];
  return YES;
}

- (void)addAlias:(NSString *)line {
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:line into:tokens maxTokens:3];
  [aliases setObject:[tokens objectAtIndex:2] forKey:[NSString stringWithFormat:@"${%@}",[tokens objectAtIndex:1]]];
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

/*- (void)processNotification:(id)notification {
  SlateLogger(@"Notification: %@", notification);
  SlateLogger(@"Notification Name: <%@>", [notification name]);
}*/

- (void)checkDefaults {
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  NSInteger screenCount = [sw getScreenCount];
  NSMutableArray *resolutions = [[NSMutableArray alloc] initWithCapacity:10];
  [sw getScreenResolutionStrings:resolutions];
  [resolutions sortUsingSelector:@selector(compare:)];
  for (NSInteger i = 0; i < [defaultLayouts count]; i++) {
    ScreenState *state = [defaultLayouts objectAtIndex:i];
    // Check count
    if ([state type] == TYPE_COUNT && [state count] == screenCount) {
      SlateLogger(@"onScreenChange count found");
      LayoutOperation *op = [[LayoutOperation alloc] initWithName:[state layout]];
      [op doOperation];
      break;
    }
    // Check resolutions
    if ([resolutions count] == [[state resolutions] count]) {
      SlateLogger(@"onScreenChange resolution counts equal. Check %@ vs %@",resolutions,[state resolutions]);
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
        break;
      }
    }
  }

}

- (void)onScreenChange:(id)notification {
  SlateLogger(@"onScreenChange");
  if (![ScreenWrapper hasScreenConfigChanged]) return;
  [self checkDefaults];
}

- (NSDictionary *)snapshotsToDictionary {
  NSMutableDictionary *snapshotDict = [NSMutableDictionary dictionary];
  NSArray *keys = [snapshots allKeys];
  for (NSString *name in keys) {
    SnapshotList *list = [snapshots objectForKey:name];
    if (![list saveToDisk]) continue;
    [snapshotDict setObject:[list toDictionary] forKey:name];
  }
  return snapshotDict;
}

- (void)saveSnapshots {
  // Build NSDictionary with snapshots
  NSDictionary *snapshotDict = [self snapshotsToDictionary];
  
  // Get NSData from NSDictionary
  NSData *jsonData = [snapshotDict JSONData];
  
  // Save NSData to file
  [jsonData writeToFile:[SNAPSHOTS_FILE stringByExpandingTildeInPath] atomically:YES];
}

- (void)addSnapshot:(Snapshot *)snapshot name:(NSString *)name saveToDisk:(BOOL)saveToDisk isStack:(BOOL)isStack {
  SnapshotList *list = [snapshots objectForKey:name];
  if (list == nil) {
    list = [[SnapshotList alloc] initWithName:name saveToDisk:saveToDisk isStack:isStack];
  } else {
    [list setName:name];
    [list setSaveToDisk:saveToDisk];
    [list setIsStack:isStack];
  }
  [list addSnapshot:snapshot];
  [snapshots setObject:list forKey:name];
  
  [self saveSnapshots];
}

- (void)deleteSnapshot:(NSString *)name pop:(BOOL)pop {
  if (pop) {
    SnapshotList *list = [snapshots objectForKey:name];
    if (list) {
      [list popSnapshot:YES];
    }
  } else {
    [snapshots removeObjectForKey:name];
  }
  
  [self saveSnapshots];
}

- (Snapshot *)popSnapshot:(NSString *)name remove:(BOOL)remove {
  SnapshotList *list = [snapshots objectForKey:name];
  Snapshot *snapshot = nil;
  if (list) {
    snapshot = [list popSnapshot:remove];
  }
  [self saveSnapshots];
  return snapshot;
}

- (void)setupDefaultConfigs {
  [self setConfigDefaults:[NSMutableDictionary dictionaryWithCapacity:10]];
  [configDefaults setObject:DEFAULT_TO_CURRENT_SCREEN_DEFAULT forKey:DEFAULT_TO_CURRENT_SCREEN];
  [configDefaults setObject:NUDGE_PERCENT_OF_DEFAULT forKey:NUDGE_PERCENT_OF];
  [configDefaults setObject:RESIZE_PERCENT_OF_DEFAULT forKey:RESIZE_PERCENT_OF];
  [configDefaults setObject:REPEAT_ON_HOLD_OPS_DEFAULT forKey:REPEAT_ON_HOLD_OPS];
  [configDefaults setObject:SECONDS_BETWEEN_REPEAT_DEFAULT forKey:SECONDS_BETWEEN_REPEAT];
  [configDefaults setObject:CHECK_DEFAULTS_ON_LOAD_DEFAULT forKey:CHECK_DEFAULTS_ON_LOAD];
  [configDefaults setObject:FOCUS_CHECK_WIDTH_DEFAULT forKey:FOCUS_CHECK_WIDTH];
  [configDefaults setObject:FOCUS_CHECK_WIDTH_MAX_DEFAULT forKey:FOCUS_CHECK_WIDTH_MAX];
  [configDefaults setObject:FOCUS_PREFER_SAME_APP_DEFAULT forKey:FOCUS_PREFER_SAME_APP];
  [configDefaults setObject:ORDER_SCREENS_LEFT_TO_RIGHT_DEFAULT forKey:ORDER_SCREENS_LEFT_TO_RIGHT];
  [configDefaults setObject:WINDOW_HINTS_BACKGROUND_COLOR_DEFAULT forKey:WINDOW_HINTS_BACKGROUND_COLOR];
  [configDefaults setObject:WINDOW_HINTS_FONT_COLOR_DEFAULT forKey:WINDOW_HINTS_FONT_COLOR];
  [configDefaults setObject:WINDOW_HINTS_FONT_NAME_DEFAULT forKey:WINDOW_HINTS_FONT_NAME];
  [configDefaults setObject:WINDOW_HINTS_FONT_SIZE_DEFAULT forKey:WINDOW_HINTS_FONT_SIZE];
  [configDefaults setObject:WINDOW_HINTS_HEIGHT_DEFAULT forKey:WINDOW_HINTS_HEIGHT];
  [configDefaults setObject:WINDOW_HINTS_WIDTH_DEFAULT forKey:WINDOW_HINTS_WIDTH];
  [configDefaults setObject:WINDOW_HINTS_DURATION_DEFAULT forKey:WINDOW_HINTS_DURATION];
  [configDefaults setObject:WINDOW_HINTS_ROUNDED_CORNER_SIZE_DEFAULT forKey:WINDOW_HINTS_ROUNDED_CORNER_SIZE];
  [configDefaults setObject:WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS_DEFAULT forKey:WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS];
  [configDefaults setObject:WINDOW_HINTS_TOP_LEFT_X_DEFAULT forKey:WINDOW_HINTS_TOP_LEFT_X];
  [configDefaults setObject:WINDOW_HINTS_TOP_LEFT_Y_DEFAULT forKey:WINDOW_HINTS_TOP_LEFT_Y];
  [configDefaults setObject:WINDOW_HINTS_ORDER_DEFAULT forKey:WINDOW_HINTS_ORDER];
  [configDefaults setObject:SWITCH_ICON_SIZE_DEFAULT forKey:SWITCH_ICON_SIZE];
  [configDefaults setObject:SWITCH_BACKGROUND_COLOR_DEFAULT forKey:SWITCH_BACKGROUND_COLOR];
  [configDefaults setObject:SWITCH_ROUNDED_CORNER_SIZE_DEFAULT forKey:SWITCH_ROUNDED_CORNER_SIZE];
  [self setConfigs:[NSMutableDictionary dictionaryWithCapacity:10]];
  [configs setValuesForKeysWithDictionary:configDefaults];
}


@end

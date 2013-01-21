//
//  GridOperation.m
//  Slate
//
//  Created by Jigish Patel on 9/7/12.
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

#import "GridOperation.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"
#import "Constants.h"
#import "GridWindow.h"
#import "GridView.h"
#import "Binding.h"
#import "SlateAppDelegate.h"
#import "ExpressionPoint.h"
#import "MoveOperation.h"

@interface ScreenConfig : NSObject {
  NSInteger width;
  NSInteger height;
  NSString *key;
}

@property NSInteger width;
@property NSInteger height;
@property NSString *key;

+ (ScreenConfig *)screenConfigFromDictionary:(NSDictionary *)dict key:(NSString *)key;

@end

@implementation ScreenConfig

@synthesize width, height, key;

+ (ScreenConfig *)screenConfigFromDictionary:(NSDictionary *)dict key:(NSString *)key {
  if ([dict objectForKey:WIDTH] == nil || [dict objectForKey:HEIGHT] == nil || key == nil) {
    @throw([NSException exceptionWithName:@"Invalid Grid" reason:[NSString stringWithFormat:@"Invalid Grid '%@'", key] userInfo:nil]);
  }
  ScreenConfig *sc = [[ScreenConfig alloc] init];
  [sc setWidth:[[dict objectForKey:WIDTH] integerValue]];
  [sc setHeight:[[dict objectForKey:HEIGHT] integerValue]];
  [sc setKey:key];
  return sc;
}

@end

@implementation GridOperation

@synthesize screenConfigs, grids, focusedWindow, padding;

static const UInt32 ESC_GRID_ID = 10002;

- (id)init {
  self = [super init];
  if (self) {
    [self setScreenConfigs:[NSMutableDictionary dictionary]];
    [self setGrids:[NSMutableArray array]];
    [self setPadding:2];
  }
  return self;
}

- (id)initWithScreenConfigs:(NSDictionary *)myScreenConfigs padding:(NSInteger)myPadding {
  self = [super init];
  if (self) {
    [self setScreenConfigs:myScreenConfigs];
    [self setGrids:[NSMutableArray array]];
    [self setPadding:myPadding];
  }
  return self;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Grid Operation -----------------");
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:sw];
  SlateLogger(@"-----------------  End Grid Operation  -----------------");
  return success;
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  [self evalOptions];
  [self setFocusedWindow:[[AccessibilityWrapper alloc] init]];
  NSInteger currentScreenId = [sw getScreenIdForPoint:[NSEvent mouseLocation]];
  [(SlateAppDelegate *)[NSApp delegate] setCurrentGridOperation:self];
  NSInteger screenId = 0;
  NSWindow *toFocus = nil;
  for (NSScreen *screen in [sw screens]) {
    NSRect frame;
    frame = NSMakeRect([screen frame].size.width/2-[screen frame].size.width/8,
                       [screen frame].size.height/2-[screen frame].size.height/8,
                       [screen frame].size.width/4,
                       [screen frame].size.height/4);
    NSWindow *window = [[GridWindow alloc] initWithContentRect:frame
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO
                                                        screen:screen];
    [window setReleasedWhenClosed:NO];
    [window setOpaque:NO];
    [window setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    [window makeKeyAndOrderFront:NSApp];
    [window setLevel:(NSScreenSaverWindowLevel - 1)];
    GridView *view = [[GridView alloc] initWithFrame:frame];
    NSInteger width = 12;
    NSInteger height = 12;
    NSString *resolution = [NSString stringWithFormat:@"%ldx%ld", [[NSNumber numberWithFloat:[screen frame].size.width] integerValue], [[NSNumber numberWithFloat:[screen frame].size.height] integerValue]];
    ScreenConfig *myConfig = [[self screenConfigs] objectForKey:resolution];
    if (myConfig == nil) {
      myConfig = [[self screenConfigs] objectForKey:[NSString stringWithFormat:@"%ld",screenId]];
    }
    if (myConfig != nil) {
      height = [myConfig height];
      width = [myConfig width];
    }
    [view addGridWithWidth:width height:height padding:[self padding]];
    [view setOp:self];
    [window setContentView:view];
    NSWindowController *wc = [[NSWindowController alloc] initWithWindow:window];
    [grids addObject:wc];
    if (screenId == currentScreenId) { toFocus = window; }
    screenId++;
  }
  if (toFocus != nil) {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [toFocus makeKeyAndOrderFront:self];
  }

  // Register the escape hotkey
  NSNumber *keyCode = [[Binding asciiToCodeDict] objectForKey:@"esc"];
  EventHotKeyID myHotKeyID;
  EventHotKeyRef myHotKeyRef;
  myHotKeyID.signature = *[@"hotkeyESC" cStringUsingEncoding:NSASCIIStringEncoding];
  myHotKeyID.id = (UInt32)(ESC_GRID_ID);
  RegisterEventHotKey([keyCode unsignedIntValue], 0, myHotKeyID, GetEventMonitorTarget(), 0, &myHotKeyRef);
  escHotKeyRef = myHotKeyRef;

  return YES;
}

- (void)killGrids {
  for (NSWindowController *controller in grids) {
    [controller close];
  }
  UnregisterEventHotKey(escHotKeyRef);
  [grids removeAllObjects];
  [(SlateAppDelegate *)[NSApp delegate] setCurrentGridOperation:nil];
}

- (void)activateGridKey:(NSInteger)hintId {
  [self killGrids];
}

- (BOOL)testOperation {
  return YES;
}

- (void)activateLayoutWithOrigin:(ExpressionPoint *)origin size:(ExpressionPoint *)size screenId:(NSInteger)screenId {
  NSLog(@"Activate Layout: %@, %@, %@, %@", origin.x, origin.y, size.x, size.y);
  MoveOperation *mo = [[MoveOperation alloc] initWithTopLeftEP:origin dimensionsEP:size screenId:screenId];
  [focusedWindow focus];
  [mo doOperation];
}

- (void)parseOption:(NSString *)name value:(id)value {
  if (value == nil) { return; }
  if ([name isEqualToString:OPT_PADDING]) {
    // should be a string or integer
    if (![value isKindOfClass:[NSString class]] && ![value isKindOfClass:[NSValue class]]) {
      @throw([NSException exceptionWithName:@"Invalid Padding" reason:[NSString stringWithFormat:@"Invalid Padding '%@'", value] userInfo:nil]);
    }
    [self setPadding:[value integerValue]];
  } else if ([name isEqualToString:OPT_GRIDS]) {
    // should be a dictionary
    if (![value isKindOfClass:[NSDictionary class]]) {
      @throw([NSException exceptionWithName:@"Invalid Grids" reason:[NSString stringWithFormat:@"Invalid Grids '%@'", value] userInfo:nil]);
    }
    NSMutableDictionary *configs = [NSMutableDictionary dictionary];
    for (NSString *screen in [value allKeys]) {
      id dict = [value objectForKey:screen];
      if (![dict isKindOfClass:[NSDictionary class]]) {
        @throw([NSException exceptionWithName:@"Invalid Grid" reason:[NSString stringWithFormat:@"Invalid Grid '%@'", value] userInfo:nil]);
      }
      [configs setObject:[ScreenConfig screenConfigFromDictionary:dict key:screen] forKey:screen];
    }
    [self setScreenConfigs:configs];
  }
}

+ (id)gridOperation {
  return [[GridOperation alloc] init];
}

+ (id)gridOperationFromString:(NSString *) gridOperation {
  // grid padding:<padding> <screenNumber or resolution>:<width>,<height> ...
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:gridOperation into:tokens];

  if ([tokens count] < 1) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", gridOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Grid operations require the following format: 'grid <screenNumber or resolution>:<width>,<height> ...'", gridOperation] userInfo:nil]);
  }

  NSMutableDictionary *screenConfigs = [NSMutableDictionary dictionary];
  NSInteger padding = 2;
  if ([tokens count] > 1) {
    for (NSInteger i = 1; i < [tokens count]; i++) {
      NSArray *split = [[tokens objectAtIndex:i] componentsSeparatedByString:COLON];
      if ([split count] != 2) { continue; }
      NSString *key = [split objectAtIndex:0];
      if ([key isEqualToString:PADDING]) {
        padding = [[split objectAtIndex:1] integerValue];
        continue;
      }
      NSArray *widthHeight = [[split objectAtIndex:1] componentsSeparatedByString:COMMA];
      if ([widthHeight count] != 2) { continue; }
      ScreenConfig *screenConfig = [[ScreenConfig alloc] init];
      [screenConfig setKey:key];
      [screenConfig setWidth:[[widthHeight objectAtIndex:0] integerValue]];
      [screenConfig setHeight:[[widthHeight objectAtIndex:1] integerValue]];
      [screenConfigs setObject:screenConfig forKey:key];
    }
  }

  Operation *op = [[GridOperation alloc] initWithScreenConfigs:screenConfigs padding:padding];
  return op;
}

@end

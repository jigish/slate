//
//  ConfigurationHelperView.m
//  Slate
//
//  Created by Jigish Patel on 3/5/12.
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

#import "ConfigurationHelperView.h"
#import "SlateLogger.h"
#import "Constants.h"
#import "SlateConfig.h"

@implementation ConfigurationHelperView

@synthesize directiveLabel, directive, save, configs;

- (NSTextField *)createLabel:(NSString *)text frame:(NSRect)frame {
  NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
  [label setStringValue:text];
  [label setFont:[NSFont fontWithName:@"Menlo" size:11]];
  [label setSelectable:NO];
  [label setEnabled:NO];
  [label setDrawsBackground:NO];
  [label setBordered:NO];
  [label setBezeled:NO];
  return label;
}

- (NSTextField *)createTextField:(NSString *)text frame:(NSRect)frame {
  NSTextField *field = [[NSTextField alloc] initWithFrame:frame];
  [field setStringValue:text];
  [field setFont:[NSFont fontWithName:@"Menlo" size:11]];
  return field;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      configs = [NSMutableDictionary dictionary];
      directiveLabel = [self createLabel:@"Choose a Directive:" frame:NSMakeRect(5, frame.size.height - 25, 150, 20)];
      [self addSubview:directiveLabel];
      directive = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(150, frame.size.height - 25, 100, 22)];
      [directive addItemsWithTitles:[NSArray arrayWithObjects:EMPTY, CONFIG, LAYOUT, DEFAULT, BIND, nil]];
      [directive setTarget:self];
      [directive setAction:@selector(directiveChanged)];
      save = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width/2 - 50, 30, 100, 25)];
      [save setTitle:@"Save"];
      [save setTarget:self];
      [save setAction:@selector(saveToConfig)];
      [save setBezelStyle:NSRoundedBezelStyle];
      [self addSubview:directive];
      [self addSubview:save];
      [self addDirectiveSpecificUIs];
      [self updateDirectiveSpecificUI:[[directive selectedItem] title]];
    }
    return self;
}

- (void)directiveChanged {
  NSString *title = [[directive selectedItem] title];
  SlateLogger(@"Directive Changed: %@", title);
  [self updateDirectiveSpecificUI:title];
}

- (void)addDirectiveSpecificUIs {
   SlateLogger(@"addDirectiveSpecificUIs");
  [self addConfigUI];
}

- (void)hideDirectiveSpecificUIs {
  [self hideConfigUI];
}

- (void)addConfigUI {
  SlateLogger(@"addConfigUI");
  NSInteger i = 0;
  for (NSString *configName in [[[SlateConfig getInstance] configs] allKeys]) {
    if ([configs objectForKey:configName]) continue;
    SlateLogger(@"ADDING CONFIG %@", configName);
    NSTextField *configLabel = [self createLabel:configName frame:NSMakeRect(5, [self frame].size.height - 25 * (i+2), 215, 20)];
    NSTextField *configField = [self createTextField:[[SlateConfig getInstance] getConfig:configName] frame:NSMakeRect(220, [self frame].size.height - 25 * (i+2) + 1, 200, 20)];
    NSTextField *configDefault = [self createLabel:[NSString stringWithFormat:@"Default: %@", [[SlateConfig getInstance] getConfigDefault:configName]] frame:NSMakeRect(420, [self frame].size.height - 25 * (i+2), 200, 20)];
    NSArray *objects = [NSArray arrayWithObjects:configLabel, configField, configDefault, nil];
    [configs setObject:objects forKey:configName];
    [self performSelectorOnMainThread:@selector(hideAll:) withObject:objects waitUntilDone:YES];
    [self addSubview:configLabel];
    [self addSubview:configField];
    [self addSubview:configDefault];
    i++;
  }
}

- (void)updateConfigUI {
  for (NSString *configName in [configs allKeys]) {
    [[[configs objectForKey:configName] objectAtIndex:1] setStringValue:[[SlateConfig getInstance] getConfig:configName]];
  }
}

- (void)hideConfigUI {
  for (NSString *configName in [configs allKeys]) {
    SlateLogger(@"HIDING CONFIG %@", configName);
    [self performSelectorOnMainThread:@selector(hideAll:) withObject:[configs objectForKey:configName] waitUntilDone:YES];
  }
}

- (void)showConfigUI {
  [self updateConfigUI];
  for (NSString *configName in [configs allKeys]) {
    SlateLogger(@"HIDING CONFIG %@", configName);
    [self performSelectorOnMainThread:@selector(showAll:) withObject:[configs objectForKey:configName] waitUntilDone:YES];
  }
}

- (void)hideAll:(NSArray *)theThings {
  for (NSTextField *field in theThings) {
    [self hide:field];
  }
}

- (void)showAll:(NSArray *)theThings {
  for (NSTextField *field in theThings) {
    [self show:field];
    [field needsDisplay];
  }
}

- (void)hide:(NSTextField *)field {
  [field setHidden:YES];
}

- (void)show:(NSTextField *)field {
  [field setHidden:NO];
}

- (void)updateDirectiveSpecificUI:(NSString *)str {
  // Remove everything first
  [self hideDirectiveSpecificUIs];
  if ([str isEqualToString:CONFIG]) {
    SlateLogger(@"IN CONFIG");
    [self showConfigUI];
  } else if ([str isEqualToString:ALIAS]) {

  } else if ([str isEqualToString:LAYOUT]) {

  } else if ([str isEqualToString:DEFAULT]) {

  } else if ([str isEqualToString:BIND]) {

  } else if ([str isEqualToString:SOURCE]) {

  } else if ([str isEqualToString:EMPTY]) {
    // do nothing
  }
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];// Drawing code here.
}

- (void)saveConfig {
  // Update SlateConfig



  // Save to file
}

- (void)saveToConfig {
  if ([[[directive selectedItem] title] isEqualToString:CONFIG]) {
    [self saveConfig];
  }
}

@end

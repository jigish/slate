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

@synthesize directiveLabel, directive, configs;

- (NSTextField *)createLabel:(NSString *)text frame:(NSRect)frame {
  NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
  [label setStringValue:text];
  [label setSelectable:NO];
  [label setEnabled:NO];
  [label setDrawsBackground:NO];
  [label setBordered:NO];
  [label setBezeled:NO];
  return label;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      configs = [NSMutableDictionary dictionary];
      directiveLabel = [self createLabel:@"Directive:" frame:NSMakeRect(5, frame.size.height - 25, 70, 20)];
      [self addSubview:directiveLabel];
      directive = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(70, frame.size.height - 25, 100, 22)];
      [directive addItemsWithTitles:[NSArray arrayWithObjects:CONFIG, ALIAS, LAYOUT, DEFAULT, BIND, SOURCE, nil]];
      [directive setTarget:self];
      [directive setAction:@selector(directiveChanged)];
      [self addSubview:directive];
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

- (void)addConfigUI {
  SlateLogger(@"addConfigUI");
  NSInteger i = 0;
  for (NSString *configName in [[[SlateConfig getInstance] configs] allKeys]) {
    if ([configs objectForKey:configName]) continue;
    SlateLogger(@"ADDING CONFIG %@", configName);
    NSTextField *configLabel = [self createLabel:configName frame:NSMakeRect(5, [self frame].size.height - 25 * (i+2), 200, 20)];
    [configs setObject:configLabel forKey:configName];
    [self performSelectorOnMainThread:@selector(hideLabel:) withObject:configLabel waitUntilDone:YES];
    [self addSubview:configLabel];
    i++;
  }
}

- (void)hideConfigUI {
  for (NSString *configName in [configs allKeys]) {
    SlateLogger(@"HIDING CONFIG %@", configName);
    [self performSelectorOnMainThread:@selector(hideLabel:) withObject:[configs objectForKey:configName] waitUntilDone:YES];
  }
}

- (void)showConfigUI {
  for (NSString *configName in [configs allKeys]) {
    SlateLogger(@"HIDING CONFIG %@", configName);
    [self performSelectorOnMainThread:@selector(showLabel:) withObject:[configs objectForKey:configName] waitUntilDone:YES];
  }
}

- (void)hideLabel:(NSTextField *)label {
  [label setHidden:YES];
}

- (void)showLabel:(NSTextField *)label {
  [label setHidden:NO];
}

- (void)updateDirectiveSpecificUI:(NSString *)str {
  // Remove everything first
  [self hideConfigUI];
  if ([str isEqualToString:CONFIG]) {
    SlateLogger(@"IN CONFIG");
    [self showConfigUI];
  } else if ([str isEqualToString:ALIAS]) {
    
  } else if ([str isEqualToString:LAYOUT]) {
    
  } else if ([str isEqualToString:DEFAULT]) {
    
  } else if ([str isEqualToString:BIND]) {
    
  } else if ([str isEqualToString:SOURCE]) {
    
  }
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];// Drawing code here.
}

@end

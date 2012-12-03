//
//  WindowInfoView.m
//  Slate
//
//  Created by Jigish Patel on 2/27/12.
//  Copyright 2012 Jigish Patel. All rights reserved.
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

#import "WindowInfoView.h"
#import "AccessibilityWrapper.h"
#import "ScreenWrapper.h"
#import "SlateLogger.h"
#import "RunningApplications.h"

@implementation WindowInfoView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setSelectable:YES];
    [self genText];
    lastDraw = [NSDate dateWithTimeIntervalSince1970:0];
  }
  return self;
}

- (void)viewWillDraw {
  NSDate *now = [NSDate date];
  if ([now timeIntervalSinceDate:lastDraw] < 5) { return; } // refresh every 5 seconds
  lastDraw = now;
  [self genText];
}

- (void)genText {
  SlateLogger(@"WindowInfoView gen text.");
  NSString *text = @"----------------- Screens -----------------\n";
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  NSMutableArray *resolutions = [NSMutableArray array];
  [sw getScreenResolutionStrings:resolutions];
  for (NSInteger i = 0; i < [resolutions count]; i++) {
    text = [text stringByAppendingFormat:@"Left To Right ID: %ld\n  OS X ID: %ld\n  Resolution: %@\n", [sw convertDefaultOrderToLeftToRightOrder:i], i, [resolutions objectAtIndex:i]];
  }

  text = [text stringByAppendingString:@"\n----------------- Windows -----------------\n" ];
  for (NSRunningApplication *app in [RunningApplications getInstance]) {
    NSString *appName = [app localizedName];
    pid_t appPID = [app processIdentifier];
    SlateLogger(@"I see application '%@' with pid '%d'", appName, appPID);
    text = [text stringByAppendingFormat:@"\nApplication: %@\n", appName];
    // Yes, I am aware that the following blocks are inefficient. Deal with it.
    AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
    CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
    for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
      SlateLogger(@" Printing Window: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);
      NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
      if ([title isEqualToString:@""]) continue;
      AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windowsArr, i)];
      NSSize size = [aw getCurrentSize];
      NSPoint badTL = [aw getCurrentTopLeft];
      NSInteger badScreenID = [sw getScreenIdForRect:NSMakeRect(badTL.x, badTL.y, size.width, size.height)];
      NSInteger screenID = [sw convertDefaultOrderToLeftToRightOrder:badScreenID];
      NSPoint tl = [sw convertTopLeftToScreenRelative:badTL screen:badScreenID];
      text = [text stringByAppendingFormat:@"  Window: '%@'\n    Screen ID (Left to Right): %ld\n    Size: (%ld, %ld)\n    Top Left: (screenOriginX+%ld, screenOriginY+%ld)\n", title, screenID, (NSInteger)size.width, (NSInteger)size.height, (NSInteger)tl.x, (NSInteger)tl.y];
    }
  }
  [self setString:text];
}

@end

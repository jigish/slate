//
//  VisibilityOperation.m
//  Slate
//
//  Created by Jigish Patel on 10/7/12.
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

#import "VisibilityOperation.h"
#import "StringTokenizer.h"
#import "SlateLogger.h"
#import "Constants.h"
#import "RunningApplications.h"

@implementation VisibilityOperation

@synthesize type, apps;

- (id)initWithType:(VisibilityOperationType)theType apps:(NSArray *)theApps {
  self = [super init];
  if (self) {
    [self setType:theType];
    [self setApps:theApps];
  }
  return self;
}

- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Visibility Operation -----------------");
  // We don't use the passed in AccessibilityWrapper or ScreenWrapper so they are nil. No need to waste time creating them here.
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:nil];
  SlateLogger(@"-----------------  End Visibility Operation  -----------------");
  return success;
}

- (void)applyVisibilityToApp:(NSRunningApplication *)app {
  if ([self type] == VisibilityOperationTypeShow) {
    [app unhide];
  } else if ([self type] == VisibilityOperationTypeHide) {
    [app hide];
  } else if ([self type] == VisibilityOperationTypeToggle) {
    if ([app isHidden]) {
      [app unhide];
    } else {
      [app hide];
    }
  }
}

- (BOOL)doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)iamnil screenWrapper:(ScreenWrapper *)iamalsonil {
  for (NSString *appName in [self apps]) {
    NSRunningApplication *app = nil;
    if ([CURRENT isEqualToString:appName]) {
      app = [RunningApplications focusedApp];
    } else if ([ALL isEqualToString:appName]) {
      // run through ALL THE APPS
      for (NSRunningApplication *theApp in [RunningApplications getInstance]) {
        [self applyVisibilityToApp:theApp];
      }
      continue;
    } else if ([appName hasPrefix:ALL_BUT]) {
      NSString *skipApp = [StringTokenizer removeQuotes:[appName stringByReplacingOccurrencesOfString:ALL_BUT withString:EMPTY] quoteChars:[NSCharacterSet characterSetWithCharactersInString:QUOTES]];
      // run through ALL THE APPS
      if ([skipApp isEqualToString:CURRENT]) {
        skipApp = [[RunningApplications focusedApp] localizedName];
      }
      for (NSRunningApplication *theApp in [RunningApplications getInstance]) {
        if ([skipApp isEqualToString:[theApp localizedName]]) continue;
        [self applyVisibilityToApp:theApp];
      }
      continue;
    } else {
      app = [[[RunningApplications getInstance] appNameToApp] objectForKey:appName];
    }
    [self applyVisibilityToApp:app];
  }
  return YES;
}

- (BOOL)testOperation {
  if ([self type] == VisibilityOperationTypeUnknown)
    @throw [NSException exceptionWithName:@"Unknown Type" reason:@"type" userInfo:nil];
  return YES;
}

+ (id)visibilityOperationFromString:(NSString *)visibilityOperation {
  // hide|show|toggle apps
  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:visibilityOperation into:tokens maxTokens:2];

  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", visibilityOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters" reason:[NSString stringWithFormat:@"Invalid Parameters in '%@'. Visibility operations require the following format: 'hide|show|toggle apps'", visibilityOperation] userInfo:nil]);
  }

  VisibilityOperationType theType = VisibilityOperationTypeUnknown;
  NSString *typeStr = [tokens objectAtIndex:0];
  if ([SHOW isEqualToString:typeStr]) {
    theType = VisibilityOperationTypeShow;
  } else if ([HIDE isEqualToString:typeStr]) {
    theType = VisibilityOperationTypeHide;
  } else if ([TOGGLE isEqualToString:typeStr]) {
    theType = VisibilityOperationTypeToggle;
  }

  NSString *appsStr = [tokens objectAtIndex:1];
  NSArray *appsArrayWithQuotes = [appsStr componentsSeparatedByString:COMMA];
  NSMutableArray *appsArray = [NSMutableArray array];
  for (NSString *appWithQuotes in appsArrayWithQuotes) {
    [appsArray addObject:[StringTokenizer removeQuotes:appWithQuotes quoteChars:[NSCharacterSet characterSetWithCharactersInString:QUOTES]]];
  }

  Operation *op = [[VisibilityOperation alloc] initWithType:theType apps:appsArray];
  return op;
}

@end

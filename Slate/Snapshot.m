//
//  Snapshot.m
//  Slate
//
//  Created by Jigish Patel on 2/28/12.
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

#import "Snapshot.h"
#import "WindowSnapshot.h"
#import "Constants.h"

@implementation Snapshot

@synthesize apps;

- (id)init {
  self = [super init];
  if (self) {
    [self setApps:[NSMutableDictionary dictionary]];
  }
  return self;
}

- (void)addWindow:(WindowSnapshot *)windowSnapshot app:(NSString *)appName {
  NSMutableArray *app = [apps objectForKey:appName];
  if (app == nil) {
    app = [NSMutableArray array];
  }
  [app addObject:windowSnapshot];
  [apps setObject:app forKey:appName];
}

- (NSDictionary *)toDictionary {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSMutableDictionary *appsDict = [NSMutableDictionary dictionary];
  NSArray *appNames = [apps allKeys];
  for (NSString *appName in appNames) {
    NSArray *windows = [apps objectForKey:appName];
    NSMutableArray *windowDicts = [NSMutableArray array];
    for (WindowSnapshot *windowSnap in windows) {
      [windowDicts addObject:[windowSnap toDictionary]];
    }
    [appsDict setObject:windowDicts forKey:appName];
  }
  [dict setObject:appsDict forKey:APPS];
  return dict;
}

+ (Snapshot *)snapshotFromDictionary:(NSDictionary *)dict {
  Snapshot *s = [[Snapshot alloc] init];
  NSDictionary *appsDict = [dict objectForKey:APPS];
  NSArray *appNames = [appsDict allKeys];
  for (NSString *appName in appNames) {
    NSArray *windowDicts = [appsDict objectForKey:appName];
    for (NSDictionary *windowDict in windowDicts) {
      [s addWindow:[WindowSnapshot windowSnapshotFromDictionary:windowDict] app:appName];
    }
  }
  return s;
}

- (void)dealloc {
  [self setApps:nil];
  [super dealloc];
}

@end

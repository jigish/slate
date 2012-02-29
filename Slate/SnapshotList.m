//
//  SnapshotList.m
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

#import "SnapshotList.h"
#import "Snapshot.h"
#import "Constants.h"

@implementation SnapshotList

@synthesize snapshots, name, saveToDisk, isStack;

- (id)init {
  self = [super init];
  if (self) {
    [self setSnapshots:[NSMutableArray array]];
  }
  return self;
}

- (id)initWithName:(NSString *)theName saveToDisk:(BOOL)theSaveToDisk isStack:(BOOL)theIsStack {
  self = [self init];
  if (self) {
    [self setName:theName];
    saveToDisk = theSaveToDisk;
    isStack = theIsStack;
  }
  return self;
}

- (void)addSnapshot:(Snapshot *)snapshot {
  if (isStack) {
    [snapshots addObject:snapshot];
  } else {
    [snapshots removeAllObjects];
    [snapshots addObject:snapshot];
  }
}

- (Snapshot *)popSnapshot:(BOOL)remove {
  if ([snapshots count] <= 0) return nil;
  Snapshot *returnVal = [snapshots lastObject];
  if (remove) [snapshots removeLastObject];
  return returnVal;
}

- (NSDictionary *)toDictionary {
  NSMutableDictionary *snapshotList = [NSMutableDictionary dictionary];
  NSMutableArray *snapshotsArray = [NSMutableArray array];
  [snapshotList setObject:[self name] forKey:NAME];
  [snapshotList setObject:[NSNumber numberWithBool:[self saveToDisk]] forKey:SAVE_TO_DISK];
  [snapshotList setObject:[NSNumber numberWithBool:[self isStack]] forKey:STACK];
  for (Snapshot *snap in [self snapshots]) {
    [snapshotsArray addObject:[snap toDictionary]];
  }
  [snapshotList setObject:snapshotsArray forKey:SNAPSHOTS];
  return snapshotList;
}

- (void)dealloc {
  [self setName:nil];
  [self setSnapshots:nil];
  [super dealloc];
}

@end

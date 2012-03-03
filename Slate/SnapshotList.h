//
//  SnapshotList.h
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

#import <Foundation/Foundation.h>

@class Snapshot;

@interface SnapshotList : NSObject {
@private
  NSMutableArray *snapshots;
  NSString *name;
  BOOL saveToDisk;
  BOOL isStack;
}

@property  NSMutableArray *snapshots;
@property  NSString *name;
@property (assign) BOOL saveToDisk;
@property (assign) BOOL isStack;

- (id)initWithName:(NSString *)theName saveToDisk:(BOOL)theSaveToDisk isStack:(BOOL)theIsStack;
- (void)addSnapshot:(Snapshot *)snapshot;
- (Snapshot *)popSnapshot:(BOOL)remove;
- (NSDictionary *)toDictionary;
+ (SnapshotList *)snapshotListFromDictionary:(NSDictionary *)dict;

@end

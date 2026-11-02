//
//  ConfigReview.h
//  Slate
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

// What a config load read, for the user to approve: every user config file (path + contents, in load order)
// and every config line that runs a shell command (after alias expansion).
@interface ConfigReview : NSObject

@property (readonly) NSArray<NSString *> *paths;
@property (readonly) NSArray<NSString *> *shellLines;

- (void)addFile:(NSString *)path contents:(NSString *)contents;
- (void)addLine:(NSString *)line;
- (BOOL)isEmpty;

// Hex SHA-256 over all files read, in order. Changes when any file's path, contents or the order changes.
- (NSString *)digest;

@end

//
//  SlateConfig.h
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

#import <Foundation/Foundation.h>


@interface SlateConfig : NSObject {
@private
  NSMutableDictionary *configs;
  NSMutableArray *bindings;
  NSMutableDictionary *layouts;
}

@property (retain) NSMutableDictionary *configs;
@property (retain) NSMutableArray *bindings;
@property (retain) NSMutableDictionary *layouts;

+ (SlateConfig *)getInstance;
- (BOOL)load;
- (BOOL)getBoolConfig:(NSString *)key;
- (NSInteger)getIntegerConfig:(NSString *)key;
- (NSString *)getConfig:(NSString *)key;

@end

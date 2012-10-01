//
//  NSString+Indicies.m
//  Slate
//
//  Created by Jigish Patel on 10/1/12.
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

#import "NSString+Indicies.h"

@implementation NSString (Indicies)

- (NSInteger)indexOfString:(NSString *)str {
  NSRange range = [self rangeOfString:str];
  if ( range.length > 0 ) {
    return range.location;
  } else {
    return -1;
  }
}

- (NSInteger)indexOfChar:(const unichar) c {
  NSRange range = [self rangeOfString:[NSString stringWithCharacters:&c length:1]];
  if ( range.length > 0 ) {
    return range.location;
  } else {
    return -1;
  }
}

@end
